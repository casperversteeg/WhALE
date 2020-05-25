## Header comments

# Global parameters that will be set for all kernels in the simulation
[GlobalParams]
  use_displaced_mesh = true
  family = LAGRANGE
  order = FIRST
  # displacements = 'disp_y'
[]

# Load or build mesh file for this problem.
[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 75e-6
    ymin = -10e-6
    ymax = 0
    nx = 64
    ny = 16
    elem_type = TRI3
  []
[]

# Set material parameters based on mesh regions
[Materials]
  [const]
    type = GenericConstantMaterial
    prop_names = 'kappa rho cp'
    prop_values = '167 2700 643.9'
    # prop_values = '167 2700 643.9 4.48e-26 10.78e6 0.82'
  []
  [sdot]
    type = HertzKnudsen
    temperature = T
    # boundary = 'top'
    m = 4.48e-26
    # m = 1e-20
    latent_vap = 10.78e6
    Tb = 2743
    beta = 0.82
    block = 0
    # outputs = exodus
  []
  # [cp]
  #   type = GenericFunctionMaterial
  #   prop_names = 'cp'
  #   prop_values = '0.5203*T+643.9'
  # []
[]

# Variables in the problem's governing equations which must be solved
[Variables]
  [T]
    initial_condition = 300
  []
  [disp_y]
  []
  [sdot]
  []
[]

# Auxiliary variables used for postprocessing and passing data between apps
[AuxVariables]
[]

# All the terms in the weak form that need to be solved in this simulation
[Kernels]
  [diff]
    type = HeatConduction
    variable = T
    diffusion_coefficient = 'kappa'
  []
  [time]
    type = SpecificHeatConductionTimeDerivative
    variable = T
    density = rho
    specific_heat = 'cp'
  []
  # [ale]
  #   type = HertzKnudsenAblation
  #   variable = T
  #   in_normal = '0 1 0'
  #   velocity = '0 1 0'
  #   # sdot = sdot
  #   upwinding_type = 'full'
  # []


  [sdot_nonlin]
    type = MaterialPropertyValue
    variable = sdot
    prop_name = sdot
    positive = false
  []
  [laplacemesh]
    type = Diffusion
    variable = disp_y
  []
[]

# Operations defined on auxiliary variables that will be computed at end
[AuxKernels]
[]

# Model boundary conditions that need to be enforced
[BCs]
  [insulate]
    type = NeumannBC
    variable = T
    value = 0
    boundary = 'left right bottom'
  []
  [laser]
    type = FunctionNeumannBC
    variable = T
    function = '3.83e8*(1-0.75)* 23.655e9*(t/1e-9)^7 *exp(7*(1-t/1e-9)) *exp(-7.6*(x/50e-6)^2)'
    boundary = 'top'
  []

  [sdotfix_bottom]
    type = DirichletBC
    variable = sdot
    value = 0
    boundary = 'bottom right'
  []
  [fix_bottom]
    type = DirichletBC
    variable = disp_y
    value = 0
    boundary = 'bottom right'
  []
  [ablation]
    type = CoupledDirichletDotBC
    boundary = 'top'
    variable = disp_y
    v = sdot
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
    solve_type = 'NEWTON'
  []
[]

# Type of algorithm and convergence parameters used to solve the matrix problem
[Executioner]
  type = Transient
  dt = 1e-11
  end_time = 12e-9
  dtmin = 1e-14
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-9
  nl_max_its = 100
  l_tol = 1e-6
  l_max_its = 300
[]

# Output files for viewing after model finishes
[Outputs]
  exodus = true
  print_linear_residuals = false
[]

[Debug]
  # show_actions = true
  show_var_residual_norms = true
  # show_parser = true
[]
