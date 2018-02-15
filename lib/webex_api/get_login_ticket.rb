module WebexApi
  class GetLoginTicket < WebexApi::Request

    def initialize(client)
      super(client)

    end

    def authenticate_user(saml = nil)
      body = webex_xml_request(@client.webex_email) do |xml|
        xml.bodyContent('xsi:type' =>'java:com.webex.service.binding.user.AuthenticateUser'){
          if saml
            xml.protocol("SAML2.0")
            xml.samlResponse saml
          end
        }
      end
      puts body
      perform_request(body)
    end

    def get_ticket()
      body = webex_xml_request(@client.webex_email) do |xml|
        xml.bodyContent('xsi:type' =>'java:com.webex.service.binding.user.GetLoginTicket'){
        }
      end
      puts body
      perform_request(body)
    end
  end
end
