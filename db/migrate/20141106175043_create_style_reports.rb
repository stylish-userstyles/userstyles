class CreateStyleReports < ActiveRecord::Migration
	def change
		create_table :daily_report_counts do |t|
			t.integer :style_id, :null => false
			t.string :ip, :limit => 15, :null => false
		end
		add_index :daily_report_counts, [:style_id, :ip], :unique => true
		execute 'alter table daily_report_counts add column report_date timestamp not null default CURRENT_TIMESTAMP'
	end
end
