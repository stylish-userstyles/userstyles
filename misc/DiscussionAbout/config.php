<?php if (!defined('APPLICATION')) exit();

function DiscussionAboutPluginConfig() {
	$Config = [];

	// Column name of the foreign key in GDN_Discussion referencing your item
	$Config['ForeignKey'] = 'StyleID';

	// Table name for your item
	$Config['ItemTable'] = 'styles';

	// Column name of the primary key in ItemTable
	$Config['ItemPrimaryKey'] = 'id';

	// Column name in ItemTable for the display value for your item
	$Config['ItemName'] = 'short_description';

	// Request parameter for filtering discussions for your item and creating a new discussion for your item
	$Config['ItemParameter'] = 'Discussion/StyleID';

	// Turn the ID for an item into a URL. Return null if no URL is available.
	$Config['ItemIDToURL'] = function($ID) {
		return 'https://userstyles.org/styles/'.$ID;
	};

	// If the item request parameter doesn't exist when creating a new thread, set this to have a field allowing the user to specify the item.
	$Config['UserEntryLabel'] = "If you want to discuss a specific style already posted on userstyles.org, ignore Category above and enter the style's URL here:<br>";

	// Turn the user's item entry when creating a new thread into an item ID. Return null to not set the item ID.
	$Config['UserEntryToID'] = function($Value) {
		preg_match('/https?:\/\/userstyles\.org.*\/styles\/([0-9]+).*/', $Value, $Matches);
		if (count($Matches) != 2) {
			return null;
		}
		return $Matches[1];
	};

	// Force any discussion with an item to a specific category. Null to not do that.
	$Config['ForceToCategoryID'] = 4;

	// Additional possible filters.
	// parameter_name => [
	//   filter_column => (Column in ItemTable to filter by.)
	//   index_title_sql => (Function that loads a portion of the resulting page's title. The only argument a Vanilla SQL object; this object should be used to include the "name" of the filter in the query. Your item's table name will be aliased as "discussionaboutitem". Do apply the Where - this is done separately. Return an array of [ColumnName, FormatString], where FormatString is something like "by %s", which is the text that will be added to the title of the page.
	// ]
	$Config['AdditionalFilters'] = [
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

	return $Config;
}
?>
