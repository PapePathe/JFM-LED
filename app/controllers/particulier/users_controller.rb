class Particulier::UsersController < ApplicationController

  def show
    @user = current_user
  end

  def index
  end
end
