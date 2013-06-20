//
//  HelloWorldLayer.h
//  GravityTwist
//
//  Created by Abhinav Rathod on 6/4/13.
//  Copyright 526 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "MyContactListener.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32
#define KFilterCategoryBits 0x01
#define kFilterCategoryNonSolidObjects 0x02
#define kFilterCategoryHarmfulObjects 0x04
#define kFilterCategorySolidObject 0x03
//Define a constant for gravity of world
#define GRAVITY 9.8f

// HelloWorldLayer
@interface HelloWorldLayer : CCLayerColor
{
	CCTexture2D *spriteTexture_;	// weak ref
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
    CGPoint playerVelocity;
    CCTMXTiledMap *tiledMap;
    CCTMXLayer *tile;
    CCTMXLayer *door;
    CCTMXLayer *collisions;
    CCTMXLayer *collectibles;
    int collectedCount;
    int dirOfTilt;  // 0: left, 1: top, 2: right, 3: bottom
    NSDictionary *exitPoint;
    CCTMXObjectGroup *objects;
    CCTMXObjectGroup *collisionObjects;
    CCTMXObjectGroup *collectibleObjects;
    MyContactListener *contactListener;
    CCLabelTTF *coinsLabel;
    enum tileTypes{
        HARMFUL,
        PLATFORM,
        MOVING_PLATFORM,
        COLLECTIBLE
    }tiles;
    
    BOOL playerDead;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
