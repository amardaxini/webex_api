module WebexApi
  class Meeting
    attr_reader :xml
    MEETING_ATTRIBUTES  = [:conf_name,:start_date,:host_joined,:status]

    def initialize(meeting_key,client)
      @meeting_key= meeting_key
      @email =  email
      @client = client
    end

    def self.create_meeting(client,name,options={})
      meeting_request = WebexApi::MeetingRequest.new(client)
      meeting_request.create_meeting(name,options)
      meeting_key = meeting_request.xml_response.at_xpath('//meetingkey').try(:text)
    end

    def get_meeting
      meeting_info = WebexApi::MeetingRequest.new(@client)
      meeting_info.get_meeting(@meeting_key)
      @xml = meeting_info.xml_response
    end

    def delete_meeting
      meeting_request = WebexApi::MeetingRequest.new(@client)
      meeting_request.delete_meeting(@meeting_key)
      meeting_request.success
    end

    
    def get_host_url(email=nil)
      meeting_request = WebexApi::MeetingRequest.new(@client)
      meeting_request.get_host_meeting_url(@meeting_key)
      meeting_request.xml_response.at_xpath('hostMeetingURL').try(:text)
    end

    def get_join_url(email=nil)
      meeting_request = WebexApi::MeetingRequest.new(@client)
      meeting_request.get_join_meeting_url(@meeting_key)
      meeting_request.xml_response.at_xpath('joinMeetingURL').try(:text)
    end

    def add_attendee(user_email,user_info={})
      meeting_request = WebexApi::MeetingRequest.new(@client)
      meeting_request.add_attendee(@meeting_key,user_email,user_info)
      meeting_request.success
    end

    def delete_attendee(user_email)
      meeting_request = WebexApi::MeetingRequest.new(@client)
      meeting_request.delete_attendee(@meeting_key,user_email)

      meeting_request.success
    end
    def list_attendees
      meeting_request = WebexApi::MeetingRequest.new(@client)
      meeting_request.list_attendees(@meeting_key)
      @xml = meeting_request.xml_response
    end
    def method_missing(meth, *args, &block)
      if MEETING_ATTRIBUTES.include?(meth)
        @meeting_attr[meth] ||= @xml.at_xpath("//*[contains(translate(name(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'), '#{meth.to_s.camelcase(:lower).downcase}')]").try(:text)
      end
    end


    
  end
end