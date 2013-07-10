require 'sinatra/base'
require 'pry'
require 'redis'
require 'securerandom'
require 'uri'

class UrlShort < Sinatra::Base
  set :public_dir, File.dirname(__FILE__) + '/static'
  
  def initialize
    super
    uri = URI.parse(ENV['REDIS_CLOUD'])
    @redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
  end

  helpers do
    include Rack::Utils
    def rand_base64(length)
       SecureRandom.base64(length).gsub("/","")
    end

    def rand_hash(length)
      gap = 36**(length) - 36**(length-1)
      (rand(gap) + 36**(length-1)).to_s(36) 
    end
  end

  get '/' do
    erb :index
  end

  post '/' do 
    @error = nil
    @error = 'please enter url' if URI.regexp.match(params[:url]).nil?
    @success = false
    
    unless @error
      if params[:url] and not params[:url].empty?
        @url = params[:url]
        @hash = rand_base64(5)
        exist = @redis.setnx "url:#{@url}", @hash
        if exist #key not set
          @redis.setnx "hash:#{@hash}", @url
        else
          @hash = @redis.get "url:#{@url}"
        end
        @success = true
      end
    end

    erb :index
  end

  get '/:hash' do
    url = @redis.get "hash:#{params[:hash]}" 
    redirect url
  end
end

UrlShort.run!
