#include "ComputeINSStress.h"

registerMooseObject("multiwhaleApp", ComputeINSStress);

template <>
InputParameters
validParams<ComputeINSStress>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addClassDescription("");

  params.addRequiredRangeCheckedParam<unsigned int>(
      "component", "component<3", "The component of stress tensor");
  params.addCoupledVar("p", 0, "pressure");
  params.addRequiredCoupledVar("u", "x-velocity");
  params.addCoupledVar("v", "y-velocity");
  params.addCoupledVar("w", "z-velocity");
  params.addParam<MaterialPropertyName>("mu_name", "viscosity variable name");
  return params;
}

ComputeINSStress::ComputeINSStress(const InputParameters & parameters)
  : AuxKernel(parameters),
    _component(getParam<unsigned int>("component")),
    _p(coupledValue("p")),
    _grad_u_vel(isCoupled("u") ? coupledGradient("u") : _grad_zero),
    _grad_v_vel(isCoupled("v") ? coupledGradient("v") : _grad_zero),
    _grad_w_vel(isCoupled("w") ? coupledGradient("w") : _grad_zero),
    _mu(getMaterialProperty<Real>("mu_name")),
    _normals(_assembly.normals())
{
}

Real
ComputeINSStress::computeValue()
{
  VariableGradient _grad_vel;
  switch (_component)
  {
    case 0:
      _grad_vel = _grad_u_vel;
      break;
    case 1:
      _grad_vel = _grad_v_vel;
      break;
    case 2:
      _grad_vel = _grad_w_vel;
      break;
  }
  RealVectorValue sigma_row = _mu[_qp] * _grad_vel[_qp];
  sigma_row(_component) = sigma_row(_component) - _p[_qp];
  return sigma_row * _normals[_qp];
  // RealVectorValue tau_row;
  //
  // switch (_component)
  // {
  //   case 0:
  //     tau_row(0) = 2. * _grad_u_vel[_qp](0);                  // 2*du/dx1
  //     tau_row(1) = _grad_u_vel[_qp](1) + _grad_v_vel[_qp](0); // du/dx2 + dv/dx1
  //     tau_row(2) = _grad_u_vel[_qp](2) + _grad_w_vel[_qp](0); // du/dx3 + dw/dx1
  //     break;
  //
  //   case 1:
  //     tau_row(0) = _grad_v_vel[_qp](0) + _grad_u_vel[_qp](1); // dv/dx1 + du/dx2
  //     tau_row(1) = 2. * _grad_v_vel[_qp](1);                  // 2*dv/dx2
  //     tau_row(2) = _grad_v_vel[_qp](2) + _grad_w_vel[_qp](1); // dv/dx3 + dw/dx2
  //     break;
  //
  //   case 2:
  //     tau_row(0) = _grad_w_vel[_qp](0) + _grad_u_vel[_qp](2); // dw/dx1 + du/dx3
  //     tau_row(1) = _grad_w_vel[_qp](1) + _grad_v_vel[_qp](2); // dw/dx2 + dv/dx3
  //     tau_row(2) = 2. * _grad_w_vel[_qp](2);                  // 2*dw/dx3
  //     break;
  //
  //   default:
  //     mooseError("Unrecognized _component requested.");
  // }
  // tau_row = tau_row * _mu[_qp];
  // tau_row(_component) = tau_row(_component) - _p[_qp];
  // return tau_row(_component) * _normals[_qp](_component);
}
