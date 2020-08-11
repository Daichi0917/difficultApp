class OneMonthAttendancesController < ApplicationController
  
  def update
    @user = User.find(params[:user_id])
    @one_month_attendance = OneMonthAttendance.find(params[:id])
    approver = params[:one_month_attendance][:approver]
    if approver.blank?
      flash[:danger] = "所属長を選択してください。"
    else
      if @one_month_attendance.update_attributes(approver: approver, status: "申請中")
        flash[:success] = "#{@one_month_attendance.month.month}月分の勤怠承認を申請しました。"
      else
        flash[:danger] = "申請に失敗しました。やり直してください。"
      end
    end
    redirect_to @user
  end
  
  private
    
    def one_month_attendance_params
      params.require(:one_month_attendance).permit(:approver)
    end
end
