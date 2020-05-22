//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "Material.h"
#include "RankTwoTensor.h"
#include "RankFourTensor.h"
#include "DerivativeMaterialInterface.h"

class HertzKnudsen;

template <>
InputParameters validParams<HertzKnudsen>();

/**
 * SmagorinskySGS is the base class for strain tensors
 */
class HertzKnudsen : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  HertzKnudsen(const InputParameters & parameters);

protected:
  virtual void computeQpProperties() override;

  // Coupled variables
  const VariableValue & _T;

  const Real & _m;
  const Real & _kb;
  const Real & _Pb;
  const Real & _Tb;
  const MaterialProperty<Real> & _rho;
  const Real & _latent_vap;
  const Real & _beta;

  MaterialProperty<Real> & _sdot;
  MaterialProperty<Real> & _dsdot_dT;
};
