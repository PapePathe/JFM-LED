class AnswersController < ApplicationController
  after_action :verify_authorized, except: [:create, :update]

  def create
    @report = Report.find(params[:answer][:report_id])
    @answer = Answer.create(answer_params)
      if @answer.save!
        redirect_to edit_technician_report_path(@report)
      else
        raise
      end
  end

  def update
    @answer = Answer.find(params[:id])
    @report = Report.find(@answer.report_id)
      if @answer.update!(answer_params)
        redirect_to edit_technician_report_path(@report)
      else
        render :edit
      end
  end

  private

  def answer_params
    params.require(:answer).permit(:report_id, :string, :nuemric, :boolean, :question_id, :option_choice_id, :date)
  end


end
