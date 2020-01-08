//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "VelocityBC.h"

registerMooseObject("MooseApp", VelocityBC);

defineLegacyParams(VelocityBC);

InputParameters
VelocityBC::validParams()
{
  InputParameters params = NodalBC::validParams();
  params.addRequiredParam<Real>("value", "Value of the BC");
  params.declareControllable("value");
  params.addClassDescription("Imposes the essential boundary condition $u=g$, where $g$ "
                             "is a constant, controllable value.");
  return params;
}

VelocityBC::VelocityBC(const InputParameters & parameters)
  : NodalBC(parameters), _u_dot(_var.uDot()), _value(getParam<Real>("value"))
{
}

Real
VelocityBC::computeQpResidual()
{
  return _u_dot[_qp] - _value;
}
