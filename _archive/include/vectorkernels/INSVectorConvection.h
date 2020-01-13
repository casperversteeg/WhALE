#pragma once

#include "INSVectorBase.h"
class INSVectorConvection;

template <>
InputParameters validParams<INSVectorConvection>();

class INSVectorConvection : public INSVectorBase
{
public:
  INSVectorConvection(const InputParameters & parameters);

private:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const VectorVariableValue & _mesh_dot;
  const VariableValue & _dmesh_dot;
  const unsigned int _mesh_var;
};
