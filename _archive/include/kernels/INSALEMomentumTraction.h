//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "INSALEMomentumBase.h"

// Forward Declarations
class INSALEMomentumTraction;

template <>
InputParameters validParams<INSALEMomentumTraction>();

class INSALEMomentumTraction : public INSALEMomentumBase
{
public:
  // Constructor
  INSALEMomentumTraction(const InputParameters & parameters);
  // Destructor
  virtual ~INSALEMomentumTraction() {}

protected:
  // Computes contribution to residual due to body force term
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;

  // Need to be overridden from base kernel
  virtual Real computeQpResidualViscousPart() override;
  virtual Real computeQpJacobianViscousPart() override;
  virtual Real computeQpOffDiagJacobianViscousPart(unsigned jvar) override;

  // Necessary to make the compiler stop yelling
  virtual Real computeQpOffDiagJacobian(unsigned jvar) { return 0; };
};
