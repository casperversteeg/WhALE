#include "whaleApp.h"
#include "Moose.h"
#include "AppFactory.h"
// #include "ActionFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

template <>
InputParameters
validParams<whaleApp>()
{
  InputParameters params = validParams<MooseApp>();
  // params.set<bool>("automatic_automatic_scaling") = false;
  return params;
}

whaleApp::whaleApp(InputParameters parameters) : MooseApp(parameters)
{
  whaleApp::registerAll(_factory, _action_factory, _syntax);
}

whaleApp::~whaleApp() {}

static void
associateSyntaxInner(Syntax & syntax, ActionFactory & /*action_factory*/)
{
  /* register custom execute flags, action syntax, etc. here */

  registerSyntax("EmptyAction", "FSI");
  registerSyntax("CommonFSIAction", "FSI/*");

  registerSyntax("EmptyAction", "FSI/Fluid");
  registerSyntax("FSIFluidAction", "FSI/Fluid/*");

  registerSyntax("EmptyAction", "FSI/Solid");
  registerSyntax("FSISolidAction", "FSI/Solid/*");

  registerTask("get_blocks_from_mesh", /*is_required=*/false);
  registerTask("apply_var_to_blocks", /*is_required=*/false);
  addTaskDependency("apply_var_to_blocks", "create_problem_complete");
}

void
whaleApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAll(f, af, s);
  Registry::registerObjectsTo(f, {"whaleApp"});
  Registry::registerActionsTo(af, {"whaleApp"});
  associateSyntaxInner(s, af);
}

void
whaleApp::registerApps()
{
  registerApp(whaleApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
whaleApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  whaleApp::registerAll(f, af, s);
}
extern "C" void
whaleApp__registerApps()
{
  whaleApp::registerApps();
}
