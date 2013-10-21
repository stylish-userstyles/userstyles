class StyleOption < ActiveRecord::Base
	has_many :style_option_values, :dependent => :destroy, :order => 'ordinal'

	validates_presence_of :name, :display_name
	validates_length_of :style_option_values, :minimum =>2, :message => 'must have at least 2 options.', :if => Proc.new { |option| option.option_type == "dropdown" }
	validates_length_of :style_option_values, :minimum =>1, :message => 'must have a default option.', :if => Proc.new { |option| option.option_type == "color" }
	validates_inclusion_of :option_type, :in => %w( dropdown color image )
	validates_associated :style_option_values

	def parameter_id
		id.nil? ? ordinal : id
	end

	def possibilities
		return ['#FFFFFF'] if option_type == "color"
		return ['http://example.com/image.gif'] if option_type == "image"
		return style_option_values.map {|v| v.parameter_id.to_s}
	end

end
