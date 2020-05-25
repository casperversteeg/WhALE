//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef REYNOLDSSTRESS_H
#define REYNOLDSSTRESS_H

#pragma once

#include "INSMomentumBase.h"

// Forward Declaration
class ReynoldsStress;

template <>
InputParameters validParams<ReynoldsStress>();

/**
 * This calculates the time derivative for a coupled variable
 **/
class ReynoldsStress : public INSMomentumBase
{
public:
  ReynoldsStress(const InputParameters & parameters);

protected:
  virtual Real computeQpResidualViscousPart() override;
  virtual Real computeQpJacobianViscousPart() override;
  virtual Real computeQpOffDiagJacobianViscousPart(unsigned int jvar) override;

  const VariableValue & _k;
  const VariableValue & _eps;
  const VariableGradient & _grad_k;
  const VariableGradient & _grad_eps;

  const MaterialProperty<Real> & _mu_t;
  // const MaterialProperty<RankTwoTensor> & _dmu_dvel;
};

#endif // REYNOLDSSTRESS_H
