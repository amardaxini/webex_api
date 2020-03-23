module WebexApi
  class MeetingRequest < WebexApi::Request

    def initialize(client)
      super(client)

    end
    def create_meeting(conf_name,options={})
      body = webex_xml_request(@client.webex_email) do |xml|
        xml.bodyContent('xsi:type' =>'java:com.webex.service.binding.meeting.CreateMeeting'){
          xml.enableOptions{
            xml.chat true
            xml.audioVideo true
            xml.poll true
            xml.voip false
          }
          xml.metaData{
            xml.confName conf_name
          }
          if options[:meeting_password] != nil && options[:meeting_password].strip != ''
            xml.accessControl{
              xml.meetingPassword options[:meeting_password]
            }
          end
          xml.schedule{
            if options[:join_teleconf_before_host]
              xml.joinTeleconfBeforeHost !!options[:join_teleconf_before_host]
            end
            if options[:scheduled_date]
              xml.startDate options[:scheduled_date].utc.strftime("%m/%d/%Y %T") rescue nil
              xml.timeZoneID 21   # 'GMT+00:00, GMT (London)'
            else
              options[:scheduled_date].to_s + "1"
              xml.startDate
            end
            xml.duration(options[:duration].to_i)
          }
          xml.telephony{
            xml.telephonySupport 'CALLIN'
          }
          if options[:emails]
            xml.participants{
              xml.attendees{
                options[:emails].each do |email|
                  xml.attendee {
                    xml.emailInvitations true
                    xml.person {
                      xml.email email
                    }
                  }
                end
              }
            }
          end
        }
      end
      puts body
      perform_request(body)

    end

    def get_meeting(meeting_key)
      body = webex_xml_request(@client.webex_email) do |xml|
        xml.bodyContent('xsi:type' => 'java:com.webex.service.binding.meeting.GetMeeting'){
          xml.meetingKey meeting_key
        }
      end
      begin
        perform_request(body)
      rescue Exception => e
        p e
      end
    end

    def get_host_meeting_url(meeting_key)
      body = webex_xml_request(@client.webex_email) do |xml|
        xml.bodyContent('xsi:type' => 'java:com.webex.service.binding.meeting.GethosturlMeeting'){
          xml.sessionKey meeting_key
        }
      end
      perform_request(body)
    end

    def get_join_meeting_url(meeting_key)
      body = webex_xml_request(@client.webex_email) do |xml|
        xml.bodyContent('xsi:type' => 'java:com.webex.service.binding.meeting.GetjoinurlMeeting'){
          xml.sessionKey meeting_key
        }
      end
      perform_request(body)
    end

    def delete_meeting(meeting_key)
      body = webex_xml_request(@client.webex_email) do |xml|
        xml.bodyContent('xsi:type' => 'java:com.webex.service.binding.meeting.DelMeeting'){
          xml.meetingKey meeting_key
        }
      end
      perform_request(body)

    end

    def add_attendee(meeting_key,email,options={})
       body = webex_xml_request(@client.webex_email) do |xml|
        xml.bodyContent('xsi:type' =>'java:com.webex.service.binding.attendee.CreateMeetingAttendee'){
          xml.person{
            if options[:name]
              xml.name options[:name]
            end

              xml.address {
                xml.addressType options[:address_type] || "PERSONAL"
              }

            xml.email email
            xml.type options[:type] || "VISITOR"
          }
          xml.role options[:role] || "ATTENDEE"
          xml.sessionKey meeting_key
          xml.emailInvitations options[:email_invitation] || "FALSE"
        }
      end
      puts body
      perform_request(body)
    end

    def delete_attendee(meeting_key,email)
       body = webex_xml_request(@client.webex_email) do |xml|
        xml.bodyContent('xsi:type' =>'java:com.webex.service.binding.attendee.DelMeetingAttendee'){
          xml.attendeeEmail {
            xml.email email
            xml.sessionKey meeting_key
          }
        }
      end
      perform_request(body)
    end

    def list_attendees(meeting_key)

      body = webex_xml_request(@client.webex_email) do |xml|
        xml.bodyContent('xsi:type' =>'java:com.webex.service.binding.attendee.LstMeetingAttendee'){
          xml.meetingKey meeting_key

        }
      end
      perform_request(body)
    end

  end
end
