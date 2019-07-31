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

  InputParameters getKernelParameters(std::string type, unsigned int comp);

  // displacement variables
  std::vector<VariableName> _displacements;
  unsigned int _ndisp;
  // velocity and acceleration---will be set if the problem is transient
  std::vector<VariableName> _velocities;
  std::vector<VariableName> _accelerations;

  // // @{ residual debugging
  // std::vector<AuxVariableName> _save_in;
  // std::vector<AuxVariableName> _diag_save_in;
  // // @}

  // if this vector is not empty the variables, kernels and materials are restricted to these
  // subdomains
  std::vector<SubdomainName> _subdomain_names;
  // set generated from the passed in vector of subdomain names
  std::set<SubdomainID> _subdomain_ids;
  // set generated from the combined block restrictions of all FSI/Solid action blocks
  std::set<SubdomainID> _subdomain_id_union;

  // strain formulation
  enum class Strain
  {
    Small,
    Finite
  } _strain;

  // time-integration parameters used if the problem is specified as transient
  const Real _beta;
  const Real _gamma;

  // use displaced mesh (true unless _strain is SMALL)
  bool _use_displaced_mesh;

  // // output aux variables to generate for sclar stress/strain tensor quantities
  // std::vector<std::string> _generate_output;
};
