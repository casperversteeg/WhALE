//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "INSALEMomentumBodyForce.h"
#include "Function.h"

registerMooseObject("whaleApp", INSALEMomentumBodyForce);

template <>
InputParameters
validParams<INSALEMomentumBodyForce>()
{
  InputParameters params = validParams<INSALEMomentumBase>();
  return params;
}

INSALEMomentumBodyForce::INSALEMomentumBodyForce(const InputParameters & parameters)
  : INSALEMomentumBase(parameters)
{
}

Real
INSALEMomentumBodyForce::computeQpResidual()
{
  // body force term
  return _test[_i][_qp] * (gravityTerm()(_component) - _ffn.value(_t, _q_point[_qp]));
}
