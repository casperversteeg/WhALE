#include "SmagorinskySGS.h"

registerMooseObject("whaleApp", SmagorinskySGS);

defineLegacyParams(SmagorinskySGS);

InputParameters
SmagorinskySGS::validParams()
{
  InputParameters params = SubgridScaleBase::validParams();

  params.addParam<Real>("Cs", 0.10, "Smagorinsky constant (typically 0.1-0.2)");

  return params;
}

SmagorinskySGS::SmagorinskySGS(const InputParameters & parameters)
  : SubgridScaleBase(parameters), _Cs(getParam<Real>("Cs"))
{
}

void
SmagorinskySGS::computeQpProperties()
{
  Real delta = std::cbrt(_current_elem_volume);
  Real coef = _rho[_qp] * (_Cs * _Cs * delta * delta);

  RankTwoTensor Sij(_grad_u_vel[_qp], _grad_v_vel[_qp], _grad_w_vel[_qp]);
  Sij = 0.5 * (Sij + Sij.transpose());

  Real S_bar = Sij.doubleContraction(Sij);

  S_bar = std::sqrt(2 * S_bar);

  _mu_sgs[_qp] = coef * S_bar;
  _dmu_dvel[_qp] = 2 * coef * Sij / S_bar;
}
