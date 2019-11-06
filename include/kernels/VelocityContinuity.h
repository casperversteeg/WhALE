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
  virtual Real computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar) override;
  virtual void computeElementOffDiagJacobian(unsigned int jvar) override;
  virtual void computeNeighborOffDiagJacobian(unsigned int jvar) override;

  const Real _penalty;
  const VariableValue & _coupled_var;
};
