class k8s::haproxy {
  $k8s_apiservers = lookup('k8s::apiservers')

  package { 'haproxy':
    ensure => present
  }

  file { '/etc/haproxy/haproxy.cfg':
    ensure  => file,
    content => template('k8s/haproxy.cfg.erb'),
    require => Package['haproxy'],
    notify  => Service['haproxy']
  }->

  service { 'haproxy':
    ensure  => running,
    enable  => true,
    require => [
      Package['haproxy'],
      File['/etc/haproxy/haproxy.cfg']
    ]
  }
}