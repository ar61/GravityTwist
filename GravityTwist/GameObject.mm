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
@synthesize linearImpulse;

-(id) init {
    [super init];
    
    return self;
}

-(id) initWithOptions: (b2BodyType) type withPosition:(CGPoint) position withRotation:(BOOL) rotation withPolyShape:(b2PolygonShape) poly withDensity:(CGFloat) density withFriction:(CGFloat) friction withRestitution:(CGFloat) res withTileIndex:(b2Vec2)tilePosition withTileLength:(b2Vec2)tileLength withWorld: (b2World*) world withBatchNode: (CCSpriteBatchNode*) parent withZLocation:(int)z
{
    [self initWithTexture:[parent texture] rect:CGRectMake(32*tilePosition.x, 32*tilePosition.y, 32*tileLength.x, 32*tileLength.y)];
    
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
    
    [parent addChild:self z:z tag:kTagChildNode];
    
    [self setPTMRatio:PTM_RATIO];
    [self setB2Body:body];
    [self setPosition: position];
    
    return self;
}

@end
