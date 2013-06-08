//
//  HelloWorldLayer.mm
//  GravityTwist - An awesome game!! :P
//
//  Created by Abhinav Rathod on 6/4/13.
//  Copyright 526 2013. All rights reserved.
//

// Import the interfaces
#import "HelloWorldLayer.h"

// Not included in "cocos2d.h"
#import "CCPhysicsSprite.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"


enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer
//Comment by AB

@interface HelloWorldLayer()
{
    CCPhysicsSprite *player;
    CGSize s;
}
-(void) initPhysics;
-(void) addNewSpriteAtPosition:(CGPoint)p;
-(void) createMenu;
@end

@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
		// enable events
		
        tile = [tiledMap layerNamed:@"tiles"];
        //meta = [tiledMap layerNamed:@"meta"];
        
        objects = [tiledMap objectGroupNamed:@"objects"];
        NSAssert(objects != nil, @"Tile map doesnt have a objects layer defined");
        
        NSDictionary *spawnPoint = [objects objectNamed:@"SpawnPoint"];
        int x = [spawnPoint[@"x"] integerValue];
        int y = [spawnPoint[@"y"] integerValue];
        
		self.touchEnabled = YES;
		self.accelerometerEnabled = YES;
		s = [CCDirector sharedDirector].winSize;
		
		// init physics
		[self initPhysics];
		
		// create reset button
		//[self createMenu];
		
		//Set up sprite
		
#if 1
		// Use batch node. Faster
		CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:100];
		spriteTexture_ = [parent texture];
#else
		// doesn't use batch node. Slower
		spriteTexture_ = [[CCTextureCache sharedTextureCache] addImage:@"blocks.png"];
		CCNode *parent = [CCNode node];
#endif
		[self addChild:parent z:0 tag:kTagParentNode];
		
		
		//[self addNewSpriteAtPosition:ccp(s.width/2, s.height/2)];
        
        //CCLOG(@"Add sprite %0.2f x %02.f",s.width/2,s.height/2);
        // Define the dynamic body.
        //Set up a 1m squared box in the physics world
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.position.Set(s.width/PTM_RATIO, s.height/PTM_RATIO);
        b2Body *body = world->CreateBody(&bodyDef);
        
        // Define another box shape for our dynamic body.
        b2PolygonShape dynamicBox;
        dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
        
        // Define the dynamic body fixture.
        b2FixtureDef fixtureDef;
        fixtureDef.shape = &dynamicBox;
        fixtureDef.density = 1.0f;
        fixtureDef.friction = 0.3f;
        body->CreateFixture(&fixtureDef);
        
        
        CCNode *parent1 = [self getChildByTag:kTagParentNode];
        
        //We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
        //just randomly picking one of the images
       // int idx = (CCRANDOM_0_1() > .5 ? 0:1);
        //int idy = (CCRANDOM_0_1() > .5 ? 0:1);
        player = [CCPhysicsSprite spriteWithTexture:spriteTexture_ rect:CGRectMake(32 * 1,32 * 1,32,32)];
        [parent1 addChild:player];
        
        [player setPTMRatio:PTM_RATIO];
        [player setB2Body:body];
        [player setPosition: ccp( s.width/2, s.height/2)];
        
        
		//adding buttons
        CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"Icon-Small@2x.png" selectedImage:@"Icon-Small@2x.png" target:self selector:@selector(moveLeft)];
        CCMenu *menu = [CCMenu menuWithItems:item1,nil];
        menu.position = ccp(50,40);
        [self addChild:menu];
        
        CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"Icon-Small@2x.png" selectedImage:@"Icon-Small@2x.png" target:self selector:@selector(moveRight)];
        CCMenu *menu2 = [CCMenu menuWithItems:item2,nil];
        menu2.position = ccp(120,40);
        [self addChild:menu2];
        		
		[self scheduleUpdate];
	}
	return self;
}

-(void)moveLeft
{
    if((player.position.x - 50) > 0)
    {
        [player runAction:[CCMoveBy actionWithDuration:.3 position:ccp(-50,0)]];
    }
}

-(void)moveRight
{
    if((player.position.x + 50) < s.width)
    {
        [player runAction:[CCMoveBy actionWithDuration:.3 position:ccp(50,0)]];
    }
}


-(void) dealloc
{
	delete world;	
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
	[super dealloc];
}	

-(void) initPhysics
{
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
	world = new b2World(gravity);
	
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);		
	
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;		
	
	// bottom
	
	groundBox.Set(b2Vec2(0,0), b2Vec2(size.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// top
	groundBox.Set(b2Vec2(0,size.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,size.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
	
	// left
	groundBox.Set(b2Vec2(0,size.height/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// right
	groundBox.Set(b2Vec2(size.width/PTM_RATIO,size.height/PTM_RATIO), b2Vec2(size.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
}

-(void) draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	world->DrawDebugData();	
	
	kmGLPopMatrix();
}

-(void) update: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
    
    CGPoint pos = player.position;
    
    pos.x += playerVelocity.x;
    pos.y += playerVelocity.y;
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    float imageWidthHalved = player.texture.contentSize.width * 0.5f;
    float imageHeightHalved = player.texture.contentSize.height * 0.5f;
    
    float leftBorderLimit = imageWidthHalved;
    float rightBorderLimit = screenSize.width - imageWidthHalved;
    
    float topBorderLimit = imageHeightHalved;
    float bottomBorderLimit = screenSize.height - imageHeightHalved;
    
    if(pos.x < leftBorderLimit)
    {
        pos.x = leftBorderLimit;
        playerVelocity.x = 0;
    }
    else if(pos.x > rightBorderLimit)
    {
        pos.x = rightBorderLimit;
        playerVelocity.x = 0;
    }
    
    if(pos.x < topBorderLimit)
    {
        pos.x = leftBorderLimit;
        playerVelocity.x = 0;
    }
    else if(pos.x > rightBorderLimit)
    {
        pos.x = bottomBorderLimit;
        playerVelocity.x = 0;
    }
    
    player.position = pos;

}

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    float deceleration = 1.0f;
    float maxVelocity = 2;
    
    playerVelocity.x = playerVelocity.x * deceleration + acceleration.x;
    playerVelocity.y = playerVelocity.y * deceleration + acceleration.y;
    
    if(playerVelocity.x > maxVelocity)
    {
        playerVelocity.x = maxVelocity;
    }
    else if (playerVelocity.x < -maxVelocity)
    {
        playerVelocity.x = -maxVelocity;
    }
    
    if(playerVelocity.y > maxVelocity)
    {
        playerVelocity.y = maxVelocity;
    }
    else if (playerVelocity.y < -maxVelocity)
    {
        playerVelocity.y = -maxVelocity;
    }
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [player runAction:[CCJumpTo actionWithDuration:1.0f position:player.position height:50 jumps:1]];
}



@end
