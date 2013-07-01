//
//  GameObject.m
//  GravityTwist
//
//  Created by Student on 6/23/13.
//  Copyright 2013 526. All rights reserved.
//

#import "GameObject.h"

@implementation GameObject

@synthesize body;
@synthesize object;

-(id) init {
    [super init];
    
    return self;
}

-(CCSpriteBatchNode*) getSpriteBatchNodeObject: (NSString*) textureFilename
{
    parent1 = [CCSpriteBatchNode batchNodeWithFile:textureFilename capacity:100];
    spriteTexture = [parent1 texture];
    
    return parent1;
}

//-(void)changePosition: (CGPoint) pos

-(id) initWithOptions: (b2BodyType) type withPosition:(CGPoint) position withFixedRotation:(BOOL) rotation withPolyShape:(b2PolygonShape) poly withDensity:(CGFloat) density withFriction:(CGFloat) friction withRestitution:(CGFloat) res withWorld: (b2World*) world withParent: (CCNode*) parent tag: (int) tag
{
    b2BodyDef bodyDef;
    bodyDef.type = type;
    bodyDef.position.Set(position.x, position.y);
    bodyDef.fixedRotation = rotation;
    
    body = world->CreateBody(&bodyDef);    
    
    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &poly;
    fixtureDef.density = density;
    fixtureDef.friction = friction;
    fixtureDef.restitution = res;
    body->CreateFixture(&fixtureDef);
    
    //parent = (CCNode *) parent1;
    
    object = [CCPhysicsSprite spriteWithTexture:spriteTexture rect:CGRectMake(32 * 1,32 * 1,32,32)];
    [parent addChild:object z:0 tag:tag];
    
    [object setPTMRatio:PTM_RATIO];
    [object setB2Body:body];
    [object setPosition: position];
    
    return self;
}

@end
