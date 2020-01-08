#pragma once

#include "AuxKernel.h"
#include "Assembly.h"

class ComputeINSStress;

template <>
InputParameters validParams<ComputeINSStress>();

class ComputeINSStress : public AuxKernel
{
public:
  ComputeINSStress(const InputParameters & parameters);

protected:
  virtual Real computeValue() override;

  const unsigned int _component;
  const VariableValue & _p;
  const VariableGradient & _grad_u_vel;
  const VariableGradient & _grad_v_vel;
  const VariableGradient & _grad_w_vel;

  const MaterialProperty<Real> & _mu;
  const MooseArray<Point> & _normals;
};
