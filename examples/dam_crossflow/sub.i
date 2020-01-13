[Debug]
  # show_actions = true
  # show_var_residual_norms = true
  # show_parser = true
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  order = FIRST
[]

[Mesh]
  [GenMesh]
    type = GeneratedMeshGenerator
    nx = 50
    ny = 20
    xmin = 0
    xmax = 0.05
    ymin = 0
    ymax = 0.02
    elem_type = QUAD4
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
  []
  [disp_y]
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
  [vel_x]
    family = LAGRANGE
  []
  [vel_y]
    family = LAGRANGE
  []
[]

[AuxKernels]
  [vel_x]
    type = TestNewmarkTI
    variable = vel_x
    displacement = disp_x
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
  []
  [inertia_y]
    type = InertialForce
    variable = disp_y
  []
[]

[Modules/TensorMechanics/Master]
  [solid_domain]
    strain = SMALL
  []
[]

[Materials]
  [elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 68.9e9
    poissons_ratio = 0.3
  []
  [elastic_stress1]
    type = ComputeLinearElasticStress
  []
  [density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '2700'
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
