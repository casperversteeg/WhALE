#pragma once

#include "Assembly.h"
#include "NodalBC.h"
// #include "MooseEnum.h"

// Forward Declarations
class DirichletBCfromAux;

template <>
InputParameters validParams<DirichletBCfromAux>();

// This class ports a boundary condition from an auxiliary variable, used in
// multiapp transfers with interpolation

class DirichletBCfromAux : public NodalBC
{
public:
  // Constructor
  DirichletBCfromAux(const InputParameters & parameters);
  // Destructor
  virtual ~DirichletBCfromAux() {}

  // // Makes boundary type options
  // enum BCTYPE
  // {
  //   DIRICHLET,
  //   TRACTION
  // };
  //
  // /// Used to construct InputParameters
  // static MooseEnum bcTypes() { return MooseEnum("dirichlet traction", "dirichlet"); }
  //
  // /// The direction this Transfer is going in
  // int bcType() { return _bc_type; }

protected:
  // Override residual computation
  virtual Real computeQpResidual() override;
  // The variable that couples into this boundary condition
  const VariableValue & _aux_variable;
  // const MooseEnum _bc_type;

  // // shape functions
  //
  // /// shape function values (in QPs)
  // const VariablePhiValue & _phi;
  // /// gradients of shape functions (in QPs)
  // const VariablePhiGradient & _grad_phi;
  //
  // // test functions
  //
  // /// test function values (in QPs)
  // const VariableTestValue & _test;
  // /// gradients of test functions  (in QPs)
  // const VariableTestGradient & _grad_test;
  //
  // unsigned int _i, _j;
};
