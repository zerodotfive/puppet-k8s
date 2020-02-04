class k8s::worker {
  $k8s_version = lookup('k8s::version')
  $k8s_internal_interface = lookup('k8s::internal_interface')
  $k8s_internal_ip = inline_template("<%= scope.lookupvar('::ipaddress_${k8s_internal_interface}') -%>")
  $k8s_cluster_dns = lookup('k8s::cluster_dns')
  $k8s_cluster_cidr = lookup('k8s::cluster_cidr')
  $k8s_node_labels = lookup('k8s::node_labels', Data, 'first', undef)
  $k8s_node_taints = lookup('k8s::node_taints', Data, 'first', undef)

  $k8s_bootstrap_crt = lookup('k8s::bootstrap_crt', Data, 'first', undef)
  $k8s_bootstrap_key = lookup('k8s::bootstrap_key', Data, 'first', undef)
  $k8s_kubelet_crt = lookup('k8s::kubelet_crt', Data, 'first', undef)
  $k8s_kubelet_key = lookup('k8s::kubelet_key', Data, 'first', undef)

  class {'k8s::haproxy':}
  class {'k8s::packages':}

  class {'k8s::ssl::kubelet':
    require => Class['k8s::haproxy']
  }
  class {'k8s::ssl::proxy':}

  k8s_kubelet_binary_install { '/usr/local/bin/kubelet':
    ensure  => present,
    version => lookup('k8s::version'),
    require => Service['docker'],
    notify  => Service['kubelet']
  }

  file { '/etc/default/kubelet':
    ensure  => file,
    content => template('k8s/kubelet.erb'),
    notify  => [
      Service['kubelet']
    ]
  }

  file { '/lib/systemd/system/kubelet.service':
    ensure => file,
    source => 'puppet:///modules/k8s/kubelet.service',
    notify => [
      Exec['kubelet_service_install_systemctl_daemon_reload'],
      Service['kubelet']
    ]
  }

  exec { 'kubelet_service_install_systemctl_daemon_reload':
    command     => '/bin/systemctl daemon-reload',
    require     => File['/lib/systemd/system/kubelet.service'],
    refreshonly => true
  }

  file { [
    '/etc/kubernetes',
    '/etc/kubernetes/manifests',
    '/var/lib/kubelet',
    '/var/lib/kube-proxy',
    '/opt/cni',
    '/opt/cni/bin'
  ]:
    ensure => directory
  }

  file { '/var/lib/kubelet/kubeconfig':
    ensure  => file,
    source  => 'puppet:///modules/k8s/kubeconfig-kubelet',
    require => Class['k8s::ssl::kubelet'],
    notify  => [
      Service['kubelet']
    ]
  }

  if $k8s_bootstrap_crt != undef and $k8s_bootstrap_key != undef {
    file { '/var/lib/kubelet/kubeconfig-bootstrap':
      ensure  => file,
      source  => 'puppet:///modules/k8s/kubeconfig-bootstrap',
      require => Class['k8s::ssl::kubelet'],
      notify  => [
        Service['kubelet']
      ]
    }
  }

  service { 'kubelet':
    ensure  => running,
    enable  => true,
    require => [
      Exec['kubelet_service_install_systemctl_daemon_reload'],
      K8s_kubelet_binary_install['/usr/local/bin/kubelet'],
      File[
        '/etc/default/kubelet',
        '/opt/cni/bin'
      ]
    ]
  }

  file { '/var/lib/kube-proxy/kubeconfig':
    ensure  => file,
    source  => 'puppet:///modules/k8s/kubeconfig-kube-proxy',
    notify  => [
      Service['kubelet'],
      Class['k8s::ssl::proxy']
    ]
  }

  file { '/etc/kubernetes/manifests/kube-proxy.manifest':
    ensure  => file,
    content => template('k8s/kube-proxy.manifest.erb'),
    require => File[
      '/etc/kubernetes/manifests',
      '/var/lib/kube-proxy/kubeconfig'
    ]
  }
}
