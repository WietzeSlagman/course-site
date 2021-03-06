require 'dropbox'

class ConfigController < ApplicationController

	before_filter CASClient::Frameworks::Rails::Filter
	before_filter :require_admin
	
	# key entry page, also shows if already having a session
	def dropbox
		@dropbox_linked = Dropbox.connected?
	end
	
	def git_repo_save
		if Settings.git_repo.present?
			redirect_to :back, alert: 'You already cloned a repo once!'
		else
			Settings.git_repo = params[:repo_url]
			Settings.git_branch = params[:repo_branch]
			CourseLoader.new.run
			redirect_to :back, notice: 'The course content was successfully cloned.'
		end
	end
	
	def generate_secret
		secret = SecureRandom.hex(20)
		Settings.webhook_secret = secret
		render js:"$('#secret').html('#{secret}');"
	end
	
	def webhook
		@secret = Settings.webhook_secret
	end

end
