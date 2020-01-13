#pragma once

#include "INSVectorBase.h"
class INSVectorTimeDerivative;

template <>
InputParameters validParams<INSVectorTimeDerivative>();

class INSVectorTimeDerivative : public INSVectorBase
{
public:
  INSVectorTimeDerivative(const InputParameters & parameters);
  // virtual ~INSVectorTimeDerivative(){}

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const VectorVariableValue & _u_dot;
  const VariableValue & _du_dot_du;
};
