#include "NewmarkAccelFromVelAux.h"

registerMooseObject("whaleApp", NewmarkAccelFromVelAux);

template <>
InputParameters
validParams<NewmarkAccelFromVelAux>()
{
  InputParameters params = validParams<AuxKernel>();
  params.addClassDescription(
      "Computes current acceleration from given velocity using Newmark beta.");
  params.addRequiredCoupledVar("velocity", "velocity variable");
  params.addRequiredParam<Real>("gamma", "gamma parameter for Newmark beta");
  return params;
}

NewmarkAccelFromVelAux::NewmarkAccelFromVelAux(const InputParameters & parameters)
  : AuxKernel(parameters),
    _vel_old(coupledValueOld("velocity")),
    _vel(coupledValue("velocity")),
    _gamma(getParam<Real>("gamma"))
{
}

Real
NewmarkAccelFromVelAux::computeValue()
{
  if (!isNodal())
    mooseError("NewmarkAccelFromVelAux must run on Nodal variable");

  Real accel_old = _u_old[_qp];
  if (_dt == 0)
    return accel_old;

  return 1.0 / (_gamma * _dt) * ((_vel[_qp] - _vel_old[_qp]) - (1 - _gamma) * _dt * accel_old);
}
