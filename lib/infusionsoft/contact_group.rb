module Infusionsoft

  class ContactGroup < Base

    def GroupCategory
      # TODO: query for a GroupCategory
      'GroupCategoryId'
    end

    def delete
      get('DataService.delete', 'ContactGroup', self.Id)
    end

    def self.fields
      ['Id', 'GroupName', 'GroupCategoryId', 'GroupDescription']
    end

    def self.find_by_name(name)
      IS::Data.query('ContactGroup', {'GroupName' => name}).first
    end

    def self.find_by_id(id)
      IS::Data.query('ContactGroup', {'Id' => id}).first
    end
    class << self
      alias :find :find_by_id
    end
  end
end