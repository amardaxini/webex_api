module WebexApi
    class EventRequest < WebexApi::Request

        def initialize(client)
            super(client)
        end

        def create_event(session_name, options={})
            body = get_createevent_body(session_name, options)
            perform_request(body)
        end

        def get_createevent_body(session_name, options)
            body = webex_xml_request(@client.webex_email) do |xml|
                xml.bodyContent('xsi:type' =>'java:com.webex.service.binding.event.CreateEvent'){
                  get_meeting_body(xml, session_name, nil, options)
                }
            end
            puts "Event_Request:"
            puts body
            body
        end

        def get_meeting_body(xml, session_name, meeting_key, options)
            xml.accessControl{
              xml.listing         'UNLISTED'
              xml.sessionPassword options[:session_password]
            }
            xml.schedule{
              xml.startDate         options[:start_date]
              xml.duration          options[:duration]
            }
            xml.metaData{
                xml.sessionName session_name
                xml.sessionType "9"
                xml.description options[:description]
            }
            xml.telephony{
              xml.telephonySupport 'CALLIN'
            }
            if options[:emails]
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
            end
        end

        def delete_event(session_key)
            body = webex_xml_request(@client.webex_email) do |xml|
                xml.bodyContent('xsi:type' => 'java:com.webex.service.binding.event.DelEvent'){
                  xml.sessionKey session_key
                }
              end
              perform_request(body)
        end

        def update

        end
    end
end
