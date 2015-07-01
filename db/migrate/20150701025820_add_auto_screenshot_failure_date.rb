class AddAutoScreenshotFailureDate < ActiveRecord::Migration
	def change
		add_column :styles, :auto_screenshot_last_failure_date, :datetime, after: :auto_screenshot_date
	end
end
