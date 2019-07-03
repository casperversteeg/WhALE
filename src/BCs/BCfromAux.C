#include "BCfromAux.h"

registerMooseObject("whaleApp", BCfromAux);

template <>
InputParameters
validParams<BCfromAux>()
{
  InputParameters params = validParams<IntegratedBC>(); // include parent class name

  params.addRequiredCoupledVar("aux_variable",
                               "Auxiliary variable that this boundary should enforce");
  params.addParam<MooseEnum>("bc_type",
                             BCfromAux::bcTypes(),
                             "Which type of boundary is this (dirichlet [default] or traction)");

  return params;
}

BCfromAux::BCfromAux(const InputParameters & parameters)
  : IntegratedBC(parameters),
    _aux_variable(coupledValue("aux_variable")),
    _bc_type(getParam<MooseEnum>("bc_type"))
{
}

Real
BCfromAux::computeQpResidual()
{
  switch (_bc_type)
  {
    case DIRICHLET:
      return _u[_qp] - _aux_variable[_qp];
    case TRACTION:
      return _test[_i][_qp] * _aux_variable[_qp];
    default:
      mooseError("bc_type is not one of the accepted parameters (dirichlet/traction)");
  }
}
