//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "INSALEMomentumConvection.h"
#include "Function.h"

registerMooseObject("whaleApp", INSALEMomentumConvection);

template <>
InputParameters
validParams<INSALEMomentumConvection>()
{
  InputParameters params = validParams<INSALEMomentumBase>();
  params.addClassDescription("");
  params.addRequiredCoupledVar("mesh_x", "x component of mesh displacement");
  params.addCoupledVar("mesh_y", 0, "y component of mesh displacement");
  params.addCoupledVar("mesh_z", 0, "z component of mesh displacement");
  params.set<bool>("use_displaced_mesh") = true;
  params.addParam<bool>(
      "supg", false, "Whether to perform SUPG stabilization of the momentum residuals");
  return params;
}

INSALEMomentumConvection::INSALEMomentumConvection(const InputParameters & parameters)
  : INSALEMomentumBase(parameters),
    _supg(getParam<bool>("supg")),
    _u_mesh(coupledDot("mesh_x")),
    _v_mesh(coupledDot("mesh_y")),
    _w_mesh(coupledDot("mesh_z"))
{
}

// These are modified from the INSBase class to include the mesh velocity, and
// compute the complete convective velocity c in (c dot grad) dot u
RealVectorValue
INSALEMomentumConvection::convectiveTerm()
{
  RealVectorValue U_vel(_u_vel[_qp], _v_vel[_qp], _w_vel[_qp]);
  RealVectorValue U_mesh(_u_mesh[_qp], _v_mesh[_qp], _w_mesh[_qp]);
  RealVectorValue c = U_vel - U_mesh; // Convection velocity

  return _rho[_qp] *
         RealVectorValue(c * _grad_u_vel[_qp], c * _grad_v_vel[_qp], c * _grad_w_vel[_qp]);
}

RealVectorValue
INSALEMomentumConvection::dConvecDUComp(unsigned comp)
{
  RealVectorValue U_vel(_u_vel[_qp], _v_vel[_qp], _w_vel[_qp]);
  RealVectorValue U_mesh(_u_mesh[_qp], _v_mesh[_qp], _w_mesh[_qp]);
  RealVectorValue c = U_vel - U_mesh;

  RealVectorValue d_U_d_comp(0, 0, 0);
  d_U_d_comp(comp) = _phi[_j][_qp];

  RealVectorValue convective_term = _rho[_qp] * RealVectorValue(d_U_d_comp * _grad_u_vel[_qp],
                                                                d_U_d_comp * _grad_v_vel[_qp],
                                                                d_U_d_comp * _grad_w_vel[_qp]);
  convective_term(comp) += _rho[_qp] * c * _grad_phi[_j][_qp];

  return convective_term;
}

Real
INSALEMomentumConvection::computeQpResidual()
{
  Real r = _test[_i][_qp] * convectiveTerm()(_component);

  if (_supg)
    r += computeQpPGResidual();

  return r;
}

Real
INSALEMomentumConvection::computeQpPGResidual()
{
  RealVectorValue U(_u_vel[_qp], _v_vel[_qp], _w_vel[_qp]);

  RealVectorValue convective_term = convectiveTerm();
  RealVectorValue viscous_term =
      _laplace ? strongViscousTermLaplace() : strongViscousTermTraction();
  RealVectorValue transient_term =
      _transient_term ? timeDerivativeTerm() : RealVectorValue(0, 0, 0);

  return tau() * U * _grad_test[_i][_qp] *
         ((convective_term + viscous_term + transient_term + strongPressureTerm() +
           gravityTerm())(_component)-_ffn.value(_t, _q_point[_qp]));

  // For GLS as opposed to SUPG stabilization, one would need to modify the test function functional
  // space to include second derivatives of the Galerkin test functions corresponding to the viscous
  // term. This would look like:
  // Real lap_test =
  //     _second_test[_i][_qp](0, 0) + _second_test[_i][_qp](1, 1) + _second_test[_i][_qp](2, 2);

  // Real pg_viscous_r = -_mu[_qp] * lap_test * tau() *
  //                     (convective_term + viscous_term + strongPressureTerm()(_component) +
  //                      gravityTerm())(_component);
}

