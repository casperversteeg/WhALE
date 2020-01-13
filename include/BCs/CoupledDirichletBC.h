#ifndef CoupledDirichletBC_H
#define CoupledDirichletBC_H

#include "PresetNodalBC.h"

class CoupledDirichletBC;

template <>
InputParameters validParams<CoupledDirichletBC>();

class CoupledDirichletBC : public PresetNodalBC
{
public:
  CoupledDirichletBC(const InputParameters & parameters);

protected:
  virtual Real computeQpValue() override;

  const VariableValue & _v;
};

#endif // CoupledDirichletBC_H
