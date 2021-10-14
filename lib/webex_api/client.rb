require 'webex_api/webex_error'
require 'webex_api/request'
require 'webex_api/meeting_request'
require 'webex_api/meeting'
require 'webex_api/event_request'
require 'webex_api/event'
require 'webex_api/get_login_ticket'
require 'webex_api/authenticate_user_request'

module WebexApi
  class Client
    attr_accessor :webex_id,
                  :webex_password,
                  :site_id,
                  :site_name,
                  :partner_id,
                  :webex_email,
                  :site_name,
                  :access_token,
                  :session_ticket,
                  :debug

    def initialize(webex_id, webex_email, site_name, site_id=nil, partner_id=nil, debug=false)
      @webex_id = webex_id
      @site_name = site_name
      @debug = debug
    end

    def with_access_token(access_token)
      @access_token = access_token
    end

    def with_password(password)
      @webex_password = password
    end

    def authenticate_user(access_token)
      authenticate_user_request = WebexApi::AuthenticateUserRequest.new(self)
      session_ticket = authenticate_user_request.authenticate_user(access_token)
    end

    def set_session_ticket
      if @access_token && !@session_ticket
        @session_ticket = authenticate_user @access_token
      end
    end

    def create_meeting(name, options={})
      set_session_ticket
      meeting = WebexApi::Meeting.create_meeting(self, name, options)
    end

    def create_meetings(meetings)
      set_session_ticket
      meeting = WebexApi::Meeting.create_meetings(self, meetings)
    end

    def create_event(name, options={})
      set_session_ticket
      meeting = WebexApi::Event.create_event(self, name, options)
    end

    def delete_event(name)
      set_session_ticket
      meeting = WebexApi::Event.delete_event(self, name)
    end

    def set_meeting(name, meeting_key, options={})
      set_session_ticket
      meeting = WebexApi::Meeting.set_meeting(self, name, meeting_key, options)
    end

    def get_recording(meeting_name)
      set_session_ticket
      recording = WebexApi::Meeting.get_recording_info(self, meeting_name)
    end

    def get_meeting(meeting_key)
      set_session_ticket
      meeting = WebexApi::Meeting.new(meeting_key,self)
      meeting.get_meeting
      meeting
    end

    def get_meeting_host_url(meeting_key,user_email=nil)
      set_session_ticket
      meeting = WebexApi::Meeting.new(meeting_key,self)
      meeting.get_host_url(user_email)
    end

    def get_meeting_join_url(meeting_key,user_email=nil)
      set_session_ticket
      meeting = WebexApi::Meeting.new(meeting_key,self)
      meeting.get_join_url(user_email)

    end

    def delete_meeting(meeting_key)
      set_session_ticket
      meeting = WebexApi::Meeting.new(meeting_key,self)
      meeting.delete_meeting
    end
    # option {:name=>"ss",:address_type=>"PERSONAL or GLOBAL",:role=>"ATTENDEE or PRESENTER or HOST"}
    def add_attendee_to_meeting(meeting_key,user_email,options={})
      set_session_ticket
      meeting = WebexApi::Meeting.new(meeting_key,self)
      meeting.add_attendee(user_email,options)
    end

    def delete_attendee_from_meeting(meeting_key,user_email)
      set_session_ticket
      meeting = WebexApi::Meeting.new(meeting_key,self)
      meeting.delete_attendee(user_email)
    end
    def list_attendee_for_meeting(meeting_key)
      set_session_ticket
      meeting = WebexApi::Meeting.new(meeting_key,self)
      meeting.list_attendees
    end

  end
end
