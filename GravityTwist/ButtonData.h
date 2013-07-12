//
//  ButtonData.h
//  GravityTwist
//
//  Created by Daniel Kessler on 7/10/13.
//  Copyright (c) 2013 526. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"
#import "cocos2d.h"

@interface ButtonData : NSObject
{
@private
    NSMutableArray *doorBodies;
    CCTMXLayer *doorLayer;
}

-(id) initWithBodies: (NSMutableArray*)bodies withDoorLayer:(CCTMXLayer*) layer;
-(void) setButtonPressed: (BOOL)pressed;

@end
