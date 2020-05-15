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
#include "NearestNodeLocator.h"
#include "MooseMesh.h"
#include "GeometricSearchData.h"

class SubgridScaleBase;
class NearestNodeLocator;

template <>
InputParameters validParams<SubgridScaleBase>();

/**
 * SmagorinskySGS is the base class for strain tensors
 */
class SubgridScaleBase : public DerivativeMaterialInterface<Material>
{
public:
  static InputParameters validParams();

  SubgridScaleBase(const InputParameters & parameters);

protected:
  virtual void initQpStatefulProperties() override;
  virtual void computeQpProperties() override;
  virtual void computeSGSviscosity(){};
  Real computeMinBndDistance();

  // Coupled variables
  const VariableValue & _u_vel;
  const VariableValue & _v_vel;
  const VariableValue & _w_vel;

  // Gradients
  const VariableGradient & _grad_u_vel;
  const VariableGradient & _grad_v_vel;
  const VariableGradient & _grad_w_vel;

  // Variable numberings
  unsigned _u_vel_var_number;
  unsigned _v_vel_var_number;
  unsigned _w_vel_var_number;
  unsigned _p_var_number;

  const VariablePhiGradient & _grad_phi;

  const MaterialProperty<Real> & _rho;
  const Real & _current_elem_volume;

  MaterialProperty<Real> & _mu_sgs;
  std::vector<MaterialProperty<Real> *> _dmu_dvel;

  MaterialProperty<Real> & _min_bnd_dist;
  const MaterialProperty<Real> & _min_bnd_dist_old;
};
