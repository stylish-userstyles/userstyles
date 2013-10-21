class AllowedBindingsController < ApplicationController
	layout "standard_layout"

	def index
		@allowed_bindings = AllowedBinding.find(:all)
	end
end
