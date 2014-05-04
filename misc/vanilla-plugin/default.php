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

	private static $IMAGE_DOMAIN = 'https://df6a.https.cdn.softlayer.net/80DF6A/static.userstyles.org';

	public function PostController_BeforeFormInputs_Handler($Sender) {
		if ($this->getStyleID($Sender)) {
			$Sender->AddCssFile($this->GetResource('post.css', FALSE, FALSE));
			#$Sender->CategoryData = array('4' => 4);
			$cd = CategoryModel::Categories();
			$Sender->Category = $cd['4'];
		} else {
			# render our own category selector, see PostController_BeforeBodyInput_Handler
			$Sender->ShowCategorySelector = false;
		}
	}

	public function PostController_BeforeBodyInput_Handler($Sender) {
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
						echo '<input name="Discussion/CategoryID" id="category-'.$c['CategoryID'].'" type="radio" value="'.$c['CategoryID'].'"'.($SelectedCategory == $c['CategoryID'] ? ' checked' : '').'><label for="category-'.$c['CategoryID'].'">'.$c['Name'].' - '.$c['Description'].'</label><br>';
					}
				}
			}
			#echo $Sender->Form->CategoryDropDown('CategoryID', array('Value' => GetValue('CategoryID', $this->Category)));
			echo '</div>';
		echo '</div>';
	}

	public function DiscussionModel_BeforeSaveDiscussion_Handler($Sender) {
		# unset a category of -1, which is what class.discussionmodel.php does
		if ($Sender->EventArguments['FormPostValues']['CategoryID'] == -1) {
			$Sender->EventArguments['FormPostValues']['CategoryID'] = null;
		}
		#$Sender->Validation->ApplyRule('CategoryID', 'Required');

		# Handle empty string StyleID
		if ($Sender->EventArguments['FormPostValues']['StyleID'] == '') {
			$Sender->EventArguments['FormPostValues']['StyleID'] = null;
		}
	}

	public function DiscussionModel_AfterSaveDiscussion_Handler($Sender) {
		# clear the cache
		$styleID = $this->getStyleID($Sender);
		if (isset($styleID) && is_numeric($styleID)) {
			file_get_contents("http://userstyles.org/styles/expire_by_id/".$styleID);
		}
	}

	public function PostController_DiscussionFormOptions_Handler($Sender) {
		if ($this->getStyleID($Sender)) {
			$StyleName = $this->getStyleName($Sender);
			$Sender->EventArguments['Options'] .= '<div class="Rating">Rate <i>'.htmlspecialchars($StyleName).'</i>:'.$Sender->Form->RadioList('Rating', array(
				'0' => '<img class="no-rating" src="'.self::$IMAGE_DOMAIN.'/images/question.png" alt=""> No rating (just a question or comment)',
				'1' => '<img class="bad-rating" src="'.self::$IMAGE_DOMAIN.'/images/bad.gif" alt=""> Bad (doesn\'t work or is ugly)',
				'2' => '<img class="ok-rating" src="'.self::$IMAGE_DOMAIN.'/images/ok.png" alt=""> OK (works, but could use improvement)',
				'3' => '<img class="good-rating" src="'.self::$IMAGE_DOMAIN.'/images/good.gif" alt=""> Good (works well, is fully functional or good looking)'
			)).'</div>';
		}

		# style id
		if (Gdn::Session()->CheckPermission('Vanilla.Discussions.Edit')) {
			$Sender->EventArguments['Options'] .= "<p>Style ID: <input type='text' name='Discussion/StyleID' value='".htmlspecialchars($this->getStyleID($Sender))."'></p>";
		}	else if ($this->getStyleID($Sender)) {
			$Sender->EventArguments['Options'] .= "<input type='hidden' name='Discussion/StyleID' value='".htmlspecialchars($this->getStyleID($Sender))."'>";
		}
	}

	public function PostController_BeforeFormButtons_Handler($Sender) {
	}

	public function DiscussionsController_BeforeBuildPager_Handler($Sender) {
		if (is_numeric($_REQUEST['Discussion/StyleAuthorID'])) {

			$DiscussionModel = new DiscussionModel();

			$prefix = $DiscussionModel->SQL->Database->DatabasePrefix;
			$DiscussionModel->SQL->Database->DatabasePrefix = '';

      		$DiscussionModel->SQL
	         ->Select('d.DiscussionID', 'count', 'CountDiscussions')
	         ->Select('users.name', '', 'Name')
	         ->From('GDN_Discussion d')
			 ->Join('styles styles', 'd.StyleID = styles.id', 'left')
			 ->Join('users users', 'users.id = styles.user_id', 'inner')
             ->Where('styles.user_id', $_REQUEST['Discussion/StyleAuthorID']);

			$DiscussionModel->SQL->Database->DatabasePrefix = $prefix;

			$Row = $DiscussionModel->SQL->Get()->FirstRow();
			$User = $Row->Name;
			$Sender->SetData('CountDiscussions', $Row->CountDiscussions);

			$Sender->Head->AddRss(Url('/discussions/feed.rss?Discussion/StyleAuthorID='.$_REQUEST['Discussion/StyleAuthorID'], TRUE), 'Discussions on Styles by '.$User);
			$Sender->Head->Title('Discussions on Styles by '.$User);
		} else if (is_numeric($_REQUEST['Discussion/StyleID'])) {

			$DiscussionModel = new DiscussionModel();

			$prefix = $DiscussionModel->SQL->Database->DatabasePrefix;
			$DiscussionModel->SQL->Database->DatabasePrefix = '';

      		$DiscussionModel->SQL
	         ->Select('d.DiscussionID', 'count', 'CountDiscussions')
	         ->Select('styles.short_description', '', 'Name')
	         ->From('GDN_Discussion d')
			 ->Join('styles styles', 'd.StyleID = styles.id', 'left')
             ->Where('styles.id', $_REQUEST['Discussion/StyleID']);

			$DiscussionModel->SQL->Database->DatabasePrefix = $prefix;

			$Row = $DiscussionModel->SQL->Get()->FirstRow();
			$Style = $Row->Name;
			$Sender->SetData('CountDiscussions', $Row->CountDiscussions);

			$Sender->Head->AddRss(Url('/discussions/feed.rss?Discussion/StyleID='.$_REQUEST['Discussion/StyleID'], TRUE), 'Discussions on '.$User);
			$Sender->Head->Title('Discussions on '.$Style);
		} else if ($this->shouldFilterReviews()) {
			// if we're the default discussions view, we'll block style reviews.
			$DiscussionModel = new DiscussionModel();

			$prefix = $DiscussionModel->SQL->Database->DatabasePrefix;
			$DiscussionModel->SQL->Database->DatabasePrefix = '';

      		$DiscussionModel->SQL
	         ->Select('d.DiscussionID', 'count', 'CountDiscussions')
	         ->From('GDN_Discussion d')
             ->Where('d.CategoryID <>', 4);

			$DiscussionModel->SQL->Database->DatabasePrefix = $prefix;

			$Row = $DiscussionModel->SQL->Get()->FirstRow();
			$Sender->SetData('CountDiscussions', $Row->CountDiscussions);
		}

	}

	public function DiscussionsController_AfterBuildPager_Handler($Sender) {
		if (is_numeric($_REQUEST['Discussion/StyleAuthorID'])) {
			$Sender->SetData('_PagerUrl', $Sender->Data('_PagerUrl').'?Discussion/StyleAuthorID='.$_REQUEST['Discussion/StyleAuthorID']);
		} else if (is_numeric($_REQUEST['Discussion/StyleID'])) {
			$Sender->SetData('_PagerUrl', $Sender->Data('_PagerUrl').'?Discussion/StyleID='.$_REQUEST['Discussion/StyleID']);
		}
  }

	public function DiscussionController_BeforeDiscussion_Handler($Sender) {
		$Sender->AddCssFile($this->GetResource('discussion.css', FALSE, FALSE));
		if (isset($Sender->Discussion->StyleID) && $Sender->Discussion->StyleID != 0) {
			echo '<div class="Tabs HeadingTabs DiscussionTabs">';
			echo 'About: <a href="http://userstyles.org/styles/'.$Sender->Discussion->StyleID.'">'.htmlspecialchars($Sender->Discussion->StyleName).'</a>';
			echo ' '.$this->getRatingImage($Sender->Discussion->Rating);
			echo '</div>';
		}
		echo $Sender->Pager->ToString('more');
	}

	public function DiscussionModel_BeforeGet_Handler($Sender) {
		if (is_numeric($_REQUEST['BlockCategory'])) {
			$Sender->SQL->Where('d.CategoryID <>', $_REQUEST['BlockCategory']);
		}
	}

	private function getRatingImage($Rating) {
		switch ($Rating) {
			case 1:
				return '<img class="bad-rating" src="'.self::$IMAGE_DOMAIN.'/images/bad.gif" alt="Bad rating">';
			case 2:
				return '<img class="ok-rating" src="'.self::$IMAGE_DOMAIN.'/images/ok.png" alt="OK rating">';
			case 3:
				return '<img class="good-rating" src="'.self::$IMAGE_DOMAIN.'/images/good.gif" alt="Good rating">';
		}
		return null;
	}

	public function DiscussionModel_AfterDiscussionSummaryQuery_Handler($Sender) {
		$prefix = $Sender->SQL->Database->DatabasePrefix;
		$Sender->SQL->Database->DatabasePrefix = '';
		$Sender->SQL->Join('styles styles', 'd.StyleID = styles.id', 'left');
		$Sender->SQL->Select('styles.short_description', '', 'StyleName');
		if (is_numeric($_REQUEST['Discussion/StyleAuthorID'])) {
			$Sender->SQL->Where('styles.user_id', $_REQUEST['Discussion/StyleAuthorID']);
		} else if (is_numeric($_REQUEST['Discussion/StyleID'])) {
			$Sender->SQL->Where('styles.id', $_REQUEST['Discussion/StyleID']);
		} else {
			// if we're the default discussions view, we'll block style reviews.
			if ($this->shouldFilterReviews()) {
				$Sender->SQL->Where('d.CategoryID <>', 4);
			}
		}
		$Sender->SQL->Database->DatabasePrefix = $prefix;
	}
	
	private function shouldFilterReviews() {
		// i can't find a better way to detect this.
		foreach (debug_backtrace() as $i) {
			// echo $i['class'].':'.$i['function']."\n";
			# we don't want to do this for...
			if ($i['class'] == 'BookmarkedModule' // bookmarks in the sidebar
				|| $i['function'] == 'GetAnnouncements' // announcements
				|| $i['class'] == 'CategoriesController' // category listings
				|| $i['function'] == 'Bookmarked' // bookmarks listings
				|| $i['function'] == 'Mine' // my discussions
				|| $i['class'] == 'ParticipatedPlugin' // participated
				|| $i['function'] == 'ProfileController_Discussions_Create' // profile discussion list
				) {
				return false;
			}
		}
		return true;
	}

	public function DiscussionModel_BeforeGetID_Handler($Sender) {
		$prefix = $Sender->SQL->Database->DatabasePrefix;
		$Sender->SQL->Database->DatabasePrefix = '';
		$Sender->SQL->Join('styles styles', 'd.StyleID = styles.id', 'left');
		$Sender->SQL->Select('styles.short_description', '', 'StyleName');
		$Sender->SQL->Database->DatabasePrefix = $prefix;
	}

	public function DiscussionsController_AfterDiscussionTitle_Handler($Sender) {
		$Discussion = $Sender->EventArguments['Discussion'];
		if (is_numeric($Discussion->StyleID) && $Discussion->StyleID != 0) {
			$Sender->AddCssFile($this->GetResource('list.css', FALSE, FALSE));
			echo '<span class="Title">- '.htmlspecialchars($Discussion->StyleName).' '.$this->getRatingImage($Discussion->Rating).'</span>';
		}
	}

	public function UserInfoModule_OnBasicInfo_Handler($Sender) {
		echo '<dt><a href="http://userstyles.org/users/show_by_forum_id/'.$Sender->User->UserID.'">Main Profile</a></dt><dd></dd>';
	}

	public function CategoriesController_AfterDiscussionTitle_Handler($Sender) {
		$this->DiscussionsController_AfterDiscussionTitle_Handler($Sender);
	}

	public function Structure() {
		$Structure = Gdn::Structure();
		$Structure->Table('Discussion')->Column('StyleID', 'int');
		$Structure->Table('Discussion')->Column('Rating', 'int');
	}

	public function Setup() {
		$this->Structure();
	}

	private function getStyleID($Sender) {
		if (is_numeric($Sender->Discussion->StyleID)) {
			if ($Sender->Discussion->StyleID == '0') {
				return null;
			}
			return $Sender->Discussion->StyleID; 
		}
		if (is_numeric($_REQUEST['Discussion/StyleID'])) {
			if ($_REQUEST['Discussion/StyleID'] == '0') {
				return null;
			}
			return $_REQUEST['Discussion/StyleID'];
		}
		return null;
	}

	private function getStyleName($Sender) {
		$StyleID = $this->getStyleID($Sender);
		$Results = $Sender->Database->Query('SELECT short_description StyleName FROM styles WHERE id = '.$StyleID)->Result('DATASET_TYPE_ARRAY');
		return $Results[0]->StyleName;
	}
	
	public function Base_Render_Before($Sender) {
		$Sender->AddCssFile($this->GetResource('global.css', FALSE, FALSE));
		if ($_REQUEST['minimal'] == 'true') {
			$Sender->AddCssFile($this->GetResource('minimal.css', FALSE, FALSE));
		}
		if ($Sender->Menu) {
			$Sender->Menu->AddLink('Userstyles', T('userstyles.org'), 'http://userstyles.org/', FALSE, array('class' => 'HomeLink', 'title' => 'This is the greatest feature ever'));
			# added to config: $Configuration['Garden']['Menu']['Sort'] = ['Userstyles', 'Dashboard', 'Discussions'];
		}
	}

}

