#include "Conversion.h"
#include "FEProblem.h"
#include "Factory.h"
#include "MooseMesh.h"
#include "MooseObjectAction.h"
#include "FSIFluidAction.h"

#include "libmesh/string_to_enum.h"
#include <algorithm>

// ***** Register different tasks this action needs to perform *****
// registerMooseAction(appName, actionName, taskName)

// registerMooseAction("whaleApp", FSIFluidAction, "meta_action");
registerMooseAction("whaleApp", FSIFluidAction, "get_blocks_from_mesh");
registerMooseAction("whaleApp", FSIFluidAction, "apply_var_to_blocks");
registerMooseAction("whaleApp", FSIFluidAction, "add_variable");
// registerMooseAction("whaleApp", FSIFluidAction, "add_aux_variable");
registerMooseAction("whaleApp", FSIFluidAction, "add_kernel");
// registerMooseAction("whaleApp", FSIFluidAction, "add_aux_kernel");
// registerMooseAction("whaleApp", FSIFluidAction, "add_material");

template <>
InputParameters
validParams<FSIFluidAction>()
{
  // ***** This is a child class that builds the Navier-Stokes kernels required for the FSI problem.
  // It will require the normal inputs for NS kernels, such as velocities, and pressure. Further,
  // because FSI are composite problems, the domain to which these kernels should be applied will
  // also be required. THIS MAY CHANGE AS IMMERSED METHODS ARE IMPLEMENTED *****
  // parameters specified here only appear in the input file sub-blocks of the
  // FSI master action, not in the common parameters area
  InputParameters params = validParams<FSIActionBase>();

  // Document class
  params.addClassDescription("Sets up fluid domain kernels for FSI problem");

  // ***** Required parameters for this class *****
  // velocity variable names
  params.addRequiredParam<std::vector<VariableName>>(
      "velocities", "The nonlinear velocity variables for the problem");
  // pressure variable name
  params.addRequiredParam<VariableName>("pressure", "The nonlinear pressure variable name");
  // subdomain blocks these kernels and variables should be applied to
  params.addRequiredParam<std::vector<SubdomainName>>("block",
                                                      "The list of ids of the blocks (subdomain) "
                                                      "that should be designated as fluid domain");

  // ***** Output *****
  // params.addParam<MultiMooseEnum>("additional_generate_output",
  //                                 /*some output types in MultiMooseEnum or something*/,
  //                                 "Add scalar quantity output for fluid stress (will be "
  //                                 "appended to the list in `generate_output`)");
  // params.addParamNamesToGroup("additional_generate_output", "Output");
  return params;
}

// ***** Constructor for this child class *****
// Build "FSIActionBase" base class with constructor parameters for this class
FSIFluidAction::FSIFluidAction(const InputParameters & params)
  : FSIActionBase(params),
    // Parameters specific to this class and only in the [Fluid] block
    _velocities(getParam<std::vector<VariableName>>("velocities")),
    _nvel(_velocities.size()),
    _pressure(getParam<VariableName>("pressure")),
    _subdomain_names(getParam<std::vector<SubdomainName>>("block")),
    _subdomain_ids(),
    // Parameters defined in the parent class that should be set in this one
    _use_displaced_mesh(getParam<bool>("use_displaced_mesh"))
{
}

