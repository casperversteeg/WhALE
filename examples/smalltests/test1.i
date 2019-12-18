[Debug]
#   show_actions = true
  show_var_residual_norms = true
#   show_parser = true
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
    nx = 2
    ny = 1
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
[]


[Variables]
  [vel_x]
    order = SECOND
    family = LAGRANGE
  []
  [vel_y]
    order = SECOND
    family = LAGRANGE
  []
  [p]
    order = FIRST
    family = LAGRANGE
  []
  [disp_x]
    order = SECOND
    family = LAGRANGE
  []
  [disp_y]
    order = SECOND
    family = LAGRANGE
  []
[]

[Kernels]
  [mass]
    type = INSMass
    variable = p
    u = vel_x
    v = vel_y
    p = p
    block = 'fluid'
  []
  [x_convection]
    type = INSALEMomentumConvection
    variable = vel_x
    component = 0
    u = vel_x
    v = vel_y
    p = p
    mesh_x = disp_x
    mesh_y = disp_y
    block = 'fluid'
  []
  [y_convection]
    type = INSALEMomentumConvection
    variable = vel_y
    component = 1
    u = vel_x
    v = vel_y
    p = p
    mesh_x = disp_x
    mesh_y = disp_y
    block = 'fluid'
  []
  [x_viscous]
    type = INSALEMomentumTraction
    variable = vel_x
    component = 0
    u = vel_x
    v = vel_y
    p = p
    block = 'fluid'
  []
  [y_viscous]
    type = INSALEMomentumTraction
    variable = vel_y
    component = 1
    u = vel_x
    v = vel_y
    p = p
    block = 'fluid'
  []
  [x_diffusion]
    type = Diffusion
    variable = disp_x
  []
  [y_diffusion]
    type = Diffusion
    variable = disp_y
  []
[]

[Materials]
  [const]
    type = GenericConstantMaterial
    # block = 'fluid'
    prop_names = 'rho mu'
    prop_values = '1 1'
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

  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-7
  nl_max_its = 150
  l_tol = 1e-6
  #l_max_its = 300
  end_time = 2e-3

  solve_type = 'NEWTON'
[]

[Outputs]
  [exodus]
    type = Exodus
  []
[]
