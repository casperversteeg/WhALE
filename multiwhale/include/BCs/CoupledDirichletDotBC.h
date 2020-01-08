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

class CoupledDirichletDotBC;

template <>
InputParameters validParams<CoupledDirichletDotBC>();

/**
 * Boundary condition of a Dirichlet type
 *
 * Sets the value in the node
 */
class CoupledDirichletDotBC : public NodalBC
{
public:
  static InputParameters validParams();

  CoupledDirichletDotBC(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;

  /// The value for this BC
  const VariableValue & _v;
  bool _implicit;
  const VariableValue & _v_dot;
};
