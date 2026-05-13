class OrganizationsController < ApplicationController
  include OrganizationScoped

  skip_before_action :set_current_organization, only: [:new, :create]
  before_action :require_owner, only: [:edit, :update]

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(organization_params)
    Organization.transaction do
      @organization.save!
      @organization.memberships.create!(user: Current.user, role: :owner)
    end
    redirect_to organization_submissions_path(@organization), notice: t(".success")
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  def show
  end

  def edit
  end

  def update
    if Current.organization.update(organization_params)
      redirect_to organization_path(Current.organization), notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def organization_params
    params.expect(organization: [:name])
  end

  def require_owner
    unless Current.organization.owner?(Current.user)
      redirect_to organization_path(Current.organization), alert: t("organizations.require_owner")
    end
  end
end
