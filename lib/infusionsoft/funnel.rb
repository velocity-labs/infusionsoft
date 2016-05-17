module Infusionsoft

    # Funnel Service is used to add contacts to your sequences
    class Funnel < Base

      # Achieves a goal, Returns the result of a goal being achieved.
      #
      # @param integration, string, The integration name of the goal. This defaults to the name of the app.
      # @param call_name, string, The call name of the goal
      # @param cid, int, The id of the contact you want to add to a sequence.
      #
      def self.funnel_achieve_goal(integration, call_name, cid)
        get('FunnelService.achieveGoal', integration, call_name, cid)
      end

    end

end