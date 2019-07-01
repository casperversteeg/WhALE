//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "INSBase.h"

// Forward Declarations
class INSALEMomentumBase;

template <>
InputParameters validParams<INSALEMomentumBase>();

/**
 * This class computes the momentum equation residual and Jacobian
 * contributions for the incompressible Navier-Stokes momentum
 * equation.
 */
class INSALEMomentumBase : public INSBase
{
public:
  INSALEMomentumBase(const InputParameters & parameters);

  virtual ~INSALEMomentumBase() {}

protected:
  // These must be overridden by the traction kernel
  virtual Real computeQpResidualViscousPart() = 0;
  virtual Real computeQpJacobianViscousPart() = 0;
  virtual Real computeQpOffDiagJacobianViscousPart(unsigned jvar) = 0;

  // Common variables across all INS ALE kernels
  unsigned _component;
  bool _integrate_p_by_parts;
  const Function & _ffn;
};
