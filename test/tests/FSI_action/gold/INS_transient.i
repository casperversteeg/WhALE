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

[Variables]
  [vel_x]
    family = LAGRANGE
    order = SECOND
  []
  [vel_y]
    family = LAGRANGE
    order = SECOND
  []
  [pressure]
    family = LAGRANGE
    order = FIRST
  []
[]

[Kernels]
  # Enforce incompressible continuity with INSMass, which adds div(velocity) to residual
  [mass]
    type = INSMass
    variable = pressure
    u = vel_x
    v = vel_y
    p = pressure
  []
  # Unsteady momentum equation terms
  [unsteady_x]
    type = INSMomentumTimeDerivative
    variable = vel_x
  []
  [unsteady_y]
    type = INSMomentumTimeDerivative
    variable = vel_y
  []
  # Momentum equation residuals
  [momentum_x]
    type = INSMomentumTractionForm
    variable = vel_x
    component = 0
    u = vel_x
    v = vel_y
    p = pressure
  []
  [momentum_y]
    type = INSMomentumTractionForm
    variable = vel_y
    component = 1
    u = vel_x
    v = vel_y
    p = pressure
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
  type = Transient
  dt = 0.1
  end_time = 1

  nl_abs_tol = 1e-8

  solve_type = 'PJFNK'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -sub_pc_type -sub_pc_factor_levels'
  petsc_options_value = '300                bjacobi  ilu          4'
[]

[Outputs]
  print_linear_residuals = false
  exodus = true
  file_base = "INS_transient"
[]
