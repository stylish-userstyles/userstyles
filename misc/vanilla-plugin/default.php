<?php if (!defined('APPLICATION')) exit();

// Define the plugin:
$PluginInfo['Userstyles'] = array(
   'Name' => 'Userstyles',
   'Description' => 'Userstyles.org customizations',
   'Version' => '1.0',
   'Author' => "Jason Barnabe",
   'AuthorEmail' => 'jason.barnabe@gmail.com',
   'AuthorUrl' => 'http://userstyles.org'
);

class UserstylesPlugin extends Gdn_Plugin {

	# Link to main profile
	public function UserInfoModule_OnBasicInfo_Handler($Sender) {
		$UserModel = new UserModel();

		$UserModel->SQL
			->Select('u.ForeignUserKey', '', 'MainUserID')
			->From('UserAuthentication u')
			->Where('u.UserID', $Sender->User->UserID);

		$Row = $UserModel->SQL->Get()->FirstRow();
		echo '<dt><a href="https://userstyles.org/users/'.$Row->MainUserID.'">userstyles.org Profile</a></dt><dd></dd>';
	}

	# Add CSS, JS, and link to main site
	public function Base_Render_Before($Sender) {
		$Sender->AddCssFile($this->GetResource('global.css', FALSE, FALSE));
		$Sender->AddJsFile($this->GetResource('global.js', FALSE, FALSE));
		if ($Sender->Menu) {
			$Sender->Menu->AddLink('userstyles.org', T('userstyles.org'), 'https://userstyles.org/', FALSE, array('class' => 'HomeLink'));
			# added to config: $Configuration['Garden']['Menu']['Sort'] = ['Greasy Fork', 'Dashboard', 'Discussions'];
		}
	}

	# Going to render our own category selector
	public function PostController_BeforeFormInputs_Handler($Sender) {
		$Sender->ShowCategorySelector = false;
	}

	# Our own category selector, with description
	public function PostController_BeforeBodyInput_Handler($Sender) {
		# If the style ID is passed in, it will be hardcoded to category 4.
		if ($this->StyleIDPassed($Sender)) {
			return;
		}
		echo '<div class="P">';
		echo '<div class="Category">';
		echo $Sender->Form->Label('Category', 'CategoryID'), ' ';
		echo '<br>';
		$SelectedCategory = GetValue('CategoryID', $Sender->Category);
		foreach (CategoryModel::Categories() as $c) {
			# -1 is the root
			if ($c['CategoryID'] != -1) {
				#4 is Style Reviews, which should only by used when style id is passed (and skips this anyway) or by mods
				if ($c['CategoryID'] != 4 || Gdn::Session()->CheckPermission('Vanilla.Discussions.Edit')) {
					echo '<input name="CategoryID" id="category-'.$c['CategoryID'].'" type="radio" value="'.$c['CategoryID'].'"'.($SelectedCategory == $c['CategoryID'] ? ' checked' : '').'><label for="category-'.$c['CategoryID'].'">'.$c['Name'].' - '.$c['Description'].'</label><br>';
				}
			}
		}
		#echo $Sender->Form->CategoryDropDown('CategoryID', array('Value' => GetValue('CategoryID', $this->Category)));
		echo '</div>';
		echo '</div>';
	}

	private function StyleIDPassed($Sender) {
		# Same logic as GetItemID in DiscussionAbout
		if (isset($Sender->Discussion) && is_numeric($Sender->Discussion->StyleID)) {
			return $Sender->Discussion->StyleID != '0';
		}
		if (isset($_REQUEST['Discussion/StyleID']) && is_numeric($_REQUEST['Discussion/StyleID'])) {
			return $_REQUEST['Discussion/StyleID'] != '0';
		}
		return false;
	}


	private function shouldFilterReviews() {
		#return false;
		// i can't find a better way to detect this.
		foreach (debug_backtrace() as $i) {
			#echo $i['class'].':'.$i['function']."\n";
			# we don't want to do this for...
			if ((isset($i['class']) && ($i['class'] == 'BookmarkedModule' // bookmarks in the sidebar
				|| $i['class'] == 'CategoriesController' // category listings
				|| $i['class'] == 'ParticipatedPlugin')) // participated
				|| $i['function'] == 'GetAnnouncements' // announcements
				|| $i['function'] == 'Bookmarked' // bookmarks listings
				|| $i['function'] == 'Mine' // my discussions
				|| $i['function'] == 'ProfileController_Discussions_Create' // profile discussion list
				) {
				return false;
			}
		}
		return true;
	}

	private function FilterParameterPassed() {
		if (isset($_REQUEST['Discussion/StyleID']) && is_numeric($_REQUEST['Discussion/StyleID'])) {
			if ($_REQUEST['Discussion/StyleID'] != '0') {
				return true;
			}
		}
		if (isset($_REQUEST['Discussion/StyleAuthorID']) && is_numeric($_REQUEST['Discussion/StyleAuthorID'])) {
			if ($_REQUEST['Discussion/StyleAuthorID'] != '0') {
				return true;
			}
		}
		return false;
	}

	
	public function DiscussionsController_BeforeBuildPager_Handler($Sender) {
		if (!$this->FilterParameterPassed() && $this->shouldFilterReviews()) {
			// if we're the default discussions view, we'll block style reviews.
			$DiscussionModel = new DiscussionModel();

			$prefix = $DiscussionModel->SQL->Database->DatabasePrefix;
			$DiscussionModel->SQL->Database->DatabasePrefix = '';

			$DiscussionModel->SQL->Select('d.DiscussionID', 'count', 'CountDiscussions')
				->From('GDN_Discussion d')
				->Where('d.CategoryID <>', 4);

			$DiscussionModel->SQL->Database->DatabasePrefix = $prefix;

			$Row = $DiscussionModel->SQL->Get()->FirstRow();
			$Sender->SetData('CountDiscussions', $Row->CountDiscussions);
		}

	}

	public function DiscussionModel_BeforeGet_Handler($Sender) {
		$prefix = $Sender->SQL->Database->DatabasePrefix;
		$Sender->SQL->Database->DatabasePrefix = '';
		if (!$this->FilterParameterPassed() && $this->shouldFilterReviews()) {
			$Sender->SQL->Where('d.CategoryID <>', 4);
		}
		$Sender->SQL->Database->DatabasePrefix = $prefix;
	}

	public function SpamModel_CheckSpam_Handler($Sender) {
		if ($Sender->EventArguments['RecordType'] != 'Discussion') {
			return;
		}

		if (preg_match('/9815331734/', $Sender->EventArguments['Data']['Name'])) {
			$Sender->EventArguments['IsSpam'] = true;
		}
	}
}

