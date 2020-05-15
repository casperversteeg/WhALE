//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

// MOOSE includes
#include "NearestBoundaryDistanceAux.h"
#include "NearestNodeLocator.h"
#include "MooseMesh.h"

registerMooseObject("whaleApp", NearestBoundaryDistanceAux);

defineLegacyParams(NearestBoundaryDistanceAux);

InputParameters
NearestBoundaryDistanceAux::validParams()
{
  InputParameters params = AuxKernel::validParams();
  params.addClassDescription(
      "Stores the distance between a block and boundary or between two boundaries.");
  // params.addRequiredParam<BoundaryName>("paired_boundary", "The boundary to find the distance
  // to.");
  params.set<bool>("use_displaced_mesh") = true;
  return params;
}

NearestBoundaryDistanceAux::NearestBoundaryDistanceAux(const InputParameters & parameters)
  : AuxKernel(parameters), _nearest_node(0)
// _nearest_node(_nodal ? getNearestNodeLocator(parameters.get<BoundaryName>("paired_boundary"),
//                                              boundaryNames()[0])
//                      : getQuadratureNearestNodeLocator(
//                            parameters.get<BoundaryName>("paired_boundary"), boundaryNames()[0]))
{
  if (_nodal)
    mooseError("NearestBoundaryDistanceAux only works with elemental variables");
  const std::set<BoundaryID> candidates = _mesh.getBoundaryIDs();
  for (auto candidate : candidates)
  {
    _nearest_node.push_back(&(getQuadratureNearestNodeLocator(
        _mesh.getBoundaryName(candidate), _mesh.getBoundaryName((*candidates.begin())))));
  }
}

Real
NearestBoundaryDistanceAux::computeValue()
{
  Real dist = 1e6;
  Node * qnode = _mesh.getQuadratureNode(_current_elem, _current_side, _qp);

  // printf("%d\n", _nearest_node.size());
  for (unsigned i = 0; i < _nearest_node.size(); ++i)
  {
    std::cout << _nearest_node[i]->distance(i) << std::endl;
    std::cout << qnode->id() << std::endl;
    // if (_nearest_node[i]->distance(qnode->id()) < dist)
    // {
    //   dist = _nearest_node[i]->distance(qnode->id());
    // }
  }

  return dist;
}
