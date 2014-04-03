class GradeMailer < ActionMailer::Base

	helper GradesHelper

	default from: "info@mprog.nl"
	
	def new_mail(grade)
		@course_name = Settings.short_course_name
		@grade_name = grade.pset.name
		@feedback = grade.comments
		@grade = grade.grade
		
		mail(to: grade.user.mail, subject: "Feedback for #{Settings.short_course_name}")
	end
	
end