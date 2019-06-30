#include "INSBodyForceTerm.h"

registerMooseObject("whaleApp", INSBodyForceTerm);

template <>
InputParameters
validParams<>()
{

  return params;
}
