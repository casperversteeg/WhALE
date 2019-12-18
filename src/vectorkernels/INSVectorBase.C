#include "INSVectorBase.h"

registerMooseObject("whaleApp", INSVectorBase);

template <>
InputParameters
validParams<INSVectorBase>()
{
  InputParameters params = validParams<VectorKernel>();

  params.addClassDescription("");
  // Require pressure be coupled in
  params.addRequiredCoupledVar("p", "Scalar pressure variable");

  // Optional parameters
  params.addParam<RealVectorValue>(
      "gravity", RealVectorValue(0, 0, 0), "Direction of the gravity vector");

  params.addParam<MaterialPropertyName>("mu_name", "mu", "The name of the dynamic viscosity");
  params.addParam<MaterialPropertyName>("rho_name", "rho", "The name of the density");

  return params;
}

INSVectorBase::INSVectorBase(const InputParameters & parameters)
  : VectorKernel(parameters),
    _p(coupledValue("p")),
    _grad_p(coupledGradient("p")),
    _p_var_number(coupled("p")),
    _gravity(getParam<RealVectorValue>("gravity")),
    _mu(getMaterialProperty<Real>("mu_name")),
    _rho(getMaterialProperty<Real>("rho_name"))
{
}

Real
INSVectorBase::computeQpResidual()
{
  return 0;
}
Real
INSVectorBase::computeQpJacobian()
{
  return 0;
}
Real
INSVectorBase::computeQpOffDiagJacobian(unsigned int jvar)
{
  return 0;
}
