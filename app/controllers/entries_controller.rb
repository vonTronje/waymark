class EntriesController < ApplicationController
  before_action :set_entry, only: %i[ show edit update destroy ]
  before_action :authorize_entry

  def index
    @entries = policy_scope(Entry)
  end

  def show
  end

  def new
    @entry = Entry.new
  end

  def create
    @entry = Entry.new(entry_params)

    if @entry.save
      redirect_to @entry, notice: "Entry was successfully created.", status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @entry.update(entry_params)
      redirect_to @entry, notice: "Entry was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @entry.destroy!
    redirect_to entries_path, notice: "Entry was successfully destroyed.", status: :see_other
  end

  private
    def set_entry
      @entry = Entry.find(params.expect(:id))
    end

    def authorize_entry
      authorize(@entry || Entry)
    end

    def entry_params
      params.expect(entry: [ :title, :description ])
    end
end
