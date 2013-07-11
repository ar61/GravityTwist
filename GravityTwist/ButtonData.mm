//
//  ButtonData.m
//  GravityTwist
//
//  Created by Daniel Kessler on 7/10/13.
//  Copyright (c) 2013 526. All rights reserved.
//

#import "ButtonData.h"

@implementation ButtonData

-(id) initWithBodies: (NSMutableArray*)bodies withDoorLayer:(CCTMXLayer*) layer {
    if (self = [super init]) {
        doorBodies = bodies;
        doorLayer = layer;
    }
    return self;
}

-(void) setButtonPressed: (BOOL)pressed {
    doorLayer.visible = !pressed;
    for (id doorColBody in doorBodies) {
        //((b2Body*)[doorColBody pointerValue])->SetActive();
        ((b2Body*)[doorColBody pointerValue])->SetUserData([NSNumber numberWithBool:pressed]);
    }
}

@end
