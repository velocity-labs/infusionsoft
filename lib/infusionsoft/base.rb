module Infusionsoft
  class Base < Hashie::Mash
    include Infusionsoft::Api

    def persisted?
      if self.Id
        true
      else
        false
      end
    end
  end
end