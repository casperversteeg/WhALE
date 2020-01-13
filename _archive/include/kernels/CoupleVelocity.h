#pragma once

#include "Kernel.h"

class CoupleVelocity;

template <>
InputParameters validParams<CoupleVelocity>();

class CoupleVelocity : public Kernel
{
public:
  CoupleVelocity(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const VariableValue & _disp_dot;
  const VariableValue & _disp_dot_du;
  const unsigned int _disp_var;
};
