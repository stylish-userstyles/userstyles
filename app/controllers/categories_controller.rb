class CategoriesController < ApplicationController

	def show
		root_categories = ['site', 'app', 'global']
		if params[:id].nil?
			@page_title = 'Themes and skins by category'
			@meta_description = 'Find themes and skins, listed by category.'
			root_counts = Rails.cache.fetch 'categories/root' do
				Style.select('category, count(*) c').where('obsolete = false').group('category').load
			end
			root_counts.each do |root_count|
				case root_count['category']
					when 'site'
						@site_count = root_count['c']
					when 'app'
						@app_count = root_count['c']
					when 'global'
						@global_count = root_count['c']
				end
			end
			render :action => 'root'
		elsif root_categories.index(params[:id]).nil?
			redirect_to :controller => 'styles', :action => 'browse', 'subcategory' => params[:id]
		else
			@page_title = "#{params[:id].capitalize} themes and skins by category"
			@meta_description = "Find #{params[:id].capitalize} themes and skins, listed by category."
			@root_category = params[:id]
			@subcategory_counts = Rails.cache.fetch "categories/subcategory/#{params[:id]}" do
				Style.select('category, subcategory, count(*) c').where(['obsolete = false AND category = ?', params[:id]]).group('category, subcategory').order('c DESC').limit(50).load
			end
			@bc_category = params[:id]
		end
	end

private

	def public_action?
		false
	end
	
	def admin_action?
		true
	end
	
	def verify_private_action(user_id)
		false
	end

end
