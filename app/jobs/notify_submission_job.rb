class NotifySubmissionJob < ApplicationJob
  queue_as :default
  discard_on ActiveRecord::RecordNotFound

  def perform(submission_id)
    submission = Submission.find(submission_id)
    submission.organization.users.each do |user|
      SubmissionsMailer.notify(user, submission).deliver_now
    end
  end
end
