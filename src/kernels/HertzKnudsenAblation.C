#include "HertzKnudsenAblation.h"

registerMooseObject("whaleApp", HertzKnudsenAblation);

defineLegacyParams(HertzKnudsenAblation);

InputParameters
HertzKnudsenAblation::validParams()
{
  InputParameters params = ConservativeAdvection::validParams();

  // params.makeParamNotRequired<RealVectorValue>("velocity");
  params.addRequiredParam<RealVectorValue>("in_normal", "normal incident vector");

  params.addParam<MaterialPropertyName>("sdot", "sdot", "Hertz-Knudsen surface velocity");
  params.addParam<MaterialPropertyName>("cp", "cp", "Specific heat capacity");
  params.addParam<MaterialPropertyName>("rho_name", "rho", "The name of the density");

  return params;
}

HertzKnudsenAblation::HertzKnudsenAblation(const InputParameters & parameters)
  : DerivativeMaterialInterface<ConservativeAdvection>(parameters),
    _sdot(getMaterialProperty<Real>("sdot")),
    _dsdot_dT(getMaterialPropertyDerivative<Real>("sdot", _var.name())),
    _in_normal(getParam<RealVectorValue>("in_normal").unit()),
    _rho(getMaterialProperty<Real>("rho")),
    _cp(getMaterialProperty<Real>("cp"))
{
}

Real
HertzKnudsenAblation::computeQpResidual()
{
  return _rho[_qp] * _cp[_qp] * _grad_test[_i][_qp] * _in_normal * _sdot[_qp] * _u[_qp];
}

Real
HertzKnudsenAblation::computeQpJacobian()
{
  return _rho[_qp] * _cp[_qp] * _grad_test[_i][_qp] * _in_normal *
         (_sdot[_qp] * _phi[_j][_qp] - 0 * _dsdot_dT[_qp] * _u[_qp]);
}
