TERRAFORM=terraform
BASE_TARGETS=-target=module.vpc -target=module.nat_instance -target=aws_key_pair.poc2_key -target=tls_private_key.rsa_key -target=local_file.private_key -target=module.lab_sg

.PHONY: init vpc docker compose podman swarm k3s all destroy

init:
	$(TERRAFORM) init

validate:
	$(TERRAFORM) validate

plan:
	$(TERRAFORM) plan

vpc:
	$(TERRAFORM) apply -auto-approve $(BASE_TARGETS)

docker:
	$(TERRAFORM) apply -auto-approve $(BASE_TARGETS) -target=module.docker_host

compose:
	$(TERRAFORM) apply -auto-approve $(BASE_TARGETS) -target=module.compose_host

podman:
	$(TERRAFORM) apply -auto-approve $(BASE_TARGETS) -target=module.podman_host

swarm:
	$(TERRAFORM) apply -auto-approve $(BASE_TARGETS) -target=module.swarm_nodes

k3s:
	$(TERRAFORM) apply -auto-approve $(BASE_TARGETS) -target=module.sg_k3s -target=module.k3s_server

get-k3s-config:
	scp -i actividad6-dev-key.pem -o StrictHostKeyChecking=no ubuntu@$$(terraform output -raw k3s_public_ip):/etc/rancher/k3s/k3s.yaml k3s.yaml
	sed -i '' "s/127.0.0.1/$$(terraform output -raw k3s_public_ip)/g" k3s.yaml
	@echo "Kubeconfig descargado y actualizado con la IP pública. Ya puedes usar 'kubectl get nodes'."

all:
	$(TERRAFORM) apply -auto-approve

destroy:
	$(TERRAFORM) destroy -auto-approve
