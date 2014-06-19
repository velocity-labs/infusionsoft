module Infusionsoft
  module Api
    def self.included(base)
      base.extend Infusionsoft::Connection
      base.extend ClassMethods
    end

    module ClassMethods
      def fields_for(table)
        case table
        when 'ContactGroup'
          Infusionsoft::ContactGroup.fields
        when 'Contact'
          Infusionsoft::Contact.fields
        when 'DataFormField'
          Infusionsoft::DataFormField.fields
        when 'DataFormGroup'
          Infusionsoft::DataFormGroup.fields
        when 'DataFormTab'
          Infusionsoft::DataFormTab.fields
        when 'ContactGroupAssign'
          Infusionsoft::ContactGroupAssign.fields
        else
          raise Exception.new("Missing fields for class #{table}")
        end
      end

      def infusionsoft_class(table)
        "Infusionsoft::#{table}".constantize
      end
    end


  end
end

