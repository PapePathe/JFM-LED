class Manager::ReportsController < ApplicationController
  before_action :params_user, only: [:index, :show, :edit]
  before_action :params_report, only: [:show, :edit]

  def index
    @reports = Report.all # car un seul diagnosticien pour l'instant
  end

  def show
    @sections = Section.all
    @booking = @report.booking
  end

  def edit
    @booking = @report.booking
    @sections = Section.all
  end

  def update
    @user = params_user
    @report = Report.find(params[:id])
    @sections = Section.all
    @booking = @report.booking
    if @report.update(photos_params)
      redirect_to([@user.role, @report])
    else
      render :edit
    end
  end


  private

  def params_user
    @user = current_user
  end

  def params_report
    @report = Report.find(params[:id])
  end

  def photos_params
    params.require(:report).permit(photos:[])
  end
end
