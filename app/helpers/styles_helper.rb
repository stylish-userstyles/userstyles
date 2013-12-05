require 'rubygems'
require 'sanitize'

module StylesHelper

	def style_list(styles, none_text, edit_links=false, list_id='style-list', additional_link=nil)
		if styles.empty?
			return "<p class=\"none-text\">" + none_text + "</p>"
		end
		code = "<ul#{(!list_id.nil? and list_id != '') ? " id='#{list_id}'" : ''}>\n" + styles.map { |style|
			if edit_links
				edit_text = " <a class=\"edit-link\" href=\"#{url_for(:controller => 'styles', :action => 'edit', :id => style.id)}\" rel='nofollow'>[Edit]</a> <a class=\"delete-link\" href=\"#{url_for(:controller => 'styles', :action => 'delete', :id => style.id)}\" rel='nofollow'>[Delete]</a>"
			else
				edit_text = ""
			end
			rating_class = nil
			if style.rating.nil?
				rating_class = 'no-rating'
			elsif style.rating >= 2.5
				rating_class = 'good-rating'
			elsif style.rating >= 1.5
				rating_class = 'ok-rating'
			else
				rating_class = 'bad-rating'
			end
			"<li class='#{style.obsolete? ? 'obsolete' : ''} #{rating_class}' weekly-install-count='#{style.weekly_install_count}' total-install-count='#{style.total_install_count}' average-rating='#{style.rating}'><a href='/styles/#{style.id}/#{style.url_snippet}' #{style.obsolete? ? 'rel="nofollow"' : ''}>#{h style.short_description}</a>#{edit_text}</li>"
		}.join("\n") 
		if !additional_link.nil?
			code += "<li class='additional-link'>#{additional_link}</li>"
		end
		code += '</ul>'
		code.html_safe
	end

	def format_user_text_plain(text)
		# run it through the normal formatter then strip the tags. the normal formatter will modify the text
		return Sanitize.clean(format_user_text(text)).html_safe
	end

	def format_user_text(text)
		yes_follow = lambda do |env|
			follow_domains = ['mozillazine.org', 'mozilla.org', 'mozilla.com', 'userscripts.org', 'userstyles.org', 'mozdev.org', 'photobucket.com', 'facebook.com', 'chrome.google.com', 'github.com']
			return unless env[:node_name] == 'a'
			node = env[:node]
			href = nil
			href = node['href'].downcase unless node['href'].nil?
			follow = false	
			if href.nil?
				# missing the href, we don't want a rel here
				follow = true
			elsif href =~ Sanitize::REGEX_PROTOCOL
				# external link, let's figure out the domain if it's http or https
				match = /https?:\/\/([^\/]+).*/.match(href)
				# check domain against our list, including subdomains
				if !match.nil?
					follow_domains.each do |d|
						if match[1] == d or match[1].ends_with?('.' + d)
							follow = true
							break
						end
					end
				end
			else
				# internal link
				follow = true
			end
			if follow
				# take out any rel value the user may have provided
				node.delete('rel')
			else
				node['rel'] = 'nofollow'
			end

			# make a config that allows the rel attribute and does not include this transformer
			# do a deep copy of anything we're going to change
			config_allows_rel = env[:config].dup
			config_allows_rel[:attributes] = config_allows_rel[:attributes].dup
			config_allows_rel[:attributes]['a'] = config_allows_rel[:attributes]['a'].dup
			config_allows_rel[:attributes]['a'] << 'rel'
			config_allows_rel[:add_attributes] = config_allows_rel[:add_attributes].dup
			config_allows_rel[:add_attributes]['a'] = config_allows_rel[:add_attributes]['a'].dup
			config_allows_rel[:add_attributes]['a'].delete('rel')
			config_allows_rel[:transformers] = config_allows_rel[:transformers].dup
			config_allows_rel[:transformers].delete(yes_follow)

			Sanitize.clean_node!(node, config_allows_rel)

			# whitelist so the initial clean call doesn't strip the rel
			return {:node_whitelist => [node]}
		end

		linkify_urls = lambda do |env|
			node = env[:node]
			return unless node.text?
			return if has_anchor_ancestor(node)
			url_reference = node.text.match(/(\s|^|\()(https?:\/\/[^\s\)\]]*)/i)
			return if url_reference.nil?
			resulting_nodes = replace_text_with_link(node, url_reference[2], url_reference[2], url_reference[2])
			# sanitize the new nodes ourselves; they won't be picked up otherwise.
			resulting_nodes.delete(node)
			resulting_nodes.each do |new_node|

				Sanitize.clean_node!(new_node, env[:config])
			end
		end

		linkify_styles = lambda do |env|
			node = env[:node]
			return unless node.text?
			return if has_anchor_ancestor(node)
			style_pattern = /(\s|^|\()(style ([0-9]+))/i
			style_reference = node.text.match(style_pattern)
			return if style_reference.nil?
			index = 0
			# in normal cases we will only handle one reference per call, but we actually need to loop in case there are invalid references
			until style_reference.nil?
				original_text = style_reference[2]
				style_id = style_reference[3].to_i
				index = index + node.text[index, node.text.length].index(original_text)
				begin
					style = Style.find(style_id)
					resulting_nodes = replace_text_with_link(node, original_text, style.short_description, style.pretty_url)
					# the current node will not contain any more references as all subsequent text will be in the newly created nodes.
					# sanitize the new nodes ourselves; they won't be picked up otherwise.
					resulting_nodes.delete(node)
					resulting_nodes.each do |new_node|
						Sanitize.clean_node!(new_node, env[:config])
					end
					return
				rescue ActiveRecord::RecordNotFound => ex
					# not a valid reference, move on to the next
				end
				index = index + original_text.length
				style_reference = node.text[index, node.text.length].match(style_pattern)
			end
		end

		linkify_users = lambda do |env|
			node = env[:node]
			return unless node.text?
			return if has_anchor_ancestor(node)
			user_pattern = /(\s|^|\()(user ([0-9]+))/i
			user_reference = node.text.match(user_pattern)
			return if user_reference.nil?
			index = 0
			# in normal cases we will only handle one reference per call, but we actually need to loop in case there are invalid references
			until user_reference.nil?
				original_text = user_reference[2]
				user_id = user_reference[3].to_i
				index = index + node.text[index, node.text.length].index(original_text)
				begin
					user = User.find(user_id)
					resulting_nodes = replace_text_with_link(node, original_text, user.name, url_for(:controller => "users", :action => "show", :id => user.id))
					# the current node will not contain any more references as all subsequent text will be in the newly created nodes.
					# sanitize the new nodes ourselves; they won't be picked up otherwise.
					resulting_nodes.delete(node)
					resulting_nodes.each do |new_node|
						Sanitize.clean_node!(new_node, env[:config])
					end
					return
				rescue ActiveRecord::RecordNotFound => ex
					# not a valid reference, move on to the next
				end
				index = index + original_text.length
				user_reference = node.text[index, node.text.length].match(user_pattern)
			end
		end

		fix_whitespace = lambda do |env|
			node = env[:node]
			return unless node.text?
			node.content = node.content.lstrip if node.previous_sibling.nil? or (!node.previous_sibling.description.nil? and node.previous_sibling.description.block?)
			node.content = node.content.rstrip if node.next_sibling.nil? or (!node.next_sibling.description.nil? and node.next_sibling.description.block?)
			return if node.text.empty?
			return unless node.text.include?("\n")
			resulting_nodes = replace_text_with_node(node, "\n", Nokogiri::XML::Node.new('br', node.document))
			# sanitize the new nodes ourselves; they won't be picked up otherwise.
			resulting_nodes.delete(node)
			resulting_nodes.each do |new_node|
				Sanitize.clean_node!(new_node, env[:config])
			end
		end					

		config = Sanitize::Config::BASIC.merge({
			:transformers => [linkify_urls, linkify_styles, linkify_users, yes_follow, fix_whitespace]
		})
		Sanitize.clean(text, config).html_safe
	end

private

	def replace_text_with_link(node, original_text, link_text, url)
			# the text itself becomes a link
			link = Nokogiri::XML::Node.new('a', node.document)
			link['href'] = url
			link.add_child(Nokogiri::XML::Text.new(link_text, node.document))
			return replace_text_with_node(node, original_text, link)
	end

	def replace_text_with_node(node, text, node_to_insert)
			original_content = node.text
			start = node.text.index(text)
			# the stuff before stays in the current node
			node.content = original_content[0, start]
			# add the new node
			node.add_next_sibling(node_to_insert)
			# the stuff after becomes a new text node
			node_to_insert.add_next_sibling(Nokogiri::XML::Text.new(original_content[start + text.size, original_content.size], node.document))
			return [node, node.next_sibling, node.next_sibling.next_sibling]
	end

	def has_anchor_ancestor(node)
		until node.nil?
			return true if node.name == 'a'
			node = node.parent
		end
		return false
	end


end
