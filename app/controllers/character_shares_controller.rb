class CharacterSharesController < SharesController
    private
      def set_shareable
        @shareable = Character.find(params.expect(:character_id))
      end
end
