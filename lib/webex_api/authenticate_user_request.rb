module WebexApi
  class AuthenticateUserRequest < WebexApi::Request

    def initialize(client)
      super(client)

    end

    def authenticate_user(access_token)
      session_ticket = nil
      body = webex_xml_request(@client.webex_email) do |xml|
        xml.bodyContent('xsi:type' =>'java:com.webex.service.binding.user.AuthenticateUser'){
          xml.accessToken access_token
        }
      end
#       puts body
      perform_request(body)

      if self.xml_response.at_xpath('//sessionTicket')
        session_ticket = self.xml_response.at_xpath('//sessionTicket').text
      end

      return session_ticket
    end

  end
end
