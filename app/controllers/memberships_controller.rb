class MembershipsController < ApplicationController
  include OrganizationScoped

  before_action :require_owner, only: [:create, :destroy]

  def index
    @memberships = Current.organization.memberships.includes(:user).order(:created_at)
  end

  def create
    user = User.find_by(email_address: params[:email_address]&.strip&.downcase)

    if user.nil?
      redirect_to organization_memberships_path(Current.organization), alert: t(".not_found")
    elsif Current.organization.member?(user)
      redirect_to organization_memberships_path(Current.organization), alert: t(".already_member")
    else
      Current.organization.memberships.create!(user: user, role: :member)
      redirect_to organization_memberships_path(Current.organization), notice: t(".success", email: user.email_address)
    end
  end

  def destroy
    membership = Current.organization.memberships.find(params[:id])

    if membership.owner? && Current.organization.memberships.owner.count == 1
      redirect_to organization_memberships_path(Current.organization), alert: t(".last_owner")
    else
      membership.destroy
      redirect_to organization_memberships_path(Current.organization), notice: t(".success")
    end
  end

  private

  def require_owner
    unless Current.organization.owner?(Current.user)
      redirect_to organization_path(Current.organization), alert: t("organizations.require_owner")
    end
  end
end
