//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

// MOOSE includes
#include "LESsubgridViscosityAux.h"
#include "Assembly.h"

registerMooseObject("whaleApp", LESsubgridViscosityAux);

defineLegacyParams(LESsubgridViscosityAux);

InputParameters
LESsubgridViscosityAux::validParams()
{
  InputParameters params = AuxKernel::validParams();
  params.addClassDescription(
      "Stores the distance between a block and boundary or between two boundaries.");
  // params.addRequiredParam<BoundaryName>("paired_boundary", "The boundary to find the distance
  // to.");
  params.addRequiredCoupledVar("u", "x-velocity component");
  params.addCoupledVar("v", 0, "y-velocity component");
  params.addCoupledVar("w", 0, "z-velocity component");
  // params.set<bool>("use_displaced_mesh") = false;
  return params;
}

LESsubgridViscosityAux::LESsubgridViscosityAux(const InputParameters & parameters)
  : AuxKernel(parameters),
    _u_vel(coupledValue("u")),
    _v_vel(coupledValue("v")),
    _w_vel(coupledValue("w")),
    _grad_u_vel(isCoupled("u") ? coupledGradient("u") : _grad_zero),
    _grad_v_vel(isCoupled("v") ? coupledGradient("v") : _grad_zero),
    _grad_w_vel(isCoupled("w") ? coupledGradient("w") : _grad_zero),
    // _rho(getMaterialProperty<Real>("rho_name")),
    _current_elem_volume(_assembly.elemVolume())
{
}

Real
LESsubgridViscosityAux::computeValue()
{
  const Point * q = _q_point.data();
  Node * qnode = (Node *)q; //= _mesh.getQuadratureNode(_current_elem, _current_side, _qp);
  Real d = 1e6;
  // qnode->print();
  // std::cout << (*qnode)(1) << ", " << (*qnode)(1) << std::endl;

  for (MooseMesh::bnd_node_iterator n = _mesh.bndNodesBegin(); n != _mesh.bndNodesEnd(); n++)
  {
    Node * itnode = ((**n)._node);
    RealVectorValue R((*qnode) - (*itnode));
    d = std::min(R.norm(), d);
  }

  Real delta = std::cbrt(_current_elem_volume);
  Real coef = std::min(0.1 * delta, 0.42 * d);
  RankTwoTensor Sij(_grad_u_vel[_qp], _grad_v_vel[_qp], _grad_w_vel[_qp]);
  Sij = 0.5 * (Sij + Sij.transpose());

  Real S_bar = Sij.doubleContraction(Sij);

  S_bar = std::sqrt(std::abs(2 * S_bar));

  return 5000 * coef * coef * S_bar;
}
