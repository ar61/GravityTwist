//
//  Credits.m
//  GravityTwist
//
//  Created by Student on 7/25/13.
//  Copyright 2013 526. All rights reserved.
//

#import "Credits.h"

#import "AppDelegate.h"
#import "LevelManager.h"
#import "GameLayer.h"
#import "SimpleAudioEngine.h"
#import "MenuItemLayer.h"

@implementation Credits

+(CCScene *) scene
{
    CCScene *scene = [CCScene node];
    
    Credits *layer = [Credits node];
    
    [scene addChild:layer];
    
    return scene;
    
}

-(id) init
{
	if( (self=[super init])) {
        
		// create menu
		[self createCredits];
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background.mp3" loop:YES];
        
	}
	return self;
}

-(void) createCredits
{
	// Default font size will be 32 points.
	[CCMenuItemFont setFontSize:64];
    
    CCMenuItemLabel *line1 = [CCMenuItemFont itemWithString:@"A game by"];
    line1.color = ccBLACK;
    
    [CCMenuItemFont setFontSize:32];
    
    
    CCMenuItemLabel *name1 = [CCMenuItemFont itemWithString:@"Abhinav Rathod"];
    name1.color = ccBLACK;
    
    CCMenuItemLabel *name2 = [CCMenuItemFont itemWithString: @"Arpit Bansal"];
    name2.color = ccBLACK;

    CCMenuItemLabel *name3 = [CCMenuItemFont itemWithString: @"Daniel Kessler"];
    name3.color = ccBLACK;
                              
    CCMenuItemLabel *name4 = [CCMenuItemFont itemWithString: @"Pramodh Aravindan"];
    name4.color = ccBLACK;
    
    [CCMenuItemFont setFontSize:48];
    CCMenuItemLabel *backLabel = [CCMenuItemFont itemFromString:@"Back" block:^(id sender) { [self goBack]; }];
    backLabel.position = ccp(-400,-275);
    backLabel.color = ccBLACK;
    
    
    [CCMenuItemFont setFontSize:32];
    CCMenuItemLabel *thanks = [CCMenuItemFont itemWithString:@"Special thanks to:"];
    thanks.color = ccBLACK;
    thanks.position = ccp(300, -200);
    
    CCMenuItemLabel *name5 = [CCMenuItemFont itemWithString:@"Scott Easley"];
    name5.color = ccBLACK;
    name5.position = ccp(300, -250);
    
    CCMenuItemLabel *name6 = [CCMenuItemFont itemWithString:@"Jerry Lin"];
    name6.color = ccBLACK;
    name6.position = ccp(300,-275);


    CCMenu *menu = [CCMenu menuWithItems:nil];
	[menu addChild:line1];
    [menu addChild:name1];
    [menu addChild:name2];
    [menu addChild:name3];
    [menu addChild:name4];
    [menu alignItemsVertically];
	
    [menu addChild:backLabel];
    [menu addChild:thanks];
    [menu addChild:name5];
    [menu addChild:name6];
    
    
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width/2, size.height/2)];
	
    [self addChild: menu];
    

    CCMenuItemImage *image = [CCMenuItemImage itemWithNormalImage:@"MainMenu.png" selectedImage:@"MainMenu.png"];
    image.anchorPoint = CGPointMake(0,0);
    
    [self addChild:image z:-1];
    
    
	
}

-(void) goBack
{
    [[CCDirector sharedDirector] replaceScene:[MenuItemLayer scene]];
}




@end
