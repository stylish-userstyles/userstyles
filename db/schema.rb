# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131031180842) do

  create_table "GDN_Activity", primary_key: "ActivityID", force: true do |t|
    t.integer  "CommentActivityID"
    t.integer  "ActivityTypeID",                           null: false
    t.integer  "ActivityUserID"
    t.integer  "RegardingUserID"
    t.text     "Story"
    t.string   "Route"
    t.integer  "CountComments",                default: 0, null: false
    t.integer  "InsertUserID"
    t.datetime "DateInserted",                             null: false
    t.string   "InsertIPAddress",   limit: 15
    t.integer  "Emailed",           limit: 1,  default: 0, null: false
  end

  add_index "GDN_Activity", ["ActivityUserID"], name: "FK_Activity_ActivityUserID", using: :btree
  add_index "GDN_Activity", ["CommentActivityID"], name: "FK_Activity_CommentActivityID", using: :btree
  add_index "GDN_Activity", ["InsertUserID"], name: "FK_Activity_InsertUserID", using: :btree
  add_index "GDN_Activity", ["RegardingUserID"], name: "FK_Activity_RegardingUserID", using: :btree

  create_table "GDN_ActivityType", primary_key: "ActivityTypeID", force: true do |t|
    t.string  "Name",            limit: 20,             null: false
    t.integer "AllowComments",   limit: 1,  default: 0, null: false
    t.integer "ShowIcon",        limit: 1,  default: 0, null: false
    t.string  "ProfileHeadline",                        null: false
    t.string  "FullHeadline",                           null: false
    t.string  "RouteCode"
    t.integer "Notify",          limit: 1,  default: 0, null: false
    t.integer "Public",          limit: 1,  default: 1, null: false
  end

  create_table "GDN_AnalyticsLocal", id: false, force: true do |t|
    t.string  "TimeSlot", limit: 8, null: false
    t.integer "Views"
  end

  add_index "GDN_AnalyticsLocal", ["TimeSlot"], name: "UX_AnalyticsLocal", unique: true, using: :btree

  create_table "GDN_AntiSpam", primary_key: "ID", force: true do |t|
    t.integer "StopForumSpam", limit: 1,   default: 1, null: false
    t.integer "Akismet",       limit: 1,   default: 0, null: false
    t.string  "AkismetKey",    limit: 150,             null: false
    t.integer "DeleteSpam",    limit: 1,   default: 0, null: false
  end

  create_table "GDN_AntiSpamLog", primary_key: "ID", force: true do |t|
    t.integer  "UserID",                   null: false
    t.string   "Name",         limit: 64,  null: false
    t.string   "ForeignURL",               null: false
    t.integer  "ForeignID",                null: false
    t.string   "ForeignType",  limit: 32,  null: false
    t.string   "IpAddress",    limit: 150, null: false
    t.datetime "DateInserted",             null: false
  end

  add_index "GDN_AntiSpamLog", ["ForeignURL"], name: "FK_AntiSpamLog_ForeignURL", using: :btree
  add_index "GDN_AntiSpamLog", ["UserID"], name: "FK_AntiSpamLog_UserID", using: :btree

  create_table "GDN_Ban", primary_key: "BanID", force: true do |t|
    t.string   "BanType",                   limit: 9,              null: false
    t.string   "BanValue",                  limit: 50,             null: false
    t.string   "Notes"
    t.integer  "CountUsers",                           default: 0, null: false
    t.integer  "CountBlockedRegistrations",            default: 0, null: false
    t.integer  "InsertUserID",                                     null: false
    t.datetime "DateInserted",                                     null: false
  end

  add_index "GDN_Ban", ["BanType", "BanValue"], name: "UX_Ban", unique: true, using: :btree

  create_table "GDN_Category", primary_key: "CategoryID", force: true do |t|
    t.integer  "ParentCategoryID"
    t.integer  "TreeLeft"
    t.integer  "TreeRight"
    t.integer  "Depth"
    t.integer  "CountDiscussions",                 default: 0,  null: false
    t.integer  "CountComments",                    default: 0,  null: false
    t.datetime "DateMarkedRead"
    t.integer  "AllowDiscussions",     limit: 1,   default: 1,  null: false
    t.integer  "Archived",             limit: 1,   default: 0,  null: false
    t.string   "Name",                                          null: false
    t.string   "UrlCode"
    t.string   "Description",          limit: 500
    t.integer  "Sort"
    t.integer  "PermissionCategoryID",             default: -1, null: false
    t.integer  "InsertUserID",                                  null: false
    t.integer  "UpdateUserID"
    t.datetime "DateInserted",                                  null: false
    t.datetime "DateUpdated",                                   null: false
    t.integer  "LastCommentID"
    t.integer  "LastDiscussionID"
  end

  add_index "GDN_Category", ["InsertUserID"], name: "FK_Category_InsertUserID", using: :btree

  create_table "GDN_Comment", primary_key: "CommentID", force: true do |t|
    t.integer  "DiscussionID",                           null: false
    t.integer  "InsertUserID"
    t.integer  "UpdateUserID"
    t.integer  "DeleteUserID"
    t.text     "Body",                                   null: false
    t.string   "Format",          limit: 20
    t.datetime "DateInserted"
    t.datetime "DateDeleted"
    t.datetime "DateUpdated"
    t.string   "InsertIPAddress", limit: 15
    t.string   "UpdateIPAddress", limit: 15
    t.integer  "Flag",            limit: 1,  default: 0, null: false
    t.float    "Score"
    t.text     "Attributes"
  end

  add_index "GDN_Comment", ["Body"], name: "TX_Comment", type: :fulltext
  add_index "GDN_Comment", ["DateInserted"], name: "FK_Comment_DateInserted", using: :btree
  add_index "GDN_Comment", ["DiscussionID"], name: "FK_Comment_DiscussionID", using: :btree
  add_index "GDN_Comment", ["InsertUserID"], name: "FK_Comment_InsertUserID", using: :btree

  create_table "GDN_Conversation", primary_key: "ConversationID", force: true do |t|
    t.string   "Subject",         limit: 100
    t.string   "Contributors",                            null: false
    t.integer  "FirstMessageID"
    t.integer  "InsertUserID",                            null: false
    t.datetime "DateInserted"
    t.string   "InsertIPAddress", limit: 15
    t.integer  "UpdateUserID",                            null: false
    t.datetime "DateUpdated",                             null: false
    t.string   "UpdateIPAddress", limit: 15
    t.integer  "CountMessages",               default: 0, null: false
    t.integer  "LastMessageID"
    t.integer  "RegardingID"
  end

  add_index "GDN_Conversation", ["DateInserted"], name: "FK_Conversation_DateInserted", using: :btree
  add_index "GDN_Conversation", ["FirstMessageID"], name: "FK_Conversation_FirstMessageID", using: :btree
  add_index "GDN_Conversation", ["InsertUserID"], name: "FK_Conversation_InsertUserID", using: :btree
  add_index "GDN_Conversation", ["RegardingID"], name: "IX_Conversation_RegardingID", using: :btree
  add_index "GDN_Conversation", ["UpdateUserID"], name: "FK_Conversation_UpdateUserID", using: :btree

  create_table "GDN_ConversationMessage", primary_key: "MessageID", force: true do |t|
    t.integer  "ConversationID",             null: false
    t.text     "Body",                       null: false
    t.string   "Format",          limit: 20
    t.integer  "InsertUserID"
    t.datetime "DateInserted",               null: false
    t.string   "InsertIPAddress", limit: 15
  end

  add_index "GDN_ConversationMessage", ["ConversationID"], name: "FK_ConversationMessage_ConversationID", using: :btree

  create_table "GDN_Discussion", primary_key: "DiscussionID", force: true do |t|
    t.string   "Type",              limit: 10
    t.string   "ForeignID",         limit: 30
    t.integer  "CategoryID",                                null: false
    t.integer  "InsertUserID",                              null: false
    t.integer  "UpdateUserID",                              null: false
    t.integer  "LastCommentID"
    t.string   "Name",              limit: 100,             null: false
    t.text     "Body",                                      null: false
    t.string   "Format",            limit: 20
    t.string   "Tags"
    t.integer  "CountComments",                 default: 1, null: false
    t.integer  "CountBookmarks"
    t.integer  "CountViews",                    default: 1, null: false
    t.integer  "Closed",            limit: 1,   default: 0, null: false
    t.integer  "Announce",          limit: 1,   default: 0, null: false
    t.integer  "Sink",              limit: 1,   default: 0, null: false
    t.datetime "DateInserted"
    t.datetime "DateUpdated",                               null: false
    t.string   "InsertIPAddress",   limit: 15
    t.string   "UpdateIPAddress",   limit: 15
    t.datetime "DateLastComment"
    t.integer  "LastCommentUserID"
    t.float    "Score"
    t.text     "Attributes"
    t.integer  "RegardingID"
    t.integer  "StyleID"
    t.integer  "Rating",                        default: 0, null: false
  end

  add_index "GDN_Discussion", ["CategoryID"], name: "FK_Discussion_CategoryID", using: :btree
  add_index "GDN_Discussion", ["DateLastComment"], name: "IX_Discussion_DateLastComment", using: :btree
  add_index "GDN_Discussion", ["ForeignID"], name: "IX_Discussion_ForeignID", using: :btree
  add_index "GDN_Discussion", ["InsertUserID"], name: "FK_Discussion_InsertUserID", using: :btree
  add_index "GDN_Discussion", ["Name", "Body"], name: "TX_Discussion", type: :fulltext
  add_index "GDN_Discussion", ["RegardingID"], name: "IX_Discussion_RegardingID", using: :btree
  add_index "GDN_Discussion", ["Type"], name: "IX_Discussion_Type", using: :btree

  create_table "GDN_Draft", primary_key: "DraftID", force: true do |t|
    t.integer  "DiscussionID"
    t.integer  "CategoryID"
    t.integer  "InsertUserID",                         null: false
    t.integer  "UpdateUserID",                         null: false
    t.string   "Name",         limit: 100
    t.string   "Tags"
    t.integer  "Closed",       limit: 1,   default: 0, null: false
    t.integer  "Announce",     limit: 1,   default: 0, null: false
    t.integer  "Sink",         limit: 1,   default: 0, null: false
    t.text     "Body",                                 null: false
    t.string   "Format",       limit: 20
    t.datetime "DateInserted",                         null: false
    t.datetime "DateUpdated"
  end

  add_index "GDN_Draft", ["CategoryID"], name: "FK_Draft_CategoryID", using: :btree
  add_index "GDN_Draft", ["DiscussionID"], name: "FK_Draft_DiscussionID", using: :btree
  add_index "GDN_Draft", ["InsertUserID"], name: "FK_Draft_InsertUserID", using: :btree

  create_table "GDN_Flag", id: false, force: true do |t|
    t.integer  "InsertUserID",            null: false
    t.string   "InsertName",   limit: 64, null: false
    t.integer  "AuthorID",                null: false
    t.string   "AuthorName",   limit: 64, null: false
    t.string   "ForeignURL",              null: false
    t.integer  "ForeignID",               null: false
    t.string   "ForeignType",  limit: 32, null: false
    t.text     "Comment",                 null: false
    t.datetime "DateInserted",            null: false
    t.integer  "DiscussionID"
  end

  add_index "GDN_Flag", ["ForeignURL"], name: "FK_Flag_ForeignURL", using: :btree
  add_index "GDN_Flag", ["InsertUserID"], name: "FK_Flag_InsertUserID", using: :btree

  create_table "GDN_Invitation", primary_key: "InvitationID", force: true do |t|
    t.string   "Email",          limit: 200, null: false
    t.string   "Code",           limit: 50,  null: false
    t.integer  "InsertUserID"
    t.datetime "DateInserted",               null: false
    t.integer  "AcceptedUserID"
  end

  add_index "GDN_Invitation", ["InsertUserID"], name: "FK_Invitation_InsertUserID", using: :btree

  create_table "GDN_Log", primary_key: "LogID", force: true do |t|
    t.string   "Operation",       limit: 8,  null: false
    t.string   "RecordType",      limit: 12, null: false
    t.integer  "RecordID"
    t.integer  "RecordUserID"
    t.datetime "RecordDate",                 null: false
    t.string   "RecordIPAddress", limit: 15
    t.integer  "InsertUserID",               null: false
    t.datetime "DateInserted",               null: false
    t.string   "InsertIPAddress", limit: 15
    t.string   "OtherUserIDs"
    t.datetime "DateUpdated"
    t.integer  "ParentRecordID"
    t.text     "Data"
    t.integer  "CountGroup"
  end

  add_index "GDN_Log", ["ParentRecordID"], name: "IX_Log_ParentRecordID", using: :btree
  add_index "GDN_Log", ["RecordID"], name: "IX_Log_RecordID", using: :btree
  add_index "GDN_Log", ["RecordIPAddress"], name: "IX_Log_RecordIPAddress", using: :btree
  add_index "GDN_Log", ["RecordType"], name: "IX_Log_RecordType", using: :btree

  create_table "GDN_Media", primary_key: "MediaID", force: true do |t|
    t.string   "Name",                      null: false
    t.string   "Type",          limit: 128, null: false
    t.integer  "Size",                      null: false
    t.integer  "ImageWidth",    limit: 2
    t.integer  "ImageHeight",   limit: 2
    t.string   "StorageMethod", limit: 24,  null: false
    t.string   "Path",                      null: false
    t.integer  "InsertUserID",              null: false
    t.datetime "DateInserted",              null: false
    t.integer  "ForeignID"
    t.string   "ForeignTable",  limit: 24
  end

  create_table "GDN_Message", primary_key: "MessageID", force: true do |t|
    t.text    "Content",                             null: false
    t.string  "Format",       limit: 20
    t.integer "AllowDismiss", limit: 1,  default: 1, null: false
    t.integer "Enabled",      limit: 1,  default: 1, null: false
    t.string  "Application"
    t.string  "Controller"
    t.string  "Method"
    t.string  "AssetTarget",  limit: 20
    t.string  "CssClass",     limit: 20
    t.integer "Sort"
  end

  create_table "GDN_Permission", primary_key: "PermissionID", force: true do |t|
    t.integer "RoleID",                                         default: 0, null: false
    t.string  "JunctionTable",                      limit: 100
    t.string  "JunctionColumn",                     limit: 100
    t.integer "JunctionID"
    t.integer "Garden.Email.Manage",                limit: 1,   default: 0, null: false
    t.integer "Garden.Settings.Manage",             limit: 1,   default: 0, null: false
    t.integer "Garden.Settings.View",               limit: 1,   default: 0, null: false
    t.integer "Garden.Routes.Manage",               limit: 1,   default: 0, null: false
    t.integer "Garden.Messages.Manage",             limit: 1,   default: 0, null: false
    t.integer "Garden.Applications.Manage",         limit: 1,   default: 0, null: false
    t.integer "Garden.Plugins.Manage",              limit: 1,   default: 0, null: false
    t.integer "Garden.Themes.Manage",               limit: 1,   default: 0, null: false
    t.integer "Garden.SignIn.Allow",                limit: 1,   default: 0, null: false
    t.integer "Garden.Registration.Manage",         limit: 1,   default: 0, null: false
    t.integer "Garden.Applicants.Manage",           limit: 1,   default: 0, null: false
    t.integer "Garden.Roles.Manage",                limit: 1,   default: 0, null: false
    t.integer "Garden.Users.Add",                   limit: 1,   default: 0, null: false
    t.integer "Garden.Users.Edit",                  limit: 1,   default: 0, null: false
    t.integer "Garden.Users.Delete",                limit: 1,   default: 0, null: false
    t.integer "Garden.Users.Approve",               limit: 1,   default: 0, null: false
    t.integer "Garden.Activity.Delete",             limit: 1,   default: 0, null: false
    t.integer "Garden.Activity.View",               limit: 1,   default: 0, null: false
    t.integer "Garden.Profiles.View",               limit: 1,   default: 0, null: false
    t.integer "Garden.Profiles.Edit",               limit: 1,   default: 0, null: false
    t.integer "Garden.Moderation.Manage",           limit: 1,   default: 0, null: false
    t.integer "Garden.AdvancedNotifications.Allow", limit: 1,   default: 0, null: false
    t.integer "Vanilla.Settings.Manage",            limit: 1,   default: 0, null: false
    t.integer "Vanilla.Categories.Manage",          limit: 1,   default: 0, null: false
    t.integer "Vanilla.Spam.Manage",                limit: 1,   default: 0, null: false
    t.integer "Vanilla.Discussions.View",           limit: 1,   default: 0, null: false
    t.integer "Vanilla.Discussions.Add",            limit: 1,   default: 0, null: false
    t.integer "Vanilla.Discussions.Edit",           limit: 1,   default: 0, null: false
    t.integer "Vanilla.Discussions.Announce",       limit: 1,   default: 0, null: false
    t.integer "Vanilla.Discussions.Sink",           limit: 1,   default: 0, null: false
    t.integer "Vanilla.Discussions.Close",          limit: 1,   default: 0, null: false
    t.integer "Vanilla.Discussions.Delete",         limit: 1,   default: 0, null: false
    t.integer "Vanilla.Comments.Add",               limit: 1,   default: 0, null: false
    t.integer "Vanilla.Comments.Edit",              limit: 1,   default: 0, null: false
    t.integer "Vanilla.Comments.Delete",            limit: 1,   default: 0, null: false
    t.integer "Plugins.Attachments.Upload.Allow",   limit: 1,   default: 0, null: false
    t.integer "Plugins.Attachments.Download.Allow", limit: 1,   default: 0, null: false
    t.integer "Conversations.Moderation.Manage",    limit: 1,   default: 0, null: false
  end

  add_index "GDN_Permission", ["RoleID"], name: "FK_Permission_RoleID", using: :btree

  create_table "GDN_Photo", primary_key: "PhotoID", force: true do |t|
    t.string   "Name",         null: false
    t.integer  "InsertUserID"
    t.datetime "DateInserted", null: false
  end

  add_index "GDN_Photo", ["InsertUserID"], name: "FK_Photo_InsertUserID", using: :btree

  create_table "GDN_Regarding", primary_key: "RegardingID", force: true do |t|
    t.string   "Type",                       null: false
    t.integer  "InsertUserID",               null: false
    t.datetime "DateInserted",               null: false
    t.string   "ForeignType",     limit: 32, null: false
    t.integer  "ForeignID",                  null: false
    t.text     "OriginalContent"
    t.string   "ParentType",      limit: 32
    t.integer  "ParentID"
    t.string   "ForeignURL"
    t.text     "Comment",                    null: false
    t.integer  "Reports"
  end

  add_index "GDN_Regarding", ["Type"], name: "FK_Regarding_Type", using: :btree

  create_table "GDN_Role", primary_key: "RoleID", force: true do |t|
    t.string  "Name",        limit: 100,             null: false
    t.string  "Description", limit: 500
    t.integer "Sort"
    t.integer "Deletable",   limit: 1,   default: 1, null: false
    t.integer "CanSession",  limit: 1,   default: 1, null: false
  end

  create_table "GDN_Session", primary_key: "SessionID", force: true do |t|
    t.integer  "UserID",                  default: 0, null: false
    t.datetime "DateInserted",                        null: false
    t.datetime "DateUpdated",                         null: false
    t.string   "TransientKey", limit: 12,             null: false
    t.text     "Attributes"
  end

  create_table "GDN_Spammer", primary_key: "UserID", force: true do |t|
    t.integer "CountSpam",        limit: 2, default: 0, null: false
    t.integer "CountDeletedSpam", limit: 2, default: 0, null: false
  end

  create_table "GDN_Tag", primary_key: "TagID", force: true do |t|
    t.string   "Name",                                    null: false
    t.string   "Type",             limit: 10
    t.integer  "InsertUserID"
    t.datetime "DateInserted",                            null: false
    t.integer  "CountDiscussions",            default: 0, null: false
  end

  add_index "GDN_Tag", ["InsertUserID"], name: "FK_Tag_InsertUserID", using: :btree
  add_index "GDN_Tag", ["Name"], name: "UX_Tag", unique: true, using: :btree
  add_index "GDN_Tag", ["Type"], name: "IX_Tag_Type", using: :btree

  create_table "GDN_TagDiscussion", id: false, force: true do |t|
    t.integer "TagID",        null: false
    t.integer "DiscussionID", null: false
  end

  create_table "GDN_User", primary_key: "UserID", force: true do |t|
    t.string   "Name",                     limit: 50,                null: false
    t.binary   "Password",                 limit: 100,               null: false
    t.string   "HashMethod",               limit: 10
    t.string   "Photo"
    t.text     "About"
    t.string   "Email",                    limit: 200,               null: false
    t.integer  "ShowEmail",                limit: 1,   default: 0,   null: false
    t.string   "Gender",                   limit: 1,   default: "m", null: false
    t.integer  "CountVisits",                          default: 0,   null: false
    t.integer  "CountInvitations",                     default: 0,   null: false
    t.integer  "CountNotifications"
    t.integer  "InviteUserID"
    t.text     "DiscoveryText"
    t.text     "Preferences"
    t.text     "Permissions"
    t.text     "Attributes"
    t.datetime "DateSetInvitations"
    t.datetime "DateOfBirth"
    t.datetime "DateFirstVisit"
    t.datetime "DateLastActive"
    t.string   "LastIPAddress",            limit: 15
    t.datetime "DateInserted",                                       null: false
    t.string   "InsertIPAddress",          limit: 15
    t.datetime "DateUpdated"
    t.string   "UpdateIPAddress",          limit: 15
    t.integer  "HourOffset",                           default: 0,   null: false
    t.float    "Score"
    t.integer  "Admin",                    limit: 1,   default: 0,   null: false
    t.integer  "Banned",                   limit: 1,   default: 0,   null: false
    t.integer  "Deleted",                  limit: 1,   default: 0,   null: false
    t.integer  "CountDiscussions"
    t.integer  "CountUnreadDiscussions"
    t.integer  "CountComments"
    t.integer  "CountDrafts"
    t.integer  "CountBookmarks"
    t.integer  "CountUnreadConversations"
    t.datetime "DateAllViewed"
  end

  add_index "GDN_User", ["Email"], name: "IX_User_Email", using: :btree
  add_index "GDN_User", ["Name"], name: "FK_User_Name", using: :btree

  create_table "GDN_UserAuthentication", id: false, force: true do |t|
    t.string  "ForeignUserKey",            null: false
    t.string  "ProviderKey",    limit: 64, null: false
    t.integer "UserID",                    null: false
  end

  add_index "GDN_UserAuthentication", ["UserID"], name: "FK_UserAuthentication_UserID", using: :btree

  create_table "GDN_UserAuthenticationNonce", primary_key: "Nonce", force: true do |t|
    t.string    "Token",     limit: 128, null: false
    t.timestamp "Timestamp",             null: false
  end

  create_table "GDN_UserAuthenticationProvider", primary_key: "AuthenticationKey", force: true do |t|
    t.string "AuthenticationSchemeAlias", limit: 32, null: false
    t.string "Name",                      limit: 50
    t.string "URL"
    t.text   "AssociationSecret",                    null: false
    t.string "AssociationHashMethod",     limit: 20, null: false
    t.string "AuthenticateUrl"
    t.string "RegisterUrl"
    t.string "SignInUrl"
    t.string "SignOutUrl"
    t.string "PasswordUrl"
    t.string "ProfileUrl"
    t.text   "Attributes"
  end

  create_table "GDN_UserAuthenticationToken", id: false, force: true do |t|
    t.string    "Token",          limit: 128, null: false
    t.string    "ProviderKey",    limit: 64,  null: false
    t.string    "ForeignUserKey"
    t.string    "TokenSecret",    limit: 64,  null: false
    t.string    "TokenType",      limit: 7,   null: false
    t.integer   "Authorized",     limit: 1,   null: false
    t.timestamp "Timestamp",                  null: false
    t.integer   "Lifetime",                   null: false
  end

  add_index "GDN_UserAuthenticationToken", ["ForeignUserKey"], name: "GDN_UserAuthenticationToken_ForeignUserKey", using: :btree

  create_table "GDN_UserCategory", id: false, force: true do |t|
    t.integer  "UserID",                               null: false
    t.integer  "CategoryID",                           null: false
    t.datetime "DateMarkedRead"
    t.integer  "Unfollow",       limit: 1, default: 0, null: false
  end

  create_table "GDN_UserComment", id: false, force: true do |t|
    t.integer  "UserID",         null: false
    t.integer  "CommentID",      null: false
    t.float    "Score"
    t.datetime "DateLastViewed"
  end

  create_table "GDN_UserConversation", id: false, force: true do |t|
    t.integer  "UserID",                                  null: false
    t.integer  "ConversationID",                          null: false
    t.integer  "CountReadMessages",           default: 0, null: false
    t.integer  "LastMessageID"
    t.datetime "DateLastViewed"
    t.datetime "DateCleared"
    t.integer  "Bookmarked",        limit: 1, default: 0, null: false
    t.integer  "Deleted",           limit: 1, default: 0, null: false
  end

  add_index "GDN_UserConversation", ["LastMessageID"], name: "FK_UserConversation_LastMessageID", using: :btree

  create_table "GDN_UserDiscussion", id: false, force: true do |t|
    t.integer  "UserID",                               null: false
    t.integer  "DiscussionID",                         null: false
    t.float    "Score"
    t.integer  "CountComments",            default: 0, null: false
    t.datetime "DateLastViewed"
    t.integer  "Dismissed",      limit: 1, default: 0, null: false
    t.integer  "Bookmarked",     limit: 1, default: 0, null: false
  end

  add_index "GDN_UserDiscussion", ["DiscussionID"], name: "FK_UserDiscussion_DiscussionID", using: :btree

  create_table "GDN_UserMeta", id: false, force: true do |t|
    t.integer "UserID", null: false
    t.string  "Name",   null: false
    t.text    "Value"
  end

  add_index "GDN_UserMeta", ["Name"], name: "IX_UserMeta_Name", using: :btree

  create_table "GDN_UserRole", id: false, force: true do |t|
    t.integer "UserID", null: false
    t.integer "RoleID", null: false
  end

  create_table "LUM_Attachment", primary_key: "AttachmentID", force: true do |t|
    t.integer  "UserID",                   default: 0,  null: false
    t.integer  "DiscussionID",             default: 0,  null: false
    t.integer  "CommentID",                default: 0,  null: false
    t.string   "Title",        limit: 200, default: "", null: false
    t.text     "Description",                           null: false
    t.string   "Name",         limit: 200, default: "", null: false
    t.text     "Path",                                  null: false
    t.integer  "Size",                     default: 0,  null: false
    t.string   "MimeType",     limit: 200, default: "", null: false
    t.datetime "DateCreated",                           null: false
    t.datetime "DateModified",                          null: false
  end

  create_table "LUM_Category", primary_key: "CategoryID", force: true do |t|
    t.string  "Name",        limit: 100, default: "", null: false
    t.text    "Description"
    t.integer "Priority",                default: 0,  null: false
  end

  create_table "LUM_CategoryBlock", id: false, force: true do |t|
    t.integer "CategoryID",           default: 0,   null: false
    t.integer "UserID",               default: 0,   null: false
    t.string  "Blocked",    limit: 1, default: "1", null: false
  end

  add_index "LUM_CategoryBlock", ["UserID"], name: "cat_block_user", using: :btree

  create_table "LUM_CategoryRoleBlock", id: false, force: true do |t|
    t.integer "CategoryID",           default: 0,   null: false
    t.integer "RoleID",               default: 0,   null: false
    t.string  "Blocked",    limit: 1, default: "0", null: false
  end

  add_index "LUM_CategoryRoleBlock", ["CategoryID"], name: "cat_roleblock_cat", using: :btree
  add_index "LUM_CategoryRoleBlock", ["RoleID"], name: "cat_roleblock_role", using: :btree

  create_table "LUM_Comment", id: false, force: true do |t|
    t.integer  "CommentID",                               null: false
    t.integer  "DiscussionID",              default: 0,   null: false
    t.integer  "AuthUserID",                default: 0,   null: false
    t.datetime "DateCreated"
    t.integer  "EditUserID"
    t.datetime "DateEdited"
    t.integer  "WhisperUserID"
    t.text     "Body"
    t.string   "FormatType",    limit: 20
    t.string   "Deleted",       limit: 1,   default: "0", null: false
    t.datetime "DateDeleted"
    t.integer  "DeleteUserID",              default: 0,   null: false
    t.string   "RemoteIp",      limit: 100, default: ""
  end

  add_index "LUM_Comment", ["AuthUserID"], name: "comment_user", using: :btree
  add_index "LUM_Comment", ["DiscussionID"], name: "comment_discussion", using: :btree
  add_index "LUM_Comment", ["WhisperUserID"], name: "comment_whisper", using: :btree

  create_table "LUM_Discussion", primary_key: "DiscussionID", force: true do |t|
    t.integer  "AuthUserID",                        default: 0,   null: false
    t.integer  "WhisperUserID",                     default: 0,   null: false
    t.integer  "FirstCommentID",                    default: 0,   null: false
    t.integer  "LastUserID",                        default: 0,   null: false
    t.string   "Active",                limit: 1,   default: "1", null: false
    t.string   "Closed",                limit: 1,   default: "0", null: false
    t.string   "Sticky",                limit: 1,   default: "0", null: false
    t.string   "Sink",                  limit: 1,   default: "0", null: false
    t.string   "Name",                  limit: 100, default: "",  null: false
    t.datetime "DateCreated",                                     null: false
    t.datetime "DateLastActive",                                  null: false
    t.integer  "CountComments",                     default: 1,   null: false
    t.integer  "CategoryID"
    t.integer  "WhisperToLastUserID"
    t.integer  "WhisperFromLastUserID"
    t.datetime "DateLastWhisper"
    t.integer  "TotalWhisperCount",                 default: 0,   null: false
    t.integer  "Rating",                                          null: false
  end

  add_index "LUM_Discussion", ["AuthUserID"], name: "discussion_user", using: :btree
  add_index "LUM_Discussion", ["CategoryID"], name: "discussion_category", using: :btree
  add_index "LUM_Discussion", ["DateLastActive"], name: "discussion_dateactive", using: :btree
  add_index "LUM_Discussion", ["FirstCommentID"], name: "discussion_first", using: :btree
  add_index "LUM_Discussion", ["LastUserID"], name: "discussion_last", using: :btree
  add_index "LUM_Discussion", ["WhisperUserID"], name: "discussion_whisperuser", using: :btree

  create_table "LUM_DiscussionUserWhisperFrom", id: false, force: true do |t|
    t.integer  "DiscussionID",      default: 0, null: false
    t.integer  "WhisperFromUserID", default: 0, null: false
    t.integer  "LastUserID",        default: 0, null: false
    t.integer  "CountWhispers",     default: 0, null: false
    t.datetime "DateLastActive",                null: false
  end

  add_index "LUM_DiscussionUserWhisperFrom", ["DateLastActive"], name: "discussion_user_whisper_lastactive", using: :btree
  add_index "LUM_DiscussionUserWhisperFrom", ["LastUserID"], name: "discussion_user_whisper_lastuser", using: :btree

  create_table "LUM_DiscussionUserWhisperTo", id: false, force: true do |t|
    t.integer  "DiscussionID",    default: 0, null: false
    t.integer  "WhisperToUserID", default: 0, null: false
    t.integer  "LastUserID",      default: 0, null: false
    t.integer  "CountWhispers",   default: 0, null: false
    t.datetime "DateLastActive",              null: false
  end

  add_index "LUM_DiscussionUserWhisperTo", ["DateLastActive"], name: "discussion_user_whisperto_lastactive", using: :btree
  add_index "LUM_DiscussionUserWhisperTo", ["LastUserID"], name: "discussion_user_whisperto_lastuser", using: :btree

  create_table "LUM_IpHistory", primary_key: "IpHistoryID", force: true do |t|
    t.string   "RemoteIp",   limit: 30, default: "", null: false
    t.integer  "UserID",                default: 0,  null: false
    t.datetime "DateLogged",                         null: false
  end

  create_table "LUM_Role", primary_key: "RoleID", force: true do |t|
    t.string  "Name",                                        limit: 100, default: "",  null: false
    t.string  "Icon",                                        limit: 155, default: "",  null: false
    t.string  "Description",                                 limit: 200, default: "",  null: false
    t.string  "Active",                                      limit: 1,   default: "1", null: false
    t.string  "PERMISSION_SIGN_IN",                          limit: 1,   default: "0", null: false
    t.string  "PERMISSION_HTML_ALLOWED",                     limit: 1,   default: "0", null: false
    t.string  "PERMISSION_RECEIVE_APPLICATION_NOTIFICATION", limit: 1,   default: "0", null: false
    t.text    "Permissions"
    t.integer "Priority",                                                default: 0,   null: false
    t.string  "UnAuthenticated",                             limit: 1,   default: "0", null: false
  end

  create_table "LUM_Style", primary_key: "StyleID", force: true do |t|
    t.integer "AuthUserID",              default: 0,  null: false
    t.string  "Name",         limit: 50, default: "", null: false
    t.string  "Url",                     default: "", null: false
    t.string  "PreviewImage", limit: 20, default: "", null: false
  end

  create_table "LUM_User", primary_key: "UserID", force: true do |t|
    t.integer   "RoleID",                                    default: 0,   null: false
    t.integer   "StyleID",                                   default: 1,   null: false
    t.string    "CustomStyle"
    t.string    "FirstName",                     limit: 50,  default: "",  null: false
    t.string    "LastName",                      limit: 50,  default: "",  null: false
    t.string    "Name",                          limit: 20,  default: "",  null: false
    t.string    "Password",                      limit: 32
    t.string    "VerificationKey",               limit: 50,  default: "",  null: false
    t.string    "EmailVerificationKey",          limit: 50
    t.string    "Email",                         limit: 200
    t.string    "UtilizeEmail",                  limit: 1,   default: "0", null: false
    t.string    "ShowName",                      limit: 1,   default: "1", null: false
    t.string    "Icon"
    t.string    "Picture"
    t.text      "Attributes"
    t.integer   "CountVisit",                                default: 0,   null: false
    t.integer   "CountDiscussions",                          default: 0,   null: false
    t.integer   "CountComments",                             default: 0,   null: false
    t.datetime  "DateFirstVisit",                                          null: false
    t.datetime  "DateLastActive",                                          null: false
    t.string    "RemoteIp",                      limit: 100, default: "",  null: false
    t.datetime  "LastDiscussionPost"
    t.integer   "DiscussionSpamCheck",                       default: 0,   null: false
    t.datetime  "LastCommentPost"
    t.integer   "CommentSpamCheck",                          default: 0,   null: false
    t.string    "UserBlocksCategories",          limit: 1,   default: "0", null: false
    t.string    "DefaultFormatType",             limit: 20
    t.text      "Discovery"
    t.text      "Preferences"
    t.string    "SendNewApplicantNotifications", limit: 1,   default: "0", null: false
    t.timestamp "MarkAllRead"
  end

  add_index "LUM_User", ["Name"], name: "user_name", using: :btree
  add_index "LUM_User", ["RoleID"], name: "user_role", using: :btree
  add_index "LUM_User", ["StyleID"], name: "user_style", using: :btree

  create_table "LUM_UserBookmark", id: false, force: true do |t|
    t.integer "UserID",       default: 0, null: false
    t.integer "DiscussionID", default: 0, null: false
  end

  create_table "LUM_UserDiscussionWatch", id: false, force: true do |t|
    t.integer  "UserID",        default: 0, null: false
    t.integer  "DiscussionID",  default: 0, null: false
    t.integer  "CountComments", default: 0, null: false
    t.datetime "LastViewed",                null: false
  end

  create_table "LUM_UserRoleHistory", id: false, force: true do |t|
    t.integer  "UserID",                  default: 0, null: false
    t.integer  "RoleID",                  default: 0, null: false
    t.datetime "Date",                                null: false
    t.integer  "AdminUserID",             default: 0, null: false
    t.string   "Notes",       limit: 200
    t.string   "RemoteIp",    limit: 100
  end

  add_index "LUM_UserRoleHistory", ["UserID"], name: "UserID", using: :btree

  create_table "admin_delete_reasons", force: true do |t|
    t.string  "reason",          limit: 50,                       null: false
    t.boolean "locked",                           default: false, null: false
    t.text    "default_message", limit: 16777215,                 null: false
  end

  create_table "allowed_bindings", force: true do |t|
    t.text   "url",         limit: 16777215, null: false
    t.string "description",                  null: false
  end

  create_table "daily_install_counts", id: false, force: true do |t|
    t.integer   "style_id",            null: false
    t.string    "source",   limit: 10, null: false
    t.string    "ip",       limit: 15, null: false
    t.timestamp "date",                null: false
  end

  add_index "daily_install_counts", ["date"], name: "daily_install_counts_date", using: :btree
  add_index "daily_install_counts", ["style_id", "ip", "source"], name: "unique_style_source_and_ip", unique: true, using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue"
  end

  create_table "livetitle_pages", force: true do |t|
    t.integer "livetitle_id",             default: 0,     null: false
    t.boolean "include",                  default: false, null: false
    t.string  "page_regexp",  limit: 100, default: "",    null: false
  end

  create_table "livetitles", force: true do |t|
    t.integer  "user_id", null: false
    t.text     "xml",     null: false
    t.string   "name"
    t.datetime "created", null: false
    t.datetime "updated", null: false
  end

  create_table "moz_doc_rules", force: true do |t|
    t.integer "style_id",              default: 0,  null: false
    t.string  "rule_type", limit: 10,  default: "", null: false
    t.string  "value",     limit: 100, default: "", null: false
  end

  add_index "moz_doc_rules", ["rule_type"], name: "rule_type", using: :btree
  add_index "moz_doc_rules", ["style_id"], name: "style_id", using: :btree
  add_index "moz_doc_rules", ["value"], name: "value", using: :btree

  create_table "schema_info", id: false, force: true do |t|
    t.integer "version"
  end

  create_table "screenshots", force: true do |t|
    t.integer "style_id",               null: false
    t.string  "description", limit: 50, null: false
    t.string  "path",        limit: 50, null: false
  end

  add_index "screenshots", ["style_id"], name: "style_id", using: :btree

  create_table "sessions", force: true do |t|
    t.string   "session_id"
    t.text     "data",       limit: 2147483647
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "style_categories", force: true do |t|
    t.string "name",       limit: 50,       null: false
    t.text   "intro_text", limit: 16777215, null: false
  end

  create_table "style_codes", force: true do |t|
    t.integer "style_id",                  default: 0, null: false
    t.text    "code",     limit: 16777215,             null: false
  end

  add_index "style_codes", ["style_id"], name: "style_id", unique: true, using: :btree

  create_table "style_install_counts", id: false, force: true do |t|
    t.integer "id",                                   null: false
    t.integer "style_id",                 default: 0, null: false
    t.date    "date",                                 null: false
    t.integer "install_count",            default: 0, null: false
    t.string  "source",        limit: 10,             null: false
  end

  add_index "style_install_counts", ["date"], name: "date", using: :btree
  add_index "style_install_counts", ["id"], name: "id", using: :btree
  add_index "style_install_counts", ["style_id", "date", "source"], name: "unique_style_source_and_date", unique: true, using: :btree
  add_index "style_install_counts", ["style_id"], name: "style_id", using: :btree

  create_table "style_install_counts_archive", id: false, force: true do |t|
    t.integer "id",            default: 0, null: false
    t.integer "style_id",      default: 0, null: false
    t.date    "date",                      null: false
    t.integer "install_count", default: 0, null: false
  end

  create_table "style_option_values", force: true do |t|
    t.integer "style_option_id",                                  null: false
    t.string  "display_name",    limit: 100,                      null: false
    t.text    "value",           limit: 16777215,                 null: false
    t.boolean "default",                          default: false, null: false
    t.integer "ordinal",                                          null: false
  end

  add_index "style_option_values", ["style_option_id"], name: "style_option_values_style_option_id", using: :btree

  create_table "style_options", force: true do |t|
    t.integer "style_id",                                      null: false
    t.string  "name",         limit: 20,                       null: false
    t.string  "display_name", limit: 100,                      null: false
    t.integer "ordinal"
    t.string  "option_type",  limit: 10,  default: "dropdown", null: false
  end

  add_index "style_options", ["style_id", "name"], name: "ix_style_options_style_id_name", unique: true, using: :btree

  create_table "styles", force: true do |t|
    t.integer   "user_id",                                     default: 0,      null: false
    t.string    "short_description",          limit: 75,                        null: false
    t.text      "long_description",           limit: 16777215,                  null: false
    t.integer   "obsolete",                   limit: 1,        default: 0,      null: false
    t.integer   "obsoleting_style_id"
    t.text      "obsoletion_message",         limit: 16777215
    t.datetime  "created",                                                      null: false
    t.datetime  "updated",                                                      null: false
    t.string    "before_screenshot_name",     limit: 20
    t.string    "after_screenshot_name",      limit: 20
    t.string    "category",                   limit: 10
    t.string    "subcategory",                limit: 50
    t.boolean   "userjs_available",                            default: false,  null: false
    t.integer   "total_install_count",                         default: 0
    t.integer   "weekly_install_count",                        default: 0
    t.integer   "allow_long_code",            limit: 1,        default: 0,      null: false
    t.integer   "forum_category_id"
    t.string    "redirect_page",              limit: 50
    t.boolean   "opera_css_available",                         default: false,  null: false
    t.integer   "popularity_score",                            default: 0,      null: false
    t.float     "rating",                     limit: 2
    t.boolean   "ie_css_available",                            default: false,  null: false
    t.boolean   "chrome_json_available",                       default: false
    t.string    "screenshot_url",             limit: 100
    t.string    "screenshot_url_override",    limit: 500
    t.string    "screenshot_type_preference", limit: 10,       default: "auto", null: false
    t.integer   "pledgie_id"
    t.text      "additional_info",            limit: 16777215
    t.date      "auto_screenshot_date"
    t.boolean   "delta",                                       default: true,   null: false
    t.string    "license",                    limit: 20
    t.string    "code_error"
    t.boolean   "auto_screenshots_same",                       default: false,  null: false
    t.boolean   "unintentional_global",                        default: false,  null: false
    t.integer   "admin_delete_reason_id"
    t.string    "moz_doc_error",              limit: 100
    t.timestamp "updated_at",                                                   null: false
  end

  add_index "styles", ["admin_delete_reason_id"], name: "admin_delete_reason_id", using: :btree
  add_index "styles", ["category"], name: "category", using: :btree
  add_index "styles", ["created"], name: "created", using: :btree
  add_index "styles", ["obsolete"], name: "obsolete", using: :btree
  add_index "styles", ["popularity_score"], name: "popularity_score", using: :btree
  add_index "styles", ["short_description"], name: "short_description", using: :btree
  add_index "styles", ["subcategory"], name: "subcategory", using: :btree
  add_index "styles", ["updated"], name: "updated", using: :btree
  add_index "styles", ["user_id"], name: "user_id", using: :btree

  create_table "user_authenticators", force: true do |t|
    t.integer "user_id",                         null: false
    t.string  "provider",            limit: 10,  null: false
    t.string  "provider_identifier", limit: 100, null: false
  end

  add_index "user_authenticators", ["provider", "provider_identifier"], name: "provider_provider_identifier_ix", using: :btree
  add_index "user_authenticators", ["provider_identifier"], name: "provider_identifier", unique: true, using: :btree
  add_index "user_authenticators", ["user_id"], name: "user_id_fk", using: :btree

  create_table "users", force: true do |t|
    t.string  "login",             limit: 20
    t.string  "name",              limit: 50,       default: "",    null: false
    t.string  "email",             limit: 30
    t.boolean "show_ads",                           default: false, null: false
    t.string  "token",             limit: 40
    t.string  "openid_url",        limit: 100
    t.integer "LUM_User_id"
    t.string  "paypal_email"
    t.string  "ip",                limit: 50
    t.string  "hashed_password",   limit: 40
    t.string  "salt",              limit: 40
    t.string  "lost_password_key", limit: 30
    t.boolean "show_email",                         default: false, null: false
    t.string  "homepage"
    t.text    "about",             limit: 16777215
    t.string  "license",           limit: 20
  end

  add_index "users", ["LUM_User_id"], name: "LUM_User_id", using: :btree
  add_index "users", ["login", "openid_url"], name: "users_login_unique", unique: true, using: :btree
  add_index "users", ["login"], name: "unique_login", unique: true, using: :btree
  add_index "users", ["token"], name: "token", using: :btree

end
