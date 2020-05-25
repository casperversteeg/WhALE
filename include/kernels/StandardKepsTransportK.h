//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#ifndef STANDARDKEPSTRANSPORTK_H
#define STANDARDKEPSTRANSPORTK_H

#pragma once

#include "Kernel.h"

// Forward Declaration
class StandardKepsTransportK;

template <>
InputParameters validParams<StandardKepsTransportK>();

/**
 * This calculates the time derivative for a coupled variable
 **/
class StandardKepsTransportK : public Kernel
{
public:
  StandardKepsTransportK(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  // Coupled variables
  const VariableValue & _u_vel;
  const VariableValue & _v_vel;
  const VariableValue & _w_vel;
  const VariableValue & _p;
  const VariableValue & _k;
  const VariableValue & _eps;
  // Gradients
  const VariableGradient & _grad_u_vel;
  const VariableGradient & _grad_v_vel;
  const VariableGradient & _grad_w_vel;
  const VariableGradient & _grad_k;
  const VariableGradient & _grad_eps;

  // Material properties
  const MaterialProperty<Real> & _mu;
  const MaterialProperty<Real> & _rho;
  const MaterialProperty<Real> & _mu_t;
  // const MaterialProperty<RankTwoTensor> & _dmu_dvel;
};

#endif // STANDARDKEPSTRANSPORTK_H
