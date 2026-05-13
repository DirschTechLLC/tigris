module OrganizationScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_current_organization
  end

  private

  def set_current_organization
    slug = params[:organization_slug] || params[:slug]
    org = Organization.friendly.find(slug)
    raise ActiveRecord::RecordNotFound unless org.member?(Current.user)
    Current.organization = org
  end
end
