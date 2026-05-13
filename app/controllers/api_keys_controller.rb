class ApiKeysController < ApplicationController
  include OrganizationScoped

  before_action :require_owner

  def index
    @api_keys = Current.organization.api_keys.order(created_at: :desc)
  end

  def create
    name = params.dig(:api_key, :name).to_s.strip

    if name.blank?
      redirect_to organization_api_keys_path(Current.organization), alert: t(".name_blank")
      return
    end

    _key, raw_token = ApiKey.generate_for(Current.organization, name: name)
    redirect_to organization_api_keys_path(Current.organization), notice: t(".success", token: raw_token)
  end

  def destroy
    api_key = Current.organization.api_keys.find(params[:id])
    api_key.revoke!
    redirect_to organization_api_keys_path(Current.organization), notice: t(".success")
  end

  private

  def require_owner
    unless Current.organization.owner?(Current.user)
      redirect_to organization_path(Current.organization), alert: t("organizations.require_owner")
    end
  end
end
