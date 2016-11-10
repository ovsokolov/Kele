require 'httparty'
require 'json'
require_relative './errors/bloc_io_error'

class Kele
  include HTTParty
  base_uri 'https://www.bloc.io/api/v1'

  attr_accessor :auth_token, :student_data, :mentor_availability

  def initialize( name, password )
    result = self.class.post('/sessions', :body => {"email" => name, "password" => password})
    raise BlocIoError, result["message"] unless result.code == 200
    @auth_token = result["auth_token"]
  end

  def get_me
    result = self.class.get('/users/me', headers: { "authorization" => @auth_token })
    @student_data = JSON.parse(result.body)
  end

  def get_mentor_availability
    self.get_me if @student_data.nil?
    mentor_id = @student_data["current_enrollment"]["mentor_id"]
    url = "/mentors/#{mentor_id}/student_availability"
    result = self.class.get(url, headers: { "authorization" => @auth_token }, :body => {"id" => mentor_id})
    @mentor_availability = JSON.parse(result.body)
  end
end
