//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "CoupledDirichletDotBC.h"

registerMooseObject("multiwhaleApp", CoupledDirichletDotBC);

defineLegacyParams(CoupledDirichletDotBC);

InputParameters
CoupledDirichletDotBC::validParams()
{
  InputParameters params = NodalBC::validParams();
  params.addRequiredCoupledVar("v", "Sets the variable equal to dv/dt");
  params.addParam<bool>("implicit", true, "Use implicit or explicit time integration");
  return params;
}

CoupledDirichletDotBC::CoupledDirichletDotBC(const InputParameters & parameters)
  : NodalBC(parameters),
    _v(coupledValue("v")),
    _implicit(getParam<bool>("implicit")),
    _v_dot(_implicit ? coupledDot("v") : coupledValueOld("v"))
{
}

Real
CoupledDirichletDotBC::computeQpResidual()
{
  if (_implicit)
    return _u[_qp] - _v_dot[_qp];

  return _u[_qp] - (_v[_qp] - _v_dot[_qp]) / _dt;
}
