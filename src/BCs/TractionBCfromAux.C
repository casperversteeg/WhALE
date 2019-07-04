#include "TractionBCfromAux.h"

registerMooseObject("whaleApp", TractionBCfromAux);

template <>
InputParameters
validParams<TractionBCfromAux>()
{
  InputParameters params = validParams<IntegratedBC>(); // include parent class name
  params.addRequiredCoupledVar("aux_variable",
                               "Auxiliary variable that this boundary should enforce");
  // params.addParam<MooseEnum>("bc_type",
  //                            TractionBCfromAux::bcTypes(),
  //                            "Which type of boundary is this (Traction [default] or traction)");
  // params.suppressParameter("is_nodal");
  return params;
}

TractionBCfromAux::TractionBCfromAux(const InputParameters & parameters)
  : IntegratedBC(parameters), // NodalBC includes _var (the variable this operates on)
    _aux_variable(coupledValue("aux_variable"))
// _bc_type(NodalBC::getParam<MooseEnum>("bc_type"))
{
}

Real
TractionBCfromAux::computeQpResidual()
{
  return -_test[_i][_qp] * _aux_variable[_qp];
}
