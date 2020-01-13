#include "CommonFSIAction.h"
#include "FSIActionBase.h"

registerMooseAction("whaleApp", CommonFSIAction, "meta_action");

template <>
InputParameters
validParams<CommonFSIAction>()
{
  InputParameters params = validParams<FSIActionBase>();
  return params;
}

CommonFSIAction::CommonFSIAction(const InputParameters & parameters) : Action(parameters) {}
