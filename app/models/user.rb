class User < ActiveRecord::Base
	
	belongs_to :group

	has_many :logins
	has_many :hands
	has_many :submits
	has_many :grades, through: :submits
	has_many :psets, through: :submits
	has_many :attendance_records
	
	has_one :ping

	# scope :admin,     -> { joins(:logins).where("logins.login in (?)", (Settings['admins'] or []) + (Settings['assistants'] or [])) }
	# scope :not_admin, -> { joins(:logins).where("logins.login not in (?)", (Settings['admins'] or []) + (Settings['assistants'] or [])) }
	scope :admin_or_assistant, -> { where(role: [User.roles[:admin], User.roles[:assistant], User.roles[:head]]) }
	scope :not_admin_or_assistant, -> { where.not(role: [User.roles[:admin], User.roles[:assistant], User.roles[:head]]) }
	scope :active,    -> { where(active: true) }
	scope :inactive,  -> { where(active: false) }
	scope :no_group,  -> { where(group_id: nil) }
	scope :but_not,   -> users { where("users.id not in (?)", users) }
	scope :with_login, -> login { joins(:logins).where("logins.login = ?", login)}
	
	# scope :from_term, -> term  { where("term" => term) if not (term.nil? or term.empty?) }
	# scope :having_status, -> status  { where("status" => status) if not (status.nil? or status.empty?) }
	
	enum role: [:guest, :student, :assistant, :head, :admin]
	
	def self.find_by_login(login)
		if login
			return Login.find_by_login(login).user
		end
	end
	
	def submit(pset)
		submits.where(:pset_id => pset.id).first
	end
	
	def activate
		update_attribute :active, true
	end
	
	def login_id
		return self.logins.first.login
	end

	def valid_profile?
		return !self.name.blank?
	end
	
	def can_submit?
		return self.valid_profile?
	end
	
	def is_admin?
		admin?
		# admins = Settings['admins']
		# return admins && (admins & self.logins.pluck(:login)).size > 0
	end
	
	def is_assistant?
		assistant?
		# assistants = Settings['assistants']
		# return assistants && (assistants & self.logins.pluck(:login)).size > 0
	end
	
	def is_admin_or_assistant?
		admin_or_assistant?
	end
	
	def admin_or_assistant?
		# is_admin? or is_assistant?
		admin? or assistant?
	end

	def final_grade
		'N/A'
	end
	
	def assign_final_grade(grader)
		# generate hash of  pset_name: submit_object
		subs = self.grades.group_by { |i| i.submit.pset.name }.each_with_object({}) { |(k,v),o| o[k] = v[0] }
		
		# calc grade from hash
		grade = GradeTools.new.calc_final_grade(subs)
		
		# save
		final = self.submits.where(pset:Pset.where(name:'final').first).count > 0
		if final || grade > 0
			final = self.submits.where(pset:Pset.where(name:'final').first).first_or_create
			final.create_grade if !final.grade
			final.grade.grade = grade
			final.grade.grader = grader
			if final.grade.changed?
				final.grade.done = false
				final.grade.public = false
				final.grade.save
			end
		end
	end
	
	def generate_token!
		self.token = SecureRandom.hex(16)
		self.save
	end
	
	def generate_pairing_code!
		self.token = SecureRandom.random_number(10000)
		self.save
	end
	
end
