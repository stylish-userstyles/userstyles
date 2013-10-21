class CategoriesController < ApplicationController

	layout "standard_layout"

	caches_action :show, :expires_in => 30.minutes

	def show
		root_categories = ['site', 'app', 'global']
		if params[:id].nil?
			@page_title = 'Themes and skins by category'
			@meta_description = 'Find themes and skins, listed by category.'
			root_counts = Style.find(:all, :select => 'category, count(*) c', :conditions => 'obsolete = false', :group => 'category')
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
			@subcategory_counts = Style.find(:all, :select => 'category, subcategory, count(*) c', :conditions => ['obsolete = false AND category = ?', params[:id]], :group => 'category, subcategory', :order => 'c DESC', :limit => 50)
			@bc_category = params[:id]
		end
	end
end
