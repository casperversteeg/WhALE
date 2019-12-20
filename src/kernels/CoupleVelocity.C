#include "CoupleVelocity.h"

registerMooseObject("whaleApp", CoupleVelocity);

template <>
InputParameters
validParams<CoupleVelocity>()
{
  InputParameters params = validParams<Kernel>();
  params.addClassDescription("Couples a velocity field to a displacement field");
  params.addRequiredCoupledVar("displacement", "The displacement variable");
  return params;
}

CoupleVelocity::CoupleVelocity(const InputParameters & parameters)
  : Kernel(parameters),
    _disp_dot(coupledDot("displacement")),
    _disp_dot_du(coupledDotDu("displacement")),
    _disp_var(coupled("displacement"))
{
}

Real
CoupleVelocity::computeQpResidual()
{
  return _test[_i][_qp] * (_u[_qp] - _disp_dot[_qp]);
}

Real
CoupleVelocity::computeQpJacobian()
{
  return _test[_i][_qp] * _phi[_j][_qp];
}

Real
CoupleVelocity::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _disp_var)
    return _test[_i][_qp] * (_phi[_j][_qp] - _disp_dot_du[_qp]);
  return 0.0;
}
