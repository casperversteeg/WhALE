//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "IntegratedBC.h"

class INSALETractionBC;

template <>
InputParameters validParams<INSALETractionBC>();

/**
 * Pressure boundary condition using coupled variable to apply pressure in a given direction
 */
class INSALETractionBC : public IntegratedBC
{
public:
  static InputParameters validParams();

  INSALETractionBC(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;

  const unsigned int _component;
  const VariableValue & _p;
  const VariableGradient & _grad_u_vel;
  const VariableGradient & _grad_v_vel;
  const VariableGradient & _grad_w_vel;

  const MaterialProperty<Real> & _mu;

};
