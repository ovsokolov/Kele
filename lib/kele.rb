require 'httparty'
require 'json'
require_relative './errors/bloc_io_error'
require_relative './raodmap_checkpoint'

class Kele
  include HTTParty, RoadMapAndCheckPoint
  base_uri 'https://www.bloc.io/api/v1'

  attr_accessor :auth_token, :student_data, :mentor_availability, :roadmap, :checkpoints, :messages

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

  def get_messages(page_no=0)
    result = self.class.get('/message_threads', headers: { "authorization" => @auth_token }, :body => {"page" => page_no}) if page_no > 0
    result = self.class.get('/message_threads', headers: { "authorization" => @auth_token }) if page_no == 0
    @messages = result
  end

  def create_message(message_text, message_subject, thread_id=0)
    student_id = @student_data["id"]
    mentor_id = @student_data["current_enrollment"]["mentor_id"]
    if thread_id == 0
      result = self.class.post('/messages', headers: { "authorization" => @auth_token }, :body => {"user_id" => student_id, "recipient_id" => mentor_id, "subject" => message_subject, "stripped-text" => message_text})
    else
      thread_token = get_thread_token(thread_id)
      result = self.class.post('/messages', headers: { "authorization" => @auth_token }, :body => {"user_id" => student_id, "recipient_id" => mentor_id, "token" => thread_token, "subject" => message_subject, "stripped-text" => message_text})
    end
  end

  def get_thread_token(thread_id)
    threads = @messages["items"]
    threads.each do |thread|
      if thread["id"] == thread_id
        return thread["token"]
      end
    end
    return nil
  end

  def create_submission(checkpoint_id,assignment_branch, assignment_commit_link, comment)
    enrollment_id = @student_data["current_enrollment"]["id"]
    result = self.class.post('/checkpoint_submissions', headers: { "authorization" => @auth_token }, :body => {"enrollment_id" => enrollment_id, "checkpoint_id" => checkpoint_id, "assignment_branch" => assignment_branch, "assignment_commit_link" => assignment_commit_link, "comment" => comment})
  end

end
