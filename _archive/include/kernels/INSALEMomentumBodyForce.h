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
class INSALEMomentumBodyForce;

template <>
InputParameters validParams<INSALEMomentumBodyForce>();

class INSALEMomentumBodyForce : public INSALEMomentumBase
{
public:
  // Constructor
  INSALEMomentumBodyForce(const InputParameters & parameters);
  // Destructor
  virtual ~INSALEMomentumBodyForce() {}

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() { return 0; };
  // Necessary to make the compiler stop yelling
  virtual Real computeQpOffDiagJacobian(unsigned jvar) { return 0; };
  virtual Real computeQpResidualViscousPart() { return 0; };
  virtual Real computeQpJacobianViscousPart() { return 0; };
  virtual Real computeQpOffDiagJacobianViscousPart(unsigned jvar) { return 0; };
};
