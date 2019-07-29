#pragma once

#include "FSIActionBase.h"

class FSISolidAction;

template <>
InputParameters validParams<FSISolidAction>();

class FSISolidAction : public FSIActionBase
{
public:
  FSISolidAction(const InputParameters & params);

  virtual void act() override;

protected:
  // Perform checks on the domain and make sure subdomains and variables are applied consistently
  void checkBlocks();
  void checkSubdomainAndVariableConsistency();

  InputParameters getKernelParameters(std::string type);

  // displacement variables
  std::vector<VariableName> _displacements;
  unsigned int _ndisp;

  // if this vector is not empty the variables, kernels and materials are restricted to these
  // subdomains
  std::vector<SubdomainName> _subdomain_names;
  // set generated from the passed in vector of subdomain names
  std::set<SubdomainID> _subdomain_ids;
  // set generated from the combined block restrictions of all FSI/Solid action blocks
  std::set<SubdomainID> _subdomain_id_union;

  bool _use_displaced_mesh;
};
