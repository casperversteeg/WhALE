//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "CoupledVelocityBC.h"
#include "Function.h"

registerMooseObject("whaleApp", CoupledVelocityBC);
template<>
InputParameters
validParams<CoupledVelocityBC>()
{
  InputParameters params = validParams<NodalBC>();
  params.addRequiredCoupledVar("v", "Coupled velocity variable");
  return params;
}

CoupledVelocityBC::CoupledVelocityBC(const InputParameters & parameters)
  : NodalBC(parameters),
    _u_dot(_var.uDot()),
    _velocity(coupledValue("v")),
    _v_num(coupled("v"))
{
}

Real
CoupledVelocityBC::computeQpResidual()
{
  return _u_dot[_qp] - _velocity[_qp];
}

Real
CoupledVelocityBC::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _v_num)
    return -1.0;
  else
    return 0.;
}
