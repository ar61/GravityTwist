//
//  GameLayer.mm
//  GravityTwist - An awesome game!! :P
//
//  Created by Abhinav Rathod on 6/4/13.
//  Copyright 526 2013. All rights reserved.
//

// Import the interfaces
#import "GameLayer.h"
#import "LevelManager.h"
#import "PauseScreen.h"

// Not included in "cocos2d.h"
#import "CCPhysicsSprite.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "ButtonData.h"
#import "GameObject.h"


@implementation GameLayer

static NSString *levelFileName;
BOOL movingForward;
int moveCount;
int spikeArrayIndex, platformArrayIndex;
CCSpriteBatchNode *parent;

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
		
        playerDead = false;
        worldBeingDestroyed = false;
        
        //Changes by Arpit - Start
        
        movingPlatformObjects = [[NSMutableArray alloc] initWithCapacity:20];
        movingSpikeObjects = [[NSMutableArray alloc] initWithCapacity:50];
        spikeArrayIndex = platformArrayIndex = moveCount = 0;
        movingForward = true;
        
        b2PolygonShape dynamicBox;
        dynamicBox.SetAsBox(.5f, .5f);
        
        spriteTextureName = @"Tilesheet.png";
        
        //CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithFile:spriteTextureName capacity:100];
        parent = [CCSpriteBatchNode batchNodeWithFile:spriteTextureName capacity:100];
        [self addChild:parent z:0 tag:kTagParentNode];

        //Changes by Arpit - End
        
        [self initLevel: levelFileName];
        
		self.touchEnabled = YES;
		self.accelerometerEnabled = YES;
		s = [CCDirector sharedDirector].winSize;
        
        contactListener = new MyContactListener();
        world->SetContactListener(contactListener); 
        
        player = [[GameObject alloc] initWithOptions:b2_dynamicBody withPosition: spawnPoint withRotation:YES withPolyShape:dynamicBox withDensity:1.0f withFriction:0.3f withRestitution:0.0f withTileIndex:b2Vec2(8,4) withTileLength:b2Vec2(1,1) withWorld:world withBatchNode:parent withZLocation:0];
        
        
        CCTMXObjectGroup *boxes = [tiledMap objectGroupNamed:@"boxes"];
        
        boxGameObjects = [[NSMutableArray alloc] initWithCapacity:[[boxes objects] count]];

        for (id box in [boxes objects]) {
            int boxx = [box[@"x"] intValue];
            int boxy = [box[@"y"] intValue];
            //int boxw = [box[@"width"] intValue];
            //int boxh = [box[@"height"] intValue];
            b2PolygonShape boxDynamicBox;
            boxDynamicBox.SetAsBox(.5f, .5f);
            
            GameObject *gameBox = [[GameObject alloc] initWithOptions:b2_dynamicBody withPosition:CGPointMake(boxx, boxy) withRotation:YES withPolyShape:boxDynamicBox withDensity:1.0f withFriction:0.3f withRestitution:0.0f withTileIndex:b2Vec2(1, 1) withTileLength:b2Vec2(1, 1) withWorld:world withBatchNode:parent withZLocation:0];
            
            [boxGameObjects addObject:gameBox];
        }
        
        // make buttons
        NSMutableArray *buttons = [[tiledMap objectGroupNamed:@"buttons"] objects];
        
        doorCollisions = [NSMutableDictionary dictionaryWithCapacity:[buttons count]];
        NSMutableArray *doorCollisionObjects = [[tiledMap objectGroupNamed:@"doorCollisions"] objects];
        
        for (id button in buttons) {
            b2Body* buttonBody = [self createCollisionBody:button bits:6];
            
            // add door collision bodies
            NSMutableArray *doorColBodies = [[NSMutableArray alloc] initWithCapacity:5];
            [doorCollisions setValue:doorColBodies forKey:button[@"doorLayer"]];
            
            for (id doorCol in doorCollisionObjects) {
                if ([doorCol[@"doorLayer"] isEqualToString:button[@"doorLayer"]]) {
                    [doorColBodies addObject:[NSValue valueWithPointer:[self createCollisionBody:doorCol bits:1]]];
                }
            }
            ButtonData *bd = [[ButtonData alloc] initWithBodies:doorColBodies withDoorLayer:[tiledMap layerNamed:button[@"doorLayer"]]];
            buttonBody->GetFixtureList()->SetUserData(bd);
            
        }
        
        [doorCollisions retain];
        [self addChild:tiledMap z:-10];
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
    
    meta = [tiledMap layerNamed:@"Meta"];
    meta.visible = NO;
    
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

