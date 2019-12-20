[Debug]
#   show_actions = true
  show_var_residual_norms = true
#   show_parser = true
[]

[GlobalParams]
  convective_term = true
  transient_term = true
  displacements = 'disp_x disp_y'
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
  [./vel_x]
    # block = 'fluid'
    order = SECOND
    family = LAGRANGE
  [../]
  [./vel_y]
    # block = 'fluid'
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
  # [./vel_x_solid]
  #   block = 'solid'
  #   order = SECOND
  #   family = LAGRANGE
  # [../]
  # [./vel_y_solid]
  #   block = 'solid'
  #   order = SECOND
  #   family = LAGRANGE
  # [../]
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


  [../]
  [./vel_x]
    type = NewmarkVelAux
    variable = vel_x_aux
    acceleration = accel_x
    gamma = 0.6
    execute_on = timestep_end
    block = 'solid'


  [../]
  [./accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y_aux
    beta = 0.3025
    execute_on = timestep_end
    block = 'solid'


  [../]
  [./vel_y]
    type = NewmarkVelAux
    variable = vel_y_aux
    acceleration = accel_y
    gamma = 0.6
    execute_on = timestep_end
    block = 'solid'


  [../]
[]

[Kernels]
  [./vel_x_time]
    type = INSMomentumTimeDerivative
    variable = vel_x
    block = 'fluid'

  [../]
  [./vel_y_time]
    type = INSMomentumTimeDerivative
    variable = vel_y
    block = 'fluid'

  [../]
  [./mass]
    type = INSMass
    variable = p
    u = vel_x
    v = vel_y
    p = p
    block = 'fluid'

  [../]
  [./x_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_x
    u = vel_x
    v = vel_y
    p = p
    component = 0
    block = 'fluid'

  [../]
  [./y_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_y
    u = vel_x
    v = vel_y
    p = p
    component = 1
    block = 'fluid'

  [../]
  [./vel_x_mesh]
    type = INSConvectedMesh
    disp_x = disp_x
    disp_y = disp_y
    variable = vel_x
    block = 'fluid'

  [../]
  [./vel_y_mesh]
    type = INSConvectedMesh
    disp_x = disp_x
    disp_y = disp_y
    variable = vel_y
    block = 'fluid'

  [../]
  [./disp_x_fluid]
    type = Diffusion
    variable = disp_x
    block = 'fluid'


  [../]
  [./disp_y_fluid]
    type = Diffusion
    variable = disp_y
    block = 'fluid'


  [../]

  [./SolidInertia_x]
    type = InertialForce
    variable = disp_x
    velocity = vel_x_aux
    acceleration = accel_x
    beta = 0.3025
    gamma = 0.6

    block = 'solid'
  [../]
  [./SolidInetia_y]
    type = InertialForce
    variable = disp_y
    velocity = vel_y_aux
    acceleration = accel_y
    beta = 0.3025
    gamma = 0.6

    block = 'solid'
  [../]

  [./vxs_time_derivative_term]
    type = CoupledTimeDerivative
    variable = vel_x
    v = disp_x
    block = 'solid'


  [../]
  [./vys_time_derivative_term]
    type = CoupledTimeDerivative
    variable = vel_y
    v = disp_y
    block = 'solid'


  [../]
  [./source_vxs]
    type = MatReaction
    variable = vel_x
    block = 'solid'
    mob_name = 1


  [../]
  [./source_vys]
    type = MatReaction
    variable = vel_y
    block = 'solid'
    mob_name = 1


  [../]
[]

[InterfaceKernels]
  [./penalty_interface_x]
    type = CoupledPenaltyInterfaceDiffusion
    variable = vel_x
    neighbor_var = disp_x
    slave_coupled_var = vel_x
    boundary = 'fsi'
    penalty = 1e6


  [../]
  [./penalty_interface_y]
    type = CoupledPenaltyInterfaceDiffusion
    variable = vel_y
    neighbor_var = disp_y
    slave_coupled_var = vel_y
    boundary = 'fsi'
    penalty = 1e6


  [../]
[]

[Modules/TensorMechanics/Master]
  [./solid_domain]
    strain = SMALL
    # add_variables = true
    # incremental = false
    # generate_output = 'strain_xx strain_yy strain_zz' ## Not at all necessary, but nice
    block = 'solid'


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
    type = ComputeLinearElasticStress
    block = 'solid'
  [../]
  [./density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '1e3'
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
  [inlet]
    type = FunctionDirichletBC
    variable = vel_x
    boundary = 'left'
    function = '1'
  []
  # [x_noslip]
  #   type = DirichletBC
  #   variable = vel_x
  #   value = 0
  #   boundary = 'top bottom'
  # []
  # [y_noslip]
  #   type = DirichletBC
  #   variable = vel_y
  #   value = 0
  #   boundary = 'top bottom'
  # []
  [no_disp_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'right'
    value = 0
  []
  [no_disp_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'right'
    value = 0
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
  dt = 1e-4

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-6
  nl_max_its = 150
  l_tol = 1e-6
  l_max_its = 300
  end_time = 1e-1

  solve_type = 'PJFNK'
[]

[Outputs]
  print_linear_residuals = false
  execute_on = 'timestep_end'
  # xda = true
  [out]
    type = Exodus
  []
[]
