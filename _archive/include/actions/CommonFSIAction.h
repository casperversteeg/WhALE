#pragma once

#include "Action.h"

// read "base class":
class CommonFSIAction;

template <>
InputParameters validParams<CommonFSIAction>();

class CommonFSIAction : public Action
{
public:
  CommonFSIAction(const InputParameters & params);

  virtual void act() override{};
};
