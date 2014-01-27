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
		return [{:iskey => false, :value => 'example text'}] if setting_type == "text"
		return style_setting_options.map {|v| {:iskey => true, :value => v.install_key}}
	end

end
