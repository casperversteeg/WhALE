//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "INSALEMomentumBase.h"

// Forward Declarations
class INSALEMomentumConvection;

template <>
InputParameters validParams<INSALEMomentumConvection>();

class INSALEMomentumConvection : public INSALEMomentumBase
{
public:
  // Constructor
  INSALEMomentumConvection(const InputParameters & parameters);
  // Destructor
  virtual ~INSALEMomentumConvection() {}

protected:
  // Overriding the convection term calculations for ALE
  virtual RealVectorValue convectiveTerm() override;
  virtual RealVectorValue dConvecDUComp(unsigned comp) override;

  // Computing residuals and Jacobian terms
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned jvar) override;

  // Necessary to make the compiler stop yelling
  virtual Real computeQpResidualViscousPart() { return 0; };
  virtual Real computeQpJacobianViscousPart() { return 0; };
  virtual Real computeQpOffDiagJacobianViscousPart(unsigned jvar) { return 0; };

  // Setting stabilized upwind Petrov-Galerkin stabilization
  const bool & _supg;
  virtual Real computeQpPGResidual();
  virtual Real computeQpPGJacobian(unsigned comp);

  // Mesh velocity variables
  const VariableValue & _u_mesh;
  const VariableValue & _v_mesh;
  const VariableValue & _w_mesh;
};
