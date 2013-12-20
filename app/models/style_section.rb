class StyleSection < ActiveRecord::Base
	has_many :style_section_rules, -> { order(:id) }, :dependent => :destroy
end
