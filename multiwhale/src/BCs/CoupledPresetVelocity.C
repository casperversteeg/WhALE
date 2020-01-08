#include "CoupledPresetVelocity.h"

registerMooseObject("multiwhaleApp", CoupledPresetVelocity);

defineLegacyParams(CoupledPresetVelocity);

InputParameters
CoupledPresetVelocity::validParams()
{
  InputParameters params = NodalBC::validParams();
  params.addRequiredCoupledVar("v", "coupled variable");
  return params;
}

CoupledPresetVelocity::CoupledPresetVelocity(const InputParameters & parameters)
  : PresetNodalBC(parameters), _u_old(valueOld()), _v(coupledValue("v"))
{
}

Real
CoupledPresetVelocity::computeQpValue()
{
  return _u_old[_qp] + _dt * _v[_qp];
}
