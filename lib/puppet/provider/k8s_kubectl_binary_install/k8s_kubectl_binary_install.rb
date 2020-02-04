require "puppet"
require 'fileutils'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "download.rb"))

Puppet::Type.type(:k8s_kubectl_binary_install).provide(:ruby) do
    def create
      url = "https://storage.googleapis.com/kubernetes-release/release/v#{resource[:version]}/bin/linux/amd64/kubectl"
      path = resource[:name]

      return nil if !download(url, path)

      fail "failed to download kubectl"
    end

    def destroy
      FileUtils.rm_rf resource[:name]
    end

    def exists?
      kubectl_output = Facter::Util::Resolution.exec("#{resource[:name]} version")
      if !kubectl_output.nil?
        kubectl_output.each_line do |line|
          line.strip!
          if line.include? 'Client Version:'
            line.split(/version\.Info/)[1].gsub(/^\{|\}$/, '').split(',').each do |param|
              param.strip!
              if param.include? 'GitVersion:'
                return true if Puppet::Util::Package.versioncmp(resource[:version], param.split(':')[1].gsub(/^"v|"$/, '')) == 0

                return false
              end
            end
          end
        end
      end

      return false
    end
end
