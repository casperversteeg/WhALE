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

  // ***** Optional parameters *****
  // params.addParam<bool>(
  //     "compressible",
  //     false,
  //     "Whether to use compressible kernels for Navier-Stokes problem. Default is
  //     incompressible.");

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
    // _compressible(getParam<bool>("compressible")),
    // Parameters defined in the parent class that should be set in this one
    // _fsi_formulation(getParam<MooseEnum>("fsi_formulation").getEnum<FSIFormulation>()),
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
    for (unsigned int i = 0; i < _nvel; ++i)
    {
      // Get valid parameters for a Navier-Stokes kernel of this type
      auto params = getKernelParameters("INSMomentumTractionForm");
      // for each velocity component, add an INSMomentumTractionForm kernel
      std::string kernel_name = "FSIFluid_" + name() + Moose::stringify(i);
      // INSMomentumTractionForm must have a primary variable with associated component
      params.set<unsigned int>("component") = i;
      params.set<NonlinearVariableName>("variable") = _velocities[i];

      // if we're using AD, will need to change how we add the kernel, but not currently doing that,
      // so hurray
      _problem->addKernel("INSMomentumTractionForm", kernel_name, params);

      // If the problem is transient, also add the respective TimeDerivative terms:
      if (_is_transient)
      {
        auto params_t = getKernelParameters("INSMomentumTimeDerivative");
        params_t.set<NonlinearVariableName>("variable") = _velocities[i];
        kernel_name = "FSIFluid_" + name() + "_unsteady_" + Moose::stringify(i);
        _problem->addKernel("INSMomentumTimeDerivative", kernel_name, params_t);
      }
    }
    auto params_p = getKernelParameters("INSMass");
    params_p.set<NonlinearVariableName>("variable") = _pressure;
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
  // Gather info about all other fluid actions when we add variables
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
            "If more than one fluid action is defined, all must be restricted by mesh block.");
    }
  }
}

InputParameters
FSIFluidAction::getKernelParameters(std::string type)
{
  InputParameters params = _factory.getValidParams(type);
  params.applyParameters(parameters(), {"use_displaced_mesh"});
  params.set<bool>("use_displaced_mesh") = _use_displaced_mesh;
  if (type != "INSMomentumTimeDerivative")
  {
    std::vector<std::string> v_comp = {"u", "v", "w"};

    for (unsigned i = 0; i < _nvel; ++i)
    {
      params.set<std::vector<VariableName>>(v_comp[i]) = {_velocities[i]};
    }
    params.set<std::vector<VariableName>>("p") = {_pressure};
  }
  return params;
}
