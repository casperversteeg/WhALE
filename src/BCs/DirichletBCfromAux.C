#include "DirichletBCfromAux.h"

registerMooseObject("whaleApp", DirichletBCfromAux);

template <>
InputParameters
validParams<DirichletBCfromAux>()
{
  InputParameters params = validParams<NodalBC>(); // include parent class name
  params.addRequiredCoupledVar("aux_variable",
                               "Auxiliary variable that this boundary should enforce");
  // params.addParam<MooseEnum>("bc_type",
  //                            DirichletBCfromAux::bcTypes(),
  //                            "Which type of boundary is this (dirichlet [default] or traction)");
  // params.suppressParameter("is_nodal");
  return params;
}

DirichletBCfromAux::DirichletBCfromAux(const InputParameters & parameters)
  : NodalBC(parameters), // NodalBC includes _var (the variable this operates on)
    _aux_variable(coupledValue("aux_variable"))
{
}

Real
DirichletBCfromAux::computeQpResidual()
{
  return _u[_qp] - _aux_variable[_qp];
}

//
// switch (_bc_type)
// {
//   case DIRICHLET:
//     if (isNodal())
//     {
//       return _u[_qp] - _aux_variable[_qp]; // NodalBC::computeQpResidual();
//     }
//     else
//     {
//       mooseError("Dirichlet must be nodal");
//     }
//   case TRACTION:
//     // return 0;
//     if (!isNodal())
//     {
//       return _test[_i][_qp] * _aux_variable[_qp];
//     }
//     else
//     {
//       mooseError("Traction must be elemental");
//     }
//   default:
//     mooseError("bc_type is not one of the accepted parameters (dirichlet/traction)");
// }
// }
