#include "BCfromAux.h"

registerMooseObject("whaleApp", BCfromAux);

template <>
InputParameters
validParams<BCfromAux>()
{
  InputParameters params = validParams<NodalBC>(); // include parent class name
  params.addRequiredCoupledVar("aux_variable",
                               "Auxiliary variable that this boundary should enforce");
  params.addParam<MooseEnum>("bc_type",
                             BCfromAux::bcTypes(),
                             "Which type of boundary is this (dirichlet [default] or traction)");

  return params;
}

BCfromAux::BCfromAux(const InputParameters & parameters)
  : NodalBC(parameters), // NodalBC includes _var (the variable this operates on)
    _aux_variable(NodalBC::coupledValue("aux_variable")),
    _bc_type(NodalBC::getParam<MooseEnum>("bc_type")),
    _phi(_assembly.phiFace(_var)),
    _grad_phi(_assembly.gradPhiFace(_var)),
    _test(_var.phiFace()),
    _grad_test(_var.gradPhiFace())
{
}

Real
BCfromAux::computeQpResidual()
{
  switch (_bc_type)
  {
    case DIRICHLET:
      return _u[_qp] - _aux_variable[_qp]; // NodalBC::computeQpResidual();
    case TRACTION:
      return 0;
      // return IntegratedBC::_test[_i][IntegratedBC::_qp] *
      //        _aux_variable[IntegratedBC::_qp]; // IntegratedBC::computeQpResidual();
    default:
      NodalBC::mooseError("bc_type is not one of the accepted parameters (dirichlet/traction)");
  }
}
//
// Real
// BCfromAux::NodalBC::computeQpResidual()
// {
//   return _u[_qp] - _aux_variable[_qp];
// }
//
// Real
// BCfromAux::IntegratedBC::computeQpResidual()
// {
//   return -_test[_i][_qp] * _aux_variable[_qp];
// }
