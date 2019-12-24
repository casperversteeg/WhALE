[Debug]
#   show_actions = true
  show_var_residual_norms = true
  # show_parser = true
[]

[Mesh]
  [GenMesh]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 2
    ymin = 0
    ymax = 1
    elem_type = QUAD9
    nx = 10
    ny = 5
  []
  [fluid]
    type = SubdomainBoundingBoxGenerator
    input = GenMesh
    block_id = 0
    bottom_left = '0 0 0'
    top_right = '1 1 0'
    block_name = 'fluid'
  []
  [solid]
    type = SubdomainBoundingBoxGenerator
    input = fluid
    block_id = 1
    bottom_left = '1 0 0'
    top_right = '2 1 0'
    block_name = 'solid'
  []
  [interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = solid
    master_block = '0'
    paired_block = '1'
    new_boundary = 'fsi'
  []
  [break_boundary]
    input = interface
    type = BreakBoundaryOnSubdomainGenerator
  []
[]

[Variables]
  [vel_x]
    order = SECOND
    family = LAGRANGE
    block = 'fluid'
  []
  [vel_y]
    order = SECOND
    family = LAGRANGE
    block = 'fluid'
  []
  [p]
    order = FIRST
    family = LAGRANGE
    block = 'fluid'
  []
  [disp_x]
    order = SECOND
    family = LAGRANGE
  []
  [disp_y]
    order = SECOND
    family = LAGRANGE
  []
[]

[AuxVariables]
  [traction_x]
    order = CONSTANT
    family = MONOMIAL
  []
  [traction_y]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [traction_x]
    type = ComputeINSStress
    variable = traction_x
    u = vel_x
    v = vel_y
    p = p
    mu_name = mu
    component = 0
    boundary = 'fsi'
    block = 'fluid'
  []
  [traction_y]
    type = ComputeINSStress
    variable = traction_y
    u = vel_x
    v = vel_y
    p = p
    mu_name = mu
    component = 1
    boundary = 'fsi'
    block = 'fluid'
  []
[]

[Kernels]
  [mass]
    type = INSMass
    variable = p
    u = vel_x
    v = vel_y
    p = p
    block = 'fluid'
  []
  [x_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_x
    u = vel_x
    v = vel_y
    p = p
    component = 0
    block = 'fluid'
  []
  [y_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_y
    u = vel_x
    v = vel_y
    p = p
    component = 1
    block = 'fluid'
  []
  [disp_x_fluid]
    type = Diffusion
    variable = disp_x
    block = 'fluid'
  []
  [disp_y_fluid]
    type = Diffusion
    variable = disp_y
    block = 'fluid'
  []

  # [x_null]
  #   type = NullKernel
  #   variable = vel_x
  #   block = 'solid'
  # []
  # [y_null]
  #   type = NullKernel
  #   variable = vel_y
  #   block = 'solid'
  # []
[]

[Modules/TensorMechanics/Master]
  displacements = 'disp_x disp_y'
  [./solid_domain]
    strain = SMALL
    generate_output = 'stress_xx stress_yy'
    block = 'solid'
    displacements = 'disp_x disp_y'
  [../]
[]

[InterfaceKernels]
  [v_interface_x]
    type = VelocityContinuity
    variable = vel_x
    neighbor_var = disp_x
    boundary = 'fsi'
  []
  [v_interface_y]
    type = VelocityContinuity
    variable = vel_y
    neighbor_var = disp_y
    boundary = 'fsi'
  []
[]


[BCs]
  [noslip_x]
    type = DirichletBC
    variable = vel_x
    boundary = 'left'
    value = 0.0
  []
  [noslip_y]
    type = DirichletBC
    variable = vel_y
    boundary = 'left'
    value = 1.0
  []
  [no_d_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'right'
    value = 0.0
  []
  [no_d_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'right'
    value = 0.0
  []

  [vy_in]
    type = FunctionDirichletBC
    variable = vel_y
    boundary = 'bottom'
    function = 'if(x<1,-(x-1), 0)'
  []

  [vy_out]
    type = FunctionDirichletBC
    variable = vel_y
    boundary = 'top'
    function = 'if(x<1,-(x-1), 0)'
  []
  # [x_traction]
  #   type = TractionBCfromAux
  #   variable = disp_x
  #   traction = traction_x
  #   boundary = 'fsi'
  #   use_displaced_mesh = false
  # []
  # [y_traction]
  #   type = TractionBCfromAux
  #   variable = disp_y
  #   traction = traction_y
  #   boundary = 'fsi'
  #   use_displaced_mesh = false
  # []
[]

[Materials]
  [elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1e8
    poissons_ratio = 0.3
    block = 'solid'
  []
  [_elastic_stress1]
    type = ComputeLinearElasticStress
    block = 'solid'
  []
  [density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '1e3'
    block = 'solid'
  []
  [const]
    type = GenericConstantMaterial
    block = 'fluid'
    prop_names = 'rho mu'
    prop_values = '1  1'
  []
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Steady
  solve_type = Newton
  nl_rel_tol = 1e-8
  l_max_its = 20
[]

[Outputs]
  print_linear_residuals = false
  [out]
    type = Exodus
    # elemental_as_nodal = true
  []
[]
