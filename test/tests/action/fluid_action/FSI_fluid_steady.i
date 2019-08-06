[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
  elem_type = QUAD9
[]

[Materials]
  [const]
    type = GenericConstantMaterial
    prop_names = 'rho mu'
    prop_values = '1  1'
  []
[]

[FSI]
  [Fluid]
    [1]
      velocities = 'vel_x vel_y'
      pressure = 'pressure'
      add_variables = true
      block = 0
    []
  []
[]

[BCs]
  [vel_inlet]
    type = DirichletBC
    variable = vel_x
    boundary = 'left'
    value = 1.0
  []
  [p_outlet]
    type = DirichletBC
    variable = pressure
    boundary = 'right'
    value = 0.0
  []
  [no_slip_x]
    type = DirichletBC
    variable = vel_x
    boundary = 'top bottom'
    value = 0.0
  []
  [no_slip_y]
    type = DirichletBC
    variable = vel_y
    boundary = 'top bottom'
    value = 0.0
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

  nl_abs_tol = 1e-8

  solve_type = 'PJFNK'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -sub_pc_type -sub_pc_factor_levels'
  petsc_options_value = '300                bjacobi  ilu          4'
[]

[Outputs]
  print_linear_residuals = false
  exodus = true
  file_base = "FSI_fluid_steady"
[]
