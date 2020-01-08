#include "multiwhaleApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
multiwhaleApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  return params;
}

multiwhaleApp::multiwhaleApp(InputParameters parameters) : MooseApp(parameters)
{
  multiwhaleApp::registerAll(_factory, _action_factory, _syntax);
}

multiwhaleApp::~multiwhaleApp() {}

void
multiwhaleApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAll(f, af, s);
  Registry::registerObjectsTo(f, {"multiwhaleApp"});
  Registry::registerActionsTo(af, {"multiwhaleApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
multiwhaleApp::registerApps()
{
  registerApp(multiwhaleApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
multiwhaleApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  multiwhaleApp::registerAll(f, af, s);
}
extern "C" void
multiwhaleApp__registerApps()
{
  multiwhaleApp::registerApps();
}
