//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "BoundaryValuePostprocessor.h"

registerMooseObject("whaleApp", BoundaryValuePostprocessor);

template <>
InputParameters
validParams<BoundaryValuePostprocessor>()
{
  InputParameters params = validParams<SidePostprocessor>();
  params.addRequiredCoupledVar("variable",
                               "The name of the variable that this boundary condition applies to");
  return params;
}

BoundaryValuePostprocessor::BoundaryValuePostprocessor(const InputParameters & parameters)
  : SidePostprocessor(parameters), _qp(0), _u(coupledValue("variable"))
{
}

Real
BoundaryValuePostprocessor::getValue()
{
  return _u[_qp];
}

void
BoundaryValuePostprocessor::initialize()
{
}

void
BoundaryValuePostprocessor::execute()
{
}

void
BoundaryValuePostprocessor::threadJoin(const UserObject & y)
{
  const BoundaryValuePostprocessor & pps = static_cast<const BoundaryValuePostprocessor &>(y);
}
