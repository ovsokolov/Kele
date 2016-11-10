require 'httparty'
require_relative './errors/bloc_io_error'

class Kele
  include HTTParty
  base_uri 'https://www.bloc.io/api/v1'

  attr_accessor :auth_token

  def initialize( name, password )
    result = self.class.post('/sessions', :body => {"email" => name, "password" => password})
    raise BlocIoError, result["message"] unless result.code == 200
    @auth_token = result["auth_token"]
  end
end
