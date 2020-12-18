module WebexApi
  class Meeting
    attr_reader :xml
    MEETING_ATTRIBUTES  = [:conf_name,:start_date,:host_joined,:status]

    def initialize(meeting_key,client)
      @meeting_key= meeting_key
      @email =  email
      @client = client
    end

    def self.create_meeting(client,names,meeting_options={})
      meetings_request = WebexApi::MeetingRequest.new(client)
      meetings_request.create_meeting(names,options)

      if meeting_key
        return {
          key: meeting_key,
          password: meeting_request.xml_response.at_xpath('//meetingPassword')&.text,
          ical_host_url: meeting_request.xml_response.at_xpath('//host')&.text,
          ical_attendee_url: meeting_request.xml_response.at_xpath('//attendee')&.text,
          uuid: meeting_request.xml_response.at_xpath('//meetingUUID')&.text,
        }
      else
        return nil
      end
    end

    def self.create_meetings(client, meetings)
      meeting_request = WebexApi::MeetingRequest.new(client)
      meeting_request.create_meetings(meetings)

      create_meetings_response = {}

      meeting_request.xml_response.xpath("//bodyContent").each do |meeting|
        meeting_key = meeting.at("meetingkey")&.text

        create_meetings_response[meeting_key] = {
          key: meeting_key,
          password: meeting.at('meetingPassword')&.text,
          ical_host_url: meeting.at('host')&.text,
          ical_attendee_url: meeting.at('attendee')&.text,
          uuid: meeting.at('meetingUUID')&.text,
        }
      end

      meeting_keys = create_meetings_response.keys
      meetings_info = WebexApi::MeetingRequest.new(client)
      meetings_info.get_meetings(meeting_keys)
      meetings_info_response = meetings_info.xml_response

      result = {}
      meetings_info_response.xpath("//bodyContent").each do |meeting|
        meeting_key  = meeting.at("meetingkey")&.text
        meeting_name = meeting.at("confName")&.text

        result[meeting_name]                  = create_meetings_response[meeting_key]
        result[meeting_name][:title]          = meeting_name
        result[meeting_name][:host_key]       = meeting.at("hostKey")&.text
        result[meeting_name][:web_link]       = meeting.at("meetingLink")&.text
        result[meeting_name][:sip_address]    = meeting.at("sipURL")&.text
        result[meeting_name][:call_in_number] = meeting.at("tollNum")&.text
      end

      result
    end

    def self.get_recording_info(client, meeting_name)
      meeting_request = WebexApi::MeetingRequest.new(client)
      meeting_request.get_recording_info(meeting_name)

      puts meeting_request.xml_response
      if meeting_request.xml_response.at_xpath('//total').text.to_i >= 1
        stream_urls = meeting_request.xml_response.xpath("//streamURL").map do |url|
          url.text
        end

        file_urls = meeting_request.xml_response.xpath("//fileURL").map do |url|
          url.text
        end

        passwords = meeting_request.xml_response.xpath("//password").map do |password|
          password.text
        end

        return {
          passwords: passwords,
          stream_urls: stream_urls,
          file_urls: file_urls
        }
      else
        return nil
      end
    end

    def self.set_meeting(client, name, meeting_key, options={})
      meeting_request = WebexApi::MeetingRequest.new(client)
      meeting_request.set_meeting(name, meeting_key, options)
      if meeting_request.xml_response.at_xpath('//meetingkey')
        meeting_key = meeting_request.xml_response.at_xpath('//meetingkey').text
      end

      if meeting_key
        return {
          key: meeting_key,
          password: meeting_request.xml_response.at_xpath('//meetingPassword')&.text,
          ical_host_url: meeting_request.xml_response.at_xpath('//host')&.text,
          ical_attendee_url: meeting_request.xml_response.at_xpath('//attendee')&.text
        }
      else
        return nil
      end
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
      if meeting_request.xml_response.at_xpath('hostMeetingURL')
        meeting_request.xml_response.at_xpath('hostMeetingURL').text
      else
        nil
      end
    end

    def get_join_url(email=nil)
      meeting_request = WebexApi::MeetingRequest.new(@client)
      meeting_request.get_join_meeting_url(@meeting_key)
      if meeting_request.xml_response.at_xpath('joinMeetingURL')
        meeting_request.xml_response.at_xpath('joinMeetingURL').text
      else
        nil
      end
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
        if @meeting_attr[meth]
          @meeting_attr[meth]
        else
          if @xml.at_xpath("//*[contains(translate(name(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'), '#{meth.to_s.camelcase(:lower).downcase}')]")
            @meeting_attr[meth]  = @xml.at_xpath("//*[contains(translate(name(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'), '#{meth.to_s.camelcase(:lower).downcase}')]").text
          else
            @meeting_attr[meth]  = nil
          end

        end

        @meeting_attr[meth] ||= @xml.at_xpath("//*[contains(translate(name(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'), '#{meth.to_s.camelcase(:lower).downcase}')]")
      end
    end



  end
end