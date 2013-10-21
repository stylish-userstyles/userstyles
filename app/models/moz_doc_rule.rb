class MozDocRule < ActiveRecord::Base
	belongs_to :style
	validates_length_of :value, :minimum => 1

	validates_each :value do |record, attr, value|
		record.errors.add_to_base "@-moz-document domain rules must be a domain name only - '#{value}'." if record.rule_type == 'domain' and !/[\/\(\)]+/.match(value).nil?
	end

	def to_userjs_includes
		if rule_type == 'domain'
			return ["http://" + self.value + "/*", "https://" + self.value + "/*", "http://*." + self.value + "/*", "https://*." + self.value + "/*"]
		end
		if rule_type == 'url-prefix'
			return [self.value + "*"]
		end
		if rule_type == 'url'
			return [self.value]
		end
		#not supported on chrome
		#if rule_type == 'regexp'
		#	return ['/' + self.value + '/']
		#end
		return nil
	end

	def <=> m
		type_compare = rule_type <=> m.rule_type
		return type_compare if type_compare != 0
		return value <=> value
	end

end
