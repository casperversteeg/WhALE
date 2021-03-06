//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "SubgridScaleBase.h"

class SmagorinskySGS;

template <>
InputParameters validParams<SmagorinskySGS>();

/**
 * SmagorinskySGS is the base class for strain tensors
 */
class SmagorinskySGS : public SubgridScaleBase
{
public:
  static InputParameters validParams();

  SmagorinskySGS(const InputParameters & parameters);

protected:
  virtual void computeSGSviscosity() override;

  const Real _Cs;
};
