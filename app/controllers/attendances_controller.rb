class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :show_applied_attendances]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month
  before_action :set_superiors, only: :edit_one_month
  before_action :set_statuses, only: :show_applied_attendances
  before_action :set_applied_attendances, only: :show_applied_attendances
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0), initial_started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0), initial_finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_one_month
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        unless item[:approver].blank?
          if attendance.update_attributes!(item)
            attendance.update_attributes!(status: "申請中", checked: false, approved: false)
            flash[:success] = "勤怠変更を申請しました。"
          end
        end
      end
    end
    redirect_to user_url(date: params[:date])
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、申請をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  def show_applied_attendances
  end
  
  def approve_applied_attendances
    ActiveRecord::Base.transaction do
      applied_attendances_params.each do |id, item|
        if item[:checked]
          attendance = Attendance.find(id)
          attendance.update_attributes!(item)
          attendance.update_attributes!(approved: true)
          flash[:success] = "勤怠変更申請を承認しました。"
        end
      end
      redirect_to current_user
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "承認に失敗しました。やり直してください。"
    redirect_to current_user
  end
  
  private
    
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :next_day, :note, :approver,
                                                 :changed_started_at, :changed_finished_at])[:attendances]
    end
    
    def applied_attendances_params
      params.permit(attendances: [:started_at, :finished_at, :next_day, :note, :approver, :status, :checked])[:attendances]
    end
end
