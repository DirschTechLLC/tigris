class SubmissionsMailer < ApplicationMailer
  def notify(user, submission)
    @user = user
    @submission = submission
    @organization = submission.organization
    mail(
      to: user.email_address,
      subject: t(".subject", organization: @organization.name)
    )
  end
end
