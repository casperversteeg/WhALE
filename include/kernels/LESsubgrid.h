//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef LESSUBGRID_H
#define LESSUBGRID_H

#pragma once

#include "INSMomentumBase.h"
#include "JvarMapInterface.h"
#include "DerivativeMaterialInterface.h"

// Forward Declaration
class LESsubgrid;

template <>
InputParameters validParams<LESsubgrid>();

/**
 * This calculates the time derivative for a coupled variable
 **/
class LESsubgrid : public DerivativeMaterialInterface<JvarMapKernelInterface<INSMomentumBase>>
{
public:
  LESsubgrid(const InputParameters & parameters);

protected:
  virtual Real computeQpResidualViscousPart() override;
  virtual Real computeQpJacobianViscousPart() override;
  virtual Real computeQpOffDiagJacobianViscousPart(unsigned int jvar) override;

  const MaterialProperty<Real> & _mu_sgs;
  std::vector<const MaterialProperty<Real> *> _dmu_dvel;
};

#endif // LESSUBGRID_H
