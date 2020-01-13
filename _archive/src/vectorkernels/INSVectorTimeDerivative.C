#include "INSVectorTimeDerivative.h"

registerMooseObject("whaleApp", INSVectorTimeDerivative);

template <>
InputParameters
validParams<INSVectorTimeDerivative>()
{
  InputParameters params = validParams<INSVectorBase>();
  params.addClassDescription("");
  return params;
}

INSVectorTimeDerivative::INSVectorTimeDerivative(const InputParameters & parameters)
  : INSVectorBase(parameters), _u_dot(_var.uDot()), _du_dot_du(_var.duDotDu())
{
}

Real
INSVectorTimeDerivative::computeQpResidual()
{
  return _rho[_qp] * _test[_i][_qp] * _u_dot[_qp];
}

Real
INSVectorTimeDerivative::computeQpJacobian()
{
  return _rho[_qp] * _test[_i][_qp] * _phi[_j][_qp] * _du_dot_du[_qp];
}

Real
INSVectorTimeDerivative::computeQpOffDiagJacobian(unsigned int jvar)
{
  return 0;
}
