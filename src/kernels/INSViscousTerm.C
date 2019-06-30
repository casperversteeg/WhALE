#include "INSViscousTerm.h"

registerMooseObject("whaleApp", INSViscousTerm);

template <>
InputParameters
validParams<>()
{

  return params;
}
