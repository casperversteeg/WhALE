[GlobalParams]
  integrate_p_by_parts = true
  u = vel_x
  v = vel_y
  supg = true
  laplace = false
  mesh_disp_x = disp_x
  mesh_disp_y = disp_y
  ref_vel_x = ref_vel_x
  ref_vel_y = ref_vel_y
  nodal_normal_x = nodal_normal_x
  nodal_normal_y = nodal_normal_y
  gravity = '0 -9800 0'
[]

[Mesh]
  type = FileMesh
  file = mesh/fluid.msh
  displacements = 'disp_x disp_y'
[]

[Variables]
  [vel_x]
    order = SECOND
    family = LAGRANGE
  []
  [vel_y]
    order = SECOND
    family = LAGRANGE
  []
  [p]
  []
[]

[NodalNormals]
[]

[AuxVariables]
  [disp_x]
    order = SECOND
    family = LAGRANGE
  []
  [disp_y]
    order = SECOND
    family = LAGRANGE
  []
  [tau_x]
    order = CONSTANT
    family = MONOMIAL
  []
  [tau_y]
    order = CONSTANT
    family = MONOMIAL
  []
  [ref_vel_x]
    order = SECOND
  []
  [ref_vel_y]
    order = SECOND
  []
[]

[AuxKernels]
  [tau_x]
    type = FSIFluidTraction
    variable = tau_x
    p = p
    vel = vel_x
    component = 0
    boundary = 'structure_top structure_bottom structure_left structure_right'
    execute_on = 'timestep_end'
    use_displaced_mesh = true
  []
  [tau_y]
    type = FSIFluidTraction
    variable = tau_y
    p = p
    vel = vel_y
    component = 1
    boundary = 'structure_top structure_bottom structure_left structure_right'
    execute_on = 'timestep_end'
    use_displaced_mesh = true
  []
  [ref]
    type = FunctionAux
    variable = ref_vel_x
    # function = '5e3*t'
    function = 0
  []
[]

[Kernels]
  [mass]
    type = INSMass
    variable = p
    p = p
    use_displaced_mesh = true
  []
  [x_time]
    type = INSMomentumTimeDerivative
    variable = vel_x
    use_displaced_mesh = true
  []
  [y_time]
    type = INSMomentumTimeDerivative
    variable = vel_y
    use_displaced_mesh = true
  []
  [x_momentum]
    type = INSMomentumTractionFormALE
    variable = vel_x
    p = p
    component = 0
  []
  [y_momentum]
    type = INSMomentumTractionFormALE
    variable = vel_y
    p = p
    component = 1
  []
[]

[BCs]
  [interface_x_no_slip]
    type = FSInterfaceNoSlipBC
    variable = vel_x
    component = 0
    boundary = 'structure_top structure_bottom structure_left structure_right'
    use_displaced_mesh = true
  []
  [interface_y_no_slip]
    type = FSInterfaceNoSlipBC
    variable = vel_y
    component = 1
    boundary = 'structure_top structure_bottom structure_left structure_right'
    use_displaced_mesh = true
  []
  [xvel_no_bc]
    type = INSOpenBC
    variable = vel_x
    boundary = 'top bottom left right'
    component = 0
    p = p
    use_displaced_mesh = true
  []
  [yvel_no_bc]
    type = INSOpenBC
    variable = vel_y
    boundary = 'top bottom left right'
    component = 1
    p = p
    use_displaced_mesh = true
  []
[]

[Materials]
  [const]
    type = GenericConstantMaterial
    prop_names = 'rho mu'
    prop_values = '1.2e-12 1.8e-11'
  []
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package '
  petsc_options_value = 'lu       superlu_dist'

  # petsc_options_iname = '-ksp_gmres_restart -pc_type -sub_pc_type -sub_pc_factor_levels'
  # petsc_options_value = '300                bjacobi  ilu          4'
  nl_rel_tol = 1e-6
  nl_max_its = 30
  l_tol = 1e-6
  l_max_its = 300
  dt = 1e-4
[]

[Outputs]
  print_linear_residuals = false
  [exodus]
    type = Exodus
    file_base = output/fluid
  []
[]
