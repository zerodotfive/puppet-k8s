require "puppet"
require 'fileutils'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "download.rb"))

Puppet::Type.type(:k8s_kubelet_binary_install).provide(:ruby) do
    def create
      url = "https://storage.googleapis.com/kubernetes-release/release/v#{resource[:version]}/bin/linux/amd64/kubelet"
      path = resource[:name]

      return nil if !download(url, path)

      fail "failed to download kubelet"
    end

    def destroy
      FileUtils.rm_rf resource[:name]
    end

    def exists?
      kubelet_output = Facter::Util::Resolution.exec("#{resource[:name]} --version")
      if !kubelet_output.nil?
        return true if Puppet::Util::Package.versioncmp(resource[:version], kubelet_output.split(/\s+/)[1].gsub(/^v/, '').strip()) == 0

        return false
      end

      return false
    end
end
