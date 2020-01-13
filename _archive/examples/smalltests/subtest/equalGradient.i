#
# This test demonstrates an InterfaceKernel set that can enforce the componentwise
# continuity of the gradient of a variable using the Lagrange multiplier method.
#

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 20
    ny = 10
    ymax = 0.5
  []
  [./box1]
    type = SubdomainBoundingBoxGenerator
    block_id = 1
    bottom_left = '0 0 0'
    top_right = '0.51 1 0'
    input = gen
  [../]
  [./box2]
    type = SubdomainBoundingBoxGenerator
    block_id = 2
    bottom_left = '0.49 0 0'
    top_right = '1 1 0'
    input = box1
  [../]
  [./iface_u]
    type = SideSetsBetweenSubdomainsGenerator
    master_block = 1
    paired_block = 2
    new_boundary = 10
    input = box2
  [../]
[]

[Variables]
  [./u]
    [./InitialCondition]
      type = FunctionIC
      function = 'if(x<0.5,1-x,0)'
    []
  [../]
[]

[Kernels]
  [./u2_diff]
    type = Diffusion
    variable = u
    block = 1
  [../]
  [./u2_dt]
    type = TimeDerivative
    variable = u
    block = 1
  [../]
  [./v2_diff]
    type = Diffusion
    variable = u
    block = 2
  [../]
  [./v2_reac]
    type = BodyForce
    value = 1
    variable = u
    block = 2
  [../]
  [./v2_dt]
    type = TimeDerivative
    variable = u
    block = 2
  [../]
[]

[InterfaceKernels]
  [reaction]
    type = InterfaceReaction
    variable = u
    neighbor_var = u
    kf = 1
    kb = 1
    boundary = 10
  []
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient

  petsc_options_iname = '-pctype -sub_pc_type -sub_pc_factor_shift_type -pc_factor_shift_type'
  petsc_options_value = ' asm    lu          nonzero                    nonzero'

  dt = 0.002
  num_steps = 100
[]

[Outputs]
  exodus = true
  # hide = lambda
  print_linear_residuals = false
[]
