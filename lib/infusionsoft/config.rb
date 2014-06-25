module Infusionsoft
  class Config

    attr_accessor :api_url, :api_key, :api_logger, :user_agent

    def user_agent
      @user_agent ||= "Infusionsoft (RubyGem)"
    end

    def api_logger
      @api_logger || Infusionsoft::APILogger.new
    end

  end

end
