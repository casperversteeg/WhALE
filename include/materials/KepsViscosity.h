//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "RANSMaterialBase.h"

class KepsViscosity;

template <>
InputParameters validParams<KepsViscosity>();

/**
 * SmagorinskySGS is the base class for strain tensors
 */
class KepsViscosity : public RANSMaterialBase
{
public:
  static InputParameters validParams();

  KepsViscosity(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  const Real _C_mu;
};
