#include "SubgridScaleBase.h"
#include "Assembly.h"

registerMooseObject("whaleApp", SubgridScaleBase);

defineLegacyParams(SubgridScaleBase);

InputParameters
SubgridScaleBase::validParams()
{
  InputParameters params = Material::validParams();
  params.addRequiredCoupledVar("u", "x-velocity component");
  params.addCoupledVar("v", 0, "y-velocity component");
  params.addCoupledVar("w", 0, "z-velocity component");

  params.addParam<MaterialPropertyName>("rho_name", "rho", "The name of the density");

  return params;
}

SubgridScaleBase::SubgridScaleBase(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _u_vel(coupledValue("u")),
    _v_vel(coupledValue("v")),
    _w_vel(coupledValue("w")),
    _grad_u_vel(isCoupled("u") ? coupledGradient("u") : _grad_zero),
    _grad_v_vel(isCoupled("v") ? coupledGradient("v") : _grad_zero),
    _grad_w_vel(isCoupled("w") ? coupledGradient("w") : _grad_zero),
    _u_vel_var_number(coupled("u")),
    _v_vel_var_number(coupled("v")),
    _w_vel_var_number(coupled("w")),
    _grad_phi(_assembly.gradPhi()),
    _rho(getMaterialProperty<Real>("rho_name")),
    _current_elem_volume(_assembly.elemVolume()),
    _mu_sgs(declareProperty<Real>("mu_sgs")),
    _dmu_dvel(_coupled_moose_vars.size())
{
  for (unsigned i = 0; i < _coupled_moose_vars.size(); ++i)
  {
    _dmu_dvel[i] = &declarePropertyDerivative<Real>("mu_sgs", _coupled_moose_vars[i]->name());
  }
}

void
SubgridScaleBase::initQpStatefulProperties()
{
  _mu_sgs[_qp] = 0;
  for (unsigned i = 0; i < _dmu_dvel.size(); ++i)
  {
    (*_dmu_dvel[i])[_qp] = 0;
  }
}
