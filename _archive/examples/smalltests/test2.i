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
    elem_type = QUAD4
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
    order = FIRST
    family = LAGRANGE
  []
  [vel_y]
    order = FIRST
    family = LAGRANGE
  []
  [p]
    order = FIRST
    family = LAGRANGE
    block = 'fluid'
  []
  [disp_x]
    order = FIRST
    family = LAGRANGE
  []
  [disp_y]
    order = FIRST
    family = LAGRANGE
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  convective_term = true
  transient_term = true
  pspg=true
[]


[AuxVariables]
  [accel_x]
    block = 'solid'
    order = FIRST
  []
  [accel_y]
    block = 'solid'
    order = FIRST
  []
[]

[AuxKernels]
  [accel_x]
    type = NewmarkAccelFromVelAux
    variable = accel_x
    velocity = vel_x
    gamma = 0.5
    execute_on = timestep_end
    block = 'solid'
  []
  [accel_y]
    type = NewmarkAccelFromVelAux
    variable = accel_y
    velocity = vel_y
    gamma = 0.5
    execute_on = timestep_end
    block = 'solid'
  []
[]

[Kernels]
  [vel_x_time]
    type = INSMomentumTimeDerivative
    variable = vel_x
    block = 'fluid'
  []
  [vel_y_time]
    type = INSMomentumTimeDerivative
    variable = vel_y
    block = 'fluid'
  []
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
  [vel_x_mesh]
    type = INSConvectedMesh
    disp_x = disp_x
    disp_y = disp_y
    variable = vel_x
    block = 'fluid'
  []
  [vel_y_mesh]
    type = INSConvectedMesh
    disp_x = disp_x
    disp_y = disp_y
    variable = vel_y
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

  [SolidInertia_x]
    type = InertialForce
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    beta = 0.25
    gamma = 0.5
    block = 'solid'
  []
  [SolidInetia_y]
    type = InertialForce
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    beta = 0.25
    gamma = 0.5
    block = 'solid'
  []

  [solid_x_vel]
    type = CoupleVelocity
    variable = vel_x
    displacement = disp_x
    block = 'solid'
  []
  [solid_y_vel]
    type = CoupleVelocity
    variable = vel_y
    displacement = disp_y
    block = 'solid'
  []

  # [vxs_time_derivative_term]
  #   type = CoupledTimeDerivative
  #   variable = vel_x
  #   v = disp_x
  #   block = 'solid'
  # []
  # [vys_time_derivative_term]
  #   type = CoupledTimeDercivative
  #   variable = vel_y
  #   v = disp_y
  #   block = 'solid'
  # []
  # [source_vxs]
  #   type = MatReaction
  #   variable = vel_x
  #   block = 'solid'
  #   mob_name = 1
  # []
  # [source_vys]
  #   type = MatReaction
  #   variable = vel_y
  #   block = 'solid'
  #   mob_name = 1
  # []
[]

[InterfaceKernels]
  [v_interface_x]
    type = InterfaceReaction
    variable = vel_x
    neighbor_var = vel_x
    boundary = 'fsi'
    kb = 1
    kf = 1
  []
  [v_interface_y]
    type = InterfaceReaction
    variable = vel_y
    neighbor_var = vel_y
    boundary = 'fsi'
    kb = 1
    kf = 1
  []
  # [dv_interface_x]
  #   type = InterfaceDiffusion
  #   variable = vel_x
  #   neighbor_var = vel_x
  #   boundary = 'fsi'
  #   D = 1
  #   D_neighbor = 1
  # []
  # [dv_interface_y]
  #   type = InterfaceDiffusion
  #   variable = vel_y
  #   neighbor_var = vel_y
  #   boundary = 'fsi'
  #   D = 1
  #   D_neighbor = 1
  # []
[]

[Modules/TensorMechanics/Master]
  [./solid_domain]
    strain = SMALL
    generate_output = 'stress_xx stress_yy' ## Not at all necessary, but nice
    block = 'solid'
  [../]
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
  dt = 1e-3

  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-7
  nl_max_its = 150
  l_tol = 1e-6
  l_max_its = 300
  end_time = 1e-0

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


[AuxKernels]
  [fluidstress_x]
    type = INSStressComponentAux
    variable = stress_xx
    comp = 0
    mu_name = mu
    pressure = p
    velocity = vel_x
    block = 'fluid'
  []
  [fluidstress_y]
    type = INSStressComponentAux
    variable = stress_yy
    comp = 1
    mu_name = mu
    pressure = p
    velocity = vel_y
    block = 'fluid'
  []
[]
