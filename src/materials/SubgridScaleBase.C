#include "SubgridScaleBase.h"
#include "Assembly.h"
#include "NearestNodeLocator.h"
#include "MooseMesh.h"
#include "libmesh/tensor_tools.h"
#include "libmesh/type_vector.h"
#include "libmesh/node.h"

registerMooseObject("whaleApp", SubgridScaleBase);

defineLegacyParams(SubgridScaleBase);

InputParameters
SubgridScaleBase::validParams()
{
  InputParameters params = Material::validParams();
  params.addRequiredCoupledVar("u", "x-velocity component");
  params.addCoupledVar("v", 0, "y-velocity component");
  params.addCoupledVar("w", 0, "z-velocity component");

  params.addParam<MaterialPropertyName>("rho_name", "rho", "The name of the density");

  return params;
}

SubgridScaleBase::SubgridScaleBase(const InputParameters & parameters)
  : DerivativeMaterialInterface<Material>(parameters),
    _u_vel(coupledValue("u")),
    _v_vel(coupledValue("v")),
    _w_vel(coupledValue("w")),
    _grad_u_vel(isCoupled("u") ? coupledGradient("u") : _grad_zero),
    _grad_v_vel(isCoupled("v") ? coupledGradient("v") : _grad_zero),
    _grad_w_vel(isCoupled("w") ? coupledGradient("w") : _grad_zero),
    _u_vel_var_number(coupled("u")),
    _v_vel_var_number(coupled("v")),
    _w_vel_var_number(coupled("w")),
    _grad_phi(_assembly.gradPhi()),
    _rho(getMaterialProperty<Real>("rho_name")),
    _current_elem_volume(_assembly.elemVolume()),
    _mu_sgs(declareProperty<Real>("mu_sgs")),
    _dmu_dvel(_coupled_moose_vars.size()),
    _min_bnd_dist(declareProperty<Real>("bnd_dist")),
    _min_bnd_dist_old(getMaterialPropertyOld<Real>("bnd_dist"))
{
  for (unsigned i = 0; i < _coupled_moose_vars.size(); ++i)
  {
    _dmu_dvel[i] = &declarePropertyDerivative<Real>("mu_sgs", _coupled_moose_vars[i]->name());
  }
  // std::vector<Real> bdry_candidates(boundaryNames().size());
  // std::vector<BoundaryID> bID = _mesh.getBoundaryIDs(boundaryNames());
  // for (unsigned i = 0; i < boundaryNames().size(); ++i)
  // {
  //   NearestNodeLocator nearest_bdry_node(_subproblem, _mesh, bID[0], bID[i]);
  //   Node * qnode = _mesh.getQuadratureNode(_current_elem, _current_side, _qp);
  //   bdry_candidates[i] = nearest_bdry_node.distance(qnode->id());
  // }
  // _nearest_bdry_dist = *std::min_element(bdry_candidates.begin(), bdry_candidates.end());
}

void
SubgridScaleBase::initQpStatefulProperties()
{
  _mu_sgs[_qp] = 0;
  _min_bnd_dist[_qp] = computeMinBndDistance();
  for (unsigned i = 0; i < _dmu_dvel.size(); ++i)
  {
    (*_dmu_dvel[i])[_qp] = 0;
  }
}

Real
SubgridScaleBase::computeMinBndDistance()
{
  const Point * q = _q_point.data();
  Node * qnode = (Node *)q; //= _mesh.getQuadratureNode(_current_elem, _current_side, _qp);
  Real d = 1e6;
  // qnode->print();
  // std::cout << (*qnode)(1) << ", " << (*qnode)(1) << std::endl;

  for (MooseMesh::bnd_node_iterator n = _mesh.bndNodesBegin(); n != _mesh.bndNodesEnd(); n++)
  {
    Node * itnode = ((**n)._node);
    RealVectorValue R((*qnode) - (*itnode));
    d = std::min(R.norm(), d);
  }
  return d;
}

void
SubgridScaleBase::computeQpProperties()
{
  // _min_bnd_dist[_qp] = computeMinBndDistance();
  computeSGSviscosity();
}
