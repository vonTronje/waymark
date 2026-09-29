class EntrySharesController < SharesController
  private
    def set_shareable
      @shareable = Entry.find(params.expect(:entry_id))
    end
end
