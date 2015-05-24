class ChangeToUtf8mb4 < ActiveRecord::Migration
	def change
		reversible do |dir|
			dir.up do
				execute 'UPDATE GDN_User SET Email = \'\' where length(Email) > 150;'
				# I guess these are duplicate with the new charset somehow?
				execute "update users set login = concat('user', id) where login IN (_utf8mb4 x'C281C281C281C281C281C281C281C281C281C281', _utf8mb4 x'C282', CONCAT('Ã', _utf8mb4 x'C281', 'lef') COLLATE utf8mb4_unicode_ci, '', CONCAT('O', _utf8mb4 x'1B') COLLATE utf8mb4_unicode_ci);"
				execute "update users set login = concat('user', id) where login IN ('Julia E.', 'filipa', '', 'jaah', 'FunBlader');"

				execute 'ALTER TABLE GDN_AntiSpamLog MODIFY COLUMN `ForeignUrl` varchar(150) NOT NULL;'
				execute 'ALTER TABLE GDN_UserAuthenticationToken MODIFY COLUMN `ForeignUserKey` varchar(150) NOT NULL;'

				execute 'ALTER TABLE GDN_Flag MODIFY COLUMN `ForeignUrl` varchar(150) NOT NULL;'
				execute 'ALTER TABLE GDN_Regarding MODIFY COLUMN `Type` varchar(150) NOT NULL;'
				execute 'ALTER TABLE GDN_Tag MODIFY COLUMN `Name` varchar(150) NOT NULL;'
				execute 'ALTER TABLE GDN_User MODIFY COLUMN `Email` varchar(150) NOT NULL;'
				execute 'ALTER TABLE GDN_UserMeta MODIFY COLUMN `Name` varchar(150) NOT NULL;'
				execute 'ALTER TABLE GDN_UserAuthentication MODIFY COLUMN `ForeignUserKey` varchar(150) NOT NULL;'
				execute 'ALTER TABLE GDN_UserAuthenticationNonce MODIFY COLUMN `Nonce` varchar(150) NOT NULL;'

				execute 'ALTER DATABASE userstyles CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;'

				['GDN_Activity','GDN_ActivityComment','GDN_ActivityType','GDN_AnalyticsLocal','GDN_AntiSpam','GDN_AntiSpamLog','GDN_Ban','GDN_Category','GDN_Comment','GDN_Conversation','GDN_ConversationMessage','GDN_Discussion','GDN_Draft','GDN_Flag','GDN_Invitation','GDN_Log','GDN_Media','GDN_Message','GDN_Permission','GDN_Photo','GDN_Regarding','GDN_Role','GDN_Session','GDN_Spammer','GDN_Tag','GDN_TagDiscussion','GDN_User','GDN_UserAuthentication','GDN_UserAuthenticationNonce','GDN_UserAuthenticationProvider','GDN_UserAuthenticationToken','GDN_UserCategory','GDN_UserComment','GDN_UserConversation','GDN_UserDiscussion','GDN_UserMerge','GDN_UserMergeItem','GDN_UserMeta','GDN_UserPoints','GDN_UserRole','admin_delete_reasons','daily_install_counts','daily_report_counts','delayed_jobs','precalculated_warnings','screenshots','style_codes','style_install_counts','style_section_rules','style_sections','style_setting_options','style_settings','styles','user_authenticators','users'].each do |table|
					execute "ALTER TABLE #{table} CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
				end
			end
		end
	end
end
