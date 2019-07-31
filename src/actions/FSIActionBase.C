#include "FSIActionBase.h"
// Want to be able to check if there are "parent" input-block parameters to absorb into any "child"
// input-blocks:
#include "CommonFSIAction.h"
// Get access to _mesh, _problem, and getAction() methods:
#include "ActionWarehouse.h"

template <>
InputParameters
validParams<FSIActionBase>()
{
  InputParameters params = validParams<Action>();
  // ***** As a base class for both the fluid and structure sub-blocks, this class needs to be
  // careful which parameters it allows, as ones applied to Navier-Stokes kernels do not necessarily
  // need to be applied to stress divergence kernels *****

  // Document class
  params.addClassDescription(
      "Base class that gathers inputs applied to both Fluid and Solid problem domains.");

  // ***** None of these parameters are required, but will be available to children of this class,
  // FSIFluidAction and FSISolidAction *****

  // Use transient formulation?
  params.addParam<bool>(
      "transient", false, "Whether to include transient (i.e. time derivative) kernels.");
  // Use displaced mesh across all kernels?
  params.addParam<bool>(
      "use_displaced_mesh", false, "Whether to use displaced mesh in the kernels.");
  // Add variables and forego [Variables] declaration block?
  params.addParam<bool>("add_variables", false, "Add the nonlinear variables.");

  // Create parameter enum that can be used to set the enum variable declared in the class
  MultiMooseEnum fsiFormulationType("ALE", "ALE", false);
  // Which type of FSI formulation dictates which kernels should be added
  params.addParam<MultiMooseEnum>(
      "FSI_formulation", fsiFormulationType, "What type of FSI formulation to use");
  params.addParamNamesToGroup("FSI_formulation", "Advanced");

  // ***** Output *****
  // params.addParam<MultiMooseEnum>("generate_output",
  //                                 /*some output types in MultiMooseEnum or something*/,
  //                                 "Add scalar quantity output for fluid stress, solid
  //                                 stress/strain");
  // params.addParamNamesToGroup("generate_output", "Output");

  // ***** AD not currently supported *****
  // params.addParam<bool>("use_automatic_differentiation",
  //                       false,
  //                       "Flag to use automatic differentiation (AD) objects when possible");

  return params;
}

// ***** Constructor for this base class *****
// Build "Action" class with constructor parameters for this class
FSIActionBase::FSIActionBase(const InputParameters & parameters)
  : Action(parameters),
    _fsi_formulation(getParam<MultiMooseEnum>("FSI_formulation")),
    _is_transient(getParam<bool>("transient")),
    _use_ad(false /*getParam<bool>("use_automatic_differentiation")*/)
{
  // ***** This class is the foundation for FSIFluid and FSISolid classes, which ought to be nested
  // in a [FSI] block, which itself may contain parameter settings. These settings in the [FSI]
  // block, but NOT in the [Fluid] or [Solid] blocks, will be added to the [Fluid] and [Solid]
  // blocks, overriding whatever settings were defined therein. *****

  // Get parameters in "CommonFSIAction" kernels, which are by default the kernels built for [FSI]
  // blocks. _awh.getActions() are from ActionWarehouse.h
  auto parent_action = _awh.getActions<CommonFSIAction>();
  // If such a class was built, the parameters defined in that class will overwrite the parameters
  // in this class, which are defined in _pars in the Action.h class
  if (parent_action.size() > 0)
  {
    _pars.applyParameters(parent_action[0]->parameters());
  }

  // Need to make sure that the transient formulation is consistent between all sub-blocks. Throw an
  // error if the _is_transient variable does not match between actions
  auto other_FSI_actions = _awh.getActions<FSIActionBase>();
  for (const auto & action : other_FSI_actions)
  {
    mooseAssert(_is_transient == action->_is_transient,
                "Inconsistent transient formulation between " + name() + " and " + action->name());
  }
  // the generate_output parameter can be amended with additional_generate_output from any child
  // classes. Can do that here.
  // if (isParamValid("additional_generate_output"))
  // {
  //   // Get both generate_output and additional_generate_output, and push_back all
  //   // additional_generate_output members to generate_output
  //   MultiMooseEnum generate_output = getParam<MultiMooseEnum>("generate_output");
  //
  //   // ...
  // }
}
