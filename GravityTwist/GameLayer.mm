//
//  GameLayer.mm
//  GravityTwist - An awesome game!! :P
//
//  Created by Abhinav Rathod on 6/4/13.
//  Copyright 526 2013. All rights reserved.
//

// Import the interfaces
#import "GameLayer.h"

// Not included in "cocos2d.h"
#import "CCPhysicsSprite.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "GameObject.h"


@implementation GameLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
        playerDead = false;
        tiledMap = [CCTMXTiledMap tiledMapWithTMXFile:@"LevelOne.tmx"];
		
        tile = [tiledMap layerNamed:@"tiles"];
        
        door = [tiledMap layerNamed:@"Exit"];
        door.visible = NO;
        
        objects = [tiledMap objectGroupNamed:@"objects"];
        NSAssert(objects != nil, @"Tile map doesnt have an objects layer defined");
        
        NSDictionary *spawnPoint = [objects objectNamed:@"SpawnPoint"];
        int x = [spawnPoint[@"x"] integerValue];
        int y = [spawnPoint[@"y"] integerValue];
        
        exitPoint = [objects objectNamed:@"Exit"];
        
        collisions = [tiledMap layerNamed:@"collisions"];
        collisions.visible = NO;
        
        collisionObjects = [tiledMap objectGroupNamed:@"collisions"];
        
        collectibleObjects = [tiledMap objectGroupNamed:@"collectibles"];
        
        collectibles = [tiledMap layerNamed:@"collectibles"];
        collectibles.tag = 1;
        collectedCount = 0;
        
		self.touchEnabled = YES;
		self.accelerometerEnabled = YES;
		s = [CCDirector sharedDirector].winSize;
		
		// init physics
		[self initPhysics];
		
        [self createPlatformObjects: collisionObjects withType:1];
        [self createPlatformObjects: collectibleObjects withType:2];
        
        contactListener = new MyContactListener();
        world->SetContactListener(contactListener);
        
        player = [[GameObject alloc] init];
        
        b2PolygonShape dynamicBox;        
        dynamicBox.SetAsBox(.5f, .5f);
        
        spriteTextureName = @"blocks.png";
        
        CCSpriteBatchNode *parent = [player getSpriteBatchNodeObject:spriteTextureName];
        
        [self addChild:parent z:0 tag:kTagParentNode];
        
        CCNode *parent1 = [self getChildByTag:kTagParentNode];
        
        player = [player initWithOptions:b2_dynamicBody withPosition:ccp(x,y) withFixedRotation:YES withPolyShape:dynamicBox withDensity:1.0f withFriction:0.3f withRestitution:0.0f withWorld:world withParent:parent1];        
        
        [self addChild:tiledMap z:-1];
		[self scheduleUpdate];
	}
	return self;
}

-(void)createPlatformObjects: (CCTMXObjectGroup*) layer withType:(int) type
{
    NSMutableDictionary *objPoints;
    
    int x,y,w,h;
    BOOL spikes;
    //int z = [[layer valueForKeyPath:@"spike.hurtful"] integerValue];
    
    for(objPoints in [layer objects])
    {
        x = [[objPoints valueForKey:@"x"] intValue];
        y = [[objPoints valueForKey:@"y"] intValue];
        w = [[objPoints valueForKey:@"width"] intValue];
        h = [[objPoints valueForKey:@"height"] intValue];
        
        CGPoint _point = ccp(x+w/2, y+h/2);
        CGPoint _size = ccp(w,h);
        
        
        if([objPoints valueForKey:@"name"] == NULL)
        {
            spikes = false;
        }
        else
        {
            NSString *named = [NSString stringWithFormat:@"%@", [objPoints objectForKey:@"name"]];
            spikes = [named compare:@"spikes"];
        }
        
        if(!spikes)
        {
            [self createCollisionTiles: _point withSize: _size withType: type];
        }
        else
        {
            [self createCollisionTiles: _point withSize: _size withType: 4];
        }
    }
}

