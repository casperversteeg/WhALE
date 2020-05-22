#pragma once

#include "DirichletBCBase.h"

class CoupledPresetVelocity : public DirichletBCBase
{
public:
  static InputParameters validParams();

  CoupledPresetVelocity(const InputParameters & parameters);

protected:
  virtual Real computeQpValue();

  const VariableValue & _u_old;
  const VariableValue & _v;
};

template <>
InputParameters validParams<CoupledPresetVelocity>();
