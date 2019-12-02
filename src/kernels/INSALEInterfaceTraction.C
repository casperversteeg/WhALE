#include "INSALEInterfaceTraction.h"

registerMooseObject("whaleApp", INSALEInterfaceTraction);

template <>
InputParameters
validParams<INSALEInterfaceTraction>()
{
  InputParameters params = validParams<InterfaceKernel>();
  params.addClassDescription("Continuity of tractions between fluid and solid domains.");
  params.addRequiredParam<unsigned int>("component", "component of interface normal direction");
  params.addRequiredParam<Real>(
      "penalty", "The penalty that penalizes jump between master and neighbor variables.");
  params.addRequiredCoupledVar("p", "pressure");
  params.addRequiredCoupledVar("u", "x-velocity");
  params.addCoupledVar("v", 0, "y-velocity"); // only required in 2D and 3D
  params.addCoupledVar("w", 0, "z-velocity");
  params.addParam<bool>("neighbor_displacements", false, "Use solid domain displacement field.");
  return params;
}

INSALEInterfaceTraction::INSALEInterfaceTraction(const InputParameters & parameters)
  : InterfaceKernel(parameters),
    _component(getParam<unsigned int>("component")),
    _p(coupledValue("p")),
    _grad_u_vel(coupledGradient("u")),
    _grad_v_vel(coupledGradient("v")),
    _grad_w_vel(coupledGradient("w")),
    _penalty(getParam<Real>("penalty")),
    // By default will make the solid-domain velocity the neighbor variable, although may also
    // define solid_displacement to couple in a displacement field, in which case this kernel will
    // use the _u_dot from that field
    // _coupled_var(coupledNeighborValueDot("neighbor_var"))
    _coupled_var(getParam<bool>("neighbor_displacements")
                     ? (_is_transient ? coupledNeighborValueDot("neighbor_var") : _zero)
                     : _neighbor_var.slnNeighbor()),
    _base_name(isParamValid("base_name") ? getParam<std::string>("base_name") + "_" : ""),
    _stress(getMaterialPropertyByName<RankTwoTensor>(_base_name + "stress")),
    _normals(_assembly.normals())
{
}

Real
INSALEInterfaceTraction::computeQpResidual(Moose::DGResidualType type)
{
  Real r = 0;
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
  tau_row(_component) =- _p[_qp];
  switch (type)
  {
    // Moose::Element is the "master" domain.
    case Moose::Element:
      // In master, compute residual as
      // R_w = (w_i , penalty * (u - d))
      r = _test[_i][_qp] * _penalty * (tau_row - _stress[_qp].row(_component)) * _normals[_qp];
      break;
    // Moose::Neighbor is the "slave" domain
    case Moose::Neighbor:
      // In neighbor, compute residual as
      // R_f = (f_i , - penalty * (u - d))
      r = _test_neighbor[_i][_qp] * -_penalty * (tau_row - _stress[_qp].row(_component)) * _normals[_qp];
      // Is negative because reaction goes other direction in the neighbor domain
      break;
  }

  return r;
}

Real INSALEInterfaceTraction::computeQpJacobian(Moose::DGJacobianType type) { return 0; }
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
INSALEInterfaceTraction::computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar)
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
INSALEInterfaceTraction::computeElementOffDiagJacobian(unsigned int jvar)
{
  computeOffDiagElemNeighJacobian(Moose::ElementElement, jvar);
  computeOffDiagElemNeighJacobian(Moose::ElementNeighbor, jvar);
}

void
INSALEInterfaceTraction::computeNeighborOffDiagJacobian(unsigned int jvar)
{
  computeOffDiagElemNeighJacobian(Moose::NeighborElement, jvar);
  computeOffDiagElemNeighJacobian(Moose::NeighborNeighbor, jvar);
}
