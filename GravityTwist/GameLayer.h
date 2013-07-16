//
//  GameLayer.h
//  GravityTwist
//
//  Created by Arpit Bansal on 6/4/13.
//  Copyright 526 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "GameObject.h"
#import "MyContactListener.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

//Define a constant for gravity of world
#define GRAVITY 9.8f

#define KFilterCategoryBits 0x01
#define kFilterCategoryNonSolidObjects 0x02
#define kFilterCategoryHarmfulObjects 0x04
#define kFilterCategorySolidObject 0x03
#define kFilterCategoryExit 0x05

// GameLayer
@interface GameLayer : CCLayer
{
    GameObject *player;
    CGSize s;
    CGPoint spawnPoint;
    CGPoint exitPoint;
    CGPoint exitSize;
	NSString *spriteTextureName;
	b2World* world;
	GLESDebugDraw *m_debugDraw;
    CCTMXTiledMap *tiledMap;
    CCTMXLayer *tile;
    CCTMXLayer *door;
    CCTMXLayer *collectibles;
    CCTMXLayer *meta;
    int collectedCount;
    NSDictionary *exitObject;
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
    BOOL worldBeingDestroyed;
    CGPoint firstTouch, lastTouch;
    
    //Changes by Arpit - Start
    GameObject *movingPlatform;
    GameObject *movingSpike;
    NSMutableArray *movingPlatformObjects;
    NSMutableArray *movingSpikeObjects;
    
    bool pauseScreenUp;
    CCLayer *pauseLayer;
    CCSprite *pauseScreen;
    CCMenu *pauseScreenMenu;
    //Changes by Arpit - End
    
    // TODO: make this non-global
    NSMutableDictionary *doorCollisions;
    NSMutableArray *boxGameObjects;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene: (NSString*) layerName;
-(void) initPhysics;

@end
