#pragma once

#include "FSIActionBase.h"

class FSIFluidAction;

template <>
InputParameters validParams<FSIFluidAction>();

class FSIFluidAction : public FSIActionBase
{
public:
  FSIFluidAction(const InputParameters & params);

  virtual void act() override;

protected:
  // Perform checks on the domain and make sure subdomains and variables are applied consistently
  void checkBlocks();
  void checkSubdomainAndVariableConsistency();

  // Velocity variables
  std::vector<VariableName> _velocities;
  unsigned int _nvel;

  // pressure variable
  VariableName _pressure;

  // if this vector is not empty the variables, kernels and materials are restricted to these
  // subdomains
  std::vector<SubdomainName> _subdomain_names;
  // set generated from the passed in vector of subdomain names
  std::set<SubdomainID> _subdomain_ids;
  // set generated from the combined block restrictions of all FSI/Fluid action blocks
  std::set<SubdomainID> _subdomain_id_union;

  // flag whether to use INS kernels
  // bool _compressible;

  bool _use_displaced_mesh;
  // Can add some methods that mess with MooseMesh type of stuff that checks if the element order is
  // *at least* second.
};
