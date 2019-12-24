#pragma once

#include "InterfaceKernel.h"

// Forward Declarations
class VelocityContinuity;

template <>
InputParameters validParams<VelocityContinuity>();

/**
 * DG kernel for interfacing diffusion between two variables on adjacent blocks
 */
class VelocityContinuity : public InterfaceKernel
{
public:
  VelocityContinuity(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual(Moose::DGResidualType type) override;
  virtual Real computeQpJacobian(Moose::DGJacobianType type) override;

  // const VariableValue & _u_dot;
  const VariableValue & _neighbor_dot;
  const VariableValue & _neighbor_old;
};
