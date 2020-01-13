//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "TractionBCfromAux.h"

registerMooseObject("whaleApp", TractionBCfromAux);

template <>
InputParameters
validParams<TractionBCfromAux>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addClassDescription(
      "Applies a traction from a variable on a given boundary in a given direction");
  params.addRequiredCoupledVar("traction", "Coupled variable containing the traction");

  return params;
}

TractionBCfromAux::TractionBCfromAux(const InputParameters & parameters)
  : IntegratedBC(parameters), _traction(coupledValue("traction"))
{
}

Real
TractionBCfromAux::computeQpResidual()
{
  return _traction[_qp] * _test[_i][_qp];
}
