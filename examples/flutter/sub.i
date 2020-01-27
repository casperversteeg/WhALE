[Debug]
  # show_actions = true
  # show_var_residual_norms = true
  # show_parser = true
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  order = SECOND
[]

[Mesh]
  [GenMesh]
    type = GeneratedMeshGenerator
    nx = 32
    ny = 20
    xmin = 0.489897
    xmax = 3.989897
    ymin = -0.1
    ymax = 0.1
    elem_type = QUAD9
    dim = 2
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
    youngs_modulus = 1.4e3
    poissons_ratio = 0.4
  []
  [elastic_stress1]
    type = ComputeLinearElasticStress
  []
  [density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '10'
  []
[]

[BCs]
  [fix_x]
    type = DirichletBC
    variable = disp_x
    value = 0.0
    boundary = 'left'
  []
  [fix_y]
    type = DirichletBC
    variable = disp_y
    value = 0.0
    boundary = 'left'
  []
  [fsi_traction_x]
    type = TractionBCfromAux
    variable = disp_x
    boundary = 'top bottom right'
    traction = traction_x
  []
  [fsi_traction_y]
    type = TractionBCfromAux
    variable = disp_y
    boundary = 'top bottom right'
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
