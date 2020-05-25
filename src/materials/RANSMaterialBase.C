#include "RANSMaterialBase.h"
#include "Assembly.h"

registerMooseObject("whaleApp", RANSMaterialBase);

defineLegacyParams(RANSMaterialBase);

InputParameters
RANSMaterialBase::validParams()
{
  InputParameters params = Material::validParams();
  params.addRequiredCoupledVar("u", "x-velocity component");
  params.addCoupledVar("v", 0, "y-velocity component");
  params.addCoupledVar("w", 0, "z-velocity component");
  params.addRequiredCoupledVar("k", "Turbulent kinetic energy");
  params.addRequiredCoupledVar("eps", "Turbulent disspation");

  params.addParam<MaterialPropertyName>("rho_name", "rho", "The name of the density");

  return params;
}

RANSMaterialBase::RANSMaterialBase(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _u_vel(coupledValue("u")),
    _v_vel(coupledValue("v")),
    _w_vel(coupledValue("w")),
    _k(coupledValue("k")),
    _eps(coupledValue("eps")),
    _grad_u_vel(isCoupled("u") ? coupledGradient("u") : _grad_zero),
    _grad_v_vel(isCoupled("v") ? coupledGradient("v") : _grad_zero),
    _grad_w_vel(isCoupled("w") ? coupledGradient("w") : _grad_zero),
    _grad_k(isCoupled("k") ? coupledGradient("k") : _grad_zero),
    _grad_eps(isCoupled("eps") ? coupledGradient("eps") : _grad_zero),
    _u_vel_var_number(coupled("u")),
    _v_vel_var_number(coupled("v")),
    _w_vel_var_number(coupled("w")),
    _k_var_number(coupled("k")),
    _eps_var_number(coupled("eps")),
    _rho(getMaterialProperty<Real>("rho_name")),
    _current_elem_volume(_assembly.elemVolume()),
    _mu_sgs(declareProperty<Real>("mu_sgs"))
{
}

void
RANSMaterialBase::initQpStatefulProperties()
{
  _mu_sgs[_qp] = 0;
}
