<?php if (!defined('APPLICATION')) exit();

$PluginInfo['DiscussionAbout'] = array(
	'Name' => 'DiscussionAbout',
	'Description' => 'Have discussions about a non-Vanilla item in your database.',
	'Version' => '1.0',
	'Author' => "Jason Barnabe",
	'AuthorEmail' => 'jason.barnabe@gmail.com',
	'MobileFriendly' => TRUE
);

require_once dirname(__FILE__).'/config.php';

class DiscussionAboutPlugin extends Gdn_Plugin {

	public $Config = null;

	public function __construct() {
		parent::__construct();
		$this->Config = DiscussionAboutPluginConfig();
	}

	# Load item name for discussion index and apply filters if parameters passed
	public function DiscussionModel_BeforeGet_Handler($Sender, $JoinToUser = FALSE) {
		$prefix = $Sender->SQL->Database->DatabasePrefix;
		$Sender->SQL->Database->DatabasePrefix = '';
		$Sender->SQL->Join($this->Config['ItemTable'].' discussionaboutitem', 'd.'.$this->Config['ForeignKey'].' = discussionaboutitem.'.$this->Config['ItemPrimaryKey'], 'left');
		$Sender->SQL->Select('discussionaboutitem.'.$this->Config['ItemName'], '', 'DiscussionAboutName');
		foreach ($this->Config['AdditionalFilters'] as $filter_param => $filter_options) {
			$filter_column = $filter_options['filter_column'];
			if (isset($_REQUEST[$filter_param])) {
				$Sender->SQL->Where('discussionaboutitem.'.$filter_column, $_REQUEST[$filter_param]);
			}
		}
		if (isset($_REQUEST[$this->Config['ItemParameter']]) && is_numeric($_REQUEST[$this->Config['ItemParameter']])) {
			$Sender->SQL->Where('discussionaboutitem.'.$this->Config['ItemPrimaryKey'], $_REQUEST[$this->Config['ItemParameter']]);
		}
		$Sender->SQL->Database->DatabasePrefix = $prefix;
	}

	# https://github.com/JasonBarnabe/DiscussionAbout/issues/1
	# Same as above, for profile
	public function DiscussionModel_BeforeGetByUser_Handler($Sender) {
		$this->DiscussionModel_BeforeGet_Handler($Sender);
	}

	public function DiscussionModel_AfterAddColumns_Handler($Sender) {
		# Remove announcements when we're filtering
		if (!empty($this->GetFilterParamString())) {
			$Sender->RemoveAnnouncements($Sender->EventArguments['Data']);
		}
		# Include related name in discussion name when rendering RSS
		if (Gdn::Request()->OutputFormat() == 'rss') {
			$Discussions = $Sender->EventArguments['Data'];
			foreach ($Discussions->Result() as $Discussion) {
				if (isset($Discussion->DiscussionAboutName) && $Discussion->DiscussionAboutName) {
					$Discussion->Name.=' - '.$Discussion->DiscussionAboutName;
				}
			}
		}
	}

	# Add filter parameters to paginate links
	public function DiscussionsController_AfterBuildPager_Handler($Sender) {
		$FilterParams = $this->GetFilterParamString();
		if (!empty($FilterParams)) {
			$Sender->SetData('_PagerUrl', $Sender->Data('_PagerUrl').'?'.$FilterParams);
		}
	}

	# Update discussion count and title for index
	public function DiscussionsController_BeforeBuildPager_Handler($Sender) {
		# Only do this if some of the parameters we care about are set
		$FilterParams = $this->GetFilterParamString();
		if (empty($FilterParams)) {
			return;
		}

		$DiscussionModel = new DiscussionModel();

		$prefix = $DiscussionModel->SQL->Database->DatabasePrefix;
		$DiscussionModel->SQL->Database->DatabasePrefix = '';

		$DiscussionModel->SQL
			->Select('d.DiscussionID', 'count', 'CountDiscussions')
			->Select('discussionaboutitem.'.$this->Config['ItemName'], '', 'DiscussionAboutItemName')
			->From('GDN_Discussion d')
			->Join($this->Config['ItemTable'].' discussionaboutitem', 'd.'.$this->Config['ForeignKey'].' = discussionaboutitem.'.$this->Config['ItemPrimaryKey'], 'left');

		if (isset($_REQUEST[$this->Config['ItemParameter']]) && is_numeric($_REQUEST[$this->Config['ItemParameter']])) {
			$DiscussionModel->SQL->Where('discussionaboutitem.'.$this->Config['ItemPrimaryKey'], $_REQUEST[$this->Config['ItemParameter']]);
		}
		$AdditionalFilterColumnNames = [];
		foreach ($this->Config['AdditionalFilters'] as $filter_param => $filter_options) {
			$filter_column = $filter_options['filter_column'];
			if (isset($_REQUEST[$filter_param])) {
				$DiscussionModel->SQL->Where('discussionaboutitem.'.$filter_column, $_REQUEST[$filter_param]);
				if (isset($filter_options['index_title_sql'])) {
					$AdditionalFilterColumnNames[] = $filter_options['index_title_sql']($DiscussionModel->SQL);
				}
			}
		}

		$DiscussionModel->SQL->Database->DatabasePrefix = $prefix;

		$Row = $DiscussionModel->SQL->Get()->FirstRow();
		$Sender->SetData('CountDiscussions', $Row->CountDiscussions);

		$Title = 'Discussions';
		# If there's no rows, we won't have the data necessary to do this
		if ($Row->CountDiscussions > 0) {
			$FilterNames = [];
			if (isset($_REQUEST[$this->Config['ItemParameter']]) && is_numeric($_REQUEST[$this->Config['ItemParameter']])) {
				$FilterNames[] = sprintf(T('DiscussionAbout.AboutItemHeader', 'about %s'), $Row->DiscussionAboutItemName);
			}
			foreach ($AdditionalFilterColumnNames as $ColumnName) {
				$FilterNames[] = sprintf($ColumnName[1], $Row->{$ColumnName[0]});
			}
			$Title = 'Discussions '.implode(' ', $FilterNames);
		}
		$Sender->Head->AddRss(Url('/discussions/feed.rss?'.$FilterParams, TRUE), $Title);
		$Sender->Head->Title($Title);
	}

