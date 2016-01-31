class Hand < ActiveRecord::Base

	belongs_to :user
	belongs_to :assist, class_name: "User"

	after_create do |hand|
		notifier = Slack::Notifier.new ENV['SLACK_WEBHOOK'], username: hand.user.name, channel: Settings.hands_slack_channel
		notifier.ping "Location: #{hand.location}\n#{hand.help_question}"
	end
	
	def user_last_seen
		if attend = self.user.attendance_records.order('cutoff desc').first
			attend.cutoff
		else
			nil
		end
	end

end
