[GlobalParams]
  gravity = '0 0 0'
  integrate_p_by_parts = false
  laplace = true
  convective_term = true
  transient_term = true
  pspg = true
  displacements = 'disp_x disp_y'
[]

[Mesh]
  type = FileMesh
  file = mesh/domain.msh
  dim = 2
  # uniform_refine = 6
[]

[Variables]
  [./vel_x]
    block = 'fluid'
    order = SECOND
    family = LAGRANGE
  [../]
  [./vel_y]
    block = 'fluid'
    order = SECOND
    family = LAGRANGE
  [../]
  [./p]
    block = 'fluid'
    order = FIRST
    family = LAGRANGE
  [../]
  [./disp_x]
    order = SECOND
    family = LAGRANGE
  [../]
  [./disp_y]
    order = SECOND
    family = LAGRANGE
  [../]
[]

[AuxVariables]
  [./vel_x_aux]
    block = 'solid'
    order = SECOND
  [../]
  [./accel_x]
    block = 'solid'
    order = SECOND
  [../]
  [./vel_y_aux]
    block = 'solid'
    order = SECOND
  [../]
  [./accel_y]
    block = 'solid'
    order = SECOND
  [../]
[]

[AuxKernels]
  [./accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x_aux
    beta = 0.3025
    execute_on = timestep_end
    block = 'solid'
    use_displaced_mesh = true
  [../]
  [./vel_x]
    type = NewmarkVelAux
    variable = vel_x_aux
    acceleration = accel_x
    gamma = 0.6
    execute_on = timestep_end
    block = 'solid'
    use_displaced_mesh = true
  [../]
  [./accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y_aux
    beta = 0.3025
    execute_on = timestep_end
    block = 'solid'
    use_displaced_mesh = true
  [../]
  [./vel_y]
    type = NewmarkVelAux
    variable = vel_y_aux
    acceleration = accel_y
    gamma = 0.6
    execute_on = timestep_end
    block = 'solid'
    use_displaced_mesh = true
  [../]
[]


[Kernels]
  [./vel_x_time]
    type = INSMomentumTimeDerivative
    variable = vel_x
    block = 'fluid'
    use_displaced_mesh = true
  [../]
  [./vel_y_time]
    type = INSMomentumTimeDerivative
    variable = vel_y
    block = 'fluid'
    use_displaced_mesh = true
  [../]
  [./mass]
    type = INSMass
    variable = p
    u = vel_x
    v = vel_y
    p = p
    block = 'fluid'
    use_displaced_mesh = true
  [../]
  [./x_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_x
    u = vel_x
    v = vel_y
    p = p
    component = 0
    block = 'fluid'
    use_displaced_mesh = true
  [../]
  [./y_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_y
    u = vel_x
    v = vel_y
    p = p
    component = 1
    block = 'fluid'
    use_displaced_mesh = true
  [../]
  [./vel_x_mesh]
    type = INSConvectedMesh
    disp_x = disp_x
    disp_y = disp_y
    variable = vel_x
    block = 'fluid'
    use_displaced_mesh = true
  [../]
  [./vel_y_mesh]
    type = INSConvectedMesh
    disp_x = disp_x
    disp_y = disp_y
    variable = vel_y
    block = 'fluid'
    use_displaced_mesh = true
  [../]
  [./disp_x_fluid]
    type = Diffusion
    variable = disp_x
    block = 'fluid'
    use_displaced_mesh = true
  [../]
  [./disp_y_fluid]
    type = Diffusion
    variable = disp_y
    block = 'fluid'
    use_displaced_mesh = true
  [../]

  [./SolidInertia_x]
    type = InertialForce
    variable = disp_x
    velocity = vel_x_aux
    acceleration = accel_x
    beta = 0.3025
    gamma = 0.6
    use_displaced_mesh = true
    block = 'solid'
  [../]
  [./SolidInetia_y]
    type = InertialForce
    variable = disp_y
    velocity = vel_y_aux
    acceleration = accel_y
    beta = 0.3025
    gamma = 0.6
    use_displaced_mesh = true
    block = 'solid'
  [../]
[]

[InterfaceKernels]
  [./penalty_interface_x]
    type = VelocityContinuity
    variable = vel_x
    neighbor_var = disp_x
    neighbor_displacements = true
    boundary = 'dam_left dam_top dam_right'
    penalty = 1e6
    use_displaced_mesh = true
  [../]
  [./penalty_interface_y]
    type = VelocityContinuity
    variable = vel_y
    neighbor_var = disp_y
    neighbor_displacements = true
    boundary = 'dam_left dam_top dam_right'
    penalty = 1e6
    use_displaced_mesh = true
  [../]
[]

[Modules/TensorMechanics/Master]
  generate_output = 'stress_xx stress_yy stress_zz'
  [./solid_domain]
    strain = FINITE
    # add_variables = true
    # incremental = false
    # generate_output = 'strain_xx strain_yy strain_zz' ## Not at all necessary, but nice
    block = 'solid'
    use_displaced_mesh = true
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1e8
    poissons_ratio = 0.3
    block = 'solid'
  [../]
  [./_elastic_stress1]
    type = ComputeFiniteStrainElasticStress
    block = 'solid'
  [../]
  [./density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '1e2'
    block = 'solid'
  [../]
  [./const]
    type = GenericConstantMaterial
    block = 'fluid'
    prop_names = 'rho mu'
    prop_values = '1  1'
  [../]
[]

[BCs]
  [./fluid_x_no_slip]
    type = DirichletBC
    variable = vel_x
    boundary = 'no_slip'
    value = 0.0
    use_displaced_mesh = true
  [../]
  [./fluid_y_no_slip]
    type = DirichletBC
    variable = vel_y
    boundary = 'no_slip'
    value = 0.0
    use_displaced_mesh = true
  [../]
  [./inlet]
    type = FunctionDirichletBC
    variable = vel_x
    boundary = 'inlet'
    function = '1'
    use_displaced_mesh = true
  [../]
  [./outlet]
    type = FunctionDirichletBC
    variable = p
    boundary = 'outlet'
    function = '0'
    use_displaced_mesh = true
  [../]
  [./no_disp_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'fixed no_slip inlet outlet'
    value = 0
    use_displaced_mesh = true
  [../]
  [./no_disp_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'fixed no_slip inlet outlet'
    value = 0
    use_displaced_mesh = true
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  # type = Steady
  type = Transient

  dt = 1e-4

  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-7
  nl_max_its = 15
  l_tol = 1e-6
  l_max_its = 300
  end_time = 5e-3

  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  petsc_options = '-snes_converged_reason -ksp_converged_reason'
  # petsc_options_iname = '-ksp_gmres_restart -pc_type -sub_pc_type -sub_pc_factor_levels'
  # petsc_options_value = '300                bjacobi  ilu          4'
  line_search = none
[]

[Outputs]
  print_linear_residuals = false
  execute_on = 'timestep_end'
  # xda = true
  [./out]
    type = Exodus
  [../]
[]

[Debug]
  # show_actions = true
  show_var_residual_norms = true
[]
