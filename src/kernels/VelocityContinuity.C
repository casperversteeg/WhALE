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
  : InterfaceKernel(parameters), _coupled_dot(_is_transient ? _neighbor_var.uDot() : _zero)
// _penalty(getParam<Real>("penalty")),
// By default will make the solid-domain velocity the neighbor variable, although may also
// define solid_displacement to couple in a displacement field, in which case this kernel will
// use the _u_dot from that field
// _coupled_var(coupledNeighborValueDot("neighbor_var"))
// _coupled_var(getParam<bool>("neighbor_displacements")
//                  ? (_is_transient ? coupledNeighborValueDot("neighbor_var") : _zero)
// : _neighbor_var.slnNeighbor())
{
}

Real
VelocityContinuity::computeQpResidual(Moose::DGResidualType type)
{
  Real r = 0;
  // Note for comments: "u" describes "master variable", "d" describes "slave variable"
  //                    "w" describes test in "master", "f" describes test in "slave"
  switch (type)
  {
    // Moose::Element is the "master" domain.
    case Moose::Element:
      // In master, compute residual as
      // R_w = (w_i , penalty * (u - d))
      r = _test[_i][_qp] * (_u[_qp] - _coupled_dot[_qp]);
      break;
    // Moose::Neighbor is the "slave" domain
    case Moose::Neighbor:
      // In neighbor, compute residual as
      // R_f = (f_i , - penalty * (u - d))
      r = _test_neighbor[_i][_qp] * (_u[_qp] - _coupled_dot[_qp]);
      // Is negative because reaction goes other direction in the neighbor domain
      break;
  }

  return r;
}
Real
VelocityContinuity::computeQpJacobian(Moose::DGJacobianType type)
{
  Real jac = 0;
  switch (type)
  {
    case Moose::ElementElement:
      jac = _test[_i][_qp] * _phi[_j][_qp];
      break;
    case Moose::NeighborNeighbor:
      jac = -_test_neighbor[_i][_qp] * _phi_neighbor[_j][_qp];
      break;
    case Moose::NeighborElement:
      jac = -_test_neighbor[_i][_qp] * _phi[_j][_qp];
      break;
    case Moose::ElementNeighbor:
      jac = _test[_i][_qp] * _phi_neighbor[_j][_qp];
      break;
  }
  return jac;
}
