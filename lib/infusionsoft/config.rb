module Infusionsoft
  class Config

    attr_accessor :api_url, :api_key, :api_logger, :user_agent

    def user_agent
      @user_agent ||= "Infusionsoft-#{Infusionsoft.version} (RubyGem)"
    end

    def api_logger
      @api_logger || Infusionsoft::APILogger.new
    end

    def version
      '2.0.2'
    end
  end

end
