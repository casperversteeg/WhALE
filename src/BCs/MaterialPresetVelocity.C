#include "MaterialPresetVelocity.h"

registerMooseObject("whaleApp", MaterialPresetVelocity);

defineLegacyParams(MaterialPresetVelocity);

InputParameters
MaterialPresetVelocity::validParams()
{
  InputParameters params = NodalBC::validParams();
  params.addRequiredCoupledVar("v", "coupled variable");
  return params;
}

MaterialPresetVelocity::MaterialPresetVelocity(const InputParameters & parameters)
  : DerivativeMaterialInterface<DirichletBCBase>(parameters),
    _u_old(valueOld()),
    _v(coupledValue("v"))
{
}

Real
MaterialPresetVelocity::computeQpValue()
{
  return _u_old[_qp] + _dt * _v[_qp];
}
