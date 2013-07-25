//
//  LevelManager.h
//  GravityTwist
//
//  Created by Student on 7/11/13.
//  Copyright 2013 526. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LevelManager : CCLayer {
    
    CCMenuItemFont *menuItem;
    CCMenuItemLabel *menuItemLabel;
    CCMenuItemFont *levelSelectLabel;
    CCMenuItemFont *backLabel;
    CCMenu *menu;
    CCMenu *menu2;
    CCMenu *menu3;
    CCMenu *menu4;
    CCMenu *menu5;
    CCMenuItemImage *image;
    
}

+(CCScene *) scene;

@end
