//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "AuxKernel.h"

// Forward Declarations
class LESsubgridViscosityAux;

template <>
InputParameters validParams<LESsubgridViscosityAux>();

/**
 * Computes the distance from a block or boundary to another boundary.
 */
class LESsubgridViscosityAux : public AuxKernel
{
public:
  static InputParameters validParams();

  LESsubgridViscosityAux(const InputParameters & parameters);

protected:
  virtual Real computeValue() override;

  // Coupled variables
  const VariableValue & _u_vel;
  const VariableValue & _v_vel;
  const VariableValue & _w_vel;

  // Gradients
  const VariableGradient & _grad_u_vel;
  const VariableGradient & _grad_v_vel;
  const VariableGradient & _grad_w_vel;

  // const MaterialProperty<Real> & _rho;
  const Real & _current_elem_volume;
};
