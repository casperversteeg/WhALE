#pragma once

#include "IntegratedBC.h"

// Forward Declarations
class TractionBCfromAux;

template <>
InputParameters validParams<TractionBCfromAux>();

// This class ports a boundary condition from an auxiliary variable, used in
// multiapp transfers with interpolation

class TractionBCfromAux : public IntegratedBC
{
public:
  // Constructor
  TractionBCfromAux(const InputParameters & parameters);
  // Destructor

protected:
  // Override residual computation
  virtual Real computeQpResidual() override;
  // The variable that couples into this boundary condition
  const VariableValue & _traction;
};
