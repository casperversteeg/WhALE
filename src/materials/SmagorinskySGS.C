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
SmagorinskySGS::computeSGSviscosity()
{
  Real delta = std::cbrt(_current_elem_volume);
  Real coef = std::min(_Cs * delta, 0.42 * _min_bnd_dist[_qp]);
  RankTwoTensor Sij(_grad_u_vel[_qp], _grad_v_vel[_qp], _grad_w_vel[_qp]);
  Sij = 0.5 * (Sij + Sij.transpose());

  Real S_bar = Sij.doubleContraction(Sij);

  S_bar = std::sqrt(2 * S_bar);

  _mu_sgs[_qp] = _rho[_qp] * coef * coef * S_bar;
  for (unsigned i = 0; i < _dmu_dvel.size(); ++i)
  {
    (*_dmu_dvel[i])[_qp] = 0; // coef * (Sij.column(i) * _grad_phi[_qp]) / S_bar;
  }
}
