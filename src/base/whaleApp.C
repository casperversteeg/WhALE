#include "whaleApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

template <>
InputParameters
validParams<whaleApp>()
{
  InputParameters params = validParams<MooseApp>();
  return params;
}

whaleApp::whaleApp(InputParameters parameters) : MooseApp(parameters)
{
  whaleApp::registerAll(_factory, _action_factory, _syntax);
}

whaleApp::~whaleApp() {}

void
whaleApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAll(f, af, s);
  Registry::registerObjectsTo(f, {"whaleApp"});
  Registry::registerActionsTo(af, {"whaleApp"});

  /* register custom execute flags, action syntax, etc. here */

  registerSyntax("FluidStructureInterAction", "FSI");
  registerSyntax("FSIFluidAction", "FSI/Fluid/*");
  registerSyntax("FSISolidAction", "FSI/Solid/*");
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
