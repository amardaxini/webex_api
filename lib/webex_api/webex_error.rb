module WebexApi
  class WebexError < StandardError
    attr_reader :data

    def initialize(data)
      @data = data
      super
    end
  end

  class ConnectionError < StandardError; end
  class NotFound      < StandardError; end
end