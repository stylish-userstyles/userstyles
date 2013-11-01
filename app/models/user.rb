require 'digest/sha1'

class User < ActiveRecord::Base
	strip_attributes

	has_many :styles, -> { order(:short_description) }
	has_many :user_authenticators

	validates_uniqueness_of :login, :allow_nil => true, :case_sensitive => false
	validates_length_of :login, :in => 1..20, :allow_nil => true

	validates_uniqueness_of :name, :case_sensitive => false
	validates_length_of :name, :minimum => 1

	validates_length_of :homepage, :maximum => 255, :allow_blank => true
	validates_length_of :about, :maximum => 4000, :allow_blank => true
	validates_format_of :homepage, :with => /\A(#{URI::regexp(%w(http https))})\z/, :allow_blank => true

	validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_blank => true
	validates_format_of :paypal_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :allow_blank => true

	validates_confirmation_of :password

	validates_inclusion_of :license, :in => %w( publicdomain ccby ccbysa ccbynd ccbync ccbyncsa ccbyncnd arr ), :allow_nil => true

	def self.authenticate(name, password)
		return nil if name.nil? or password.nil?
		user = User.where(:login => name).first
		if user
			expected_password = encrypted_password(password, user.salt)
			if user.hashed_password != expected_password
				user = nil
			end
		end
		return user
	end

	#things others have said about this user's styles
	def comments_to
		render :nothing => true, :status => 401
	end

	def generate_login_token
		Digest::SHA1.hexdigest("#{self.login}-#{self.password}-#{Time.now.to_i}")[0..39]
	end

	def generate_key
		(1..30).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
	end

	def create_lost_password_key
		self.lost_password_key = generate_key
	end

	def password
		@password
	end

	def password=(pwd)
		@password = pwd
		if pwd.nil?
			self.salt = nil
			self.hashed_password = nil
			return
		end	
		create_new_salt
		self.hashed_password = User.encrypted_password(self.password, self.salt)
	end

	def forum_id
		User.get_forum_id_for_user(self.id)
	end

	def self.get_forum_id_for_user(id)
		User.connection.select_value("SELECT UserID FROM GDN_UserAuthentication WHERE ForeignUserKey = #{User.connection.quote(id)};")
	end

	def self.get_user_for_forum_id(id)
		User.connection.select_value("SELECT ForeignUserKey FROM GDN_UserAuthentication WHERE UserID = #{User.connection.quote(id)};")
	end

	def style_forum_stats
		results = {}
		User.connection.select_rows("SELECT gd.StyleID, MAX(IF(DateLastComment IS NULL, DateInserted, DateLastComment)) FROM GDN_Discussion gd JOIN styles on styles.id = gd.StyleID WHERE user_id = #{id} AND gd.Closed = 0 GROUP BY gd.StyleID").each do |k,v|
			#results[k] = Date.parse(v)
			results[k] = v
		end
		return results
	end
	
	def has_spare_login_methods
		return true if !self.hashed_password.nil? and !self.user_authenticators.empty?
		return true if self.user_authenticators.size > 1
		return false
	end

	private
		def self.encrypted_password(password, salt)
			Digest::SHA1.hexdigest(password + "zomgwtfbbq" + salt)
		end

		def create_new_salt
			self.salt = self.object_id.to_s + rand.to_s
		end

end
