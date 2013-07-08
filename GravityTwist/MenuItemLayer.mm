//
//  MenuItemLayer.m
//  GravityTwist
//
//  Created by Arpit Bansal on 6/10/13.
//  Copyright 2013 526. All rights reserved.
//

// Import the interfaces
#import "MenuItemLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "GameLayer.h"


#pragma mark - MenuItemLayer

@interface MenuItemLayer()
-(void) createMenu;
@end

@implementation MenuItemLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MenuItemLayer *layer = [MenuItemLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
        
		// create reset button
		[self createMenu];
        
	}
	return self;
}


-(void) createMenu
{
	// Default font size will be 22 points.
	[CCMenuItemFont setFontSize:22];
	
	// Reset Button
	CCMenuItemLabel *reset = [CCMenuItemFont itemWithString:@"Start Game" block:^(id sender){
		[[CCDirector sharedDirector] replaceScene: [GameLayer scene: @"boxbutton.tmx"]];
	}];
	
    /*
     // Achievement Menu Item using blocks
     CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
     
     
     GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
     achivementViewController.achievementDelegate = self;
     
     AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
     
     [[app navController] presentModalViewController:achivementViewController animated:YES];
     
     [achivementViewController release];
     }];
     
     // Leaderboard Menu Item using blocks
     CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
     
     
     GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
     leaderboardViewController.leaderboardDelegate = self;
     
     AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
     
     [[app navController] presentModalViewController:leaderboardViewController animated:YES];
     
     [leaderboardViewController release];
     }];
     */
	
	CCMenu *menu = [CCMenu menuWithItems:reset, nil];
	
	[menu alignItemsVertically];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width/2, size.height/2)];
	
	
	[self addChild: menu z:-1];
}

/*
 #pragma mark GameKit delegate
 
 -(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
 {
 AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
 [[app navController] dismissModalViewControllerAnimated:YES];
 }
 
 -(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
 {
 AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
 [[app navController] dismissModalViewControllerAnimated:YES];
 }
 */

@end
