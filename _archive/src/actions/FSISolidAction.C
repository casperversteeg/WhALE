#include "Conversion.h"
#include "FEProblem.h"
#include "Factory.h"
#include "MooseMesh.h"
#include "MooseObjectAction.h"
#include "FSISolidAction.h"

#include "libmesh/string_to_enum.h"
#include <algorithm>

// ***** Register different tasks this action needs to perform *****
// registerMooseAction(appName, actionName, taskName)

registerMooseAction("whaleApp", FSISolidAction, "meta_action");
registerMooseAction("whaleApp", FSISolidAction, "get_blocks_from_mesh");
registerMooseAction("whaleApp", FSISolidAction, "apply_var_to_blocks");
// registerMooseAction("whaleApp", FSISolidAction, "add_variable");
registerMooseAction("whaleApp", FSISolidAction, "add_aux_variable");
registerMooseAction("whaleApp", FSISolidAction, "add_kernel");
// registerMooseAction("whaleApp", FSISolidAction, "add_aux_kernel");
// registerMooseAction("whaleApp", FSISolidAction, "add_material");

template <>
InputParameters
validParams<FSISolidAction>()
{
  // ***** This is a child class that builds the Navier-Stokes kernels required for the FSI problem.
  // It will require the normal inputs for NS kernels, such as velocities, and pressure. Further,
  // because FSI are composite problems, the domain to which these kernels should be applied will
  // also be required. THIS MAY CHANGE AS IMMERSED METHODS ARE IMPLEMENTED *****
  // parameters specified here only appear in the input file sub-blocks of the
  // FSI master action, not in the common parameters area
  InputParameters params = validParams<FSIActionBase>();

  // Document class
  params.addClassDescription("Sets up solid domain kernels for FSI problem");

  // ***** Required parameters for this class *****
  // velocity variable names
  params.addRequiredParam<std::vector<VariableName>>(
      "displacements", "The nonlinear displacement variables for the problem");
  // subdomain blocks these kernels and variables should be applied to
  params.addRequiredParam<std::vector<SubdomainName>>("block",
                                                      "The list of ids of the blocks (subdomain) "
                                                      "that should be designated as solid domain");

  // ***** Optional parameters *****
  MooseEnum strainType("SMALL FINITE", "SMALL");
  params.addParam<MooseEnum>("strain", strainType, "Strain formulation");
  params.addParam<Real>("beta", "beta parameter for Newmark Time integration");
  params.addParam<Real>("gamma", "gamma parameter for Newmark Time integration");

  // ***** Output *****
  // params.addParam<MultiMooseEnum>("additional_generate_output",
  //                                 /*some output types in MultiMooseEnum or something*/,
  //                                 "Add scalar quantity output for solid stress (will be "
  //                                 "appended to the list in `generate_output`)");
  // params.addParamNamesToGroup("additional_generate_output", "Output");
  return params;
}

// ***** Constructor for this child class *****
// Build "FSIActionBase" base class with constructor parameters for this class
FSISolidAction::FSISolidAction(const InputParameters & params)
  : FSIActionBase(params),
    // Parameters specific to this class and only in the [Solid] block
    _displacements(getParam<std::vector<VariableName>>("displacements")),
    _ndisp(_displacements.size()),
    _velocities(_ndisp),
    _accelerations(_ndisp),
    _subdomain_names(getParam<std::vector<SubdomainName>>("block")),
    _subdomain_ids(),
    _strain(getParam<MooseEnum>("strain").getEnum<Strain>()),
    _beta(),
    _gamma(),
    // Parameters defined in the parent class that should be set in this one
    // _fsi_formulation(getParam<MooseEnum>("fsi_formulation").getEnum<FSIFormulation>()),
    _use_displaced_mesh(getParam<bool>("use_displaced_mesh"))
{
  if (_is_transient)
  {
    if (!isParamValid("beta") && !isParamValid("gamma"))
    {
      return;
    }
    else if (isParamValid("beta") && isParamValid("gamma"))
    {
      std::vector<std::string> comps = {"x", "y", "z"};
      for (unsigned int i = 0; i < _ndisp; ++i)
      {
        // generate VariableName (basically a std::string alias) for vel and accel aux
        _velocities[i] = "vel_" + comps[i];
        _accelerations[i] = "accel_" + comps[i];
      }
    }
    else
      mooseError("For transient problems, either set both or neither beta and gamma.");
  }
}