// Add new method
- (CGPoint)tileCoordForPosition:(CGPoint)position {
    int x = position.x / tiledMap.tileSize.width;
    int y = ((tiledMap.mapSize.height * tiledMap.tileSize.height) - position.y) / tiledMap.tileSize.height;
    return ccp(x, y);
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

-(b2Body*)createCollisionBody: (NSDictionary*)object bits: (int)bits {
    CGPoint p = ccp([object[@"x"] integerValue],[object[@"y"] integerValue]);
    CGPoint size = ccp([object[@"width"] integerValue],[object[@"height"] integerValue]);
    
    CGPoint _point = ccp(p.x+size.x/2, p.y+size.y/2);
    CGPoint _size = ccp(size.x,size.y);
    
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
    
    fDef.filter.categoryBits = bits;
    
    b->CreateFixture(&fDef);
    
    return b;
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
        movingPlatform = [[GameObject alloc] init];
        [self addNewSpriteAtPosition:_point withSize:size withTilePosition:b2Vec2(10,4) withObject:movingPlatform];
        [movingPlatformObjects insertObject:movingPlatform atIndex:platformArrayIndex++];
        [movingPlatform release];
    }
    else if (isMovingSpikes) {
        b2Vec2 tilePosition;
        
        if ([[object valueForKey:@"topSpike"] isEqual:@"true"])
            tilePosition = b2Vec2(11,1);
        else if ([[object valueForKey:@"leftSpike"] isEqual:@"true"])
            tilePosition = b2Vec2(9,3);
        else if ([[object valueForKey:@"bottomSpike"] isEqual:@"true"])
            tilePosition = b2Vec2(10,2);
        else if ([[object valueForKey:@"rightSpike"] isEqual:@"true"])
            tilePosition = b2Vec2(12,0);
        
        movingSpike = [[GameObject alloc] init];
        [self addNewSpriteAtPosition:_point withSize:size withTilePosition:tilePosition withObject:movingSpike];
        
        b2Filter filter;
        for (b2Fixture *f = movingSpike.body->GetFixtureList(); f; f=f->GetNext()) {
            filter = f->GetFilterData();
            filter.categoryBits = kFilterCategoryHarmfulObjects;
            f->SetFilterData(filter);
        }
        [movingSpikeObjects insertObject:movingSpike atIndex:spikeArrayIndex++];
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
            // for spikes
            fDef.filter.categoryBits = kFilterCategoryHarmfulObjects;
        }
        else if(type == 5)
        {
            //for exit door
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

-(void) addNewSpriteAtPosition:(CGPoint)position withSize:(CGPoint)size withTilePosition:(b2Vec2)tilePosition withObject:(GameObject*)object
{
    b2PolygonShape dynamicBox;
    dynamicBox.SetAsBox(size.x/2.0/PTM_RATIO, size.y/2.0/PTM_RATIO);
    //CCNode *parent1 = [self getChildByTag:kTagParentNode];
    //object.spriteTexture = player.spriteTexture;
    
    object = [object initWithOptions:b2_kinematicBody withPosition: position withRotation:YES withPolyShape:dynamicBox withDensity:1.0f
                        withFriction:1.0f withRestitution:0.0f withTileIndex:tilePosition withTileLength:b2Vec2(size.x/PTM_RATIO, size.y/PTM_RATIO)
                           withWorld:world withBatchNode:parent withZLocation:1];
}

-(void) dealloc
{
	delete world;	
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
    [player release];
    [movingPlatform release];
    [movingSpike release];
    [movingPlatformObjects release];
    [movingSpikeObjects release];
    
	[super dealloc];
}	

-(void) initPhysics
{	
	b2Vec2 gravity;
	gravity.Set(0.0f, -GRAVITY);
    
	world = new b2World(gravity);	
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(false);
	
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
	/*[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	world->DrawDebugData();	
	
	kmGLPopMatrix();*/
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
        // Before the step, we disable/delete objects that have been marked
        for (id l in [doorCollisions allValues]) {
            for (NSValue* pb in l) {
                b2Body* b = (b2Body*)[pb pointerValue];
                //NSLog(@"%@\n",(NSNumber*)b->GetUserData());
                b->SetActive(![(NSNumber*)b->GetUserData() boolValue]);
            }
        }
        for (id box in boxGameObjects) {
            if ([(NSNumber*)[box body]->GetUserData() boolValue]) {
                [box body]->SetType(b2_staticBody);
            }
        }
        
        //to be worked on later by Abhinav
        /*CGPoint tileCoord = [self tileCoordForPosition:player.position];
        int tileGid = [meta tileGIDAt:tileCoord];
        if (tileGid) {
            NSDictionary *properties = [tiledMap propertiesForGID:tileGid];
            if (properties) {
                NSString *collision = properties[@"Collectible"];
                if (collision && [collision isEqualToString:@"true"]) {
                    [meta removeTileAt:tileCoord];
                    [collectibles removeTileAt:tileCoord];
                    collectedCount++;
                    coinsLabel.string = [NSString stringWithFormat:@"coins: %d", collectedCount];
                    if(collectedCount == 5)
                    {
                        door.visible = YES;
                        [self createCollisionTiles: exitObject withType:5];
                    }
                }
            }
        }*/
        
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
                            [[CCDirector sharedDirector] replaceScene:[LevelManager scene]];
                        }
                    }
                }
            }
        }
        
        [self movePlatforms:0.1];
    }
}

