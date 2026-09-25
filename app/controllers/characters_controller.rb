class CharactersController < ApplicationController
  before_action :set_character, only: %i[ show edit update destroy ]
  before_action :authorize_character

  def index
    @characters = policy_scope(Character)
  end

  def show
  end

  def new
    @character = Character.new
  end

  def create
    @character = Character.new(character_params)

    if @character.save
      redirect_to @character, notice: "Character was successfully created.", status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @character.update(character_params)
      redirect_to @character, notice: "Character was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @character.destroy!
    redirect_to characters_path, notice: "Character was successfully destroyed.", status: :see_other
  end

  private
    def set_character
      @character = Character.find(params.expect(:id))
    end

    def authorize_character
      authorize(@character || Character)
    end

    def character_params
      params.expect(character: [ :name, :level, :character_class, :species, :image ])
    end
end
