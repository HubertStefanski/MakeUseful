##MakeUseful misc recipies for whatever I need at the time, probably not so useful for you

##Grafana-Operator related

.PHONY: cluster/prepare/local
cluster/prepare/local:
	-kubectl create namespace ${NAMESPACE}
	kubectl apply -f deploy/crds
	kubectl apply -f deploy/roles -n ${NAMESPACE}
	kubectl apply -f deploy/cluster_roles
	kubectl apply -f deploy/examples/Grafana.yaml -n ${NAMESPACE}


.PHONY: cluster/cleanup	
cluster/cleanup: operator/stop
	-kubectl delete deployment grafana-deployment -n ${NAMESPACE}
	-kubectl delete namespace ${NAMESPACE}


.PHONY: operator/deploy
operator/deploy: cluster/prepare/local
	kubectl apply -f deploy/operator.yaml -n ${NAMESPACE}


.PHONY: operator/stop
operator/stop:
	-kubectl delete deployment grafana-operator -n ${NAMESPACE}

## assuming operator is running locally, as the name indicates, for quick resets between debugging
.PHONY: reset/test
reset/test: cluster/cleanup cluster/prepare/local dashboards


.PHONY: dashboards
dashboards:
	oc apply -f deploy/examples/dashboards/DashboardWithCustomFolder.yaml -n grafana
	oc apply -f deploy/examples/dashboards/SimpleDashboard.yaml -n grafana
	oc apply -f deploy/examples/dashboards/KeycloakDashboard.yaml -n grafana

.PHONY: minikube
minikube:
	-minikube start
	-minikube addons enable ingress

.PHONY: minikube/stop
minikube/stop:
	-minikube stop

.PHONY: minikube/delete
minikube/delete:
	-minikube delete

## restart minikube
.PHONY: minikube/reset
minikube/reset: minikube/stop minikube/delete minikube/start
	
## Get OCM cluster credentials 
.PHONY: get/ocm/credentials
get/ocm/credentials: 
	ocm get /api/clusters_mgmt/v1/clusters/${CLUSTERID}/credentials | jq -r .admin
