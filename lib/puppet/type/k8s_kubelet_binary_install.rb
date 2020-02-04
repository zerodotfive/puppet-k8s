Puppet::Type.newtype(:k8s_kubelet_binary_install) do
  ensurable

  newparam(:name, :namevar => true)
  newparam(:version)
end

