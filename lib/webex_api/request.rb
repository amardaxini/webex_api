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
              xml.webExID @client.webex_id if !!@client.webex_id
              xml.password @client.webex_password if !!@client.webex_password
              xml.siteID @client.site_id if !!@client.site_id
              xml.partnerID @client.partner_id if !!@client.partner_id
              xml.siteName @client.site_name if !!@client.site_name
              xml.email email if !!email
              xml.sessionTicket @client.session_ticket if !!@client.session_ticket
            }
          }
          xml.body{
            xml.parent.namespace = xml.parent.namespace_definitions.first
            yield xml
          }
        }
      end.to_xml
    end


    def perform_request(body, multiple: false)
      if @client.debug
        puts "Sending Webex XML Request: #{body}"
      end

      uri = URI.parse("https://#{@client.site_name}.webex.com")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      response = http.post('/WBXService/XMLService', body)

      if @client.debug
        puts "Webex XML Response: #{response}" # helpful for seeing XML response
        puts "Webex XML Response Body: #{response.body}"
      end

      xml_data = Nokogiri::XML(response.body).remove_namespaces!

      if xml_data.at_xpath('/message/header/response/result') && xml_data.at_xpath('/message/header/response/result').text == 'SUCCESS'
        @success = true

        if multiple
          @xml_response = xml_data.xpath('//bodyContent')
        else
          @xml_response = xml_data.at_xpath('/message/body/bodyContent')
        end

      else
        @error = OpenStruct.new
        @error.result = xml_data.at_xpath('/message/header/response/result').text rescue nil
        @error.reason = xml_data.at_xpath('/message/header/response/reason').text rescue "error"
        @error.gsbStatus = xml_data.at_xpath('/message/header/response/gsbStatus').text rescue nil
        @error.exceptionID = xml_data.at_xpath('/message/header/response/exceptionID').text rescue nil

        sub_errors_in_response = xml_data.at_xpath('/message/header/response/subErrors').children

        if sub_errors_in_response.any? {|c| c.name == 'subError'}
          @error.sub_errors = sub_errors_in_response.map do |sub_error|
            sub_error.children.map.with_object({}) do |sub_error_field, o|
              o[sub_error_field.name] = sub_error_field.text
            end
          end
        end

        raise WebexApi::WebexError.new(@error.to_h.to_json)
      end
    end

  end
end
