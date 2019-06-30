#include "INSConvectionTerm.h"

registerMooseObject("whaleApp", INSConvectionTerm);

template <>
InputParameters
validParams<>()
{

  return params;
}
