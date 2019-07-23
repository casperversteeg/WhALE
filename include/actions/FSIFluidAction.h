#pragma once

#include "Action.h"

class FluidStructureInterAction;

template <>
InputParameters validParams<FluidStructureInterAction>();

class FluidStructureInterAction : public Action
{
public:
  FluidStructureInterAction(const InputParameters & params);

  virtual void act();

protected:
  std::vector<VariableName> _velocities;
  VariableName _pressure;

  const bool _compressible;

  bool _use_displaced_mesh;
};
