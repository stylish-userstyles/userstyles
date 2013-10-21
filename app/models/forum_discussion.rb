class ForumDiscussion < ActiveRecord::Base
	set_table_name 'GDN_Discussion'
	set_primary_key 'DiscussionID'
	alias_attribute 'name', 'Name'

	def created
		return self.DateInserted
	end

	def updated
		return self.DateLastComment unless self.DateLastComment.nil?
		return self.DateInserted
	end

	def url
		"http://#{FORUM_DOMAIN}/discussion/#{self.DiscussionID}/x"
	end

end
