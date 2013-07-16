//
//  PauseScreen.m
//  GravityTwist
//
//  Created by Student on 7/15/13.
//  Copyright 2013 526. All rights reserved.
//

#import "PauseScreen.h"
#import "MenuItemLayer.h"
#import "LevelManager.h"

@implementation PauseScreen

+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
    
    PauseScreen *layer = [PauseScreen node];
    
    [scene addChild:layer];
    
    return scene;
}

-(id) init
{
    if(self = [super init])
    {
        [self createPauseMenu];
    }
    
    return self;
    
}

-(void) createPauseMenu
{
    [CCMenuItemFont setFontSize:32];
    
    CCMenuItemLabel *resume = [CCMenuItemFont itemWithString:@"Resume Game" target:self selector:@selector(resumeGame:)];
    
    CCMenuItemLabel *levelSelect = [CCMenuItemFont itemWithString:@"Level Select" target:self selector:@selector(gotoLevelSelect:)];
    
    CCMenuItemLabel *mainMenu = [CCMenuItemFont itemWithString:@"Return to Main Menu" target:self selector:@selector(gotoMainMenu:)];
    
    CCMenu *menu = [CCMenu menuWithItems:resume, levelSelect, mainMenu, nil];
    
	
	[menu alignItemsVertically];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width/2, size.height/2)];
	
	
	[self addChild: menu];
    
}

-(void) resumeGame:(id) sender
{
    [[CCDirector sharedDirector] popScene];
}

-(void) gotoMainMenu:(id) sender
{
    [[CCDirector sharedDirector] sendCleanupToScene];
    [[CCDirector sharedDirector] popScene];
    [[CCDirector sharedDirector] replaceScene:[MenuItemLayer scene]];
}

-(void) gotoLevelSelect:(id) sender
{
    [[CCDirector sharedDirector] sendCleanupToScene];
    [[CCDirector sharedDirector] popScene];
    [[CCDirector sharedDirector] replaceScene:[LevelManager scene]];
}

@end
