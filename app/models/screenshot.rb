class Screenshot < ActiveRecord::Base
	belongs_to :style, :touch => true
	validates_length_of :description, :minimum => 1
	validates_length_of :description, :maximum => 50
	validates_length_of :path, :minimum => 1

end
