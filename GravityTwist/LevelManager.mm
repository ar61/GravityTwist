//
//  LevelManager.m
//  GravityTwist
//
//  Created by Student on 7/11/13.
//  Copyright 2013 526. All rights reserved.
//

#import "LevelManager.h"
#import "GameLayer.h"
#import "MenuItemLayer.h"

@implementation LevelManager

+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    LevelManager *layer = [LevelManager node];
    
    // add layer as a child to scene
    [scene addChild: layer];
    
    // return the scene
    return scene;
}

-(id) init
{
    if( (self=[super init]))
    {
        // create menu
        [self createLevelSelectScreen];
        [self addChild:menu];
        
    }
    return self;
}

-(void) createLevelSelectScreen
{
    [CCMenuItemFont setFontSize:50];
    int realIndex = 1;
    menu = [CCMenu menuWithItems:nil];
    for (int x = 0; x < 3; x++) {
        for (int y = 0; y < 5; y++) {
            menuItem = [CCMenuItemFont itemFromString:[NSString stringWithFormat:@"%d", realIndex] block:^(id sender){ [self loadLevel: realIndex]; }];
            menuItem.tag = realIndex;
            menuItem.position = ccp(y * (menuItem.contentSize.width + 25),-(x * (menuItem.contentSize.height + 25)));
            [menu addChild:menuItem];
            realIndex++;
        }
    }
    menu.position = ccp(300,425);
    
    levelSelectLabel = [CCMenuItemFont itemFromString:@"Select Level"];
    levelSelectLabel.position = ccp(500,600);
    
    backLabel = [CCMenuItemFont itemFromString:@"Back" block:^(id sender) { [self goBack]; }];
    backLabel.position = ccp(-150,-350);
    
    [self addChild: levelSelectLabel];
    [menu addChild: backLabel];
}

-(void) loadLevel: (int) levelNumber
{
    NSString *pathAndFileName = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Level%d", levelNumber] ofType:@"tmx"];
    
    if(pathAndFileName != NULL)
        [[CCDirector sharedDirector] replaceScene:[GameLayer scene:levelNumber]];
}

-(id) goBack
{
    [[CCDirector sharedDirector] replaceScene:[MenuItemLayer scene]];
}



@end