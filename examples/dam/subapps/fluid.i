## Header comments

# Global parameters that will be set for all kernels in the simulation
[GlobalParams]
  u = vel_x
  v = vel_y
  p = pressure
  integrate_p_by_parts = true
  supg = true
  laplace = false
  use_displaced_mesh = true
  mesh_x = disp_x
  mesh_y = disp_y
[]

# Load or build mesh file for this problem.
[Mesh]
  type = FileMesh
  file = ../mesh/fluid.msh
  dim = 2 # Must be supplied for GMSH generated meshes
[]

# Set material parameters based on mesh regions
[Materials]
  # Define fluid domain material parameters by density and viscosity
  [./fluid]
    type = GenericConstantMaterial
    prop_names = 'rho mu'
    prop_values = '1e0 1e-1'
    block = 'fluid'
  [../]
[]

# Variables in the problem's governing equations which must be solved
[Variables]
  # Set x-direction velocity as variable to solve for
  [./vel_x]
    order = SECOND
    family = LAGRANGE
  [../]
  # Set y-direction velocity as variable to solve for
  [./vel_y]
    order = SECOND
    family = LAGRANGE
  [../]
  # Set pressure as variable to solve for
  [./pressure]
    order = FIRST
    family = LAGRANGE
  [../]
[]

# Auxiliary variables used for postprocessing and passing data between apps
[AuxVariables]
  [./disp_x]
    order = SECOND
    family = LAGRANGE
  [../]
  [./disp_y]
    order = SECOND
    family = LAGRANGE
  [../]
[]

# All the terms in the weak form that need to be solved in this simulation
[Kernels]
  # Need to build the Navier-Stokes equations using Moose kernels. By the end,
  # we should have the following terms in the equations:
  #
  #   grad dot u = 0  -->   Conservation of mass
  #   rho * (du/dt + (c dot grad) dot u) - grad dot sigma - rho * b = 0   -->   Conservation of momentum
  #
  # The conservation of mass equation is enforced by the INSMass kernel in Moose,
  # the unsteady (rho * du/dt) term is added with an INSMomentumTimeDerivative
  # kernel. The remainder of the terms, such as the convection term (rho * (c dot grad) dot u)
  # and the traction and body force terms, can be added either through the
  # INSMomentumTractionForm kernel, although this will need to be a custom kernel,
  # since Moose computes (u dot grad) dot u. Instead, we want to take the divergence
  # of the convection velocity, which is going to depend on the mesh movement of
  # the ALE description as well. Alternatively, those terms can be put in separate
  # kernels, which are available in this module.

  # Enforce incompressible continuity with INSMass, which adds div(velodity) to residual
  [./mass]
    type = INSMass
    variable = pressure
  [../]
  # Add unsteady term of fluid field to residual (rho * du/dt)
  [./unsteady_x]
    type = INSMomentumTimeDerivative
    variable = vel_x
  [../]
  [./unsteady_y]
    type = INSMomentumTimeDerivative
    variable = vel_y
  [../]
  # Add ALE momentum equation kernels, including convective, traction and body terms
  [./convection_x]
    type = INSALEMomentumConvection
    variable = vel_x
    component = 0
  [../]
  [./convection_y]
    type = INSALEMomentumConvection
    variable = vel_y
    component = 1
  [../]
  [./traction_x]
    type = INSALEMomentumTraction
    variable = vel_x
    component = 0
  [../]
  [./traction_y]
    type = INSALEMomentumTraction
    variable = vel_y
    component = 1
  [../]
[]

# Operations defined on auxiliary variables that will be computed at end
[AuxKernels]

[]

# Model boundary conditions that need to be enforced
[BCs]
  [./inlet]
    type = DirichletBC
    variable = vel_x
    boundary = 'inlet'
    value = 1e0
  [../]
  [./outlet]
    type = DirichletBC
    variable = pressure
    boundary = 'outlet'
    value = 0.0
  [../]
  [./x_noslip]
    type = DirichletBC
    variable = vel_x
    boundary = 'no_slip dam'
    value = 0.0
  [../]
  [./y_noslip]
    type = DirichletBC
    variable = vel_y
    boundary = 'no_slip dam'
    value = 0.0
  [../]
[]

# Define postprocessor operations that can be used for viewing data/statistics
[Postprocessors]
[]

# Set up matrix preconditioner to improve convergence
[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

# Type of algorithm and convergence parameters used to solve the matrix problem
[Executioner]
  # Set solver to transient, with Newton-Raphson nonlinear solver
  type = Transient
  solve_type = NEWTON

  # Nonlinear solver parameters for nonlinear iterations and linear subiterations
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-10
  nl_max_its = 30
  l_tol = 1e-6
  l_max_its = 300
  dt = 0.5e-5
  end_time = 1e-3

  # PETSc solver options
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package '
  petsc_options_value = 'lu       superlu_dist'
[]

# Output files for viewing after model finishes
[Outputs]
  # Do not print linear residuals to stdout
  print_linear_residuals = false
  # Write results to exodus .e file
  [./exodus]
    type = Exodus
    # Set output folder and filename
    file_base = output/fluid
  [../]
[]
