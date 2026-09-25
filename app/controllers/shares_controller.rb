class SharesController < ApplicationController
  skip_after_action :verify_policy_scoped

  before_action :set_shareable
  before_action :set_share, only: %i[update destroy]

  def create
    @share = @shareable.shares.new(create_share_params)
    authorize @share

    if @share.save
      redirect_to @shareable, notice: "Share was successfully created.", status: :see_other
    else
      redirect_to @shareable, alert: @share.errors.full_messages.to_sentence, status: :see_other
    end
  end

  def update
    @share.assign_attributes(update_share_params)
    authorize @share

    if @share.save
      redirect_to @shareable, notice: "Share was successfully updated.", status: :see_other
    else
      redirect_to @shareable, alert: @share.errors.full_messages.to_sentence, status: :see_other
    end
  end

  def destroy
    authorize @share
    @share.destroy!
    redirect_to @shareable, notice: "Share was successfully removed.", status: :see_other
  end

  private
    def set_shareable
      klass = Shareable.registry.find { |model| params["#{model.model_name.param_key}_id"].present? }
      raise ActiveRecord::RecordNotFound, "Unknown shareable" unless klass

      @shareable = klass.find(params["#{klass.model_name.param_key}_id"])
    end

    def set_share
      @share = @shareable.shares.find(params.expect(:id))
    end

    def create_share_params
      params.expect(share: [ :user_id, :access ])
    end

    def update_share_params
      params.expect(share: [ :access ])
    end
end
