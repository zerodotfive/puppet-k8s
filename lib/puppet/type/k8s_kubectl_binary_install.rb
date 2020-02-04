Puppet::Type.newtype(:k8s_kubectl_binary_install) do
  ensurable

  newparam(:name, :namevar => true)
  newparam(:version)
end

