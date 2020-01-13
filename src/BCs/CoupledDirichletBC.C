#include "CoupledDirichletBC.h"

registerMooseObject("whaleApp", CoupledDirichletBC);

template <>
InputParameters
validParams<CoupledDirichletBC>()
{
  InputParameters params = validParams<PresetNodalBC>();
  params.addRequiredCoupledVar("v", "coupled variable");
  return params;
}

CoupledDirichletBC::CoupledDirichletBC(const InputParameters & parameters)
  : PresetNodalBC(parameters), _v(coupledValue("v"))
{
}

Real
CoupledDirichletBC::computeQpValue()
{
  return _v[_qp];
}
