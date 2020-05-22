#include "HertzKnudsen.h"
#include "Assembly.h"
#include "NearestNodeLocator.h"
#include "MooseMesh.h"
#include "libmesh/tensor_tools.h"
#include "libmesh/type_vector.h"
#include "libmesh/node.h"

registerMooseObject("whaleApp", HertzKnudsen);

defineLegacyParams(HertzKnudsen);

InputParameters
HertzKnudsen::validParams()
{
  InputParameters params = Material::validParams();
  params.addRequiredCoupledVar("temperature", "Nonlinear variable containing temperature");
  params.addParam<Real>("m", 0, "atomic mass of material in kilograms");
  params.addParam<Real>("kb", 1.38064852e-23, "Boltzmann constant");
  params.addParam<Real>("Pb", 1.01e5, "Boiling pressure");
  params.addParam<Real>("Tb", 3000, "Boiling temperature in Kelvin");
  params.addParam<Real>("latent_vap", 0, "Latent heat of vaporization in J/kg");
  params.addParam<Real>("beta", 1, "Vaporization coefficient");
  params.addParam<MaterialPropertyName>("cp", "cp", "Specific heat capacity");

  // params.addRequiredParam("wall_bnd", "Wall boundary conditions");
  params.addParam<MaterialPropertyName>("rho_name", "rho", "The name of the density");

  return params;
}

HertzKnudsen::HertzKnudsen(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _T(coupledValue("temperature")),
    _m(getParam<Real>("m")),
    _kb(getParam<Real>("kb")),
    _Pb(getParam<Real>("Pb")),
    _Tb(getParam<Real>("Tb")),
    _rho(getMaterialProperty<Real>("rho")),
    _latent_vap(getParam<Real>("latent_vap")),
    _beta(getParam<Real>("beta")),
    _sdot(declareProperty<Real>("sdot")),
    _dsdot_dT(declarePropertyDerivative<Real>("sdot", "T"))
{
}

void
HertzKnudsen::computeQpProperties()
{
  _sdot[_qp] = _beta * std::sqrt(_m / 2 / M_PI / _kb / _T[_qp]) * _Pb / _rho[_qp] *
               std::exp(_m * _latent_vap / _kb * (1 / _Tb + 1 / _T[_qp]));
  _dsdot_dT[_qp] =
      -std::sqrt(2 / M_PI) / 4 * _Pb * _beta * _m *
      std::exp(_latent_vap * _m * (_T[_qp] + _Tb) / (_T[_qp] * _Tb * _kb)) *
      (2 * _latent_vap * _m + _T[_qp] * _kb) /
      (_T[_qp] * _T[_qp] * _T[_qp] * _kb * _kb * _rho[_qp] * std::sqrt(_m / _T[_qp] / _kb));
}
