# The CoupledPressureBC essentially applies a traction boundary condition, dotted with the inward pointing normal on the surface of the domain.

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [GenMesh]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 1
    elem_type = QUAD9
    nx = 10
    ny = 10
  []
[]

[AuxVariables]
  [traction_x]
  []
  [traction_y]
  []
[]

[AuxKernels]
  [traction_x]
    type = FunctionAux
    variable = traction_x
    boundary = 'top'
    function = '1'
  []
  [traction_y]
    type = FunctionAux
    variable = traction_y
    boundary = 'top'
    function = '0'
  []
[]

[Modules/TensorMechanics/Master]
  [all]
    strain = SMALL
    generate_output = 'stress_xx stress_yy'
    add_variables = true
  []
[]

[BCs]
  [no_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'bottom'
    value = 0.0
  []
  [no_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'bottom top'
    value = 0.0
  []

  [top_traction_x]
    type = TractionBCfromAux
    variable = disp_x
    boundary = 'top'
    traction = traction_x
    component = 0
  []
  [top_traction_y]
    type = TractionBCfromAux
    variable = disp_y
    boundary = 'top'
    traction = traction_y
    component = 1
  []
  # [top_traction_x]
  #   type = CoupledPressureBC
  #   variable = disp_x
  #   boundary = 'top'
  #   pressure = traction_x
  #   component = 0
  # []
  # [top_traction_y]
  #   type = CoupledPressureBC
  #   variable = disp_y
  #   boundary = 'top'
  #   pressure = traction_y
  #   component = 1
  # []
[]

[Materials]
  [Elasticity_tensor]
    type = ComputeElasticityTensor
    fill_method = symmetric_isotropic
    C_ijkl = '0 0.5e6'
  []
  [stress]
    type = ComputeLinearElasticStress
  []
[]

[Executioner]
  type = Steady
  solve_type = Newton
  nl_rel_tol = 1e-8
  l_max_its = 20
[]

[Outputs]
  [out]
    type = Exodus
    # elemental_as_nodal = true
  []
[]
