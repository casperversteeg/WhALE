[GlobalParams]
  gravity = '0 0 0'
  integrate_p_by_parts = false
  laplace = true
  convective_term = true
  transient_term = false
  pspg = false
[]

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
#   [vel_x]
#     family = LAGRANGE
#     order = SECOND
#   []
#   [vel_y]
#     family = LAGRANGE
#     order = SECOND
#   []
#   [pressure]
#     family = LAGRANGE
#     order = FIRST
#   []
[]
#
# [Kernels]
#   # Enforce incompressible continuity with INSMass, which adds div(velocity) to residual
#   [mass]
#     type = INSMass
#     variable = pressure
#     u = vel_x
#     v = vel_y
#     p = pressure
#   []
#   # Momentum equation residuals u dot grad(u)
#   [convection_x]
#     type = INSMomentumTractionForm
#     variable = vel_x
#     component = 0
#     u = vel_x
#     v = vel_y
#     p = pressure
#   []
#   [convection_y]
#     type = INSMomentumTractionForm
#     variable = vel_y
#     component = 1
#     u = vel_x
#     v = vel_y
#     p = pressure
#   []
# []

[FSI]
  [Fluid]
    [./1]
      pressure = 'pressure'
      velocities = 'vel_x vel_y'
      add_variables = true
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
  # type = Transient
  # [./TimeIntegrator]
  #   type = NewmarkBeta
  #   beta = 0.25
  #   gamma = 0.5
  # [../]
  # dt = 1e-4

  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-7
  nl_max_its = 15
  l_tol = 1e-6
  l_max_its = 300
  # end_time = 5e-3

  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  line_search = none
[]

[Outputs]
  print_linear_residuals = false
  execute_on = 'timestep_end'
  # xda = true
  [out]
    type = Exodus
  []
[]
