class Pro::BookingsController < ApplicationController
  before_action :set_user
  before_action :set_tech, only: [:new, :create, :edit, :update]

  def index
    @bookings = Booking.where(user_id: @user.id).includes(:address, :user, :availabilities, :product).sort_by(&:created_at)
    create_markers_for(@bookings)
  end

  def show
    @booking = Booking.find(params[:id])
    @availabilities = @booking.availabilities.includes(:availabilities, :product)
    create_markers_for(@booking)
  end

  def new
    if ["50", "14", "61", "27", "76", "80", "60", "62", "59", "02", "10", "51", "08", "55", "52", "54", "57", "88", "67"].include? @user.branch.address.zipcode[0..1]
      @availabilities = Availability.to_come.not_today.free_first.where(user: User.where(branch: Branch.where(name: "Compiègne")))
    else
      @availabilities = Availability.to_come.not_today.free_first.where(user: User.where(branch: Branch.where(name: "Les Ulis")))
    end
    @products = Product.all
    @booking = Booking.new
    @booking.address = Address.new
  end

  def create
    @products = Product.all
    @foremen = Foreman.where(branch_id: @user.branch_id).to_a
    @availabilities = Availability.all
    @booking = Booking.new(booking_params)
    @booking.user_id = @user.id
    if @booking.save
      @booking.availabilities.update(status: "pending")
      Report.find_or_create_by(booking_id: @booking.id)
      option_params[:option_value_ids].each do |option_value_id|
        next unless @booking.product.option_value_ids.include?(option_value_id.to_i)
        BookedProductOption.find_or_create_by(booking_id: @booking.id, option_value_id: option_value_id)
      end
      get_custom_value
      redirect_to pro_dashboard_path
    else
      render :new
    end
  end

  def edit
    @availabilities = Availability.to_come.not_today.free_first
    @products = Product.all
    @booking = Booking.find(params[:id])
  end

  def update
    @products = Product.all
    @foremen = Foreman.where(branch_id: @user.branch_id).to_a
    @availabilities = Availability.all
    @booking = Booking.find(params[:id])
    if @booking.booked_product_options.where(custom_value: false).destroy_all && @booking.update(booking_params)
      @booking.availabilities.update(status: "pending")
      Availability.where(booking: nil, status: "pending").each {|a| a.reset}
      unless params[:option].nil?
        option_params[:option_value_ids].each do |option_value_id|
          next unless @booking.product.option_value_ids.include?(option_value_id.to_i)
          BookedProductOption.find_or_create_by(booking: @booking, option_value_id: option_value_id, option: OptionValue.find(option_value_id).option)
        end
      end
      get_custom_value
      redirect_to pro_dashboard_path
    else
      render :new
    end
  end

  private

  def set_user
    @user = current_user
  end

  def set_tech
    @tech = User.where(role: 3).first
  end

  def booking_params
    params.require(:booking).permit(:comment, :pdf, :foreman_id, :address_id ,:address1, :address2, :zipcode, :city, :country, :product_id, :surface, :reference, availability_ids: [], address_attributes: [:address1, :address2, :zipcode, :city, :country])
  end

  def option_params
    params.require(:options).permit(option_value_ids: [])
  end

  def create_markers_for(bookings)
    if bookings.class == Booking
      unless bookings.address.latitude.nil? || bookings.address.latitude.nil?
        @markers = Gmaps4rails.build_markers(bookings) do |booking, marker|
          marker.lat booking.address.latitude
          marker.lng booking.address.longitude
        end
      end
    else
      bookings.each do |booking|
        unless booking.address.latitude.nil? || booking.address.latitude.nil?
          @markers = Gmaps4rails.build_markers(bookings) do |booking, marker|
            marker.lat booking.address.latitude
            marker.lng booking.address.longitude
          end
        end
      end
    end
  end

  def get_custom_value
    params[:custom_values].each do |option_id, value|
      next unless @booking.product.option_ids.include?(option_id.to_i)
      BookedProductOption.find_or_create_by(option_id: option_id, value: value, booking: @booking, custom_value: true)
    end
  end

end
