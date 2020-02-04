class k8s::packages {
  package { 'socat':
    ensure => present
  }
}