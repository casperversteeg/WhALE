#pragma once

// #include "NodalBC.h"
#include "IntegratedBC.h"
#include "MooseEnum.h"

// Forward Declarations
class BCfromAux;

template <>
InputParameters validParams<BCfromAux>();

// This class ports a boundary condition from an auxiliary variable, used in
// multiapp transfers with interpolation

class BCfromAux : public IntegratedBC
{
public:
  // Constructor
  BCfromAux(const InputParameters & parameters);
  // Destructor
  virtual ~BCfromAux() {}

  // Makes boundary type options
  enum BCTYPE
  {
    DIRICHLET,
    TRACTION
  };

  /// Used to construct InputParameters
  static MooseEnum bcTypes() { return MooseEnum("dirichlet traction", "dirichlet"); }

  /// The direction this Transfer is going in
  int bcType() { return _bc_type; }

protected:
  // Override residual computation
  virtual Real computeQpResidual() override;
  // The variable that couples into this boundary condition
  const VariableValue & _aux_variable;
  const MooseEnum _bc_type;
};
