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
#import "LevelManager.h"
#import "GameLayer.h"
#import "SimpleAudioEngine.h"

#pragma mark - MenuItemLayer

@interface MenuItemLayer()
-(void) createMenu;
-(void) selectLevel;
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
        
		// create menu
		[self createMenu];
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background.mp3" loop:YES];
        
	}
	return self;
}


-(void) createMenu
{
	// Default font size will be 32 points.
	[CCMenuItemFont setFontSize:32];
	
    // Start Button
    
    CCMenuItemLabel *start = [CCMenuItemFont itemWithString:@"Start Game" target:self selector:@selector(selectLevel)];
    start.color = ccBLACK;
    
    CCMenuItemLabel *options = [CCMenuItemFont itemWithString:@"Options"];
    options.color = ccBLACK;
    
    CCMenuItemLabel *credits = [CCMenuItemFont itemWithString:@"Credits"];
    credits.color = ccBLACK;
    
    CCMenu *menu = [CCMenu menuWithItems:start, options, credits, nil];
	[menu alignItemsVertically];
	
    
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width/2, size.height/2)];
	
    [self addChild: menu];
    
    
    CCMenuItemImage *image = [CCMenuItemImage itemWithNormalImage:@"MainMenu.png" selectedImage:@"Mainmenu.png"];
    image.anchorPoint = CGPointMake(0,0);
    
    [self addChild:image z:-1];
    
    
	
}

-(void) selectLevel
{
    [[CCDirector sharedDirector] replaceScene:[LevelManager scene]];
}



@end