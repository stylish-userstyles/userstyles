class StyleSettingOption < ActiveRecord::Base
	belongs_to :style_setting, :touch => true

	validates_presence_of :label, :install_key
	validates_length_of :label, :maximum => 100
	validates_length_of :install_key, :maximum => 20
end
