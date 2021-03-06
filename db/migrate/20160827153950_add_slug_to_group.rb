class AddSlugToGroup < ActiveRecord::Migration
	def change
		add_column :groups, :slug, :string
		add_index :groups, :slug, unique: true
		Group.all.each(&:save)
	end
end
