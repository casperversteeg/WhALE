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
#include "RotationTensor.h"
#include "DerivativeMaterialInterface.h"

class RANSMaterialBase;

template <>
InputParameters validParams<RANSMaterialBase>();

/**
 * SmagorinskySGS is the base class for strain tensors
 */
class RANSMaterialBase : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  RANSMaterialBase(const InputParameters & parameters);

protected:
  virtual void initQpStatefulProperties() override;
  // virtual void compute_dmu_dvel() = 0;

  // Coupled variables
  const VariableValue & _u_vel;
  const VariableValue & _v_vel;
  const VariableValue & _w_vel;

  const VariableValue & _k;
  const VariableValue & _eps;

  // Gradients
  const VariableGradient & _grad_u_vel;
  const VariableGradient & _grad_v_vel;
  const VariableGradient & _grad_w_vel;

  const VariableGradient & _grad_k;
  const VariableGradient & _grad_eps;

  // Variable numberings
  unsigned _u_vel_var_number;
  unsigned _v_vel_var_number;
  unsigned _w_vel_var_number;
  unsigned _p_var_number;

  unsigned _k_var_number;
  unsigned _eps_var_number;

  const MaterialProperty<Real> & _rho;
  const Real & _current_elem_volume;

  MaterialProperty<Real> & _mu_sgs;
};
