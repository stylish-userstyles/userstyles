class AllowedBinding < ActiveRecord::Base

	$allowed_bindings = nil

	def self.is_allowed?(url)
		if $allowed_bindings.nil?
			$allowed_bindings = self.find(:all)
		end
		$allowed_bindings.each do |ab|
			return true if ab.url == url
		end
		return false
	end
end
