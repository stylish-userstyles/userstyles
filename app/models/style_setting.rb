class StyleSetting < ActiveRecord::Base
	belongs_to :style, :touch => true
	has_many :style_setting_options, -> { order(:ordinal) }, :dependent => :destroy

	validates_presence_of :install_key, :label
	validates_length_of :install_key, :maximum => 20
	validates_length_of :label, :maximum => 100
	validates_length_of :style_setting_options, :minimum =>2, :message => 'must have at least 2 options.', :if => Proc.new { |setting| setting.setting_type == "dropdown" }
	validates_length_of :style_setting_options, :minimum =>1, :message => 'must have a default option.', :if => Proc.new { |setting| setting.setting_type == "color" or setting.setting_type == "text" }
	validates_inclusion_of :setting_type, :in => %w( dropdown color image text )
	validates_associated :style_setting_options

	def possibilities
		return [{:iskey => false, :value => '#FFFFFF'}] if setting_type == "color"
		return [{:iskey => false, :value => 'http://example.com/image.gif'}] if setting_type == "image"
		if setting_type == "text"
			# Let the author's default value be the thing to validate with, otherwise it would be impossible to validate in certain
			# situations where a specific kind of string is expected (like a domain).
			return [{:iskey => false, :value => default_option_value}] unless default_option_value.empty?
			return [{:iskey => false, :value => 'example text'}]
		end
		return style_setting_options.map {|v| {:iskey => true, :value => v.install_key}}
	end

	def default_option_value
		option = style_setting_options.select {|v| v.default }.first
		return option.value unless option.nil?
		return nil
	end

end