-(void)createCollisionTiles: (CGPoint)p withSize: (CGPoint) size withType: (int) type
{
    b2BodyDef bDef;
    bDef.type = b2_staticBody;
    bDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    b2Body *b = world->CreateBody(&bDef);
    
    b2PolygonShape shape;
    shape.SetAsBox(size.x/2.0/PTM_RATIO, size.y/2.0/PTM_RATIO);
    
    b2FixtureDef fDef;
    fDef.shape = &shape;
    fDef.density = 1.0f;
    fDef.friction = 0.2f;
    fDef.restitution = 0.0f;
    if(type == 2)
    {
        //for collectibles
        fDef.filter.categoryBits = kFilterCategoryNonSolidObjects;
    }
    else if(type == 4)
    {
        fDef.filter.categoryBits = kFilterCategoryHarmfulObjects;
    }
    else
    {
        //for remaining objects
        fDef.filter.categoryBits = KFilterCategoryBits;
    }
    b->CreateFixture(&fDef);
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
	groundBox.Set(b2Vec2(0,size.height/PTM_RATIO), b2Vec2(size.width/PTM_RATIO,size.height/PTM_RATIO));
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
    
    std::vector<MyContact>::iterator position;
    for(position = contactListener->_contacts.begin();
        position != contactListener->_contacts.end(); ++position)
    {
        MyContact contact = *position;
        
        if(contact.fixtureA != NULL && contact.fixtureB != NULL)
        {
            b2Body *bodyA = contact.fixtureA->GetBody();
            b2Body *bodyB = contact.fixtureB->GetBody();
            
            //if(bodyA != nil || bodyB != nil)
            {
                if(bodyA->GetType() == b2_staticBody && bodyB->GetType() == b2_dynamicBody)
                {
                    b2Fixture *fDef = bodyA->GetFixtureList();
                    b2Filter filter = fDef->GetFilterData();
                    
                    if(filter.categoryBits == kFilterCategoryNonSolidObjects)
                    {
                        b2Vec2 v = bodyA->GetPosition();
                        int x = v.x;
                        int y = ceil(v.y);
                        y = tiledMap.mapSize.height - y;
                        [collectibles removeTileAt:ccp(x,y)];
                        bodyA->DestroyFixture(fDef);
                        collectedCount++;
                        coinsLabel.string = [NSString stringWithFormat:@"coins: %d", collectedCount];
                        if(collectedCount == 6)
                        {
                            door.visible = YES;
                            
                            // go to next level
                        }
                        break;
                    }
                    else if (filter.categoryBits == kFilterCategoryHarmfulObjects)
                    {
                        //remove player fixture
                        bodyB->DestroyFixture(bodyB->GetFixtureList());
                        CCNode *parent = [self getChildByTag:kTagParentNode];
                        [parent removeChildByTag:kTagChildNode];
                        playerDead = true;
                        break;
                    }
                }
            }
        }
    }
    
}

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    if(!playerDead)
    {
        float THRESHOLD = 0.01f;
        player.body->SetAwake(true);
        b2Vec2 worldGravity = world->GetGravity();
        
        if(!player.isTouching){
            if(worldGravity.x == 0 && worldGravity.y < 0){
                float angle = atan2f(acceleration.x,acceleration.y);
                angle *= 180.0/3.14159;
                
                if(acceleration.y >= THRESHOLD)
                {
                    b2Vec2 impulse = b2Vec2(-0.7f,0.0f);
                    player.body->ApplyLinearImpulse(impulse, player.body->GetWorldCenter());
                }
                else if(acceleration.y <= -THRESHOLD)
                {
                    b2Vec2 impulse = b2Vec2(0.7f,0.0f);
                    player.body->ApplyLinearImpulse(impulse, player.body->GetWorldCenter());
                }
                
            }
            else if((worldGravity.x == 0 && worldGravity.y > 0)){
                
                float angle = atan2f(acceleration.x,acceleration.y);
                angle *= 180.0/3.14159;
                
                if(acceleration.y >= THRESHOLD)
                {
                    b2Vec2 impulse = b2Vec2(-0.7f,0.0f);
                    player.body->ApplyLinearImpulse(impulse, player.body->GetWorldCenter());
                }
                if(acceleration.y <= -THRESHOLD)
                {
                    b2Vec2 impulse = b2Vec2(0.7f,0.0f);
                    player.body->ApplyLinearImpulse(impulse, player.body->GetWorldCenter());
                }
            }
            else if(worldGravity.x < 0 && worldGravity.y == 0){
                
                if(acceleration.x >= THRESHOLD)
                {
                    b2Vec2 impulse = b2Vec2(0.0f,0.7f);
                    player.body->ApplyLinearImpulse(impulse, player.body->GetWorldCenter());
                }
                if(acceleration.x <= -THRESHOLD)
                {
                    b2Vec2 impulse = b2Vec2(0.0f,-0.7f);
                    player.body->ApplyLinearImpulse(impulse, player.body->GetWorldCenter());
                }
                
            }
            else if(worldGravity.x > 0 && worldGravity.y == 0){
                
                float angle = atan2f(acceleration.y,acceleration.x);
                angle *= 180.0/3.14159;
                if(acceleration.x >= THRESHOLD)
                {
                    b2Vec2 impulse = b2Vec2(0.0f,0.7f);
                    player.body->ApplyLinearImpulse(impulse, player.body->GetWorldCenter());
                }
                if(acceleration.x <= -THRESHOLD)
                {
                    b2Vec2 impulse = b2Vec2(0.0f,-0.7f);
                    player.body->ApplyLinearImpulse(impulse, player.body->GetWorldCenter());
                }
                
            }
        }
        else if(player.isTouching){
            float angle = atan2f(acceleration.y, acceleration.x);
            angle *= 180.0/3.14159;
            
            if (angle >= -45 && angle <= 45 ) {
                world->SetGravity(b2Vec2 (0, GRAVITY));
            }
            else if (angle > 45 && angle < 135) {
                world->SetGravity(b2Vec2 (-GRAVITY, 0));
            }
            else if (angle > -135 && angle < -45) {
                world->SetGravity(b2Vec2 (GRAVITY, 0));
            }
            else if ((angle < -135 && angle > -180)||(angle>135 && angle <=180)){
                world->SetGravity(b2Vec2 (0, -GRAVITY));
            }
        }
    }
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!playerDead)
    {
        for(NSSet* touch in touches){
            CGPoint location = [touch locationInView: [touch view]];
            location = [[CCDirector sharedDirector] convertToGL: location];                    
            player.isTouching = YES;            
            [self checkContactWithGroundAndJump];
        }
    }
}    

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
     player.isTouching = YES;
}

