[GlobalParams]
  gravity = '0 0 0'
  integrate_p_by_parts = true
  laplace = true
  convective_term = true
  transient_term = true
  displacements = 'disp_x disp_y'
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  xmin = 0
  xmax = 3.0
  ymin = 0
  ymax = 1.0
  nx = 10
  ny = 15
  elem_type = QUAD9
[]


[MeshModifiers]
  [./subdomain1]
    type = SubdomainBoundingBox
    bottom_left = '0.0 0.5 0'
    block_id = 1
    top_right = '3.0 1.0 0'
  [../]
  [./interface]
    type = SideSetsBetweenSubdomains
    depends_on = subdomain1
    master_block = '0'
    paired_block = '1'
    new_boundary = 'master0_interface'
  [../]
  [./break_boundary]
    depends_on = interface
    type = BreakBoundaryOnSubdomain
  [../]
[]

[Variables]
  [./vel_x]
    block = 0
    order = SECOND
  [../]
  [./vel_y]
    block = 0
    order = SECOND
  [../]
  [./p]
    block = 0
    order = FIRST
  [../]
  [./disp_x]
    order = SECOND
  [../]
  [./disp_y]
    order = SECOND
  [../]
  [./vel_x_solid]
    order = SECOND
    block = 1
  [../]
  [./vel_y_solid]
    order = SECOND
    block = 1
  [../]
[]

[Kernels]
  [./vel_x_time]
    type = INSMomentumTimeDerivative
    variable = vel_x
    block = 0
    use_displaced_mesh = true
  [../]
  [./vel_y_time]
    type = INSMomentumTimeDerivative
    variable = vel_y
    block = 0
    use_displaced_mesh = true
  [../]
  [./mass]
    type = INSMass
    variable = p
    u = vel_x
    v = vel_y
    p = p
    block = 0
    use_displaced_mesh = true
  [../]
  [./x_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_x
    u = vel_x
    v = vel_y
    p = p
    component = 0
    block = 0
    use_displaced_mesh = true
  [../]
  [./y_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_y
    u = vel_x
    v = vel_y
    p = p
    component = 1
    block = 0
    use_displaced_mesh = true
  [../]
  [./vel_x_mesh]
    type = INSConvectedMesh
    disp_x = disp_x
    disp_y = disp_y
    variable = vel_x
    block = 0
    use_displaced_mesh = true
  [../]
  [./vel_y_mesh]
    type = INSConvectedMesh
    disp_x = disp_x
    disp_y = disp_y
    variable = vel_y
    block = 0
    use_displaced_mesh = true
  [../]
  [./disp_x_fluid]
    type = Diffusion
    variable = disp_x
    block = 0
  [../]
  [./disp_y_fluid]
    type = Diffusion
    variable = disp_y
    block = 0
  [../]
  [./accel_tensor_x]
    type = CoupledTimeDerivative
    variable = disp_x
    v = vel_x_solid
    block = 1
  [../]
  [./accel_tensor_y]
    type = CoupledTimeDerivative
    variable = disp_y
    v = vel_y_solid
    block = 1
  [../]
  [./vxs_time_derivative_term]
    type = CoupledTimeDerivative
    variable = vel_x_solid
    v = disp_x
    block = 1
  [../]
  [./vys_time_derivative_term]
    type = CoupledTimeDerivative
    variable = vel_y_solid
    v = disp_y
    block = 1
  [../]
  [./source_vxs]
    type = MatReaction
    variable = vel_x_solid
    block = 1
    mob_name = 1
  [../]
  [./source_vys]
    type = MatReaction
    variable = vel_y_solid
    block = 1
    mob_name = 1
  [../]
[]

[InterfaceKernels]
  [./penalty_interface_x]
    type = CoupledPenaltyInterfaceDiffusion
    variable = vel_x
    neighbor_var = disp_x
    slave_coupled_var = vel_x_solid
    boundary = master0_interface
    penalty = 1e8
  [../]
  [./penalty_interface_y]
    type = CoupledPenaltyInterfaceDiffusion
    variable = vel_y
    neighbor_var = disp_y
    slave_coupled_var = vel_y_solid
    boundary = master0_interface
    penalty = 1e6
  [../]
[]

[Modules/TensorMechanics/Master]
  [./solid_domain]
    strain = SMALL
    incremental = false
    generate_output = 'stress_xx stress_yy' ## Not at all necessary, but nice
    block = '1'
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1e2
    poissons_ratio = 0.3
    block = '1'
  [../]
  [./small_stress]
    type = ComputeLinearElasticStress
    block = 1
  [../]
  [./const]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'rho mu'
    prop_values = '1  1'
  [../]
[]

[BCs]
  [./fluid_x_no_slip]
    type = DirichletBC
    variable = vel_x
    boundary = 'bottom'
    value = 0.0
  [../]
  [./fluid_y_no_slip]
    type = DirichletBC
    variable = vel_y
    boundary = 'bottom left_to_0'
    value = 0.0
  [../]
  [./x_inlet]
    type = FunctionDirichletBC
    variable = vel_x
    boundary = 'left_to_0'
    function = 'inlet_func'
  [../]
  [./no_disp_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'bottom top left_to_1 right_to_1 left_to_0 right_to_0'
    value = 0
  [../]
  [./no_disp_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'bottom top left_to_1 right_to_1 left_to_0 right_to_0'
    value = 0
  [../]
  [./solid_x_no_slip]
    type = DirichletBC
    variable = vel_x_solid
    boundary = 'top left_to_1 right_to_1'
    value = 0.0
  [../]
  [./solid_y_no_slip]
    type = DirichletBC
    variable = vel_y_solid
    boundary = 'top left_to_1 right_to_1'
    value = 0.0
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  # num_steps = 5
  end_time = 0.1
  dt = 1e-3
  solve_type = 'NEWTON'
  nl_abs_tol = 1e-6
[]

[Outputs]
  print_linear_residuals = false
  [./out]
    type = Exodus
  [../]
[]

[Functions]
  [./inlet_func]
    type = ParsedFunction
    value = '(-16 * (y - 0.25)^2 + 1) * (1 + cos(t))'
  [../]
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
    boundary = 'master0_interface'
  []
  [traction_y]
    type = ComputeINSStress
    variable = traction_y
    u = vel_x
    v = vel_y
    p = p
    mu_name = mu
    component = 1
    boundary = 'master0_interface'
  []
[]
