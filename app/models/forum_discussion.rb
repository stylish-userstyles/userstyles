class ForumDiscussion < ActiveRecord::Base
	self.table_name = 'GDN_Discussion'
	self.primary_key = 'DiscussionID'
	alias_attribute 'name', 'Name'
	
	# ignore this so we don't have to cache something we won't use
	ignore_columns :Body
	
	has_and_belongs_to_many :original_posters, -> { readonly }, :class_name => 'User', :foreign_key => 'UserID', :association_foreign_key => 'ForeignUserKey', :join_table => 'GDN_UserAuthentication'

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
	
	def original_poster
		return nil if original_posters.empty?
		original_posters.first
	end

end
