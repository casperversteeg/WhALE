#include "ActionWarehouse.h"
#include "FluidStructureInterAction.h"

#include "libmesh/string_to_enum.h"
#include <algorithm>

// Register different tasks this action needs to perform
// registerMooseAction(appName, actionName, taskName)
registerMooseAction("whaleApp", FluidStructureInterAction, "meta_action");
// registerMooseAction("whaleApp", FluidStructureInterAction, "setup_mesh_complete");
// registerMooseAction("whaleApp", FluidStructureInterAction, "validate_coordinate_systems");
// registerMooseAction("whaleApp", FluidStructureInterAction, "add_variable");
// registerMooseAction("whaleApp", FluidStructureInterAction, "add_aux_variable");
// registerMooseAction("whaleApp", FluidStructureInterAction, "add_kernel");
// registerMooseAction("whaleApp", FluidStructureInterAction, "add_aux_kernel");
// registerMooseAction("whaleApp", FluidStructureInterAction, "add_material");

template <>
InputParameters
validParams<FluidStructureInterAction>()
{
  InputParameters params = validParams<Action>();
  params.addClassDescription("Set up fluid-structure interaction kernels");

  params.addParam<bool>("add_variables", "Add the velocity and pressure variables");
  params.addParam<bool>(
      "use_displaced_mesh", false, "Whether to use displaced mesh in the kernels");

  params.addParam<bool>("use_automatic_differentiation",
                        false,
                        "Flag to use automatic differentiation (AD) objects when possible");
  // params.addRequiredParam<std::vector<VariableName>>(
  //     "displacements", "The nonlinear displacement variables for the problem");

  return params;
}

FluidStructureInterAction::FluidStructureInterAction(const InputParameters & parameters)
  : Action(parameters), _use_ad(getParam<bool>("use_automatic_differentiation"))
{
}
