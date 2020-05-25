//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "ReynoldsStress.h"

registerMooseObject("whaleApp", ReynoldsStress);

template <>
InputParameters
validParams<ReynoldsStress>()
{
  InputParameters params = validParams<INSMomentumBase>();
  params.addClassDescription("Adds a subgrid-scale eddy-viscosity for LES");
  params.addRequiredCoupledVar("k", "Nonlinear variable containing mean turbulent kinetic energy");
  params.addRequiredCoupledVar(
      "eps", "Nonlinear variable containing mean turbulent kinetic energy disspiation");
  params.addParam<MaterialPropertyName>(
      "mu_t_name", "mu_sgs", "The name of the subgrid scale turbulent viscosity");
  return params;
}

ReynoldsStress::ReynoldsStress(const InputParameters & parameters)
  : INSMomentumBase(parameters),
    _k(coupledValue("k")),
    _eps(coupledValue("eps")),
    _grad_k(coupledGradient("k")),
    _grad_eps(coupledGradient("eps")),
    _mu_t(getMaterialProperty<Real>("mu_t_name"))
// _dmu_dvel(getMaterialPropertyDerivative<RankTwoTensor>("mu_sgs_name", _var.name()))
{
}

Real
ReynoldsStress::computeQpResidualViscousPart()
{
  // Simplified version: mu * Laplacian(u_component)
  return _mu_t[_qp] * (_grad_u[_qp] * _grad_test[_i][_qp]) -
         2 / 3 * _rho[_qp] * _grad_k[_qp](_component) * _test[_i][_qp];
}

Real
ReynoldsStress::computeQpJacobianViscousPart()
{
  // Viscous part, Laplacian version
  return _mu_t[_qp] * (_grad_phi[_j][_qp] * _grad_test[_i][_qp]);
}

Real
ReynoldsStress::computeQpOffDiagJacobianViscousPart(unsigned jvar)
{
  return 0;
}
