//
//  SettingsViewController.m
//  Reddit2
//
//  Created by Ross Boucher on 6/14/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import "SettingsViewController.h"
#import "iRedditAppDelegate.h"
#import "LoginController.h"
#import "Constants.h"
#import "Three20Extensions.h"

static void settingsSoundPlayedCallback(SystemSoundID  mySSID, void* myself) 
{
	AudioServicesRemoveSystemSoundCompletion(mySSID);
	AudioServicesDisposeSystemSoundID(mySSID);
}

@implementation SettingsTableViewDataSource

- (void)tableView:(UITableView *)tableView cell:(UITableViewCell *)cell willAppearAtIndexPath:(NSIndexPath *)indexPath 
{
	id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];
	
	if ([object isKindOfClass:[CheckGroupTableItem class]])
	{
		CheckGroupTableItem *item = (CheckGroupTableItem *)object;
		
		if (item.on)
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		else
			cell.accessoryType = UITableViewCellAccessoryNone;
	}
	else
        [super tableView:tableView cell:cell willAppearAtIndexPath:indexPath]; 
} 

@end

@implementation SettingsTableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath 
{
	id<TTTableViewDataSource> dataSource = (id<TTTableViewDataSource>)tableView.dataSource;
	id object = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
	
	if ([object isKindOfClass:[CheckGroupTableItem class]])
	{
		int rowCount = [tableView numberOfRowsInSection:indexPath.section];
		for (int i=0; i<rowCount; i++)
		{
			NSIndexPath *newPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
			CheckGroupTableItem *item = [dataSource tableView:tableView objectForRowAtIndexPath:newPath];
			
			item.on = i == indexPath.row;

			UITableViewCell *cell = [tableView cellForRowAtIndexPath:newPath];
			cell.accessoryType =  i == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
		}
		
		[_controller didSelectObject:object atIndexPath:indexPath];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}							
	else
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end

@implementation SettingsViewController

- (void)loadView 
{
	[super loadView];
	
	self.title = @"Settings";
	self.autoresizesForKeyboard = YES;
	self.navigationBarTintColor = [iRedditAppDelegate redditNavigationBarTintColor];

	self.variableHeightRows = YES;
	
	self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped] autorelease];
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		self.tableView.backgroundColor = [UIColor colorWithRed:222.0/255.0 green:222.0/255.0 blue:233.0/255.0 alpha:1];
	}

	[self.view addSubview:self.tableView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (id<UITableViewDelegate>)createDelegate 
{
	return [[[SettingsTableViewDelegate alloc] initWithController:self] autorelease];
}

-(void)createModel 
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *currentSound = [defaults stringForKey:shakingSoundKey];
	
	self.dataSource = [SettingsTableViewDataSource dataSourceWithObjects:
			@"UPRISER Account Information",
			[SettingsControlItem textFieldControlWithTitle:@"Username" text:[defaults stringForKey:redditUsernameKey] placeholder:@"splashy" key:redditUsernameKey secure:NO],
			[SettingsControlItem textFieldControlWithTitle:@"Password" text:[defaults stringForKey:redditPasswordKey] placeholder:@"••••••" key:redditPasswordKey secure:YES],
			
			@"Instapaper Account Information",
			[SettingsControlItem textFieldControlWithTitle:@"Username" text:[defaults stringForKey:instapaperUsernameKey] placeholder:@"splashy" key:instapaperUsernameKey secure:NO],
			[SettingsControlItem textFieldControlWithTitle:@"Password" text:[defaults stringForKey:instapaperPasswordKey] placeholder:@"optional" key:instapaperPasswordKey secure:YES],

			@"Customized movements",
			[SettingsControlItem switchControlWithTitle:@"Use Account Settings" on:[defaults boolForKey:useCustomRedditListKey] key:useCustomRedditListKey],

			@"Display Preferences",
			[SettingsControlItem switchControlWithTitle:@"Show Thumbnails" on:[defaults boolForKey:showStoryThumbnailKey] key:showStoryThumbnailKey],
			[SettingsControlItem switchControlWithTitle:@"Shake for New idea" on:[defaults boolForKey:shakeForStoryKey] key:shakeForStoryKey],
			[SettingsControlItem switchControlWithTitle:@"Play Sound on Shake" on:[defaults boolForKey:playSoundOnShakeKey] key:playSoundOnShakeKey],
			[SettingsControlItem switchControlWithTitle:@"Show Loading face" on:[defaults boolForKey:showLoadingAlienKey] key:showLoadingAlienKey],
			[SettingsControlItem switchControlWithTitle:@"Allow Landscape" on:[defaults boolForKey:allowLandscapeOrientationKey] key:allowLandscapeOrientationKey],

			@"Serendipity Mode Sound",
			[CheckGroupTableItem itemWithText:@"Light Sword Swing" on:[currentSound isEqual:redditSoundLightsaber] URL:redditSoundLightsaber group:shakingSoundKey],
			[CheckGroupTableItem itemWithText:@"Alley Brawler" on:[currentSound isEqual:redditSoundAlleyBrawler] URL:redditSoundAlleyBrawler group:shakingSoundKey],
			[CheckGroupTableItem itemWithText:@"Transporter" on:[currentSound isEqual:redditSoundBeamMeUp] URL:redditSoundBeamMeUp group:shakingSoundKey],
			[CheckGroupTableItem itemWithText:@"En-garde" on:[currentSound isEqual:redditSoundEnGarde] URL:redditSoundEnGarde group:shakingSoundKey],
			[CheckGroupTableItem itemWithText:@"Warp Pipe" on:[currentSound isEqual:redditSoundPipe] URL:redditSoundPipe group:shakingSoundKey],
			[CheckGroupTableItem itemWithText:@"The Door" on:[currentSound isEqual:redditSoundTheDoor] URL:redditSoundTheDoor group:shakingSoundKey],
			[CheckGroupTableItem itemWithText:@"Pure Evil" on:[currentSound isEqual:redditSoundPureEvil] URL:redditSoundPureEvil group:shakingSoundKey],
			[CheckGroupTableItem itemWithText:@"Roll Out" on:[currentSound isEqual:redditSoundRollout] URL:redditSoundRollout group:shakingSoundKey],
			[CheckGroupTableItem itemWithText:@"Alien Hunter" on:[currentSound isEqual:redditSoundAlienHunter] URL:redditSoundAlienHunter group:shakingSoundKey],
			[CheckGroupTableItem itemWithText:@"Wilhelm" on:[currentSound isEqual:redditSoundScream] URL:redditSoundScream group:shakingSoundKey],
			
			nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	TTSectionedDataSource *data = (TTSectionedDataSource *)self.dataSource;
	NSArray *sections = [data sectionsCopy];

	NSString *username = [defaults stringForKey:redditUsernameKey];
	NSString *password = [defaults stringForKey:redditPasswordKey];
	BOOL useAccountSettings = [defaults boolForKey:useCustomRedditListKey];
	
	for (int i=0, count = [sections count]; i<count; i++)
	{
		NSArray *items = [data itemsInSection:i];

		for (int j=0, itemCount = [items count]; j<itemCount; j++)
		{
			id field = [items objectAtIndex:j];
			
			if ([field isKindOfClass:[CheckGroupTableItem class]])
			{
				CheckGroupTableItem *checkField = (CheckGroupTableItem *)field;
				
				if (checkField.on)
					[defaults setObject:checkField.URL forKey:checkField.group];
			}
			else if ([field isKindOfClass:[SettingsControlItem class]])
			{
				
				SettingsControlItem *item = (SettingsControlItem *)field;
				
				if ([item.control isKindOfClass:[UISwitch class]])
				{
					UISwitch *theSwitch = (UISwitch *)(item.control);
					[defaults setBool:theSwitch.on forKey:item.key];
				}
				else if ([item.control isKindOfClass:[UITextField class]])
				{
					UITextField *theTextField = (UITextField *)(item.control);
					[defaults setObject:theTextField.text forKey:item.key];
				}
			}
		}
	}

	[sections release];
	
	[defaults synchronize];
	
	if (![username isEqual:[defaults stringForKey:redditUsernameKey]] || ![password isEqual:[defaults stringForKey:redditPasswordKey]])
    {
        [[LoginController sharedLoginController] loginWithUsername:[defaults stringForKey:redditUsernameKey] password:[defaults stringForKey:redditPasswordKey]];
    }
	else if (useAccountSettings != [defaults boolForKey:useCustomRedditListKey])
    {
		[[NSNotificationCenter defaultCenter] postNotificationName:RedditDidFinishLoggingInNotification object:nil];
    }
	
	[[iRedditAppDelegate sharedAppDelegate] reloadSound];
}

- (void)didSelectObject:(TTTableLinkedItem*)object atIndexPath:(NSIndexPath*)indexPath
{
	[super didSelectObject:object atIndexPath:indexPath];
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];

	if ([object isKindOfClass:[CheckGroupTableItem class]])
	{
		SystemSoundID sound;
		NSString *path = [[NSBundle mainBundle] pathForResource:object.URL ofType:@"pcm"];
		AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path], &sound);
		AudioServicesAddSystemSoundCompletion (sound,NULL,NULL,settingsSoundPlayedCallback,(void*) self);		
		AudioServicesPlaySystemSound(sound);
	}
	else if ([object isKindOfClass:[TTTableSubtextItem class]])
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:object.URL]];
	}
}


@end
