package main

deny[msg] {
  input.kind = "Service"
  input.spec.type = "NodePort"
  msg = "Service type should be NodePort"
}

# deny images that do not come from from registry.example.com
deny[msg] {
    input.request.kind.kind == "Deployment"
    image := input.request.object.spec.template.spec.containers[_].image
    not startswith(image, "registry.example.com")
    msg := sprintf("Image %v comes from untrusted registry.", [image])
}

# deny privileged containers
deny[msg] {
    input.request.kind.kind == "Deployment"
    container := input.request.object.spec.template.spec.containers[_]
    container.securityContext.privileged
    msg := sprintf("Container %v runs in privileged mode. Please specify the 'privileged: false' option in the container securityContext.'", [container.name])
}

# deny containers running as root
deny[msg] {
    input.request.kind.kind == "Deployment"
    container := input.request.object.spec.template.spec.containers[_]
    not container.securityContext.RunAsNonRoot
    msg := sprintf("Container %v running as a root. Please specify the 'RunAsNonRoot: true' option in the container securityContext.'", [container.name])
}

# deny pods running as root
deny[msg] {
    input.request.kind.kind == "Deployment"
    not input.request.object.spec.template.spec.securityContext.RunAsNonRoot
    msg := "Pod running as a root. Please specify the 'RunAsNonRoot: true' option in the Pod securityContext.'"
}

# deny containers that allow privilege escalation
deny[msg] {
    input.request.kind.kind == "Deployment"
    container := input.request.object.spec.template.spec.containers[_]
    not container.securityContext.allowPrivilegeEscalation
    msg := sprintf("Container %v allows privilege escalation. Please specify the 'allowPrivilegeEscalation: false' option in the container securityContext.", [container.name])
}

# deny containers that do not drop kernel capabilities
deny[msg] {
    input.request.kind.kind == "Deployment"
    container := input.request.object.spec.template.spec.containers[_]
    dropcap := container.securityContext.capabilties.drop[_]
    dropcap  == "ALL"
    msg := sprintf("Container %v allows unnecessary kernel capabilities. Please add the capabilities.drop: ['ALL'] option to the container securityContext. Specific capabilities can be added, if required, using the capabilities.add option in the container securityContext.", [container.name])
}

# deny containers that add CAP_SYS_ADMIN
deny[msg] {
    input.request.kind.kind == "Deployment"
    container := input.request.object.spec.template.spec.containers[_]
    addcap := container.securityContext.capabilities.add[_]
    addcap == "CAP_SYS_ADMIN"
    msg := sprintf("Container %v adds CAP_SYS_ADMIN kernel capability.", [container.name])
}

deny[msg] {
    # apply policy to all Pod resources
    input.request.kind.kind == "Pod"
    # get all containers in the Pod
    container := input.request.object.spec.containers[_]
    # for each container's securityContext, check the privileged field
    container.securityContext.privileged
    # if the privileged field is true, return the following message
    msg := sprintf("Container %v runs in privileged mode.", [container.name])
}