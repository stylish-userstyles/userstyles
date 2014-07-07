<?php if (!defined('APPLICATION')) exit();
global $DiscussionAboutConfig;
$DiscussionAboutConfig = [];

// Copy this file to config.php and customize!

// This example assumes you want to associate discussions to "articles" and additionally be able to filter discussions by "author".
// Assumes:
//   - An ArticleID column has been added to GDN_Discussion (a foreign key to the articles table)
//   - The articles table consists of id, title, author_id
//   - The authors table consists of id, name

// Column name of the foreign key in GDN_Discussion referencing your item
$DiscussionAboutConfig['ForeignKey'] = 'StyleID';

// Table name for your item
$DiscussionAboutConfig['ItemTable'] = 'styles';

// Column name of the primary key in ItemTable
$DiscussionAboutConfig['ItemPrimaryKey'] = 'id';

// Column name in ItemTable for the display value for your item
$DiscussionAboutConfig['ItemName'] = 'short_description';

// Request parameter for filtering discussions for your item and creating a new discussion for your item
$DiscussionAboutConfig['ItemParameter'] = 'Discussion/StyleID';

// Turn the ID for an item into a URL. Return null if no URL is available.
$DiscussionAboutConfig['ItemIDToURL'] = function($ID) {
	return 'https://userstyles.org/styles/'.$ID;
};

// Force any discussion with an item to a specific category. Null to not do that.
$DiscussionAboutConfig['ForceToCategoryID'] = 4;

// Additional possible filters.
// parameter_name => [
//   filter_column => (Column in ItemTable to filter by.)
//   index_title_sql => (Function that loads a portion of the resulting page's title. The only argument a Vanilla SQL object; this object should be used to include the "name" of the filter in the query. Your item's table name will be aliased as "discussionaboutitem". Do apply the Where - this is done separately. Return an array of [ColumnName, FormatString], where FormatString is something like "by %s", which is the text that will be added to the title of the page.
// ]
$DiscussionAboutConfig['AdditionalFilters'] = [
	'Discussion/StyleAuthorID' => [
		'filter_column' => 'user_id',
		'index_title_sql' => function($SQL) {
			$ColumnName = 'name';
			$SQL->Select('users.name', '', $ColumnName);
			$SQL->Join('users', 'users.id = discussionaboutitem.user_id', 'left');
			return [$ColumnName, 'on styles by %s'];
		}
	]
];
?>
