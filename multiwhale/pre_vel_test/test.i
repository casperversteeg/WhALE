[Debug]
  # show_actions = true
  show_var_residual_norms = true
  # show_parser = true
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  [GenMesh]
    type = GeneratedMeshGenerator
    nx = 10
    ny = 10
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 1
    elem_type = QUAD9
    dim = 2
  []
[]

[Variables]
  [disp_x]
    family = LAGRANGE
    order = SECOND
  []
  [disp_y]
    family = LAGRANGE
    order = SECOND
  []
[]

[AuxVariables]
  [vel_x]
    order = SECOND
  []
  [vel_y]
    order = SECOND
  []
  [accel_x]
    order = SECOND
  []
  [accel_y]
    order = SECOND
  []
[]

[AuxKernels]
  # [accel_x]
  #   type = NewmarkAccelAux
  #   variable = accel_x
  #   displacement = disp_x
  #   velocity = vel_x
  #   beta = 0.25
  #   execute_on = 'timestep_end'
  # []
  # [vel_x]
  #   type = NewmarkVelAux
  #   variable = vel_x
  #   acceleration = accel_x
  #   gamma = 0.5
  #   execute_on = 'timestep_end'
  # []
  # [accel_y]
  #   type = NewmarkAccelAux
  #   variable = accel_y
  #   displacement = disp_y
  #   velocity = vel_y
  #   beta = 0.25
  #   execute_on = 'timestep_end'
  # []
  # [vel_y]
  #   type = NewmarkVelAux
  #   variable = vel_y
  #   acceleration = accel_y
  #   gamma = 0.5
  #   execute_on = 'timestep_end'
  # []
  [accel_x]
    type = TestNewmarkTI
    variable = accel_x
    displacement = disp_x
    first = false
  []
  [vel_x]
    type = TestNewmarkTI
    variable = vel_x
    displacement = disp_x
  []
  [accel_y]
    type = TestNewmarkTI
    variable = accel_y
    displacement = disp_y
    first = false
  []
  [vel_y]
    type = TestNewmarkTI
    variable = vel_y
    displacement = disp_y
  []
[]

[Kernels]
  [inertia_x]
    type = InertialForce
    variable = disp_x
    # acceleration = accel_x
    # velocity = vel_x
    # gamma = 0.5
    # beta = 0.25
  []
  [inertia_y]
    type = InertialForce
    variable = disp_y
    # acceleration = accel_y
    # velocity = vel_y
    # gamma = 0.5
    # beta = 0.25
  []
[]

[Modules/TensorMechanics/Master]
  [solid_domain]
    strain = SMALL
    # add_variables = true
    # incremental = false
    # generate_output = 'strain_xx strain_yy strain_zz' ## Not at all necessary, but nice
  []
[]

[Materials]
  [elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1e8
    poissons_ratio = 0.3
  []
  [elastic_stress1]
    type = ComputeLinearElasticStress
  []
  [density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '1e3'
  []
[]

[BCs]
  [fix_x]
    type = DirichletBC
    variable = disp_x
    value = 0.0
    boundary = 'bottom'
  []
  [fix_y]
    type = DirichletBC
    variable = disp_y
    value = 0.0
    boundary = 'bottom'
  []
  [vel_y]
    type = PresetVelocity
    variable = disp_y
    value = 0.1
    boundary = 'top'
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

  dt = 0.01
  end_time = 1

  nl_abs_tol = 1e-6

  solve_type = 'NEWTON'

  [TimeIntegrator]
    type = NewmarkBeta
    beta = 0.25
    gamma = 0.5
  []
[]

[Outputs]
  print_linear_residuals = false
  exodus = true
[]
