require 'sinatra'
require 'sinatra/reloader' if development?

require 'fileutils'

class KickstartServer < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  def initialize
    super

    @current_version = "0.1.0"
  end

  get '/kickstart' do
    mac = "#{%x[arp #{request.ip}].split(/\s+/)[3].gsub(':','')}"
    kickstart_file = "files/#{mac}.ks"

    if File.exists? kickstart_file
      # Basic cleanup
      FileUtils.mv( kickstart_file, "#{kickstart_file}.served")

      logger.info "Serving file for mac #{mac}.ks (#{kickstart_file}.served)"
      send_file "#{kickstart_file}.served"
    else
      logger.info "Can't locate kickstart for mac #{mac} (#{kickstart_file})"
      halt 404
    end
  end

  def current_version
    @current_version
  end

end
