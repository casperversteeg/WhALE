#include "VelocityContinuity.h"

registerMooseObject("whaleApp", VelocityContinuity);

template <>
InputParameters
validParams<VelocityContinuity>()
{
  InputParameters params = validParams<InterfaceKernel>();
  params.addClassDescription("Continuity of velocity between fluid and solid domains.");
  params.addRequiredParam<Real>(
      "penalty", "The penalty that penalizes jump between master and neighbor variables.");
  params.addParam<bool>("neighbor_displacements", false, "Use solid domain displacement field.");
  return params;
}

VelocityContinuity::VelocityContinuity(const InputParameters & parameters)
  : InterfaceKernel(parameters),
    _penalty(getParam<Real>("penalty")),
    // By default will make the solid-domain velocity the neighbor variable, although may also
    // define solid_displacement to couple in a displacement field, in which case this kernel will
    // use the _u_dot from that field
    // _coupled_var(coupledNeighborValueDot("neighbor_var"))
    _coupled_var(getParam<bool>("neighbor_displacements")
                     ? (_is_transient ? coupledNeighborValueDot("neighbor_var") : _zero)
                     : _neighbor_var.slnNeighbor())
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
      r = _test[_i][_qp] * _penalty * (_u[_qp] - _coupled_var[_qp]);
      break;
    // Moose::Neighbor is the "slave" domain
    case Moose::Neighbor:
      // In neighbor, compute residual as
      // R_f = (f_i , - penalty * (u - d))
      r = _test_neighbor[_i][_qp] * -_penalty * (_u[_qp] - _coupled_var[_qp]);
      // Is negative because reaction goes other direction in the neighbor domain
      break;
  }

  return r;
}
Real VelocityContinuity::computeQpJacobian(Moose::DGJacobianType) { return 0; }
// Real
// VelocityContinuity::computeQpJacobian(Moose::DGJacobianType type)
// {
//   // Compute the Jacobian for both the master and neighbor domains.
//   Real jac = 0;
//   switch (type)
//   {
//     // Compute dR_w / du
//     case Moose::ElementElement:
//       jac = _test[_i][_qp] * _penalty * _phi[_j][_qp];
//       break;
//     // Compute dR_w / dd
//     case Moose::ElementNeighbor:
//       jac = _test[_i][_qp] * _penalty * _phi_neighbor[_j][_qp];
//       break;
//     // Compute dR_f / du
//     case Moose::NeighborElement:
//       jac = _test_neighbor[_i][_qp] * -_penalty * _phi[_j][_qp];
//       break;
//     // Compute dR_f / dd
//     case Moose::NeighborNeighbor:
//       jac = _test_neighbor[_i][_qp] * _penalty * _phi_neighbor[_j][_qp];
//       break;
//   }
//   return jac;
// }

Real
VelocityContinuity::computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar)
{
  Real jac = 0;
  if (jvar == _var.number())
  {
    switch (type)
    {
      case Moose::ElementElement:
        jac = _test[_i][_qp] * _penalty * _phi[_j][_qp];
        break;

      case Moose::NeighborElement:
        jac = _test_neighbor[_i][_qp] * -_penalty * _phi[_j][_qp];
        break;

      case Moose::ElementNeighbor:
      case Moose::NeighborNeighbor:
        break;
    }
  }
  else if (jvar == _neighbor_var.number())
  {
    switch (type)
    {
      case Moose::ElementNeighbor:
        jac = _test[_i][_qp] * _penalty * -_phi_neighbor[_j][_qp];
        break;

      case Moose::NeighborNeighbor:
        jac = _test_neighbor[_i][_qp] * -_penalty * -_phi_neighbor[_j][_qp];
        break;

      case Moose::ElementElement:
      case Moose::NeighborElement:
        break;
    }
  }

  return jac;
}

void
VelocityContinuity::computeElementOffDiagJacobian(unsigned int jvar)
{
  computeOffDiagElemNeighJacobian(Moose::ElementElement, jvar);
  computeOffDiagElemNeighJacobian(Moose::ElementNeighbor, jvar);
}

void
VelocityContinuity::computeNeighborOffDiagJacobian(unsigned int jvar)
{
  computeOffDiagElemNeighJacobian(Moose::NeighborElement, jvar);
  computeOffDiagElemNeighJacobian(Moose::NeighborNeighbor, jvar);
}
