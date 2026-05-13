class SubmissionsController < ApplicationController
  include OrganizationScoped

  def index
    @pagy, @submissions = pagy(Current.organization.submissions.recent)
  end

  def show
    @submission = Current.organization.submissions.find(params[:id])
  end
end
