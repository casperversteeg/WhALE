#pragma once

#include "Kernel.h"

class NewmarkVel;

template <>
InputParameters validParams<NewmarkVel>();

class NewmarkVel : public Kernel
{
public:
  NewmarkVel(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;

  const VariableValue & _u_old;
  const VariableValue & _d_dot;
  // const VariableValue & _disp;
  // const VariableValue & _disp_old;
  const Real & _beta;
  // const VariableValue & _accel;
  // const VariableValue & _accel_old;
  // const Real & _gamma;
};
