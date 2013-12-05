class StyleOptionValue < ActiveRecord::Base
	belongs_to :style_option, :touch => true
	validates_presence_of :display_name
	
	def parameter_id
		id.nil? ? ordinal : id
	end
end
