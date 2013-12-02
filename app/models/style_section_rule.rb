class StyleSectionRule < ActiveRecord::Base

	def to_userjs_includes
		if rule_type == 'domain'
			return ["http://" + self.rule_value + "/*", "https://" + self.rule_value + "/*", "http://*." + self.rule_value + "/*", "https://*." + self.rule_value + "/*"]
		end
		if rule_type == 'url-prefix'
			return [self.rule_value + "*"]
		end
		if rule_type == 'url'
			return [self.rule_value]
		end
		#not supported on chrome
		#if rule_type == 'regexp'
		#	return ['/' + self.value + '/']
		#end
		return nil
	end

end
