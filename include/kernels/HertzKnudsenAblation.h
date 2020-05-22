#pragma once

#include "ConservativeAdvection.h"
#include "DerivativeMaterialInterface.h"

class HertzKnudsenAblation;

template <>
InputParameters validParams<HertzKnudsenAblation>();

class HertzKnudsenAblation : public DerivativeMaterialInterface<ConservativeAdvection>
{
public:
  static InputParameters validParams();
  HertzKnudsenAblation(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;

  const MaterialProperty<Real> & _sdot;
  const MaterialProperty<Real> & _dsdot_dT;
  RealVectorValue _in_normal;
  const MaterialProperty<Real> & _rho;
  const MaterialProperty<Real> & _cp;
};
