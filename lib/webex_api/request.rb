module WebexApi
  class Request
    attr_accessor :xml_response ,:error,:success,:client
    def initialize(client)
      @client = client
      @success = false

    end
    def webex_xml_request(email=nil)
      Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.message('xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
                            'xmlns:serv' =>  "http://www.webex.com/schemas/2002/06/service",
                            'xsi:schemaLocation' => "http://www.webex.com/schemas/2002/06/service"){
          xml.parent.namespace = xml.parent.namespace_definitions.find{|ns|ns.prefix=="serv"}
          xml.header{
            xml.parent.namespace = xml.parent.namespace_definitions.first
            xml.securityContext {
              xml.webExID @client.webex_id
              xml.password @client.webex_password
              xml.siteID @client.site_id
              xml.partnerID @client.partner_id if !!@client.partner_id
              xml.email email if !!email
            }
          }
          xml.body{
            xml.parent.namespace = xml.parent.namespace_definitions.first
            yield xml
          }
        }
      end.to_xml
    end

    
    def perform_request(body)
      
      uri = URI.parse("https://#{@client.site_name}.webex.com")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      response = http.post('/WBXService/XMLService', body)
      xml_data = Nokogiri::XML(response.body).remove_namespaces!
      if xml_data.at_xpath('/message/header/response/result').try(:text) == 'SUCCESS'
        @success = true
        @xml_response = xml_data.at_xpath('/message/body/bodyContent')
      else
        @error = xml_data.at_xpath('/message/header/response/reason').try(:text)
        raise WebexApi::WebexError.new(xml_data.at_xpath('/message/header/response/reason').try(:text))
      end
    end

  end
end