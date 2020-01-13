#include "NewmarkVel.h"

registerMooseObject("whaleApp", NewmarkVel);

template <>
InputParameters
validParams<NewmarkVel>()
{
  InputParameters params = validParams<Kernel>();

  params.addRequiredCoupledVar("displacement", "displacement variable");
  params.addRequiredParam<Real>("beta", "not gamma");
  return params;
}

NewmarkVel::NewmarkVel(const InputParameters & parameters)
  : Kernel(parameters),
    _u_old(valueOld()),
    _d_dot(coupledDot("displacement")),
    // _disp(coupledValue("displacement")),
    // _disp_old(coupledValueOld("displacement")),
    // _accel_old(coupledValueOld("acceleration")),
    _beta(getParam<Real>("beta"))
{
}

Real
NewmarkVel::computeQpResidual()
{
  return _test[_i][_qp] * (_u[_qp] - _d_dot[_qp]);
}

Real
NewmarkVel::computeQpJacobian()
{
  return _test[_i][_qp] * _phi[_j][_qp];
}
