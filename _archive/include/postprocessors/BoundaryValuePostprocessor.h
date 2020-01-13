#pragma once

// #include "NodalBC.h"
#include "SidePostprocessor.h"

// Forward Declarations
class BoundaryValuePostprocessor;

template <>
InputParameters validParams<BoundaryValuePostprocessor>();

// This class ports a boundary condition from an auxiliary variable, used in
// multiapp transfers with interpolation

class BoundaryValuePostprocessor : public SidePostprocessor
{
public:
  // Constructor
  BoundaryValuePostprocessor(const InputParameters & parameters);
  // Destructor
  virtual ~BoundaryValuePostprocessor() {}

  // Postprocessor operation
  virtual void initialize() override;
  virtual void execute() override;
  virtual Real getValue() override;
  virtual void threadJoin(const UserObject & y) override;

protected:
  unsigned int _qp;
  const VariableValue & _u;
};