-(void) movePlatforms:(ccTime)dt {
    if (movingPlatformObjects != NULL || movingSpikeObjects != NULL) {
        if (movingForward)
            moveCount++;
        else
            moveCount--;
        
        if (movingForward) {
            for (movingPlatform in movingPlatformObjects)
                movingPlatform.body->SetLinearVelocity(b2Vec2(1,0));
            
            for (movingSpike in movingSpikeObjects)
                movingSpike.body->SetLinearVelocity(b2Vec2(1,0));
            
            if (moveCount >= 60)
                movingForward = false;
        }
        else {
            for (movingPlatform in movingPlatformObjects)
                movingPlatform.body->SetLinearVelocity(b2Vec2(-1,0));
            
            for (movingSpike in movingSpikeObjects)
                movingSpike.body->SetLinearVelocity(b2Vec2(-1,0));
            
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
        
        //if([self isPlayerOnGround]){
            
            if(worldGravity.x == 0 && worldGravity.y < 0){
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
            
            else if((worldGravity.x == 0 && worldGravity.y > 0)){
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
            
            else if(worldGravity.x > 0 && worldGravity.y == 0) {
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
        //}
    } 
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!playerDead)
    {
        NSSet *allTouches = [event allTouches];
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        player.isTouching = YES;
        firstTouch = location;
    }
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!playerDead)
    {
        NSSet *allTouches = [event allTouches];
        
        int numberOfFingersTouching = [allTouches count];
        
        
        
        UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
        
        CGPoint location = [touch locationInView:[touch view]];
        
        location = [[CCDirector sharedDirector] convertToGL:location];
        player.isTouching = NO;
        lastTouch = location;
        
        if(numberOfFingersTouching == 2)
        {
            CCLOG(@"Two finger touch detected");
            [[CCDirector sharedDirector] pushScene:[PauseScreen scene]];
            
        }
        else
        {
            float swipeLength = ccpDistance(firstTouch, lastTouch);
            float xSwipeLength = fabsf(firstTouch.x - lastTouch.x);
            float ySwipeLength = fabsf(firstTouch.y - lastTouch.y);
            //CCLOG(@"Swipe Length: %f", swipeLength);
            
            if(swipeLength > 10)
            {                
                if(xSwipeLength > ySwipeLength)
                {
                    //CCLOG(@"XSwipeLength: %f", xSwipeLength);
                    if (firstTouch.x > lastTouch.x)
                    {
                        world->SetGravity(b2Vec2 (-GRAVITY, 0));
                        player.body->ApplyLinearImpulse(b2Vec2 (-player.body->GetMass()*GRAVITY/4,0), player.body->GetWorldCenter());
                    }
                    else
                    {
                        world->SetGravity(b2Vec2 (GRAVITY, 0));
                        player.body->ApplyLinearImpulse(b2Vec2 (player.body->GetMass()*GRAVITY/4,0), player.body->GetWorldCenter()); 
                    }
                }
                else if(ySwipeLength > xSwipeLength)
                {
                    //CCLOG(@"YSwipeLength: %f", ySwipeLength);
                    if (firstTouch.y > lastTouch.y) 
                    {
                        world->SetGravity(b2Vec2 (0, -GRAVITY));
                        player.body->ApplyLinearImpulse(b2Vec2 (0,-player.body->GetMass()*GRAVITY/4), player.body->GetWorldCenter());
                    }
                    
                    else  
                    {
                        world->SetGravity(b2Vec2 (0, GRAVITY));
                        player.body->ApplyLinearImpulse(b2Vec2 (0,player.body->GetMass()*GRAVITY/4), player.body->GetWorldCenter());   
                    }  
                }  
            }
        }  
    }
}





-(BOOL) isPlayerOnGround
{
    std::vector<MyContact>::iterator position;
    for(position = contactListener->_contacts.begin(); position != contactListener->_contacts.end(); ++position)   
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
                
                if(filter.categoryBits == KFilterCategoryBits || filter.categoryBits == kFilterCategoryHarmfulObjects)
                {
                    return TRUE;
                }
                else
                {
                    return FALSE;
                }
            }
            
        }
        
    }
    
    return FALSE;
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
