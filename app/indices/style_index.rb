ThinkingSphinx::Index.define :style, :with => :active_record, :delta => ThinkingSphinx::Deltas::DelayedDelta do

	# fields
	indexes short_description, :as => :name, :sortable => true
	indexes long_description, :as => :description
	indexes additional_info
	indexes category
	indexes 'IF(ISNULL(subcategory), "none", subcategory)', :as => :subcategory
	indexes user.name, :as => :author
  indexes id, :as => :style_id

	# attributes
	has :popularity_score, :as => :popularity
	has :created, :updated, :total_install_count, :weekly_install_count, :rating

	where 'obsolete = 0'

	set_property :field_weights => {
		:style_id => 10,
		:subcategory => 10,
		:name => 5,
		:author => 5,
		:description => 2,
		:additional_info => 1
	}

end