Real
INSALEMomentumConvection::computeQpJacobian()
{
  Real jac = 0;

  // viscous term
  jac += computeQpJacobianViscousPart();

  // convective term
  if (_convective_term)
    jac += _test[_i][_qp] * dConvecDUComp(_component)(_component);

  if (_supg)
    jac += computeQpPGJacobian(_component);

  return jac;
}

Real
INSALEMomentumConvection::computeQpPGJacobian(unsigned comp)
{
  RealVectorValue U(_u_vel[_qp], _v_vel[_qp], _w_vel[_qp]);
  RealVectorValue d_U_d_U_comp(0, 0, 0);
  d_U_d_U_comp(comp) = _phi[_j][_qp];

  Real convective_term = convectiveTerm()(_component);
  Real d_convective_term_d_u_comp = dConvecDUComp(comp)(_component);
  Real viscous_term =
      _laplace ? strongViscousTermLaplace()(_component) : strongViscousTermTraction()(_component);
  Real d_viscous_term_d_u_comp = _laplace ? dStrongViscDUCompLaplace(comp)(_component)
                                          : dStrongViscDUCompTraction(comp)(_component);
  Real transient_term = _transient_term ? timeDerivativeTerm()(_component) : 0;
  Real d_transient_term_d_u_comp = _transient_term ? dTimeDerivativeDUComp(comp)(_component) : 0;

  return dTauDUComp(comp) * U * _grad_test[_i][_qp] *
             (convective_term + viscous_term + strongPressureTerm()(_component) +
              gravityTerm()(_component) + transient_term - _ffn.value(_t, _q_point[_qp])) +
         tau() * d_U_d_U_comp * _grad_test[_i][_qp] *
             (convective_term + viscous_term + strongPressureTerm()(_component) +
              gravityTerm()(_component) + transient_term - _ffn.value(_t, _q_point[_qp])) +
         tau() * U * _grad_test[_i][_qp] *
             (d_convective_term_d_u_comp + d_viscous_term_d_u_comp + d_transient_term_d_u_comp);
}

Real
INSALEMomentumConvection::computeQpOffDiagJacobian(unsigned jvar)
{
  Real jac = 0;
  if (jvar == _u_vel_var_number)
  {
    Real convective_term = _test[_i][_qp] * dConvecDUComp(0)(_component);
    Real viscous_term = computeQpOffDiagJacobianViscousPart(jvar);

    jac += convective_term + viscous_term;

    if (_supg)
      jac += computeQpPGJacobian(0);

    return jac;
  }
  else if (jvar == _v_vel_var_number)
  {
    Real convective_term = _test[_i][_qp] * dConvecDUComp(1)(_component);
    Real viscous_term = computeQpOffDiagJacobianViscousPart(jvar);

    jac += convective_term + viscous_term;

    if (_supg)
      jac += computeQpPGJacobian(1);

    return jac;
  }
  else if (jvar == _w_vel_var_number)
  {
    Real convective_term = _test[_i][_qp] * dConvecDUComp(2)(_component);
    Real viscous_term = computeQpOffDiagJacobianViscousPart(jvar);

    jac += convective_term + viscous_term;

    if (_supg)
      jac += computeQpPGJacobian(2);

    return jac;
  }

  else if (jvar == _p_var_number)
  {
    if (_integrate_p_by_parts)
      jac += _grad_test[_i][_qp](_component) * dWeakPressureDPressure();
    else
      jac += _test[_i][_qp] * dStrongPressureDPressure()(_component);

    if (_supg)
    {
      RealVectorValue U(_u_vel[_qp], _v_vel[_qp], _w_vel[_qp]);
      jac += tau() * U * _grad_test[_i][_qp] * dStrongPressureDPressure()(_component);
    }

    return jac;
  }

  else
    return 0;
}
