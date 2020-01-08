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
    nx = 100
    ny = 40
    xmin = 0
    xmax = 0.05
    ymin = 0
    ymax = 0.02
    elem_type = QUAD9
    dim = 2
  []
  [solid]
    type = SubdomainBoundingBoxGenerator
    input = GenMesh
    block_id = 1
    bottom_left = '0.024 0 0'
    top_right = '.026 .01 0'
  []
  [interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = solid
    master_block = '1'
    paired_block = '0'
    new_boundary = 'dam'
  []
  [break_boundary]
    input = interface
    type = BreakBoundaryOnSubdomainGenerator
  []
  [delete_solid]
    type = BlockDeletionGenerator
    input = break_boundary
    block_id = 0
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
  [traction_x]
    family = MONOMIAL
    order = CONSTANT
  []
  [traction_y]
    family = MONOMIAL
    order = CONSTANT
  []
  [vel_bc_x]
    family = LAGRANGE
    order = SECOND
  []
  [vel_bc_y]
    family = LAGRANGE
    order = SECOND
  []
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
  [fsi_traction_x]
    type = TractionBCfromAux
    variable = disp_x
    boundary = 'dam'
    traction = traction_x
  []
  [fsi_traction_y]
    type = TractionBCfromAux
    variable = disp_y
    boundary = 'dam'
    traction = traction_y
  []
  [fsi_vel_x]
    type = CoupledPresetVelocity
    variable = disp_x
    v = vel_bc_x
    boundary = 'dam'
  []
  [fsi_vel_y]
    type = CoupledPresetVelocity
    variable = disp_y
    v = vel_bc_y
    boundary = 'dam'
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
