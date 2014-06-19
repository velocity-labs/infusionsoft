module Infusionsoft

  # Contact service is used to manage contacts. You can add, update and find contacts in
  # addition to managing follow up sequences, tags and action sets.
  class Contact < Base

    def save
      data = self.to_hash
      data.delete("LastUpdated")
      data.delete("DateCreated")

      if persisted?
        IS::Contact.update(self.Id, data)
      else
        self.Id = IS::Contact.add(data).Id
      end

      reload!
    end

    def delete
      IS::Data.delete 'Contact', self.Id
    end

    def reload!
      temp = IS::Contact.load self.Id
      temp.each do |key, val|
        self.send("#{key}=", val)
      end
    end

    def tags
      assigns = IS::Data.query 'ContactGroupAssign', {'ContactId' => self.Id}
      assigns.map { |cga| IS::Data.load 'ContactGroup', cga.GroupId }
    end
    alias_method :groups, :tags

    def add_to_group(group_id)
      IS::Contact.add_to_group(self.Id, group_id)
    end

    def remove_from_group(group_id)
      IS::Contact.remove_from_group(self.Id, group_id)
    end

    def self.fields
      default_fields + custom_fields
    end

    def self.default_fields
      ['Address1Type', 'Address2Street1', 'Address2Street2', 'Address2Type', 'Address3Street1', 'Address3Street2', 'Address3Type', 'Anniversary', 'AssistantName', 'AssistantPhone', 'BillingInformation', 'Birthday', 'City', 'City2', 'City3', 'Company', 'AccountId', 'CompanyID', 'ContactNotes', 'ContactType', 'Country', 'Country2', 'Country3', 'CreatedBy', 'DateCreated', 'Email', 'EmailAddress2', 'EmailAddress3', 'Fax1', 'Fax1Type', 'Fax2', 'Fax2Type', 'FirstName', 'Groups', 'Id', 'JobTitle', 'LastName', 'LastUpdated', 'LastUpdatedBy', 'Leadsource', 'LeadSourceId', 'MiddleName', 'Nickname', 'OwnerID', 'Password', 'Phone1', 'Phone1Ext', 'Phone1Type', 'Phone2', 'Phone2Ext', 'Phone2Type', 'Phone3', 'Phone3Ext', 'Phone3Type', 'Phone4', 'Phone4Ext', 'Phone4Type', 'Phone5', 'Phone5Ext', 'Phone5Type', 'PostalCode', 'PostalCode2', 'PostalCode3', 'ReferralCode', 'SpouseName', 'State', 'State2', 'State3', 'StreetAddress1', 'StreetAddress2', 'Suffix', 'Title', 'Username', 'Validated', 'Website', 'ZipFour1', 'ZipFour2', 'ZipFour3']
    end

    def self.custom_fields
      # -1 for Contact
      response = Infusionsoft::Data.query "DataFormField", {'FormId' => -1}
      response.map { |field| "_#{field.Name}"}
    end

    # Creates a new contact record from the data passed in the associative array.
    #
    # @param [Hash] data contains the mappable contact fields and it's data
    # @return [Integer] the id of the newly added contact
    # @example
    #   { :Email => 'test@test.com', :FirstName => 'first_name', :LastName => 'last_name' }
    def self.add(data)
      data.reject!{|key,val| val.nil? }
      contact_id = get('ContactService.add', data)

      if data.has_key?("Email")
        IS::Email.email_optin(data["Email"], "requested information")
      end

      IS::Contact.load contact_id
    end

    # Adds or updates a contact record based on matching data
    #
    # @param [Array<Hash>] data the contact data you want added
    # @param [String] check_type available options are 'Email', 'EmailAndName',
    #   'EmailAndNameAndCompany'
    # @return [Integer] id of the contact added or updated
    def self.add_with_dup_check(data, check_type)
      contact_id = get('ContactService.addWithDupCheck', data, check_type)

      if data.has_key?("Email")
        IS::Email.email_optin(data["Email"], "requested information")
      end

      contact_id
    end

    # Updates a contact in the database.
    #
    # @param [Integer] contact_id
    # @param [Hash] data contains the mappable contact fields and it's data
    # @return [Integer] the id of the contact updated
    # @example
    #   { :FirstName => 'first_name', :StreetAddress1 => '123 N Street' }
    def self.update(contact_id, data)
      data.reject!{|key,val| val.nil? }
      contact_id = get('ContactService.update', contact_id, data)

      if data.has_key?("Email");
        IS::Email.email_optin(data["Email"], "requested information")
      end

      IS::Contact.load contact_id
    end

    # Loads a contact from the database
    #
    # @param [Integer] id
    # @params [Arguments] Optional - the fields you want back as add'l args, else defaults to all default + custom fields
    # @return [Contact] an InfusionsoftContact object
    # @example this is what you would get back
    #   { "FirstName" => "John", "LastName" => "Doe" }
    def self.load(id, *selected_fields)
      fields = if selected_fields.present?
                 selected_fields
               else
                IS::Contact.fields
              end

      Contact.new get('ContactService.load', id, fields)
    end

    # Finds all contacts with the supplied email address in any of the three contact record email
    # addresses.
    #
    # @param [String] email
    # @param [Array] selected_fields the list of fields you want with it's data
    # @return [Array<Hash>] the list of contacts with it's fields and data
    def self.find_by_email(email, *selected_fields)
      fields = if selected_fields.present?
                 selected_fields
               else
                 IS::Contact.fields.reject{|field| field.eql?('AccountId') }
               end

      temp = get('ContactService.findByEmail', email, fields)

      if temp.respond_to?(:empty?)
        if temp.empty?
          nil
        else
          Contact.new temp.first
        end
      else
        Contact.new temp
      end

    end

    # Adds a contact to a follow-up sequence (campaigns were the original name of follow-up sequences).
    #
    # @param [Integer] contact_id
    # @param [Integer] campaign_id
    # @return [Boolean] returns true/false if the contact was added to the follow-up sequence
    #   successfully
    def self.add_to_campaign(contact_id, campaign_id)
      get('ContactService.addToCampaign', contact_id, campaign_id)
    end

    # Returns the Id number of the next follow-up sequence step for the given contact.
    #
    # @param [Integer] contact_id
    # @param [Integer] campaign_id
    # @return [Integer] id number of the next unfishished step in the given follow up sequence
    #   for the given contact
    def self.get_next_campaign_step(contact_id, campaign_id)
      get('ContactService.getNextCampaignStep', contact_id, campaign_id)
    end

    # Pauses a follow-up sequence for the given contact record
    #
    # @param [Integer] contact_id
    # @param [Integer] campaign_id
    # @return [Boolean] returns true/false if the sequence was paused
    def self.pause_campaign(contact_id, campaign_id)
      get('ContactService.pauseCampaign', contact_id, campaign_id)
    end

    # Removes a follow-up sequence from a contact record
    #
    # @param [Integer] contact_id
    # @param [Integer] campaign_id
    # @return [Boolean] returns true/false if removed
    def self.remove_from_campaign(contact_id, campaign_id)
      get('ContactService.removeFromCampaign', contact_id, campaign_id)
    end

    # Resumes a follow-up sequence that has been stopped/paused for a given contact.
    #
    # @param [Integer] contact_id
    # @param [Ingeger] campaign_id
    # @return [Boolean] returns true/false if sequence was resumed
    def self.resume_campaign(contact_id, campaign_id)
      get('ContactService.resumeCampaignForContact', contact_id, campaign_id)
    end

    # Immediately performs the given follow-up sequence step_id for the given contacts.
    #
    # @param [Array<Integer>] list_of_contacts
    # @param [Integer] ) step_id
    # @return [Boolean] returns true/false if the step was rescheduled
    def self.reschedule_campaign_step(list_of_contacts, step_id)
      get('ContactService.reschedulteCampaignStep', list_of_contacts, step_id)
    end

    # Removes a tag from a contact (groups were the original name of tags).
    #
    # @param [Integer] contact_id
    # @param [Integer] group_id
    # @return [Boolean] returns true/false if tag was removed successfully
    def self.remove_from_group(contact_id, group_id)
      get('ContactService.removeFromGroup', contact_id, group_id)
    end

    # Adds a tag to a contact
    #
    # @param [Integer] contact_id
    # @param [Integer] group_id
    # @return [Boolean] returns true/false if the tag was added successfully
    def self.add_to_group(contact_id, group_id)
      get('ContactService.addToGroup', contact_id, group_id)
    end

    # Runs an action set on a given contact record
    #
    # @param [Integer] contact_id
    # @param [Integer] action_set_id
    # @return [Array<Hash>] A list of details on each action run
    # @example here is a list of what you get back
    #   [{ 'Action' => 'Create Task', 'Message' => 'task1 (Task) sent successfully', 'isError' =>
    #   nil }]
    def self.run_action_set(contact_id, action_set_id)
      get('ContactService.runActionSequence', contact_id, action_set_id)
    end

    def self.link_contact(remoteApp, remoteId, localId)
      get('ContactService.linkContact', remoteApp, remoteId, localId)
    end


    def self.locate_contact_link(locate_map_id)
      get('ContactService.locateContactLink', locate_map_id)
    end

    def self.mark_link_updated(locate_map_id)
      get('ContactService.markLinkUpdated', locate_map_id)
    end

    # Creates a new recurring order for a contact.
    #
    # @param [Integer] contact_id
    # @param [Boolean] allow_duplicate
    # @param [Integer] cprogram_id
    # @param [Integer] merchant_account_id
    # @param [Integer] credit_card_id
    # @param [Integer] affiliate_id
    def self.add_recurring_order(contact_id, allow_duplicate, cprogram_id, merchant_account_id,
                                    credit_card_id, affiliate_id, days_till_charge)
      get('ContactService.addRecurringOrder', contact_id, allow_duplicate, cprogram_id,
                          merchant_account_id, credit_card_id, affiliate_id, days_till_charge)
    end

    # Executes an action sequence for a given contact, passing in runtime params
    # for running affiliate signup actions, etc
    #
    # @param [Integer] contact_id
    # @param [Integer] action_set_id
    # @param [Hash] data
    def self.run_action_set_with_params(contact_id, action_set_id, data)
      get('ContactService.runActionSequence', contact_id, action_set_id, data)
    end

  end

end
