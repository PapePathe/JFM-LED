class Technician::UsersController < ApplicationController

  def show
    @user = current_user
    @availabilities = Availability.to_come.of_the_week.of(@user).booked.oldest_to_new
    @bookings = Booking.for_next_week_for(@user)
    @markers = Gmaps4rails.build_markers(@bookings) do |booking, marker|
      marker.lat booking.latitude
      marker.lng booking.longitude
    end
  end

  def index
    @user = current_user
    @users = User.where(role: [0, 1])
  end
end
