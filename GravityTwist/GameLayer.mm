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

static NSString *levelFileName;

@implementation GameLayer

BOOL movingForward;
int moveCount;
int indexPos;

+(CCScene *) scene: (NSString*) layerName
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
    levelFileName = layerName;
    
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
        
		// Changes by Arpit Start
        array = [[NSMutableArray alloc] initWithCapacity:20];
        indexPos = 0;
        movingForward = true;
        moveCount = 0;
        
        //player = [[GameObject alloc] init];
        spriteTextureName = @"Tilesheet.png";
        //CCSpriteBatchNode *parent = [player getSpriteBatchNodeObject:spriteTextureName];
        CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithFile:spriteTextureName capacity:100];
        [self addChild:parent z:0 tag:kTagParentNode];
        // Changes by Arpit End
        
        playerDead = false;
        worldBeingDestroyed = false;
        [self initLevel: levelFileName];
        
		self.touchEnabled = YES;
		self.accelerometerEnabled = YES;
		s = [CCDirector sharedDirector].winSize;
        
        contactListener = new MyContactListener();
        world->SetContactListener(contactListener);
        
        b2PolygonShape dynamicBox;        
        dynamicBox.SetAsBox(.5f, .5f);
        //CCNode *parent1 = [self getChildByTag:kTagParentNode];
        
        player = [[GameObject alloc] initWithOptions:b2_dynamicBody withPosition: spawnPoint withFixedRotation:YES withPolyShape:dynamicBox withDensity:1.0f withFriction:0.3f withRestitution:0.0f withTileIndex:b2Vec2(1,1) withTileLength:b2Vec2(1,1) withWorld:world withBatchNode:parent withZLocation:0];
        
                
        CCTMXObjectGroup *boxes = [tiledMap objectGroupNamed:@"boxes"];
        //CCSpriteBatchNode *boxParent = [platform getSpriteBatchNodeObject:spriteTextureName];
        for (id box in [boxes objects]) {
            int boxx = [box[@"x"] intValue];
            int boxy = [box[@"y"] intValue];
            //int boxw = [box[@"width"] intValue];
            //int boxh = [box[@"height"] intValue];
            b2PolygonShape boxDynamicBox;
            boxDynamicBox.SetAsBox(.5f, .5f);
            
            GameObject *gameBox = [[GameObject alloc] init];
            //gameBox = [gameBox initWithOptions:b2_dynamicBody withPosition:CGPointMake(boxx, boxy) withFixedRotation:YES withPolyShape:boxDynamicBox withDensity:1.0f withFriction:0.3f withRestitution:0.0f withTileIndex:b2Vec2(1, 1) withTileLength:b2Vec2(1, 1) withWorld:world withParent:[self getChildByTag:kTagParentNode] withZLocation:0];
        }
        
        [self addChild:tiledMap z:-1];
		[self scheduleUpdate];
	}
	return self;
}

-(void)initLevel: (NSString*) fileName
{
    [self initPhysics];
    
    tiledMap = [CCTMXTiledMap tiledMapWithTMXFile:fileName];
    
    tile = [tiledMap layerNamed:@"tiles"];
    
    door = [tiledMap layerNamed:@"Exit"];
    
    objects = [tiledMap objectGroupNamed:@"objects"];
    NSAssert(objects != nil, @"Tile map doesnt have an objects layer defined");
    
    NSDictionary *spawnPointInObject = [objects objectNamed:@"SpawnPoint"];
    spawnPoint.x = [spawnPointInObject[@"x"] integerValue];
    spawnPoint.y = [spawnPointInObject[@"y"] integerValue];
        
    exitObject = [objects objectNamed:@"ExitPoint"];
    
    if([levelFileName isEqual:@"LevelOne.tmx"])
    {
        door.visible = YES;
        [self createCollisionTiles: exitObject withType:5];
    }
    else
    {
        door.visible = NO;
    }
    
    collisions = [tiledMap layerNamed:@"collisions"];
    collisions.visible = NO;
    
    collisionObjects = [tiledMap objectGroupNamed:@"collisions"];
    
    collectibleObjects = [tiledMap objectGroupNamed:@"collectibles"];
    
    collectibles = [tiledMap layerNamed:@"collectibles"];
    collectibles.tag = 1;
    collectedCount = 0;

    
    [self createPlatformObjects: collisionObjects withType:1];
    [self createPlatformObjects: collectibleObjects withType:2];    
}

-(void)createPlatformObjects: (CCTMXObjectGroup*) layer withType:(int) type
{
    NSMutableDictionary *objPoints;
    
    BOOL spikes;
    
    for(objPoints in [layer objects])
    {        
        if([objPoints valueForKey:@"kill"] == NULL)
        {
            spikes = false;
        }
        else
        {
            NSString *named = [NSString stringWithFormat:@"%@", [objPoints objectForKey:@"kill"]];
            spikes = [named isEqual:@"true"];
        }
        
        if(!spikes)
        {
            [self createCollisionTiles: objPoints withType: type];
        }
        else
        {
            [self createCollisionTiles: objPoints withType: 4];
        }
    }
}

