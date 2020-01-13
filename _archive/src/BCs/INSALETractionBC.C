//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "INSALETractionBC.h"

registerMooseObject("whaleApp", INSALETractionBC);

template<>
InputParameters
validParams<INSALETractionBC>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addClassDescription(
      "Applies fluid traction to solid interface");
  params.addRequiredRangeCheckedParam<unsigned int>(
      "component", "component<3", "The component for the traction");
  params.addRequiredCoupledVar("p", "pressure");
  params.addRequiredCoupledVar("u", "x-velocity");
  params.addCoupledVar("v", 0, "y-velocity"); // only required in 2D and 3D
  params.addCoupledVar("w", 0, "z-velocity");
  params.addParam<MaterialPropertyName>("mu_name", "mu", "The name of the dynamic viscosity");
  params.set<bool>("use_displaced_mesh") = true;
  return params;
}

INSALETractionBC::INSALETractionBC(const InputParameters & parameters)
  : IntegratedBC(parameters),
  _component(getParam<unsigned int>("component")),
  _p(coupledValue("p")),
  _grad_u_vel(coupledGradient("u")),
  _grad_v_vel(coupledGradient("v")),
  _grad_w_vel(coupledGradient("w")),
  _mu(getMaterialProperty<Real>("mu_name"))
{
}

Real
INSALETractionBC::computeQpResidual()
{
  // Note for comments: "u" describes "master variable", "d" describes "slave variable"
  //                    "w" describes test in "master", "f" describes test in "slave"
  // The component'th row (or col, it's symmetric) of the viscous stress tensor
  RealVectorValue tau_row;

  switch (_component)
  {
    case 0:
      tau_row(0) = 2. * _grad_u_vel[_qp](0);                  // 2*du/dx1
      tau_row(1) = _grad_u_vel[_qp](1) + _grad_v_vel[_qp](0); // du/dx2 + dv/dx1
      tau_row(2) = _grad_u_vel[_qp](2) + _grad_w_vel[_qp](0); // du/dx3 + dw/dx1
      break;

    case 1:
      tau_row(0) = _grad_v_vel[_qp](0) + _grad_u_vel[_qp](1); // dv/dx1 + du/dx2
      tau_row(1) = 2. * _grad_v_vel[_qp](1);                  // 2*dv/dx2
      tau_row(2) = _grad_v_vel[_qp](2) + _grad_w_vel[_qp](1); // dv/dx3 + dw/dx2
      break;

    case 2:
      tau_row(0) = _grad_w_vel[_qp](0) + _grad_u_vel[_qp](2); // dw/dx1 + du/dx3
      tau_row(1) = _grad_w_vel[_qp](1) + _grad_v_vel[_qp](2); // dw/dx2 + dv/dx3
      tau_row(2) = 2. * _grad_w_vel[_qp](2);                  // 2*dw/dx3
      break;

    default:
      mooseError("Unrecognized _component requested.");
  }
  tau_row = _mu[_qp] * tau_row;
  tau_row(_component) = tau_row(_component) - _p[_qp];
  tau_row(0) = tau_row(0) * _normals[_qp](0);
  tau_row(1) = tau_row(1) * _normals[_qp](1);
  tau_row(2) = tau_row(2) * _normals[_qp](2);
  return (tau_row(0) + tau_row(1) + tau_row(2)) * _test[_i][_qp];
}