-(void) checkContactWithGroundAndJump
{
    std::vector<MyContact>::iterator position;
    for(position = contactListener->_contacts.begin();
        position != contactListener->_contacts.end(); ++position)
    {
        MyContact contact = *position;
        
        if(contact.fixtureA != NULL && contact.fixtureB != NULL)
        {
            b2Body *bodyA = contact.fixtureA->GetBody();
            b2Body *bodyB = contact.fixtureB->GetBody();
            
            if(bodyA->GetType() == b2_staticBody && bodyB->GetType() == b2_dynamicBody)
            {
                b2Fixture *fDef = bodyA->GetFixtureList();
                b2Filter filter = fDef->GetFilterData();
                
                if(filter.categoryBits == KFilterCategoryBits)
                {
                    b2Vec2 worldGravity;
                    worldGravity = world->GetGravity();
                    float gravityRemovalFactor = 1.0f;
                    
                    if (worldGravity.x == 0.0f && worldGravity.y > 0.0f)
                        player.body->ApplyLinearImpulse(b2Vec2 (0, -player.body->GetMass()*GRAVITY*gravityRemovalFactor), player.body->GetWorldCenter());
                    else if (worldGravity.x == 0.0f && worldGravity.y < 0.0f)
                        player.body->ApplyLinearImpulse(b2Vec2 (0, player.body->GetMass()*GRAVITY*gravityRemovalFactor), player.body->GetWorldCenter());
                    else if (worldGravity.x > 0.0f && worldGravity.y == 0.0f)
                        player.body->ApplyLinearImpulse(b2Vec2 (-player.body->GetMass()*GRAVITY*gravityRemovalFactor, 0), player.body->GetWorldCenter());
                    else if (worldGravity.x < 0.0f && worldGravity.y == 0.0f)
                        player.body->ApplyLinearImpulse(b2Vec2 (player.body->GetMass()*GRAVITY*gravityRemovalFactor, 0), player.body->GetWorldCenter());                    
                }
            }
        }
    }
}

@end
