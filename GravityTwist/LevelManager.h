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
    CCMenu *menu;
    
}

+(CCScene *) scene;

@end
