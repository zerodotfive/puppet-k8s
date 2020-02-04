class k8s::kubectl {
  k8s_kubectl_binary_install { '/usr/local/bin/kubectl':
    ensure  => present,
    version => lookup('k8s::version')
  }
}