	# Load item name for individual discussion
	public function DiscussionModel_BeforeGetID_Handler($Sender) {
		$prefix = $Sender->SQL->Database->DatabasePrefix;
		$Sender->SQL->Database->DatabasePrefix = '';
		$Sender->SQL->Join($this->Config['ItemTable'].' discussionaboutitem', 'd.'.$this->Config['ForeignKey'].' = discussionaboutitem.'.$this->Config['ItemPrimaryKey'], 'left');
		$Sender->SQL->Select('discussionaboutitem.'.$this->Config['ItemName'], '', 'DiscussionAboutName');
		$Sender->SQL->Database->DatabasePrefix = $prefix;
	}

	# Show item name after discussion name in discussion index
	public function DiscussionsController_AfterDiscussionTitle_Handler($Sender) {
		$Discussion = $Sender->EventArguments['Discussion'];
		if (isset($Discussion->DiscussionAboutName)) {
			if (is_numeric($Discussion->{$this->Config['ForeignKey']}) && $Discussion->{$this->Config['ForeignKey']} != 0) {
				echo '<span class="DiscussionAboutListDiscussion"> - '.htmlspecialchars($Discussion->DiscussionAboutName).'</span>';
			}
		}
	}

	# Do it in the category discussion list too
	public function CategoriesController_AfterDiscussionTitle_Handler($Sender) {
		$this->DiscussionsController_AfterDiscussionTitle_Handler($Sender);
	}

	# And the profile discussion list
	public function ProfileController_AfterDiscussionTitle_Handler($Sender) {
		$this->DiscussionsController_AfterDiscussionTitle_Handler($Sender);
	}

	# Show item name in individual discussion
	public function DiscussionController_AfterDiscussionTitle_Handler($Sender) {
		if (isset($Sender->Discussion->{$this->Config['ForeignKey']}) && $Sender->Discussion->{$this->Config['ForeignKey']} != 0) {
			$URLFunction = $this->Config['ItemIDToURL'];
			$URL = null;
			if (isset($URLFunction)) {
				$URL = $URLFunction($Sender->Discussion->{$this->Config['ForeignKey']});
			}
			if (isset($URL)) {
				echo '<span class="DiscussionAboutShowDiscussion">'.sprintf(T('DiscussionAbout.AboutItemSubtitle', 'About: %s'), '<a href="'.htmlspecialchars($URL).'">'.htmlspecialchars($Sender->Discussion->DiscussionAboutName).'</a>').'</span>';
			} else {
				echo '<span class="DiscussionAboutShowDiscussion">'.sprintf(T('DiscussionAbout.AboutItemSubtitle', 'About: %s'), htmlspecialchars($Sender->Discussion->DiscussionAboutName)).'</span>';
			}
		}
	}

	# Hide category selector if we're forcing to a category
	public function PostController_BeforeFormInputs_Handler($Sender) {
		if ($this->GetItemID($Sender) && $this->Config['ForceToCategoryID'] != null) {
			$Sender->ShowCategorySelector = false;
		}
	}

