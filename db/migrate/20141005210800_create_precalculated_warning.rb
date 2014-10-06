class CreatePrecalculatedWarning < ActiveRecord::Migration
	def change
		create_table :precalculated_warnings do |t|
			t.references :style, :null => false, :index => true
			t.string :warning_type, :null => false, :limit => 20
			t.string :detail, :null => false, :limit => 1000
		end
	end
end
