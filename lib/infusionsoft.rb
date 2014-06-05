require 'infusionsoft/config'

require 'infusionsoft/api'

require 'infusionsoft/connection'
require 'infusionsoft/request'

require 'infusionsoft/client/contact'
require 'infusionsoft/client/email'
require 'infusionsoft/client/invoice'
require 'infusionsoft/client/data'
require 'infusionsoft/client/affiliate'
require 'infusionsoft/client/file'
require 'infusionsoft/client/ticket' # Deprecated by Infusionsoft
require 'infusionsoft/client/search'
require 'infusionsoft/client/credit_card'

require 'infusionsoft/api_logger'

module Infusionsoft

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
end

