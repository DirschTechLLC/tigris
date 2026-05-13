class DashboardController < ApplicationController
  def show
    @organizations = Current.user.organizations
    case @organizations.count
    when 0 then redirect_to new_organization_path
    when 1 then redirect_to organization_submissions_path(@organizations.first)
    else render :show
    end
  end
end
