module WebexApi
    class Event
    attr_reader :xml

    def initialize(meeting_key,client)
      @meeting_key= meeting_key
      @email =  email
      @client = client
    end

    def self.create_meeting(client,name,options={})
      session_key = nil
      session_request = WebexApi::EventRequest.new(client)
      session_request.create_event(name,options)
      if session_request.xml_response.at_xpath('//sessionKey')
        session_key = session_request.xml_response.at_xpath('//sessionKey').text
      end

      if session_key
        return {
          key: session_key,
          guestToken: session_request.xml_response.at_xpath('//guestToken')&.text,
        }
      else
        return nil
      end  
    end
    end
end