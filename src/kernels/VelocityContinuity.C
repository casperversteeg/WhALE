#include "VelocityContinuity.h"

registerMooseObject("whaleApp", VelocityContinuity);

template <>
InputParameters
validParams<VelocityContinuity>()
{
  InputParameters params = validParams<InterfaceKernel>();
  params.addClassDescription("Continuity of velocity between fluid and solid domains.");
  // params.addRequiredParam<Real>(
  //     "penalty", "The penalty that penalizes jump between master and neighbor variables.");
  params.addParam<bool>("neighbor_displacements", false, "Use solid domain displacement field.");
  return params;
}

VelocityContinuity::VelocityContinuity(const InputParameters & parameters)
  : InterfaceKernel(parameters),
    // _u_dot(_is_transient ? _var.uDot() : _zero),
    _neighbor_dot(_is_transient ? _neighbor_var.uDot() : _zero),
    _neighbor_old(_is_transient ? _neighbor_var.slnOld() : _zero)
{
}

Real
VelocityContinuity::computeQpResidual(Moose::DGResidualType type)
{
  switch (type)
  {
    case Moose::Element:
      return _neighbor_dot[_qp];
    case Moose::Neighbor:
      return _neighbor_old[_qp] + _dt * _u[_qp];
  }

  mooseError("Internal error in VelocityContinuity interface kernel");
}

Real
VelocityContinuity::computeQpJacobian(Moose::DGJacobianType type)
{
  Real jac = 0;
  // switch (type)
  // {
  //   case Moose::ElementElement:
  //     jac = _phi[_j][_qp];
  //     break;
  //   case Moose::NeighborNeighbor:
  //     jac = _phi_neighbor[_j][_qp];
  //     break;
  //   case Moose::NeighborElement:
  //     jac = -_phi[_j][_qp];
  //     break;
  //   case Moose::ElementNeighbor:
  //     jac = -_phi_neighbor[_j][_qp];
  //     break;
  // }
  return jac;
}
