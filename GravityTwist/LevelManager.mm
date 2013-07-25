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
        image = [CCMenuItemImage itemWithNormalImage:@"Level-Select.png" selectedImage:@"Level-Select.png"];
        image.anchorPoint = CGPointMake(0, 0);
        // create menu
        [self createLevelSelectScreen];
        [self addChild:menu];
        [self addChild:menu2];
        [self addChild:menu3];
        [self addChild:menu4];
        [self addChild:menu5];
        [self addChild:image z:-1];
        
    }
    return self;
}
-(void) createLevelSelectScreen
{
    [CCMenuItemFont setFontSize:50];
    
    menu = [CCMenu menuWithItems:nil];
    
    float padding = 60;
    int realIndex = 1;
    for(int i = 1; i <= 11; i += 5)
    {
        
        menuItem = [CCMenuItemFont itemFromString:[NSString stringWithFormat:@"%d", realIndex] block:^(id sender){ [self loadLevel: realIndex]; }];
        menuItem.tag = realIndex;
        menuItem.color = ccBLACK;
        [menu addChild:menuItem z:1];
        realIndex += 5;
    }
    menu.position = ccp(225,350);
    [menu alignItemsVerticallyWithPadding:padding];
    
    
    realIndex = 2;
    menu2 = [CCMenu menuWithItems:nil];
    for(int i = 2; i <= 12; i += 5)
    {
        menuItem = [CCMenuItemFont itemFromString:[NSString stringWithFormat:@"%d", realIndex] block:^(id sender){ [self loadLevel: realIndex]; }];
        menuItem.tag = realIndex;
        menuItem.color = ccBLACK;
        [menu2 addChild:menuItem];
        realIndex += 5;
    }
    menu2.position = ccp(375,350);
    [menu2 alignItemsVerticallyWithPadding:padding];
    
    realIndex = 3;
    menu3 = [CCMenu menuWithItems:nil];
    for(int i = 3; i <= 13; i += 5)
    {
        menuItem = [CCMenuItemFont itemFromString:[NSString stringWithFormat:@"%d", realIndex] block:^(id sender){ [self loadLevel: realIndex]; }];
        menuItem.tag = realIndex;
        menuItem.color = ccBLACK;
        [menu3 addChild:menuItem];
        realIndex += 5;
    }
    menu3.position = ccp(525,350);
    [menu3 alignItemsVerticallyWithPadding:padding];
    
    realIndex = 4;
    menu4 = [CCMenu menuWithItems:nil];
    for(int i = 4; i <= 14; i += 5)
    {
        menuItem = [CCMenuItemFont itemFromString:[NSString stringWithFormat:@"%d", realIndex] block:^(id sender){ [self loadLevel: realIndex]; }];
        menuItem.tag = realIndex;
        menuItem.color = ccBLACK;
        [menu4 addChild:menuItem];
        realIndex += 5;
    }
    menu4.position = ccp(675,350);
    [menu4 alignItemsVerticallyWithPadding:padding];
    
    realIndex = 5;
    menu5 = [CCMenu menuWithItems:nil];
    for(int i = 4; i <= 15; i += 5)
    {
        menuItem = [CCMenuItemFont itemFromString:[NSString stringWithFormat:@"%d", realIndex] block:^(id sender){ [self loadLevel: realIndex]; }];
        menuItem.tag = realIndex;
        menuItem.color = ccBLACK;
        [menu5 addChild:menuItem];
        realIndex += 5;
    }
    menu5.position = ccp(825,350);
    [menu5 alignItemsVerticallyWithPadding:padding];
    
    
    
    
    levelSelectLabel = [CCMenuItemFont itemFromString:@"Select Level"];
    levelSelectLabel.position = ccp(500,600);
    levelSelectLabel.color = ccBLACK;
    
    backLabel = [CCMenuItemFont itemFromString:@"Back" block:^(id sender) { [self goBack]; }];
    backLabel.position = ccp(-100,-250);
    backLabel.color = ccBLACK;
    
    [self addChild: levelSelectLabel];
    [menu addChild: backLabel z:1];
}

-(void) loadLevel: (int) levelNumber
{
    NSString *pathAndFileName = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Level%d", levelNumber] ofType:@"tmx"];
    
    if(pathAndFileName != NULL)
        [[CCDirector sharedDirector] replaceScene:[GameLayer scene:levelNumber]];
}

-(void) goBack
{
    [[CCDirector sharedDirector] replaceScene:[MenuItemLayer scene]];
}



@end
