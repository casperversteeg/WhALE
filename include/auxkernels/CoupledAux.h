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
class CoupledAux;

template <>
InputParameters validParams<CoupledAux>();

/**
 * Coupled auxiliary value
 */
class CoupledAux : public AuxKernel
{
public:
  /**
   * Factory constructor, takes parameters so that all derived classes can be built using the same
   * constructor.
   */
  CoupledAux(const InputParameters & parameters);

  virtual ~CoupledAux() {}

protected:
  virtual Real computeValue();

  const Real & _value;         ///< The value being set for this kernel
  const MooseEnum & _operator; ///< Operator being applied on this variable and coupled variable

  const int & _coupled;               ///< The number of the coupled variable
  const VariableValue & _coupled_val; ///< Coupled variable
};
