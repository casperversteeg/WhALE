#include "Conversion.h"
#include "FEProblem.h"
#include "Factory.h"
#include "MooseMesh.h"
#include "MooseObjectAction.h"
#include "FluidStructureInterAction.h"

#include "libmesh/string_to_enum.h"
#include <algorithm>

// Register different tasks this action needs to perform
// registerMooseAction(appName, actionName, taskName)
// registerMooseAction("whaleApp", FluidStructureInterAction, "meta_action");
// registerMooseAction("whaleApp", FluidStructureInterAction, "setup_mesh_complete");
// registerMooseAction("whaleApp", FluidStructureInterAction, "validate_coordinate_systems");
registerMooseAction("whaleApp", FluidStructureInterAction, "add_variable");
// registerMooseAction("whaleApp", FluidStructureInterAction, "add_aux_variable");
registerMooseAction("whaleApp", FluidStructureInterAction, "add_kernel");
// registerMooseAction("whaleApp", FluidStructureInterAction, "add_aux_kernel");
// registerMooseAction("whaleApp", FluidStructureInterAction, "add_material");

template <>
InputParameters
validParams<FluidStructureInterAction>()
{
  InputParameters params = validParams<FluidStructureInterActionBase>();
  params.addClassDescription("Set up fluid-structure interaction kernels");
  params.addRequiredParam<std::vector<VariableName>>(
      "displacements", "The nonlinear displacement variables for the problem");

  // parameters specified here only appear in the input file sub-blocks of the
  // Master action, not in the common parameters area
  params.addRequiredParam<std::vector<SubdomainName>>("fluid",
                                                      "The list of ids of the blocks (subdomain) "
                                                      "that should be designated as fluid domain");
  // params.addParamNamesToGroup("fluid", "");
  return params;
}
