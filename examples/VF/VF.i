## Header comments

# Global parameters that will be set for all kernels in the simulation
[GlobalParams]
  displacements = 'disp_x disp_y'
  order = SECOND
[]

# Load or build mesh file for this problem.
[Mesh]

[]

# Set material parameters based on mesh regions
[Materials]
  [elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1e8
    poissons_ratio = 0.3
  []
  [elastic_stress]
    type = ComputeLinearElasticStress
  []
  [density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '1e3'
  []
[]

# Variables in the problem's governing equations which must be solved
[Variables]

[]

# Auxiliary variables used for postprocessing and passing data between apps
[AuxVariables]
  [traction_x]
  []
  [traction_y]
  []
[]

# All the terms in the weak form that need to be solved in this simulation
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
  [all]
    strain = SMALL
    generate_output = 'stress_xx stress_yy'
    add_variables = true
  []
[]

# Operations defined on auxiliary variables that will be computed at end
[AuxKernels]

[]

# Model boundary conditions that need to be enforced
[BCs]
  [fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'fixed'
    value = 0
  []
  [fix_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'fixed'
    value = 0
  []
  [fsi_traction_x]
    type = TractionBCfromAux
    variable = disp_x
    boundary = 'no_slip'
    traction = traction_x
  []
  [fsi_traction_y]
    type = TractionBCfromAux
    variable = disp_y
    boundary = 'no_slip'
    traction = traction_y
  []
[]

# Define postprocessor operations that can be used for viewing data/statistics
[Postprocessors]

[]

# Set up matrix preconditioner to improve convergence
[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

# Type of algorithm and convergence parameters used to solve the matrix problem
[Executioner]
  type = Transient

  dt = 1e-4
  nl_abs_tol = 1e-6

  solve_type = 'NEWTON'

  [TimeIntegrator]
    type = NewmarkBeta
    beta = 0.25
    gamma = 0.5
  []
[]

# Output files for viewing after model finishes
[Outputs]
  print_linear_residuals = false
  exodus = true
[]
