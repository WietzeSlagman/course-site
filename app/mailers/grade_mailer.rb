class GradeMailer < ActionMailer::Base

	helper GradesHelper

	default from: Settings['mail_address']
	
	def new_mail(grade)
		@course_name = Settings.short_course_name
		@grade_name = grade.pset.name
		@feedback = grade.comments
		@grade = grade.grade
		@login = grade.submit.used_login if grade.submit
		@header = File.read("#{Rails.root}/public/course/mail/grade.txt") if File.exists?("#{Rails.root}/public/course/mail/grade.txt")
		Rails.logger.debug ENV["MAILER_ADDRESS"]
		mail(to: grade.user.mail, subject: "Feedback for #{Settings.short_course_name}")
	end
	
end
