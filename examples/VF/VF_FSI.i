[Debug]
#   show_actions = true
  show_var_residual_norms = true
#   show_parser = true
[]

[GlobalParams]
  gravity = '0 0 0'
  integrate_p_by_parts = false
  laplace = true
  convective_term = true
  transient_term = true
  pspg = true
  supg = true
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
  [./vel_x_solid]
    block = 'VF'
    order = SECOND
    family = LAGRANGE
  [../]
  [./vel_y_solid]
    block = 'VF'
    order = SECOND
    family = LAGRANGE
  [../]
[]


[AuxVariables]
  [./vel_x_aux]
    block = 'VF'
    order = SECOND
  [../]
  [./accel_x]
    block = 'VF'
    order = SECOND
  [../]
  [./vel_y_aux]
    block = 'VF'
    order = SECOND
  [../]
  [./accel_y]
    block = 'VF'
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
    block = 'VF'
    use_displaced_mesh = true

  [../]
  [./vel_x]
    type = NewmarkVelAux
    variable = vel_x_aux
    acceleration = accel_x
    gamma = 0.6
    execute_on = timestep_end
    block = 'VF'
    use_displaced_mesh = true

  [../]
  [./accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y_aux
    beta = 0.3025
    execute_on = timestep_end
    block = 'VF'
    use_displaced_mesh = true

  [../]
  [./vel_y]
    type = NewmarkVelAux
    variable = vel_y_aux
    acceleration = accel_y
    gamma = 0.6
    execute_on = timestep_end
    block = 'VF'
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
    block = 'VF'
  [../]
  [./SolidInetia_y]
    type = InertialForce
    variable = disp_y
    velocity = vel_y_aux
    acceleration = accel_y
    beta = 0.3025
    gamma = 0.6
    use_displaced_mesh = true
    block = 'VF'
  [../]

  [./vxs_time_derivative_term]
    type = CoupledTimeDerivative
    variable = vel_x_solid
    v = disp_x
    block = 'VF'
    use_displaced_mesh = true

  [../]
  [./vys_time_derivative_term]
    type = CoupledTimeDerivative
    variable = vel_y_solid
    v = disp_y
    block = 'VF'
    use_displaced_mesh = true

  [../]
  [./source_vxs]
    type = MatReaction
    variable = vel_x_solid
    block = 'VF'
    mob_name = 1
    use_displaced_mesh = true

  [../]
  [./source_vys]
    type = MatReaction
    variable = vel_y_solid
    block = 'VF'
    mob_name = 1
    use_displaced_mesh = true

  [../]
[]

[InterfaceKernels]
  [./penalty_interface_x]
    type = CoupledPenaltyInterfaceDiffusion
    variable = vel_x
    neighbor_var = disp_x
    slave_coupled_var = vel_x_solid
    boundary = 'VF_fsi'
    penalty = 1e6
    use_displaced_mesh = true

  [../]
  [./penalty_interface_y]
    type = CoupledPenaltyInterfaceDiffusion
    variable = vel_y
    neighbor_var = disp_y
    slave_coupled_var = vel_y_solid
    boundary = 'VF_fsi'
    penalty = 1e6
    use_displaced_mesh = true

  [../]
[]

[Modules/TensorMechanics/Master]
  [./solid_domain]
    strain = FINITE
    # add_variables = true
    # incremental = false
    # generate_output = 'strain_xx strain_yy strain_zz' ## Not at all necessary, but nice
    block = 'VF'
    use_displaced_mesh = true

  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1e8
    poissons_ratio = 0.3
    block = 'VF'
  [../]
  [./_elastic_stress1]
    type = ComputeFiniteStrainElasticStress
    block = 'VF'
  [../]
  [./density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '1e3'
    block = 'VF'
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
  [./fsi_traction_x]
    type = INSALETractionBC
    variable = disp_x
    component = 0
    boundary = 'VF_fsi'
    p = p
    u = vel_x
    v = vel_y
    displacements = 'disp_x disp_y'
  [../]
  [./fsi_traction_y]
    type = INSALETractionBC
    variable = disp_y
    component = 1
    boundary = 'VF_fsi'
    p = p
    u = vel_x
    v = vel_y
    displacements = 'disp_x disp_y'
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
  dt = 1e-4

  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-7
  nl_max_its = 150
  l_tol = 1e-6
  #l_max_its = 300
  end_time = 2e-3

  solve_type = 'NEWTON'
   petsc_options_iname = '-pc_type'
   petsc_options_value = 'lu'
  # petsc_options = '-snes_converged_reason -ksp_converged_reason'
  #petsc_options_iname = '-ksp_gmres_restart -pc_type -sub_pc_type -sub_pc_factor_levels'
  #petsc_options_value = '300                bjacobi  ilu          4'
  line_search = bt
[]

[Outputs]
  print_linear_residuals = false
  execute_on = 'timestep_end'
  # xda = true
  [./out]
    type = Exodus
  [../]
[]
