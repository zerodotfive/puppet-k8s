require 'tempfile'
require 'fileutils'
require 'net/http'

def download(url, path)
  u = URI(url)

  Net::HTTP.start(u.host, u.port, :use_ssl => true) do |http|
    request = Net::HTTP::Get.new u

    http.request request do |response|
      return true if !response.is_a?(Net::HTTPSuccess)
      tempfile = Tempfile.new("kubectl")
      response.read_body do |chunk|
        tempfile.write chunk
      end
      tempfile.close
      FileUtils.chmod(0755, tempfile.path)
      FileUtils.mv(tempfile.path, path)

      return false
    end
  end
  return true
end
