#pragma once

#include "DirichletBCBase.h"
#include "DerivativeMaterialInterface.h"
#include "Material.h"
#include "MaterialPropertyInterface.h"

class MaterialPresetVelocity : public DerivativeMaterialInterface<DirichletBCBase>
{
public:
  static InputParameters validParams();

  MaterialPresetVelocity(const InputParameters & parameters);

protected:
  virtual Real computeQpValue();

  const VariableValue & _u_old;
  const VariableValue & _v;
};

template <>
InputParameters validParams<MaterialPresetVelocity>();
