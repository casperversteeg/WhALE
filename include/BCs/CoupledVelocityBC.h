//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "NodalBC.h"

class CoupledVelocityBC : public NodalBC
{
public:
  static InputParameters validParams();

  CoupledVelocityBC(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const VariableValue & _u_dot;
  const VariableValue & _velocity;
  unsigned int _v_num;
};

template <>
InputParameters validParams<CoupledVelocityBC>();
