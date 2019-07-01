//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "INSALEMomentumBase.h"
#include "Function.h"

template <>
InputParameters
validParams<INSALEMomentumBase>()
{
  InputParameters params = validParams<INSBase>();

  params.addRequiredParam<unsigned>("component", "The velocity component that this is applied to.");
  params.addParam<bool>(
      "integrate_p_by_parts", true, "Whether to integrate the pressure term by parts.");
  params.addParam<FunctionName>("forcing_func", 0, "The mms forcing function.");
  return params;
}

INSALEMomentumBase::INSALEMomentumBase(const InputParameters & parameters)
  : INSBase(parameters),
    _component(getParam<unsigned>("component")),
    _integrate_p_by_parts(getParam<bool>("integrate_p_by_parts")),
    _ffn(getFunction("forcing_func"))
{
}