void
FSIFluidAction::act()
{
  // Some stuff about automatic differentiation (not currently supported)
  std::string ad_prepend = "";
  std::string ad_append = "";
  if (_use_ad)
  {
    ad_prepend = "AD";
    ad_append = "<RESIDUAL>";
  }

  // Check whether subdomains exist and assemble the _subdomain_ids
  checkBlocks();
  // Check whether subdomains overlap, and there are no unrestricted blocks
  checkSubdomainAndVariableConsistency();

  // ***** act() is called for every task declared with registerMooseAction(), find
  // what task we're doing now and do it *****

  // ***** add Variables before adding kernels *****
  if (_current_task == "add_variable" && getParam<bool>("add_variables"))
  {
    // Mesh should be appropriate for fluid problem
    const bool mesh_has_second_order_elements = _problem->mesh().hasSecondOrderElements();
    if (!mesh_has_second_order_elements)
    { // Can remove this if PSPG is enabled
      mooseError("Fluid mesh must have at least second order elements for velocity field");
    }
    for (const auto & vel : _velocities)
    {
      // create velocity variables:
      // _problem->addVariable(string & var_name, FEType & type, Real scale_factor, set<subdomainid>
      // * active_subdomains)
      _problem->addVariable(vel,
                            FEType(Utility::string_to_enum<Order>("SECOND"),
                                   Utility::string_to_enum<FEFamily>("LAGRANGE")),
                            1.0,
                            _subdomain_id_union.empty() ? nullptr : &_subdomain_id_union);
    }
    // create pressure variable
    _problem->addVariable(_pressure,
                          FEType(Utility::string_to_enum<Order>("FIRST"),
                                 Utility::string_to_enum<FEFamily>("LAGRANGE")),
                          1.0,
                          _subdomain_id_union.empty() ? nullptr : &_subdomain_id_union);
  }

  // ***** Add appropriate Navier-Stokes kernels *****
  else if (_current_task == "add_kernel")
  {
    // Get valid parameters for a Navier-Stokes kernel of this type
    InputParameters params = _factory.getValidParams("INSMomentumTractionForm");
    // From the parameters set in this Action, set all the ones that are common between them, with
    // the exception of whatever is in the second argument
    params.applyParameters(parameters(), {"u", "v", /*"w",*/ "p", "use_displaced_mesh"});
    // Set parameters for Navier-Stokes kernel, where inputs should be vectors
    params.set<std::vector<VariableName>>("u") = {_velocities[0]};
    params.set<std::vector<VariableName>>("v") = {_velocities[1]};
    // params.set<VariableName>("w") = _velocities[0];
    params.set<std::vector<VariableName>>("p") = {_pressure};
    params.set<bool>("use_displaced_mesh") = _use_displaced_mesh;

    for (unsigned int i = 0; i < _nvel; ++i)
    {
      // for each velocity component, add an INSMomentumTractionForm kernel
      std::string kernel_name = "FSIFluid_" + name() + Moose::stringify(i);
      // INSMomentumTractionForm must have a primary variable with associated component
      params.set<unsigned int>("component") = i;
      params.set<NonlinearVariableName>("variable") = _velocities[i];

      // if we're using AD, will need to change how we add the kernel, but not currently doing that,
      // so hurray
      _problem->addKernel("INSMomentumTractionForm", kernel_name, params);
    }

    InputParameters params_p = _factory.getValidParams("INSMass");
    params_p.applyParameters(parameters(), {"u", "v", /*"w",*/ "p", "use_displaced_mesh"});
    params_p.set<NonlinearVariableName>("variable") = _pressure;
    params_p.set<std::vector<VariableName>>("u") = {_velocities[0]};
    params_p.set<std::vector<VariableName>>("v") = {_velocities[1]};
    // params.set<VariableName>("w") = _velocities[0];
    params_p.set<std::vector<VariableName>>("p") = {_pressure};
    params_p.set<bool>("use_displaced_mesh") = _use_displaced_mesh;

    _problem->addKernel("INSMass", "FSIFluid_Mass", params_p);
  }
}

void
FSIFluidAction::checkBlocks()
{
  //
  // Do the coordinate system check only once the problem is created
  //
  if (_current_task == "get_blocks_from_mesh")
  {
    // get subdomain IDs
    for (auto & name : _subdomain_names)
      _subdomain_ids.insert(_mesh->getSubdomainID(name));
  }

  if (_current_task == "apply_var_to_blocks")
  {
    // NEED TO CHANGE THIS IN CONTEXT OF BLOCKS BEING A REQUIRED PARAMETER
    // checking if any "block = " lines are defined. If yes, only apply this action to those blocks.
    // If no, apply this action to all blocks in the mesh
    const auto & check_subdomains =
        _subdomain_ids.empty() ? _problem->mesh().meshSubdomains() : _subdomain_ids;
    if (check_subdomains.empty())
      mooseError("No blocks (subdomains) found");

    // Check consistency of coordinate system (todo)
  }
}

void
FSIFluidAction::checkSubdomainAndVariableConsistency()
{
  //
  // Gather info about all other master actions when we add variables
  //
  if (_current_task == "apply_var_to_blocks" && getParam<bool>("add_variables"))
  {
    auto other_FSIfluid_actions = _awh.getActions<FSIFluidAction>();
    for (const auto & action : other_FSIfluid_actions)
    {
      const auto size_before = _subdomain_id_union.size();
      const auto added_size = action->_subdomain_ids.size();
      _subdomain_id_union.insert(action->_subdomain_ids.begin(), action->_subdomain_ids.end());
      const auto size_after = _subdomain_id_union.size();

      if (size_after != size_before + added_size)
        mooseError("Found overlapping fluid blocks in FSI/Fluid action. Blocks must not overlap.");

      if (added_size == 0 && other_FSIfluid_actions.size() > 1)
        mooseError(
            "If more than one fluid domain is defined, they must be restricted by mesh block.");
    }
  }
}

// InputParameters
// TensorMechanicsAction::getKernelParameters(std::string type)
// {
//   InputParameters params = _factory.getValidParams(type);
//   params.applyParameters(parameters(),
//                          {"displacements", "use_displaced_mesh", "save_in", "diag_save_in"});
//
//   params.set<std::vector<VariableName>>("displacements") = _coupled_displacements;
//   params.set<bool>("use_displaced_mesh") = _use_displaced_mesh;
//
//   return params;
// }
