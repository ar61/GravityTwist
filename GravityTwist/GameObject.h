//
//  GameObject.h
//  GravityTwist
//
//  Created by Student on 6/23/13.
//  Copyright 2013 526. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "CCPhysicsSprite.h"

#define PTM_RATIO 32

@interface GameObject : CCPhysicsSprite {

    CCSpriteBatchNode *parent1;
    CCTexture2D *spriteTexture;
    
    enum {
        kTagParentNode = 1,
        kTagChildNode = 2
    };
    
}

@property(nonatomic) b2Body* body;
@property(nonatomic) BOOL isTouching;
@property b2Vec2 linearImpulse;

-(id) initWithOptions: (b2BodyType) type withPosition:(CGPoint) position withRotation:(BOOL) rotation withPolyShape:(b2PolygonShape) poly withDensity:(CGFloat) density withFriction:(CGFloat) friction withRestitution:(CGFloat) res withTileIndex:(b2Vec2)tilePosition withTileLength:(b2Vec2)tileLength withWorld: (b2World*) world withBatchNode:(CCSpriteBatchNode*)parent withZLocation:(int)z;
@end
