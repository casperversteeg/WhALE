#pragma once

#include "VectorKernel.h"
class INSVectorBase;

template <>
InputParameters validParams<INSVectorBase>();

class INSVectorBase : public VectorKernel
{
public:
  INSVectorBase(const InputParameters & parameters);
  virtual ~INSVectorBase() {}

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const VariableValue & _p;
  const VariableGradient & _grad_p;
  unsigned _p_var_number;

  RealVectorValue _gravity;

  // Material properties
  const MaterialProperty<Real> & _mu;
  const MaterialProperty<Real> & _rho;
};
