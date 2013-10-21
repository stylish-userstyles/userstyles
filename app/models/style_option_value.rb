class StyleOptionValue < ActiveRecord::Base
	validates_presence_of :display_name
	
	def parameter_id
		id.nil? ? ordinal : id
	end
end
