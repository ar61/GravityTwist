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
        [self addChild:menu2];
        [self addChild:menu3];
        [self addChild:menu4];
        [self addChild:menu5];
        
    }
    return self;
}
-(void) createLevelSelectScreen
{
    [CCMenuItemFont setFontSize:50];
    int realIndex = 1;
    menu = [CCMenu menuWithItems:nil];
    
    for(int i = 1; i <= 11; i += 5)
    {
        menuItem = [CCMenuItemFont itemFromString:[NSString stringWithFormat:@"%d", realIndex] block:^(id sender){ [self loadLevel: realIndex]; }];
        menuItem.tag = realIndex;
        [menu addChild:menuItem];
        realIndex += 5;
    }
    menu.position = ccp(300,425);
    [menu alignItemsVertically];
    
    realIndex = 2;
    menu2 = [CCMenu menuWithItems:nil];
    for(int i = 2; i <= 12; i += 5)
    {
        menuItem = [CCMenuItemFont itemFromString:[NSString stringWithFormat:@"%d", realIndex] block:^(id sender){ [self loadLevel: realIndex]; }];
        menuItem.tag = realIndex;
        [menu2 addChild:menuItem];
        realIndex += 5;
    }
    menu2.position = ccp(400,425);
    [menu2 alignItemsVertically];
    
    realIndex = 3;
    menu3 = [CCMenu menuWithItems:nil];
    for(int i = 3; i <= 13; i += 5)
    {
        menuItem = [CCMenuItemFont itemFromString:[NSString stringWithFormat:@"%d", realIndex] block:^(id sender){ [self loadLevel: realIndex]; }];
        menuItem.tag = realIndex;
        [menu3 addChild:menuItem];
        realIndex += 5;
    }
    menu3.position = ccp(500,425);
    [menu3 alignItemsVertically];
    
    realIndex = 4;
    menu4 = [CCMenu menuWithItems:nil];
    for(int i = 4; i <= 14; i += 5)
    {
        menuItem = [CCMenuItemFont itemFromString:[NSString stringWithFormat:@"%d", realIndex] block:^(id sender){ [self loadLevel: realIndex]; }];
        menuItem.tag = realIndex;
        [menu4 addChild:menuItem];
        realIndex += 5;
    }
    menu4.position = ccp(600,425);
    [menu4 alignItemsVertically];
    
    realIndex = 5;
    menu5 = [CCMenu menuWithItems:nil];
    for(int i = 4; i <= 15; i += 5)
    {
        menuItem = [CCMenuItemFont itemFromString:[NSString stringWithFormat:@"%d", realIndex] block:^(id sender){ [self loadLevel: realIndex]; }];
        menuItem.tag = realIndex;
        [menu5 addChild:menuItem];
        realIndex += 5;
    }
    menu5.position = ccp(700,425);
    [menu5 alignItemsVertically];
    
    
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






