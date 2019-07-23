#pragma once

#include "Action.h"

class FluidStructureInterAction;

template <>
InputParameters validParams<FluidStructureInterAction>();

class FluidStructureInterAction : public Action
{
public:
  FluidStructureInterAction(const InputParameters & params);

  virtual void act() override{};

protected:
  const bool _use_ad;
};
