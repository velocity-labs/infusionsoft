module Infusionsoft

  class ContactGroupAssign < Base

    def GroupCategory
      # TODO: query for a GroupCategory
      'GroupCategoryId'
    end

    def self.fields
      ['GroupId', 'ContactGroup', 'ContactId']
    end

  end
end