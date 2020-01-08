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

class VelocityBC;

template <>
InputParameters validParams<VelocityBC>();

/**
 * Boundary condition of a Dirichlet type
 *
 * Sets the value in the node
 */
class VelocityBC : public NodalBC
{
public:
  static InputParameters validParams();

  VelocityBC(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;

  /// The value for this BC
  const VariableValue & _u_dot;
  const Real & _value;
};
