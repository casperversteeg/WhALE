#include "KepsViscosity.h"

registerMooseObject("whaleApp", KepsViscosity);

defineLegacyParams(KepsViscosity);

InputParameters
KepsViscosity::validParams()
{
  InputParameters params = RANSMaterialBase::validParams();

  params.addParam<Real>("C_mu", 0.09, "Smagorinsky constant (typically 0.1-0.2)");

  return params;
}

KepsViscosity::KepsViscosity(const InputParameters & parameters)
  : RANSMaterialBase(parameters), _C_mu(getParam<Real>("C_mu"))
{
}

void
KepsViscosity::computeQpProperties()
{
  _mu_sgs[_qp] = _rho[_qp] * _C_mu * _k[_qp] * _k[_qp] / _eps[_qp];
}
