#require 'allowed_binding'

class StyleCode < ActiveRecord::Base
	belongs_to :style, :touch => true

	def old_style_rules
		StyleCode.get_old_style_rules(self.code)
	end

	def md5
		Digest::MD5.hexdigest(code)
	end

	def parse_moz_docs
		#strip whitespace and comments
		clean_code = self.code.gsub(/\/\*.*?\*\//m, '')#.gsub(/(\r\n|[\r\n])/, '\n')

		sections = []
		
		search_position = 0
		while search_position < clean_code.size do
			md = clean_code[search_position..clean_code.size].match("@-moz-document")

			# grab any global portions in between
			if md.nil?
				code_portion = clean_code[search_position..clean_code.size].strip
				if !code_portion.empty?
					sections << {:global => true, :code => code_portion}
				end
				break;
			elsif md.begin(0) > search_position
				code_portion = clean_code[search_position..(search_position + md.begin(0) - 1)].strip
				if !code_portion.empty?
					sections << {:global => true, :code => code_portion}
				end
			end
			search_position += md.begin(0)
			rule_start = search_position

			# find the end of the moz-document
			bracket_count = 0
			first_bracket = nil
			last_bracket = nil

			if false
			begin
				bracket_match = clean_code[search_position..clean_code.length].match(/[{}]/)
				if bracket_match.nil?
					if first_bracket.nil?
						# no brackets at all. increment search_position so we don't reprocess this
						search_position += 1
					else
						# mismatched bracket count
					end
					break
				end
				if bracket_match[0] == "{"
					if first_bracket.nil?
						first_bracket = search_position + bracket_match.begin(0)
					end
					bracket_count += 1
				else
					bracket_count -= 1
					last_bracket = search_position + bracket_match.begin(0)
				end
				search_position += bracket_match.end(0)
			end until bracket_count == 0
			end

			begin
				if first_bracket.nil?
					# on the first search, look for something like ") {". this will help us avoid matching on brackets inside regexps
					bracket_match = clean_code[search_position..clean_code.length].match(/\)\s*\{/)
					if bracket_match.nil?
						# no brackets at all. increment search_position so we don't reprocess this
						search_position += 1
						break
					end
					first_bracket = search_position + bracket_match.end(0) - 1
					bracket_count += 1
					search_position += bracket_match.end(0)
					next
				end
				# after the first one, look for any { or }. not perfect as there could be some in strings...
				bracket_match = clean_code[search_position..clean_code.length].match(/[{}]/)
				if bracket_match.nil?
					# mismatched bracket count
					break
				end
				if bracket_match[0] == "{"
					bracket_count += 1
				else
					bracket_count -= 1
					last_bracket = search_position + bracket_match.begin(0)
				end
				search_position += bracket_match.end(0)
			end until bracket_count == 0

			if !bracket_match.nil?
				part_code = clean_code[first_bracket + 1..last_bracket - 1].strip
				if !part_code.empty?
					part_urls = StyleCode.get_old_style_rules(clean_code[rule_start..first_bracket])
					sections << {:rules => part_urls, :code => part_code}
				end
			end
		end

		#combine adjacent sections with the same rules
		last_unique_index = nil
		current_index = 0
		while current_index < sections.length
			if current_index > 0 and sections_have_same_rules(sections[last_unique_index], sections[current_index])
				sections[last_unique_index][:code] += sections[current_index][:code]
				sections.delete_at(current_index)
			else
				last_unique_index = current_index
				current_index += 1
			end
		end
		return sections
	end

private

	def sections_have_same_rules(s1, s2)
		return false if s1[:global] != s2[:global]
		return true if s1[:rules].nil? and s2[:rules].nil?
		return false if s1[:rules].nil? or s2[:rules].nil?
		return false if s1[:rules].length != s2[:rules].length
		r1 = s1[:rules].sort
		r2 = s2[:rules].sort
		for i in 0..r1.length - 1
			if r1[i].rule_type != r2[i].rule_type or r1[i].value != r2[i].value
				return false
			end
		end
		return true
	end
	
	def self.strip_comments(css)
		#strip css comments
		start_comment = css.index("/*")
		if (start_comment == nil)
			return css
		end
		end_comment = css.index("*/", start_comment)
		if (end_comment == nil)
			return css
		end
		while start_comment < end_comment
			css = css[0, start_comment] + css[end_comment + 2, css.length]
			start_comment = css.index("/*")
			if (start_comment == nil)
				return css
			end
			end_comment = css.index("*/", start_comment)		
			if (end_comment == nil)
				return css
			end
		end
	end


	def self.get_old_style_rules(code)
		css = strip_comments(code)
		moz_doc_values = []

		#pull out @-moz-document values into an array in the form ["domain ('example.com')", "url('http://example.com')"]
		index = 0
		while ruleset = get_next_ruleset(css, index)
			moz_doc_values = moz_doc_values.concat(ruleset[0])
			index = ruleset[1]
		end

		#take each value in the form "domain ('example.com')" and put into an array in the form ["domain", "example.com"]
		site_rules = []
		moz_doc_values.each do |moz_doc_value|
			opening_bracket = moz_doc_value.index("(")
			closing_bracket = moz_doc_value.rindex(")")
			if opening_bracket != nil and closing_bracket != nil
				moz_doc_rule = MozDocRule.new
				#moz_doc_rule.style_id = style.id
				moz_doc_rule.rule_type = moz_doc_value[0..opening_bracket - 1].strip()
				moz_doc_rule.value = moz_doc_value[opening_bracket + 1..closing_bracket - 1].strip().delete("\"'")
				if moz_doc_rule.rule_type == "domain" and /^[\w\d-]+(\.[\w\d-]+)*$/.match(moz_doc_rule.value).nil?
					moz_doc_rule.errors.add('moz-document domain', 'must be a valid host name (no protocol, no wildcards)');
				end
				# unescape the css
				moz_doc_rule.value.gsub!('\\\\', '\\') if moz_doc_rule.rule_type == 'regexp'
				site_rules[site_rules.length] = moz_doc_rule
			end
			
		end

		return site_rules
	end

	def self.get_next_ruleset(code, index)
		css = code[index..code.length]
		moz_doc_rule_re = /@-moz-document\s+/
		moz_doc_rule_match = moz_doc_rule_re.match(css)
		if moz_doc_rule_match.nil?
			return nil
		end
		start_moz_doc = moz_doc_rule_match.begin(0)
		end_moz_doc = css.index("{", start_moz_doc)
		#end_moz_doc = css[start_moz_doc..css.length].rindex("{")
		if end_moz_doc.nil?
			return nil
		end
		return [css[start_moz_doc + moz_doc_rule_match[0].length..end_moz_doc - 1].split(","), index + end_moz_doc]
	end

end
