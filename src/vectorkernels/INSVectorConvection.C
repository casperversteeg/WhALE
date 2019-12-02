#include "INSVectorConvection.h"

registerMooseObject("whaleApp", INSVectorConvection);

template <>
InputParameters
validParams<INSVectorConvection>()
{
  InputParameters params = validParams<INSVectorBase>();

  params.addClassDescription("");
  params.addCoupledVar("displacement", "Optional mesh displacement parameters");

  return params;
}

INSVectorConvection::INSVectorConvection(const InputParameters & parameters)
  : INSVectorBase(parameters),
    _mesh_dot(coupledVectorDot("displacement")),
    _dmesh_dot(coupledVectorDotDu("displacement")),
    _mesh_var(coupled("displacement"))
{
}

Real
INSVectorConvection::computeQpResidual()
{
  return _test[_i][_qp].contract(_rho[_qp] * (_u[_qp] - _mesh_dot[_qp]) * _grad_u[_qp]);
}

Real
INSVectorConvection::computeQpJacobian()
{
  return _rho[_qp] * _test[_i][_qp].contract(_phi[_j][_qp] * _grad_u[_qp] +
                                             (_u[_qp] - _mesh_dot[_qp]) * _grad_phi[_j][_qp]);
}

Real
INSVectorConvection::computeQpOffDiagJacobian(unsigned int jvar)
{
  return 0;
}
