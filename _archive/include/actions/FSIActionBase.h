#pragma once

#include "Action.h"

class FSIActionBase;

template <>
InputParameters validParams<FSIActionBase>();

class FSIActionBase : public Action
{
public:
  FSIActionBase(const InputParameters & params);

  // static MultiMooseEnum outputPropertiesType();

public:
  // ///@{ table data for output generation
  // static const std::map<std::string, std::string> _ranktwoaux_table;
  // static const std::vector<char> _component_table;
  // static const std::map<std::string, std::pair<std::string, std::vector<std::string>>>
  //     _ranktwoscalaraux_table;
  // ///@}

protected:
  // FSI formulation
  MultiMooseEnum _fsi_formulation;

  const bool _is_transient;
  const bool _use_ad;
};
