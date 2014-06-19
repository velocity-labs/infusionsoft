require "xmlrpc/client"
require 'hashie'
require 'infusionsoft/api'
require 'infusionsoft/connection'
require 'infusionsoft/base'
require 'infusionsoft/exceptions'
require 'infusionsoft/exception_handler'
require 'infusionsoft/config'
require 'infusionsoft/api_logger'
require 'infusionsoft/contact'
require 'infusionsoft/contact_group'
require 'infusionsoft/contact_group_assign'
require 'infusionsoft/email'
require 'infusionsoft/data'
require 'infusionsoft/data_form_field'
# require 'infusionsoft/invoice'
# require 'infusionsoft/affiliate'
# require 'infusionsoft/file'
# require 'infusionsoft/ticket' # Deprecated by Infusionsoft
# require 'infusionsoft/search'
# require 'infusionsoft/credit_card'

module Infusionsoft

  # add all the module instance methods as module functions
  extend self

  def configure
    yield config
  end

  def config
    @config ||= Config.new
  end

  # null out the config so that it can be rewritten to, then used in new 'get' calls
  def reset
    @config = nil
  end

  def log
    config.api_logger
  end

  def api_url
    config.api_url
  end

  def api_key
    config.api_key
  end

  def user_agent
    config.user_agent
  end

  def version
    config.version
  end
end

# Alias for shorter convenience
IS = Infusionsoft