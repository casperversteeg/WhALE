#pragma once

#include "AuxKernel.h"

class NewmarkAccelFromVelAux;

template<>
InputParameters validParams<NewmarkAccelFromVelAux>();

class NewmarkAccelFromVelAux : public AuxKernel{
public:
  NewmarkAccelFromVelAux(const InputParameters & parameters);

protected:
  virtual Real computeValue();

  const VariableValue & _vel_old;
  const VariableValue & _vel;
  Real _gamma;
};
