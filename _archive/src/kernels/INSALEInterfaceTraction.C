#include "INSALEInterfaceTraction.h"

registerMooseObject("whaleApp", INSALEInterfaceTraction);

template <>
InputParameters
validParams<INSALEInterfaceTraction>()
{
  InputParameters params = validParams<InterfaceKernel>();
  params.addClassDescription("Continuity of tractions between fluid and solid domains.");
  params.addRequiredParam<unsigned int>("component", "component of interface normal direction");
  params.addRequiredCoupledVar("p", "pressure");
  params.addRequiredCoupledVar("u", "x-velocity");
  params.addCoupledVar("v", 0, "y-velocity"); // only required in 2D and 3D
  params.addCoupledVar("w", 0, "z-velocity");
  params.addParam<MaterialPropertyName>("mu_name", "viscosity variable name");
  return params;
}

INSALEInterfaceTraction::INSALEInterfaceTraction(const InputParameters & parameters)
  : InterfaceKernel(parameters),
    _component(getParam<unsigned int>("component")),
    _p(coupledValue("p")),
    _grad_u_vel(coupledGradient("u")),
    _grad_v_vel(coupledGradient("v")),
    _grad_w_vel(coupledGradient("w")),
    _mu(getMaterialProperty<Real>("mu_name")),
    _normals(_assembly.normals())
{
}

Real
INSALEInterfaceTraction::computeQpResidual(Moose::DGResidualType type)
{
  RealVectorValue sigma_row = _mu[_qp] * _grad_u[_qp];
  sigma_row(_component) = sigma_row(_component) - _p[_qp];
  Real traction = sigma_row * _normals[_qp];
  switch (type)
  {
    case Moose::Element:
      return _grad_test[_i][_qp](_component);
      break;

    case Moose::Neighbor:
      return _grad_test_neighbor[_i][_qp](_component);
      break;
  }
  mooseError("Internal error in INSALEInterfaceTraction");
}

Real
INSALEInterfaceTraction::computeQpJacobian(Moose::DGJacobianType type)
{
  return 0;
}
