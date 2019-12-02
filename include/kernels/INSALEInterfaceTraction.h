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
  virtual Real computeQpOffDiagJacobian(Moose::DGJacobianType type, unsigned int jvar) override;
  virtual void computeElementOffDiagJacobian(unsigned int jvar) override;
  virtual void computeNeighborOffDiagJacobian(unsigned int jvar) override;

  const unsigned int _component;
  const VariableValue & _p;
  const VariableGradient & _grad_u_vel;
  const VariableGradient & _grad_v_vel;
  const VariableGradient & _grad_w_vel;
  const Real _penalty;
  const VariableValue & _coupled_var;

  const std::string _base_name;
  const MaterialProperty<RankTwoTensor> & _stress;
  const MooseArray<Point> & _normals;
};
