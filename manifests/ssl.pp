class k8s::ssl::kubelet {
  file { '/var/lib/kubelet/pki':
    ensure => directory,
    require => File['/var/lib/kubelet']
  }

  file { '/var/lib/kubelet/pki/ca.crt':
    ensure  => file,
    content => lookup('k8s::ca_crt'),
    require => File['/var/lib/kubelet/pki']
  }

  if $k8s::worker::k8s_bootstrap_crt != undef and $k8s::worker::k8s_bootstrap_key != undef {
    file { '/var/lib/kubelet/pki/bootstrap.crt':
      ensure  => file,
      content => $k8s::worker::k8s_bootstrap_crt,
      require => File['/var/lib/kubelet/pki']
    }

    file { '/var/lib/kubelet/pki/bootstrap.key':
      ensure  => file,
      content => $k8s::worker::k8s_bootstrap_key,
      require => File['/var/lib/kubelet/pki']
    }
  }

  if $k8s::worker::k8s_kubelet_crt != undef and $k8s::worker::k8s_kubelet_key != undef {
    file { '/var/lib/kubelet/pki/kubelet-client.crt':
      ensure  => file,
      content => $k8s::worker::k8s_kubelet_crt,
      require => File['/var/lib/kubelet/pki']
    }->

    file { '/var/lib/kubelet/pki/kubelet-client.key':
      ensure  => file,
      content => $k8s::worker::k8s_kubelet_key,
      require => File['/var/lib/kubelet/pki']
    }
  }
}

class k8s::ssl::apiserver {
  file { '/var/lib/kube-apiserver/pki':
    ensure => directory,
    require => File['/var/lib/kube-apiserver']
  }

  file { '/var/lib/kube-apiserver/pki/apiserver.crt':
    ensure  => file,
    content => lookup('k8s::apiserver_crt'),
    require => File['/var/lib/kube-apiserver/pki']
  }

  file { '/var/lib/kube-apiserver/pki/apiserver.key':
    ensure  => file,
    content => lookup('k8s::apiserver_key'),
    require => File['/var/lib/kube-apiserver/pki']
  }

  file { '/var/lib/kube-apiserver/pki/ca.crt':
    ensure  => file,
    content => lookup('k8s::ca_crt'),
    require => File['/var/lib/kube-apiserver/pki']
  }

  file { '/var/lib/kube-apiserver/pki/service-accounts.crt':
    ensure  => file,
    content => lookup('k8s::service_accounts_crt'),
    require => File['/var/lib/kube-apiserver/pki']
  }
}

class k8s::ssl::scheduler {
  file { '/var/lib/kube-scheduler/pki':
    ensure => directory,
    require => File['/var/lib/kube-scheduler']
  }

  file { '/var/lib/kube-scheduler/pki/ca.crt':
    ensure  => file,
    content => lookup('k8s::ca_crt'),
    require => File['/var/lib/kube-scheduler/pki']
  }

  file { '/var/lib/kube-scheduler/pki/scheduler.crt':
    ensure  => file,
    content => lookup('k8s::scheduler_crt'),
    require => File['/var/lib/kube-scheduler/pki']
  }

  file { '/var/lib/kube-scheduler/pki/scheduler.key':
    ensure  => file,
    content => lookup('k8s::scheduler_key'),
    require => File['/var/lib/kube-scheduler/pki']
  }
}

class k8s::ssl::controller_manager {
  file { '/var/lib/kube-controller-manager/pki':
    ensure => directory,
    require => File['/var/lib/kube-controller-manager']
  }

  file { '/var/lib/kube-controller-manager/pki/controller-manager.crt':
    ensure  => file,
    content => lookup('k8s::controller_manager_crt'),
    require => File['/var/lib/kube-controller-manager/pki']
  }

  file { '/var/lib/kube-controller-manager/pki/controller-manager.key':
    ensure  => file,
    content => lookup('k8s::controller_manager_key'),
    require => File['/var/lib/kube-controller-manager/pki']
  }

  file { '/var/lib/kube-controller-manager/pki/ca.crt':
    ensure  => file,
    content => lookup('k8s::ca_crt'),
    require => File['/var/lib/kube-controller-manager/pki']
  }

  file { '/var/lib/kube-controller-manager/pki/ca.key':
    ensure  => file,
    content => lookup('k8s::ca_key'),
    require => File['/var/lib/kube-controller-manager/pki']
  }

  file { '/var/lib/kube-controller-manager/pki/service-accounts.key':
    ensure  => file,
    content => lookup('k8s::service_accounts_key'),
    require => File['/var/lib/kube-controller-manager/pki']
  }
}

class k8s::ssl::proxy {
  file { '/var/lib/kube-proxy/pki':
    ensure => directory,
    require => File['/var/lib/kube-proxy']
  }

  file { '/var/lib/kube-proxy/pki/kube-proxy.crt':
    ensure  => file,
    content => lookup('k8s::kube_proxy_crt'),
    require => File['/var/lib/kube-proxy/pki']
  }

  file { '/var/lib/kube-proxy/pki/kube-proxy.key':
    ensure  => file,
    content => lookup('k8s::kube_proxy_key'),
    require => File['/var/lib/kube-proxy/pki']
  }

  file { '/var/lib/kube-proxy/pki/ca.crt':
    ensure  => file,
    content => lookup('k8s::ca_crt'),
    require => File['/var/lib/kube-proxy/pki']
  }
}
