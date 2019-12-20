//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "InertialForceFromVel.h"
#include "SubProblem.h"

registerMooseObject("whaleApp", InertialForceFromVel);

template <>
InputParameters
validParams<InertialForceFromVel>()
{
  InputParameters params = validParams<TimeKernel>();
  params.addClassDescription("Calculates the residual for the inertial force "
                             "($M \\cdot acceleration$) and the contribution of mass"
                             " dependent Rayleigh damping and HHT time "
                             " integration scheme ($\\eta \\cdot M \\cdot"
                             " ((1+\\alpha)velq2-\\alpha \\cdot vel-old) $)");
  params.set<bool>("use_displaced_mesh") = true;
  // params.addRequiredCoupledVar("displacement", "displacement variable");
  params.addRequiredCoupledVar("velocity", "velocity variable");
  params.addRequiredCoupledVar("acceleration", "acceleration variable");
  params.addRequiredParam<Real>("beta", "beta parameter for Newmark Time integration");
  params.addRequiredParam<Real>("gamma", "gamma parameter for Newmark Time integration");
  params.addParam<MaterialPropertyName>("eta",
                                        0.0,
                                        "Name of material property or a constant real "
                                        "number defining the eta parameter for the "
                                        "Rayleigh damping.");
  params.addParam<Real>("alpha",
                        0,
                        "alpha parameter for mass dependent numerical damping induced "
                        "by HHT time integration scheme");
  params.addParam<MaterialPropertyName>(
      "density", "density", "Name of Material Property that provides the density");
  return params;
}

InertialForceFromVel::InertialForceFromVel(const InputParameters & parameters)
  : TimeKernel(parameters),
    _density(getMaterialProperty<Real>("density")),
    // _disp(coupledValue("displacement")),
    // _disp_old(coupledValueOld("displacement")),
    _u_old(valueOld()),
    _vel(coupledValue("velocity")),
    _vel_old(coupledValueOld("velocity")),
    _accel_old(coupledValueOld("acceleration")),
    _beta(getParam<Real>("beta")),
    _gamma(getParam<Real>("gamma")),
    _eta(getMaterialProperty<Real>("eta")),
    _alpha(getParam<Real>("alpha"))
{
}

Real
InertialForceFromVel::computeQpResidual()
{
  if (_dt == 0)
    return 0;
  else
  {
    Real accel = 1.0 / (_gamma * _dt) * ((1 - _gamma) * _dt * _accel_old[_qp]);
    // Real vel = _vel[_qp] + (_dt * (1 - _gamma)) * _accel_old[_qp] + _gamma * _dt * accel;
    return _test[_i][_qp] * _density[_qp] *
           (accel + _vel[_qp] * _eta[_qp] * (1 + _alpha) - _alpha * _eta[_qp] * _vel_old[_qp]);
  }

  // if (_dt == 0)
  //   return 0;
  // else
  // {
  //   Real accel =
  //       1.0 / (_gamma * _dt) * (_u[_qp] - _u_old[_qp] - (1 - _gamma) * _dt * _accel_old[_qp]);
  //   Real d =
  //       1.0 / _beta *
  //       ((_disp[_qp] - _disp_old[_qp]) / (_dt * _dt) - _u_old[_qp] / _dt - accel * (0.5 -
  //       _beta));
  //   return _test[_i][_qp] * _density[_qp] *
  //          (d - (accel + _u[_qp] * _eta[_qp] * (1 + _alpha) - _alpha * _eta[_qp] * _u_old[_qp]));
  // }
}

Real
InertialForceFromVel::computeQpJacobian()
{
  // return 0.0;
  if (_dt == 0)
    return 0;
  else
    return _test[_i][_qp] * _density[_qp] *
           (1 / (_beta * _dt * _dt) * _phi[_j][_qp] +
            _phi[_j][_qp] * _eta[_qp] * (1 + _alpha) * _gamma / _beta / _dt);
}
