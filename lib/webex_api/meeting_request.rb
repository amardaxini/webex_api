module WebexApi
  class MeetingRequest < WebexApi::Request

    def initialize(client)
      super(client)
    end

    def create_meeting(conf_name,options={})
      body = get_createmeeting_body(conf_name, options)

      puts body
      perform_request(body)
    end

    def create_meetings(meetings)
      body = get_createmeetings_body(meetings)
      perform_request(body, multiple: true)
    end

    def set_meeting(conf_name, meeting_key, options={})
      body = get_setmeeting_body(conf_name, meeting_key, options)
      perform_request(body)
    end

    def get_createmeeting_body(conf_name, options={})
      body = webex_xml_request(@client.webex_email) do |xml|
        xml.bodyContent('xsi:type' =>'java:com.webex.service.binding.meeting.CreateMeeting'){
          get_meeting_body(xml, conf_name, nil, options)
        }
      end

      puts body # helpful for seeing XML request
      body
    end

    def get_createmeetings_body(meetings)
      body = webex_xml_request(@client.webex_email) do |xml|
        meetings.each do |meeting|
          xml.bodyContent('xsi:type' =>'java:com.webex.service.binding.meeting.CreateMeeting'){
            get_meeting_body(xml, meeting[:name], nil, meeting[:options])
          }
        end
      end

      puts body # helpful for seeing XML request
      body
    end

    def get_recording_info(meeting_name)
      body = get_recording_info_body(meeting_name)
      perform_request(body)
    end

    def get_recording_info_body(meeting_name)
      body = webex_xml_request(@client.webex_email) do |xml|
        xml.bodyContent('xsi:type' =>'java:com.webex.service.binding.ep.LstRecording'){
          xml.recordName meeting_name
          xml.serviceTypes{
            xml.serviceType 'MeetingCenter'
          }
        }
      end
      puts body
      body
    end

    def get_setmeeting_body(conf_name, meeting_key, options={})
      body = webex_xml_request(@client.webex_email) do |xml|
        xml.bodyContent('xsi:type' =>'java:com.webex.service.binding.meeting.SetMeeting'){
          get_meeting_body(xml, conf_name, meeting_key, options)
        }
      end
      puts body
      body
    end

    def get_meeting_body(xml, conf_name, meeting_key, options)
      xml.enableOptions{
        xml.chat options[:chat] == false ? false : true
        xml.audioVideo true
        xml.poll true
        xml.voip true
        xml.autoRecord true if options[:auto_record]
        xml.HQvideo true if options[:hd_video]
        xml.HDvideo true if options[:hd_video]
        xml.autoDeleteAfterMeetingEnd false if options[:dont_auto_delete]
      }
      xml.metaData{
        xml.confName conf_name
      }
      xml.attendeeOptions{
        xml.externalAttendeeSecurity options[:external_attendee_security] if options[:external_attendee_security].present?
        xml.autoLock true if options[:auto_lock]
        xml.autoLockWaitTime options[:auto_lock_wait_time] if options[:auto_lock_wait_time].present?
      } if options[:external_attendee_security].present? || options[:auto_lock].present? || options[:auto_lock_wait_time].present?
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
          xml.startDate options[:scheduled_date].strftime("%m/%d/%Y %T") rescue nil
          xml.timeZoneID options[:time_zone_id].to_i unless options[:time_zone_id].nil?
          xml.timeZone options[:time_zone] unless options[:time_zone].nil?
        else
          options[:scheduled_date].to_s + "1"
          xml.startDate
        end
        xml.duration(options[:duration].to_i)
      }
      xml.telephony{
        xml.telephonySupport options[:telephony_mode] || 'CALLIN'
      }
      xml.meetingkey meeting_key unless meeting_key.nil?
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

      xml.repeat{
        xml.repeatType options[:repeat_type] if options[:repeat_type].present?
        xml.interval options[:interval].to_i if options[:interval].present?
        xml.afterMeetingNumber options[:after_meeting_number] if options[:after_meeting_number].present?
        xml.dayInWeek {
          options[:day_in_week].each{ |day| xml.day day } if options[:day_in_week].present?
        }
        xml.expirationDate options[:expiration_date]&.strftime("%m/%d/%Y %T") if options[:expiration_date].present?
        xml.dayInMonth = options[:day_in_month] if options[:day_in_month]
        xml.weekInMonth = options[:week_in_month] if options[:week_in_month]
        xml.monthInYear = options[:month_in_year] if options[:month_in_year]
        xml.dayInYear = options[:day_in_year] if options[:day_in_year]
        xml.isException = options[:is_exception] if options[:is_exception]
        xml.seriesMeetingKey = options[:series_meeting_key] if options[:series_meeting_key]
        xml.hasException = options[:has_exception] if options[:has_exception]
      }

    end

    def get_meeting(meeting_key)
      body = webex_xml_request(@client.webex_email) do |xml|
        xml.bodyContent('xsi:type' => 'java:com.webex.service.binding.meeting.GetMeeting'){
          xml.meetingKey meeting_key
        }
      end
      perform_request(body)
    end

    def get_meetings(meeting_keys)
      body = webex_xml_request(@client.webex_email) do |xml|
        meeting_keys.each do |meeting_key|
          xml.bodyContent('xsi:type' => 'java:com.webex.service.binding.meeting.GetMeeting'){
            xml.meetingKey meeting_key
          }
        end
      end
      perform_request(body, multiple: true)
    end

    def get_host_meeting_url(meeting_key)
      body = webex_xml_request(@client.webex_email) do |xml|
        xml.bodyContent('xsi:type' => 'java:com.webex.service.binding.meeting.GethosturlMeeting'){
          xml.sessionKey meeting_key
        }
      end

      puts body # helpful for seeing XML request

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
      puts body # helpful for seeing XML request
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
