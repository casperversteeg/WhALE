#pragma once

#include "InterfaceKernel.h"
#include "Assembly.h"

// Forward Declarations
class INSALEInterfaceTraction;

template <>
InputParameters validParams<INSALEInterfaceTraction>();

/**
 * DG kernel for interfacing diffusion between two variables on adjacent blocks
 */
class INSALEInterfaceTraction : public InterfaceKernel
{
public:
  INSALEInterfaceTraction(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual(Moose::DGResidualType type) override;
  virtual Real computeQpJacobian(Moose::DGJacobianType type) override;

  const unsigned int _component;
  const VariableValue & _p;
  const VariableGradient & _grad_u_vel;
  const VariableGradient & _grad_v_vel;
  const VariableGradient & _grad_w_vel;

  const MaterialProperty<Real> & _mu;
  const MooseArray<Point> & _normals;
};
