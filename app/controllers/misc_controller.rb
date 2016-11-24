class MiscController < ApplicationController

	def copyright
		@page_title = "Stylish - Copyright Notice"
	end

	def terms
		@page_title = "Stylish - Terms of Use"
	end
end