-(void)createCollisionTiles: (NSDictionary*)object withType: (int) type
{
    CGPoint p = ccp([object[@"x"] integerValue],[object[@"y"] integerValue]);
    CGPoint size = ccp([object[@"width"] integerValue],[object[@"height"] integerValue]);
    
    CGPoint _point = ccp(p.x+size.x/2, p.y+size.y/2);
    CGPoint _size = ccp(size.x,size.y);
    
    bool isMovingPlatform = [[object valueForKey:@"name"] isEqual: @"movingPlatform"];
    bool isMovingSpikes = [[object valueForKey:@"name"] isEqual: @"movingSpikes"];
    
    if(isMovingPlatform) {
        platform = [[GameObject alloc] init];
        [self addNewSpriteAtPosition:_point withSize:size withObject:platform];
        
    }
    else if (isMovingSpikes) {
        movingSpike = [[GameObject alloc] init];
        [self addNewSpriteAtPosition:_point withSize:size withObject:movingSpike];
        
        b2Filter filter;
        for (b2Fixture *f = movingSpike.body->GetFixtureList(); f; f=f->GetNext()) {
            filter = f->GetFilterData();
            filter.categoryBits = kFilterCategoryHarmfulObjects;
            f->SetFilterData(filter);
        }
        [array insertObject:movingSpike atIndex:indexPos++];
        [movingSpike release];
    }
    else {
        b2BodyDef bDef;
        bDef.type = b2_staticBody;
        bDef.position.Set(_point.x/PTM_RATIO, _point.y/PTM_RATIO);
        b2Body *b = world->CreateBody(&bDef);
        
        b2PolygonShape shape;
        shape.SetAsBox(_size.x/2.0/PTM_RATIO, _size.y/2.0/PTM_RATIO);
        
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
        else if(type == 5)
        {
            fDef.filter.categoryBits = kFilterCategoryExit;
        }
        else
        {
            //for remaining objects
            fDef.filter.categoryBits = KFilterCategoryBits;
        }
        b->CreateFixture(&fDef);
    }
}
/*
-(void) addNewSpriteAtPosition:(CGPoint)position withSize:(CGPoint)size withObject:(GameObject*)object
{
    b2PolygonShape dynamicBox;
    dynamicBox.SetAsBox(size.x/2.0/PTM_RATIO, size.y/2.0/PTM_RATIO);;
    
    CCNode *parent1 = [self getChildByTag:kTagParentNode];
    object.spriteTexture = player.spriteTexture;
    printf("adding sprite\n");
    object = [object initWithOptions:b2_kinematicBody withPosition: position withFixedRotation:YES withPolyShape:dynamicBox withDensity:1.0f withFriction:1.0f withRestitution:0.0f withTileIndex:b2Vec2(2,0) withTileLength:b2Vec2(size.x/PTM_RATIO, size.y/PTM_RATIO) withWorld:world withParent:parent1 withZLocation:1];
}
*/
-(void) dealloc
{
	delete world;	
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
    [player dealloc];
    [platform dealloc];
    [movingSpike release];
    [array release];
    
	[super dealloc];
}	

-(void) initPhysics
{	
	b2Vec2 gravity;
	gravity.Set(0.0f, -GRAVITY);
    
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
    
    if(!worldBeingDestroyed)
    {
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
                    if((bodyA->GetType() == b2_staticBody || bodyA->GetType() == b2_kinematicBody) && bodyB->GetType() == b2_dynamicBody)
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
                            if(collectedCount == 5)
                            {
                                door.visible = YES;
                                [self createCollisionTiles: exitObject withType:5];                            
                            }
                            break;
                        }
                        else if (filter.categoryBits == kFilterCategoryHarmfulObjects)
                        {
                            [[CCDirector sharedDirector] replaceScene: [GameLayer scene: levelFileName]];
                            //remove player fixture
                            /*bodyB->DestroyFixture(bodyB->GetFixtureList());
                            CCNode *parent = [self getChildByTag:kTagParentNode];
                            [parent removeChildByTag:kTagChildNode];
                            playerDead = true;*/
                            break;
                        }
                        else if (filter.categoryBits == kFilterCategoryExit)
                        {
                            int i = 1;
                            
                            if([levelFileName isEqual: @"LevelOne.tmx"])
                                [[CCDirector sharedDirector] replaceScene: [GameLayer scene: @"LevelTwo.tmx"]];                            
                            else if([levelFileName isEqual: @"LevelTwo.tmx"])
                                [[CCDirector sharedDirector] replaceScene: [GameLayer scene: @"LevelThree.tmx"]];
                        }
                    }
                }
            }
        }
        
        [self movePlatforms:0.1];
    }    
}

-(void) movePlatforms:(ccTime)dt {
    if (platform != NULL) {
        if (movingForward)
            moveCount++;
        else
            moveCount--;
        
        if (movingForward) {
            platform.body->SetLinearVelocity(b2Vec2(1,0));
            for (movingSpike in array) {
                movingSpike.body->SetLinearVelocity(b2Vec2(1,0));
            }
            
            if (moveCount >= 60)
                movingForward = false;
        }
        else {
            platform.body->SetLinearVelocity(b2Vec2(-1,0));
            for (movingSpike in array) {
                movingSpike.body->SetLinearVelocity(b2Vec2(-1,0));
            }
            if (moveCount <= 0)
                movingForward = true;
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
     player.isTouching = NO;
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
            
            if((bodyA->GetType() == b2_staticBody || bodyA->GetType() == b2_kinematicBody) && bodyB->GetType() == b2_dynamicBody)
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
