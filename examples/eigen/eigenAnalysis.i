[Mesh]
  type = GeneratedMesh
  dim = 2
  xmin = 0
  xmax = 100
  ymin = 0
  ymax = 100
  elem_type = QUAD4
  nx = 64
  ny = 64

  displacements = 'x_disp y_disp'
[]

#The minimum eigenvalue for this problem is 2*(pi/a)^2 + 2 with a = 100.
#Its inverse will be 0.49950700634518.

[Variables]
  [./u]
    order = first
    family = LAGRANGE
  [../]
[]

[AuxVariables]
  [./x_disp]
  [../]
  [./y_disp]
  [../]
[]

[AuxKernels]
  [./x_disp]
    type = FunctionAux
    variable = x_disp
    function = x_disp_func
  [../]
  [./y_disp]
    type = FunctionAux
    variable = y_disp
    function = y_disp_func
  [../]
[]

[Functions]
  [./x_disp_func]
    type = ParsedFunction
    value = 0
  [../]
  [./y_disp_func]
    type = ParsedFunction
    value = 0
  [../]
[]

[Kernels]
  [./diff]
    type = Diffusion
    variable = u
    use_displaced_mesh = true
  [../]

  [./rea]
    type = CoefReaction
    variable = u
    coefficient = 2.0
    use_displaced_mesh = true
  [../]

  [./rhs]
    type = CoefReaction
    variable = u
    coefficient = -1.0
    use_displaced_mesh = true
    extra_vector_tags = 'eigen'
  [../]
[]

[BCs]
  [./homogeneous]
    type = DirichletBC
    variable = u
    boundary = '0 1 2 3'
    value = 0
    use_displaced_mesh = true
  [../]
  [./eigen_bc]
    type = EigenDirichletBC
    variable = u
    boundary = '0 1 2 3'
    use_displaced_mesh = true
  [../]
[]

[Executioner]
  type = Eigenvalue
  eigen_problem_type = gen_non_hermitian
  which_eigen_pairs = 'smallest_magnitude'
  n_eigen_pairs = 10
  n_basis_vectors = 100
  solve_type = jacobi_davidson
  petsc_options = '-eps_interval=(0,10)'
  # petsc_options_iname = '-eps_interval_min -eps_interval_max'
  # petsc_options_value = '0 10'
  verbose = true
[]

[VectorPostprocessors]
  [./eigenvalues]
    type = Eigenvalues
    # contains_complete_history = true
    execute_on = 'timestep_end'
  [../]
[]

[Outputs]
  csv = true
  # execute_on = 'timestep_end'
  [./out]
    type = Exodus
    # sequence = true
    # overwrite = true
    execute_on = 'timestep_end'
  []
[]
