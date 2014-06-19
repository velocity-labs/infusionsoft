module Infusionsoft

  class DataFormField < Base

    def self.fields
      ['Id', 'DataType', 'FormId', 'GroupId', 'Name', 'Label', 'DefaultValue', 'Values', 'ListRows']
    end

    def form
      # {
      #   -1: 'Contact',
      #   -3: 'Referral Partner',
      #   -4: 'Opportunity',
      #   -5: 'Task/Note/Apt',
      #   -6: 'Company',
      #   -9: 'Order'
      # }[self.FormId]
    end
  end

end