void
FSISolidAction::act()
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

  // ***** begin with building a regular TensorMechanicsAction *****
  if (_current_task == "meta_action")
  {
    const std::string type = "TensorMechanicsAction";
    auto action_params = _action_factory.getValidParams(type);
    action_params.set<bool>("_built_by_moose") = true;
    action_params.set<std::string>("registered_identifier") = "(AutoBuilt)";
    action_params.applyParameters(parameters(), {"use_displaced_mesh"});
    action_params.set<bool>("use_displaced_mesh") = _use_displaced_mesh;
    auto action = MooseSharedNamespace::static_pointer_cast<MooseObjectAction>(
        _action_factory.create(type, name() + "_TM", action_params));
    _awh.addActionBlock(action);
  }

  // ***** If the problem is static, creating the TensorMechanicsAction is sufficient. Only need to
  // do the rest of this if the problem is transient *****
  else if (_is_transient)
  {
    // ***** If the formulation is transient, will need to create the respective vel_ and accel_
    // auxiliary variables for Newmark time-integration *****
    if (_current_task == "add_aux_variable")
    {
      // determine necessary order
      const bool second = _problem->mesh().hasSecondOrderElements();
      // declare these up front since they can be used for creating all aux below
      FEType elem_type(Utility::string_to_enum<Order>(second ? "SECOND" : "FIRST"),
                       Utility::string_to_enum<FEFamily>("LAGRANGE"));
      std::set<SubdomainID> * gimme_blocks =
          _subdomain_id_union.empty() ? nullptr : &_subdomain_id_union;
      // Loop through the displacement variables
      for (unsigned int i = 0; i < _ndisp; ++i)
      {
        // Create velocity variables
        _problem->addAuxVariable(_velocities[i], elem_type, gimme_blocks);
        // Create acceleration variables
        _problem->addAuxVariable(_accelerations[i], elem_type, gimme_blocks);
      }
    }

    // ***** All variables should now be created, so only have to create the u,tt kernels, and the
    // Newmark[]Aux *****
    else if (_current_task == "add_kernel")
    {
      for (unsigned int i = 0; i < _ndisp; ++i)
      {
        // Get valid parameters for InertialForce
        InputParameters params = _factory.getValidParams("InertialForce");
        params.applyParameters(parameters(), {"use_displaced_mesh"});
        params.set<bool>("use_displaced_mesh") = _use_displaced_mesh;
        // for each displacement component, add an InertialForce kernel
        std::string kernel_name = "FSISolidTransient_" + name() + Moose::stringify(i);
        // set InertialForce primary variable, along with velocity, acceleration and parameters
        params.set<NonlinearVariableName>("variable") = _displacements[i];
        params.set<std::vector<VariableName>>("velocity") = {_velocities[i]};
        params.set<std::vector<VariableName>>("acceleration") = {_accelerations[i]};

        // if we're using AD, will need to change how we add the kernel, but not currently doing
        // that, so hurray
        _problem->addKernel("InertialForce", kernel_name, params);

        // this might be sloppy, but will just apply the parameters from InertialForce to both the
        // NewmarkVelAux and NewmarkAccelAux since most of them will match
        InputParameters vel_params = _factory.getValidParams("NewmarkVelAux");
        vel_params.applyParameters(params, {"variable"});
        vel_params.set<AuxVariableName>("variable") = _velocities[i];
        _problem->addAuxKernel("NewmarkVelAux", "vel_" + kernel_name, vel_params);
        InputParameters acc_params = _factory.getValidParams("NewmarkAccelAux");
        acc_params.applyParameters(params, {"variable"});
        acc_params.set<AuxVariableName>("variable") = _accelerations[i];
        acc_params.set<std::vector<VariableName>>("displacement") = {_displacements[i]};
        _problem->addAuxKernel("NewmarkAccelAux", "accel_" + kernel_name, acc_params);
      }
    }
  }
}

void
FSISolidAction::checkBlocks()
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
FSISolidAction::checkSubdomainAndVariableConsistency()
{
  //
  // Gather info about all other fluid actions when we add variables
  //
  if (_current_task == "apply_var_to_blocks" && getParam<bool>("add_variables"))
  {
    auto other_FSIsolid_actions = _awh.getActions<FSISolidAction>();
    for (const auto & action : other_FSIsolid_actions)
    {
      const auto size_before = _subdomain_id_union.size();
      const auto added_size = action->_subdomain_ids.size();
      _subdomain_id_union.insert(action->_subdomain_ids.begin(), action->_subdomain_ids.end());
      const auto size_after = _subdomain_id_union.size();

      if (size_after != size_before + added_size)
        mooseError("Found overlapping solid blocks in FSI/Solid action. Blocks must not overlap.");

      if (added_size == 0 && other_FSIsolid_actions.size() > 1)
        mooseError(
            "If more than one solid action is defined, all must be restricted by mesh block.");
    }
  }
}
