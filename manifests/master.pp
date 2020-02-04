class k8s::master {
  $k8s_version = lookup('k8s::version')
  $k8s_etcd_urls = lookup('k8s::etcd_urls')
  $k8s_service_cluster_ip_range = lookup('k8s::service_cluster_ip_range')
  $k8s_cluster_cidr = lookup('k8s::cluster_cidr')
  $k8s_cluster_dns = lookup('k8s::cluster_dns')
  $k8s_node_cidr_mask_size = lookup('k8s::node_cidr_mask_size')
  $k8s_internal_interface = lookup('k8s::internal_interface')
  $k8s_internal_ip = inline_template("<%= scope.lookupvar('::ipaddress_${k8s_internal_interface}') -%>")

  class {'k8s::worker':}
  class {'k8s::ssl::apiserver':}
  class {'k8s::ssl::controller_manager':}
  class {'k8s::ssl::scheduler':}

  file { [
    '/etc/kubernetes/addons',
    '/var/lib/kube-apiserver',
    '/var/lib/kube-scheduler',
    '/var/lib/kube-controller-manager'
  ]:
    ensure  => directory,
    require => Class['k8s::worker']
  }

  file { '/var/lib/kube-scheduler/kubeconfig':
    ensure  => file,
    source  => 'puppet:///modules/k8s/kubeconfig-scheduler',
    require => Class['k8s::ssl::scheduler']
  }

  file { '/var/lib/kube-scheduler/scheduler-policy.json':
    ensure  => file,
    source  => 'puppet:///modules/k8s/scheduler-policy.json',
    require => Class['k8s::ssl::scheduler']
  }

  file { '/etc/kubernetes/manifests/kube-scheduler.manifest':
    ensure  => file,
    content => template('k8s/kube-scheduler.manifest.erb'),
    require => File[
      '/var/lib/kube-scheduler/kubeconfig',
      '/var/lib/kube-scheduler/scheduler-policy.json'
    ]
  }

  file { '/var/lib/kube-controller-manager/kubeconfig':
    ensure  => file,
    source => 'puppet:///modules/k8s/kubeconfig-controller-manager',
    require => Class['k8s::ssl::controller_manager']
  }

  file { '/etc/kubernetes/manifests/kube-controller-manager.manifest':
    ensure  => file,
    content => template('k8s/kube-controller-manager.manifest.erb'),
    require => File[
      '/var/lib/kube-scheduler/kubeconfig'
    ]
  }

  file { '/etc/kubernetes/manifests/kube-apiserver.manifest':
    ensure  => file,
    content => template('k8s/kube-apiserver.manifest.erb'),
    require => Class['k8s::ssl::apiserver']
  }

  file { '/etc/kubernetes/manifests/kube-addon-manager.manifest':
    ensure  => file,
    content => template('k8s/kube-addon-manager.manifest.erb')
  }

  file { '/etc/kubernetes/addons/calico.yaml':
    ensure  => file,
    content => template('k8s/calico.yaml.erb')
  }

  file { '/etc/kubernetes/addons/coredns.yaml':
    ensure  => file,
    content => template('k8s/coredns.yaml.erb')
  }

  file { '/etc/kubernetes/addons/bootstrap.yaml':
    ensure  => file,
    content => template('k8s/bootstrap.yaml.erb')
  }
}
