<?php if (!defined('APPLICATION')) exit();
global $ExtraDiscussionDataConfig;
$ExtraDiscussionDataConfig = [];

$ExtraDiscussionDataConfig['ColumnName'] = 'Rating';

$ExtraDiscussionDataConfig['ShowFormWhen'] = function($Sender) {
	# Same logic as GetItemID in DiscussionAbout
	if (isset($Sender->Discussion) && is_numeric($Sender->Discussion->StyleID)) {
		return $Sender->Discussion->StyleID != '0';
	}
	if (isset($_REQUEST['Discussion/StyleID']) && is_numeric($_REQUEST['Discussion/StyleID'])) {
		return $_REQUEST['Discussion/StyleID'] != '0';
	}
	return false;
};

$USERSTYLES_IMAGE_DOMAIN = 'https://df6a.https.cdn.softlayer.net/80DF6A/static.userstyles.org';

$ExtraDiscussionDataConfig['Values'] = [
	'0' => [
		'form_markup' => '<img class="no-rating" src="'.$USERSTYLES_IMAGE_DOMAIN.'/images/question.png" alt=""> No rating (just a question or comment)',
		'show_markup' => ''
	],
	'1' => [
		'form_markup' => '<img class="bad-rating" src="'.$USERSTYLES_IMAGE_DOMAIN.'/images/bad.gif" alt=""> Bad (doesn\'t work or is ugly)',
		'show_markup' => ' <img class="rating-image bad-rating" src="'.$USERSTYLES_IMAGE_DOMAIN.'/images/bad.gif" alt="Bad rating">'
	],
	'2' => [
		'form_markup' => '<img class="ok-rating" src="'.$USERSTYLES_IMAGE_DOMAIN.'/images/ok.png" alt=""> OK (works, but could use improvement)',
		'show_markup' => ' <img class="rating-image ok-rating" src="'.$USERSTYLES_IMAGE_DOMAIN.'/images/ok.png" alt="OK rating">'
	],
	'3' => [
		'form_markup' => '<img class="good-rating" src="'.$USERSTYLES_IMAGE_DOMAIN.'/images/good.gif" alt=""> Good (works well, is fully functional or good looking)',
		'show_markup' => ' <img class="rating-image good-rating" src="'.$USERSTYLES_IMAGE_DOMAIN.'/images/good.gif" alt="Good rating">'
	]
];

?>
