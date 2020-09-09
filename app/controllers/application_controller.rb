class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  $days_of_the_week = %w{日 月 火 水 木 金 土}
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def set_superiors
    @superiors = User.where(superior: true).where.not(id: current_user.id)
  end
  
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "ログインしてください。"
      redirect_to login_url
    end
  end
  
  def correct_user
    redirect_to(root_url) unless current_user?(@user)
  end
  
  def admin_user
    redirect_to root_url unless current_user.admin?
  end
  
  def admin_or_correct_user
    @user = User.find(params[:id]) if @user.blank?
    unless current_user?(@user) || current_user.admin?
      flash[:danger] = "編集権限がありません。"
      redirect_to(root_url)
    end
  end
  
  def admin_or_correct_user_or_approver
    @user = User.find(params[:id]) if @user.blank?
    unless current_user.admin? || current_user?(@user) || approver?
      flash[:danger] = "編集権限がありません。"
      redirect_to(root_url)
    end
  end
  
  def set_one_month
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date.beginning_of_month
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day]
    
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    @one_month_overtimes = @user.overtimes.where(worked_on: @first_day..@last_day).order(:worked_on)
    
    unless one_month.count == @attendances.count
      ActiveRecord::Base.transaction do
        one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end
    
    unless one_month.count == @one_month_overtimes.count
      ActiveRecord::Base.transaction do
        one_month.each { |day| @user.overtimes.create!(worked_on: day) }
      end
      @one_month_overtimes = @user.overtimes.where(worked_on: @first_day..@last_day).order(:worked_on)
    end
    
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "ページ情報の取得に失敗しました。再アクセスしてくだい。"
    redirect_to root_url
  end
  
  def set_statuses
    @statuses = {"なし": "なし",
                 "申請中": "申請中",
                 "承認": "承認",
                 "否認": "否認"}
  end
  
  def set_one_month_attendance
    @one_month_attendance = @user.one_month_attendances.find_by(month: @first_day)
    @one_month_attendance = @user.one_month_attendances.create(month: @first_day) if @one_month_attendance.nil?
  end
  
  def set_one_month_attendances
    if current_user.superior?
      @one_month_attendances = OneMonthAttendance.where(approver: current_user.id).where(status: "申請中")
    end
  end
  
  def set_overtime
    @overtime = @user.overtimes.find_by(worked_on: params[:date])
    @overtime = @user.overtimes.create(worked_on: params[:date]) if @overtime.nil?
  end
  
  def set_overtimes
    if current_user.superior?
      @overtimes = Overtime.where(approver: current_user.id).where(status: "申請中")
    end
  end
  
  def set_applied_attendance
    @applied_attendance = @user.attendances.find_by(worked_on: params[:date])
    @applied_attendance = @user.attendances.create(worked_on: params[:date]) if @applied_attendance.nil?
  end
  
  def set_applied_attendances
    if current_user.superior?
      @applied_attendances = Attendance.where(approver: current_user.id).where(status: "申請中")
    end
  end
end