	# Edit/new thread
	public function PostController_DiscussionFormOptions_Handler($Sender) {
		# Show name on new thread
		if ($this->GetItemID($Sender)) {
			$DiscussionAboutName = $this->GetDiscussionAboutName($Sender);
			if (!isset($Sender->Discussion)) {
				$URLFunction = $this->Config['ItemIDToURL'];
				$URL = null;
				if (isset($URLFunction)) {
					$URL = $URLFunction($this->GetItemID($Sender));
				}
				# add item name to title
				$ItemNameCode = null;
				if (isset($URL)) {
					$ItemNameCode = sprintf(T('DiscussionAbout.AboutItem', 'About: %s'), '<a href="'.htmlspecialchars($URL).'">'.htmlspecialchars($DiscussionAboutName).'</a>');
				} else {
					$ItemNameCode = sprintf(T('DiscussionAbout.AboutItem', 'About: %s'), htmlspecialchars($DiscussionAboutName));
				}
				$Sender->EventArguments['Options'] .= '<script>'.
					'var span = document.createElement("span");'.
					'span.innerHTML = '.json_encode($ItemNameCode).';'.
					'var header = document.getElementById("DiscussionForm").getElementsByTagName("h1")[0];'.
					'header.parentNode.insertBefore(span, header.nextSibling);'.
					'</script>';
			}
		}
		# Input to set the item ID
		if (Gdn::Session()->CheckPermission('Vanilla.Discussions.Edit')) {
			$Sender->EventArguments['Options'] .= "<p>".T('Item ID:')." <input type='text' name='".$this->Config['ForeignKey']."' value='".htmlspecialchars($this->GetItemID($Sender))."'></p>";
		} else if ($this->GetItemID($Sender)) {
			$Sender->EventArguments['Options'] .= "<input type='hidden' name='".$this->Config['ForeignKey']."' value='".htmlspecialchars($this->GetItemID($Sender))."'>";
		} else if (isset($this->Config['UserEntryLabel'])) {
			$Sender->EventArguments['Options'] .= "<label for='".$this->Config['ForeignKey']."'>".$this->Config['UserEntryLabel']."</label><input id='".$this->Config['ForeignKey']."' name='".$this->Config['ForeignKey']."-userentry' class='InputBox BigInput'>";
		}
	}

	# Fix things up on saving a discussion
	public function DiscussionModel_BeforeSaveDiscussion_Handler($Sender) {
		$UserEntryValue = $Sender->EventArguments['FormPostValues'][$this->Config['ForeignKey']."-userentry"];
		$ItemIDToURLFunction = $this->Config['UserEntryToID'];
		if ($UserEntryValue && $ItemIDToURLFunction) {
			$Sender->EventArguments['FormPostValues'][$this->Config['ForeignKey']] = $ItemIDToURLFunction($UserEntryValue);
		# Handle empty item id
		} else if ($Sender->EventArguments['FormPostValues'][$this->Config['ForeignKey']] == '') {
			$Sender->EventArguments['FormPostValues'][$this->Config['ForeignKey']] = null;
		}
		# Force to category
		if ($Sender->EventArguments['FormPostValues'][$this->Config['ForeignKey']] != null && $this->Config['ForceToCategoryID'] != null) {
			$Sender->EventArguments['FormPostValues']['CategoryID'] = $this->Config['ForceToCategoryID'];
		}
	}

	# Return the ID of the item, whether from an existing discussion or from a request parameter
	private function GetItemID($Sender) {
		if (isset($Sender->Discussion) && is_numeric($Sender->Discussion->{$this->Config['ForeignKey']})) {
			if ($Sender->Discussion->{$this->Config['ForeignKey']} == '0') {
				return null;
			}
			return $Sender->Discussion->{$this->Config['ForeignKey']};
		}
		if (isset($_REQUEST[$this->Config['ItemParameter']]) && is_numeric($_REQUEST[$this->Config['ItemParameter']])) {
			if ($_REQUEST[$this->Config['ItemParameter']] == '0') {
				return null;
			}
			return $_REQUEST[$this->Config['ItemParameter']];
		}
		return null;
	}

	# Return the display name of the item, whether from an existing discussion or from a request parameter
	private function GetDiscussionAboutName($Sender) {
		$ItemID = $this->GetItemID($Sender);
		$Results = $Sender->Database->Query('SELECT '.$this->Config['ItemName'].' DiscussionAboutName FROM '.$this->Config['ItemTable'].' WHERE '.$this->Config['ItemPrimaryKey'].' = '.$ItemID)->Result('DATASET_TYPE_ARRAY');
		return $Results[0]->DiscussionAboutName;
	}

	# Returns a query string of all the filter parameters we're concerned with
	private function GetFilterParamString() {
		$FilterParams = '';
		if (isset($_REQUEST[$this->Config['ItemParameter']]) && is_numeric($_REQUEST[$this->Config['ItemParameter']])) {
			$FilterParams .= $this->Config['ItemParameter'].'='.$_REQUEST[$this->Config['ItemParameter']];
		}
		foreach ($this->Config['AdditionalFilters'] as $filter_param => $filter_options) {
			$filter_column = $filter_options['filter_column'];
			if (isset($_REQUEST[$filter_param])) {
				if (!empty($FilterParams)) {
					$FilterParams .= '&';
				}
				$FilterParams .= $filter_param.'='.$_REQUEST[$filter_param];
			}
		}
		return $FilterParams;
	}

}
