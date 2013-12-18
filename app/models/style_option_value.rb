class StyleOptionValue < ActiveRecord::Base
	belongs_to :style_option, :touch => true

	alias_attribute :label, :display_name
	validates_presence_of :label
	validates_length_of :label, :maximum => 100

	def parameter_id
		id.nil? ? ordinal : id
	end
end
