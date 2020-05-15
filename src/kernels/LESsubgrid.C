//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "LESsubgrid.h"

registerMooseObject("whaleApp", LESsubgrid);

template <>
InputParameters
validParams<LESsubgrid>()
{
  InputParameters params = validParams<INSMomentumBase>();
  params.addClassDescription("Adds a subgrid-scale eddy-viscosity for LES");
  params.addParam<MaterialPropertyName>(
      "mu_sgs_name", "mu_sgs", "The name of the subgrid scale turbulent viscosity");
  return params;
}

LESsubgrid::LESsubgrid(const InputParameters & parameters)
  : INSMomentumBase(parameters),
    // : DerivativeMaterialInterface<JvarMapKernelInterface<INSMomentumBase>>(parameters),
    _mu_sgs(getMaterialProperty<Real>("mu_sgs_name")),
    _dmu_dvel(_coupled_moose_vars.size())
{
  // for (unsigned i = 0; i < _coupled_moose_vars.size(); ++i)
  // {
  //   _dmu_dvel[i] =
  //       &getMaterialPropertyDerivative<Real>("mu_sgs_name", _coupled_moose_vars[i]->name());
  // }
}

Real
LESsubgrid::computeQpResidualViscousPart()
{
  // Simplified version: mu * Laplacian(u_component)
  return (_mu[_qp] + _mu_sgs[_qp]) * (_grad_u[_qp] * _grad_test[_i][_qp]);
}

Real
LESsubgrid::computeQpJacobianViscousPart()
{
  // Viscous part, Laplacian version
  return (_mu[_qp] + _mu_sgs[_qp]) * (_grad_phi[_j][_qp] * _grad_test[_i][_qp]);
}

Real
LESsubgrid::computeQpOffDiagJacobianViscousPart(unsigned jvar)
{
  if (jvar == _p_var_number)
    return 0;

  // const unsigned int cvar = mapJvarToCvar(jvar);
  return 0; //(*_dmu_dvel[_j])[_qp] * _grad_test[_i][_qp];
}
