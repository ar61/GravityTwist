//
//  LevelManager.m
//  GravityTwist
//
//  Created by Student on 7/11/13.
//  Copyright 2013 526. All rights reserved.
//

#import "LevelManager.h"
#import "GameLayer.h"

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
        [CCMenuItemFont setFontSize:150];
        int realIndex = 0;
        menu = [CCMenu menuWithItems:nil];
        for (int x = 0; x < 2; x++) {
                for (int y = 0; y < 5; y++) {
                        menuItem = [CCMenuItemFont itemFromString:[NSString stringWithFormat:@"%d", realIndex] block:^(id sender){ [self loadLevel: realIndex]; }];
                        menuItem.tag = realIndex;
                        menuItem.position = ccp(y * (menuItem.contentSize.width + 25),-(x * (menuItem.contentSize.height + 25)));
                        [menu addChild:menuItem];
                        realIndex++;
                    }
            }
        levelSelectLabel = [CCMenuItemFont itemFromString:@"Select Level"];
        levelSelectLabel.position = ccp(500,600);
        [self addChild: levelSelectLabel];
        menu.position = ccp(300,425);   //   <-- Adjust coordinates.
    
    
}

-(void) loadLevel: (int) levelNumber
{
    [[CCDirector sharedDirector] replaceScene:[GameLayer scene]];
    
}



@end