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
    b2Body *body;
    CGSize s;
    BOOL isPlayerInAir;
    BOOL isPlayerOnGround;
    
}
-(void) initPhysics;

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
	if( (self = [super init])) {
		
        isPlayerOnGround = true;
        tiledMap = [CCTMXTiledMap tiledMapWithTMXFile:@"One.tmx"];
		
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
		
        //initialize collisions
        //[self createFixtures: collisions type:1];
        [self createPlatformObjects: collisionObjects withType:1];
        // initialize collectibles
        //[self createFixtures: collectibles type:2];
        [self createPlatformObjects: collectibleObjects withType:2];
        
        contactListener = new MyContactListener();
        world->SetContactListener(contactListener);
        
		//Set up sprite
		// Use batch node. Faster
		CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:100];
		spriteTexture_ = [parent texture];
		[self addChild:parent z:0 tag:kTagParentNode];
				
        // Define the dynamic body.
        //Set up a 1m squared box in the physics world
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.position.Set(s.width/PTM_RATIO, s.height/PTM_RATIO);
        bodyDef.fixedRotation = YES;
        
        body = world->CreateBody(&bodyDef);
        
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
        [player setPosition: ccp(x,y)];
        //world->SetGravity(b2Vec2(GRAVITY,0));
        
		//adding buttons
        CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"Icon-Small@2x.png" selectedImage:@"Icon-Small@2x.png" disabledImage:@"Icon-Small@2x.png" target:self selector:@selector(moveLeft)];
        CCMenu *menu = [CCMenu menuWithItems:item1,nil];
        menu.position = ccp(50,40);
        [self addChild:menu];
        
        CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"Icon-Small@2x.png" selectedImage:@"Icon-Small@2x.png" disabledImage:@"Icon-Small@2x.png" target:self selector:@selector(moveRight)];
        CCMenu *menu2 = [CCMenu menuWithItems:item2,nil];
        menu2.position = ccp(120,40);
        [self addChild:menu2];
        
        coinsLabel = [CCLabelTTF labelWithString:@"coins: 0" fontName:@"Arial" fontSize:20];
        coinsLabel.position = ccp(s.width * 0.85,s.height * 0.9);
		
        [coinsLabel setColor: ccBLACK];
        
        [self addChild:coinsLabel z:1];
        [self addChild:tiledMap z:-1];
		[self schedule:@selector(update:)];
	}
	return self;
}

-(void)createPlatformObjects: (CCTMXObjectGroup*) layer withType:(int) type
{
    NSMutableDictionary *objPoints;
    
    int x,y,w,h;
    for(objPoints in [layer objects])
    {
        x = [[objPoints valueForKey:@"x"] intValue];
        y = [[objPoints valueForKey:@"y"] intValue];
        w = [[objPoints valueForKey:@"width"] intValue];
        h = [[objPoints valueForKey:@"height"] intValue];
        
        CGPoint _point = ccp(x+w/2, y+h/2);
        CGPoint _size = ccp(w,h);
        
        [self createCollisionTiles: _point withSize: _size withType: type];
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
        fDef.filter.categoryBits = kFilterCategoryNonSolidObjects;
    }
    else
    {
        fDef.filter.categoryBits = KFilterCategoryBits;
    }
    b->CreateFixture(&fDef);
}

-(void)createFixtures: (CCTMXLayer*) layer type:(int) ty
{
    CGSize size = [layer layerSize];
    for(int i=0; i<size.width; i++)
    {
        for(int j=0; j<size.height; j++)
        {
            CCSprite *t = [layer tileAt: ccp(i,j)];
            if(t != nil)
            {
                [self createRectangleFixtures: layer x:i y:j w:1.0f h:1.0f ty:ty];
            }
        }
    }
}

-(void)createRectangleFixtures: (CCTMXLayer*) layer x:(int)x y:(int)y w:(float)width h:(float)height ty:(int) t
{
    CGPoint p = [layer positionAt: ccp(x,y)];
    CGSize size = [tiledMap tileSize];
    
    b2BodyDef bDef;
    bDef.type = b2_staticBody;
    bDef.position.Set((p.x + size.width/2.0f)/PTM_RATIO, (p.y + size.height/2.0f)/PTM_RATIO );
    b2Body *b = world->CreateBody(&bDef);
    
    b2PolygonShape shape;
    shape.SetAsBox(size.width/PTM_RATIO * 0.5 * width, size.height/PTM_RATIO * 0.5 * height);
    
    b2FixtureDef fDef;
    fDef.shape = &shape;
    fDef.density = 1.0f;
    fDef.friction = 0.2f;
    fDef.restitution = 0.0f;
    if(t == 2)
    {
        fDef.filter.categoryBits = kFilterCategoryNonSolidObjects;
    }
    else
    {
        fDef.filter.categoryBits = KFilterCategoryBits;
    }
    
    fDef.filter.maskBits = 0xffff;
    b->CreateFixture(&fDef);
}

- (CGPoint)tileCoordForPosition:(CGPoint)position {
    int x = position.x / tiledMap.tileSize.width;
    int y = ((tiledMap.mapSize.height * tiledMap.tileSize.height) - position.y) / tiledMap.tileSize.height;
    return ccp(x, y);
}

-(void)moveLeft
{
    /*
    if((player.position.x - 50) > 0)
    {
        [player runAction:[CCMoveBy actionWithDuration:.3 position:ccp(-50,0)]];
    }
    */
    
    body->ApplyForceToCenter(b2Vec2(-50,0));
    
    
    
}

-(void)moveRight
{
    /*
    if((player.position.x + 50) < s.width)
    {
        [player runAction:[CCMoveBy actionWithDuration:.3 position:ccp(50,0)]];
    }
    */
    body->ApplyForceToCenter(b2Vec2(50,0));
    
}


-(void) dealloc
{
	delete world;	
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
    
    delete contactListener;
	
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
                    if(collectedCount == 5)
                    {
                        door.visible = YES;
                        
                        //[self createFixtures:door type: 1];
                    }
                    break;
                }
            }
        }
    }
        
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
    b2Vec2 pv;
    if(dirOfTilt == 0 || dirOfTilt == 2)
    {
        pv.x = 0;
        pv.y = playerVelocity.y;
    }
    else
    {
        pv.x = playerVelocity.x;
        pv.y = 0;
    }
    b2Vec2 dir;
    dir.x = pos.x;
    dir.y = pos.y;
    //body->ApplyForceToCenter(b2Vec2(playerVelocity.x,0));
    //body->ApplyForce(pv, dir);
    //player.position = pos;

}

-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    float THRESHOLD = 0.01f;
    //float deceleration = 0.4f;
    //float sensitivity = 6.0f;
    body->SetAwake(true);
    b2Vec2 worldGravity = world->GetGravity();
   
    if(isPlayerOnGround && !isPlayerInAir){
    if(worldGravity.x == 0 && worldGravity.y < 0){
        float angle = atan2f(acceleration.x,acceleration.y);
        angle *= 180.0/3.14159;
        NSLog(@"Rotation angle: %f", angle);
        //NSLog(@"Y-Acceleration: %f",acceleration.y);
        
        if(acceleration.y >= THRESHOLD)
        {
            b2Vec2 impulse = b2Vec2(-0.7f,0.0f);
            body->ApplyLinearImpulse(impulse, body->GetWorldCenter());
        }
        else if(acceleration.y <= -THRESHOLD)
        {
            b2Vec2 impulse = b2Vec2(0.7f,0.0f);
            body->ApplyLinearImpulse(impulse, body->GetWorldCenter());
        }
        
    }
    else if((worldGravity.x == 0 && worldGravity.y > 0)){
        
        float angle = atan2f(acceleration.x,acceleration.y);
        angle *= 180.0/3.14159;
        NSLog(@"Rotation angle: %f", angle);
        //NSLog(@"Y-Acceleration: %f",acceleration.y);
        
        if(acceleration.y >= THRESHOLD)
        {
          b2Vec2 impulse = b2Vec2(-0.7f,0.0f);
          body->ApplyLinearImpulse(impulse, body->GetWorldCenter());
        }
        if(acceleration.y <= -THRESHOLD)
        {
          b2Vec2 impulse = b2Vec2(0.7f,0.0f);
          body->ApplyLinearImpulse(impulse, body->GetWorldCenter());
        }
    }
    else if(worldGravity.x < 0 && worldGravity.y == 0){
        
        if(acceleration.x >= THRESHOLD)
        {
            b2Vec2 impulse = b2Vec2(0.0f,0.7f);
            body->ApplyLinearImpulse(impulse, body->GetWorldCenter());
        }
        if(acceleration.x <= -THRESHOLD)
        {
            b2Vec2 impulse = b2Vec2(0.0f,-0.7f);
            body->ApplyLinearImpulse(impulse, body->GetWorldCenter());
        }
        
    }
    else if(worldGravity.x > 0 && worldGravity.y == 0){
        
        float angle = atan2f(acceleration.y,acceleration.x);
        angle *= 180.0/3.14159;
        NSLog(@"Rotation angle: %f", angle);
        //NSLog(@"Y-Acceleration: %f",acceleration.y);

        if(acceleration.x >= THRESHOLD)
        {
            b2Vec2 impulse = b2Vec2(0.0f,0.7f);
            body->ApplyLinearImpulse(impulse, body->GetWorldCenter());
        }
        if(acceleration.x <= -THRESHOLD)
        {
            b2Vec2 impulse = b2Vec2(0.0f,-0.7f);
            body->ApplyLinearImpulse(impulse, body->GetWorldCenter());
        }
        
    }
    }
    else if(isPlayerInAir && !isPlayerOnGround){
    if(/*acceleration.x >= THRESHOLD || acceleration.x <= -THRESHOLD ||
       acceleration.y >= THRESHOLD || acceleration.y <= -THRESHOLD*/1)
    {
        
        
        /*if(worldGravity.x == 0 && worldGravity.y < 0)
        {
            float angle = atan2f(acceleration.x,acceleration.y);
            angle = CC_RADIANS_TO_DEGREES(angle);
            NSLog(@"Rotation angle: %f", angle);
            if(angle <= -100)
            {
                body->ApplyLinearImpulse(b2Vec2 (body->GetMass()*GRAVITY,0), body->GetWorldCenter());
                world->SetGravity(b2Vec2(GRAVITY,0));
            }
            if(angle >= -60)
            {
                body->ApplyLinearImpulse(b2Vec2 (-body->GetMass()*GRAVITY,0), body->GetWorldCenter());
                world->SetGravity(b2Vec2(-GRAVITY,0));
            }
        }
        if(worldGravity.x == 0 && worldGravity.y > 0)
        {
            float angle = atan2f(acceleration.x,acceleration.y);
            angle = CC_RADIANS_TO_DEGREES(angle);
            NSLog(@"Rotation angle: %f", angle);
            if(angle >= 100)
            {
                body->ApplyLinearImpulse(b2Vec2 (body->GetMass()*GRAVITY,0), body->GetWorldCenter());
                world->SetGravity(b2Vec2(GRAVITY,0));
            }
            if(angle <= 60)
            {
                body->ApplyLinearImpulse(b2Vec2 (-body->GetMass()*GRAVITY,0), body->GetWorldCenter());
                world->SetGravity(b2Vec2(-GRAVITY,0));
            }

        }
        if(worldGravity.x > 0 && worldGravity.y == 0)
        {
            float angle = atan2f(acceleration.y,acceleration.x);
            angle *= 180.0/3.14159;
            angle = CC_RADIANS_TO_DEGREES(angle);
            NSLog(@"Rotation angle: %f", angle);
           if(angle <= -115)
            {
                body->ApplyLinearImpulse(b2Vec2 (0,-body->GetMass()*GRAVITY), body->GetWorldCenter());
                world->SetGravity(b2Vec2(0,-GRAVITY));
            }
            if(angle >= -60)
            {
                body->ApplyLinearImpulse(b2Vec2 (0,body->GetMass()*GRAVITY), body->GetWorldCenter());
                world->SetGravity(b2Vec2(0,GRAVITY));
            }

        }
       if(worldGravity.x < 0 && worldGravity.y == 0)
        {
            float angle = atan2f(acceleration.y,acceleration.x);
            angle *= 180.0/3.14159;
            angle = CC_RADIANS_TO_DEGREES(angle);
            NSLog(@"Rotation angle: %f", angle);
            if(angle >= 115)
            {
                body->ApplyLinearImpulse(b2Vec2 (0,-body->GetMass()*GRAVITY), body->GetWorldCenter());
                world->SetGravity(b2Vec2(0,-GRAVITY));
            }
            if(angle >= 60)
            {
                body->ApplyLinearImpulse(b2Vec2 (0,body->GetMass()*GRAVITY), body->GetWorldCenter());
                world->SetGravity(b2Vec2(0,GRAVITY));
            }

        }*/
        float angle = atan2f(acceleration.y, acceleration.x);
        angle *= 180.0/3.14159;
        
        if (angle >= -45 && angle <= 45 ) {
            world->SetGravity(b2Vec2 (0, GRAVITY));
            dirOfTilt = 3;
        }
        else if (angle > 45 && angle < 135) {
            world->SetGravity(b2Vec2 (-GRAVITY, 0));
            dirOfTilt = 0;
        }
        else if (angle > -135 && angle < -45) {
            world->SetGravity(b2Vec2 (GRAVITY, 0));
            dirOfTilt = 2;
        }
        else if ((angle < -135 && angle > -180)||(angle>135 && angle <=180)){
            world->SetGravity(b2Vec2 (0, -GRAVITY));
            dirOfTilt = 1;
        }
    }
    else
    {
        //playerVelocity.x = playerVelocity.x * deceleration + acceleration.x * sensitivity;
        //playerVelocity.y = playerVelocity.y * deceleration + acceleration.y * sensitivity;
    }
    }
}
-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    b2Vec2 worldGravity;
    float gravityRemovalFactor = 1.0f;
    for(NSSet* touch in touches){
        CGPoint location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL: location];
        
        worldGravity = world->GetGravity();
        b2Vec2 playerVel = body->GetLinearVelocity();
        
        //if (playerVel.y >= -1.0f && playerVel.y <= 0.1f ) {
            isPlayerInAir = YES;
            isPlayerOnGround = NO;
            if (worldGravity.x == 0.0f && worldGravity.y > 0.0f)
                body->ApplyLinearImpulse(b2Vec2 (0, -body->GetMass()*GRAVITY*gravityRemovalFactor), body->GetWorldCenter());
           // body->ApplyForceToCenter(b2Vec2 (0, -body->GetMass()*GRAVITY*gravityRemovalFactor));
            else if (worldGravity.x == 0.0f && worldGravity.y < 0.0f)
                body->ApplyLinearImpulse(b2Vec2 (0, body->GetMass()*GRAVITY*gravityRemovalFactor), body->GetWorldCenter());
           // body->ApplyForceToCenter(b2Vec2 (0,body->GetMass()*GRAVITY*gravityRemovalFactor));
            else if (worldGravity.x > 0.0f && worldGravity.y == 0.0f)
                body->ApplyLinearImpulse(b2Vec2 (-body->GetMass()*GRAVITY*gravityRemovalFactor, 0), body->GetWorldCenter());
          //  body->ApplyForceToCenter(b2Vec2 (-body->GetMass()*GRAVITY*gravityRemovalFactor, 0));
            else if (worldGravity.x < 0.0f && worldGravity.y == 0.0f)
                body->ApplyLinearImpulse(b2Vec2 (body->GetMass()*GRAVITY*gravityRemovalFactor, 0), body->GetWorldCenter());
           // body->ApplyForceToCenter(b2Vec2 (body->GetMass()*GRAVITY*gravityRemovalFactor, 0));
       // }
    }

    
}
-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
        isPlayerInAir = NO;
    isPlayerOnGround = YES;
}

/*-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    b2Vec2 worldGravity;
    float gravityRemovalFactor = 50.0f;
    
    for(NSSet* touch in touches){
        CGPoint location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL: location];
        
        worldGravity = world->GetGravity();
        b2Vec2 playerVel = body->GetLinearVelocity();
        
        if (playerVel.y >= -1.0f && playerVel.y <= 0.1f ) {
            if (worldGravity.x == 0.0f && worldGravity.y > 0.0f)
                body->ApplyForceToCenter(b2Vec2 (0, -body->GetMass()*GRAVITY*gravityRemovalFactor));
            else if (worldGravity.x == 0.0f && worldGravity.y < 0.0f)
                body->ApplyForceToCenter(b2Vec2 (0, body->GetMass()*GRAVITY*gravityRemovalFactor));
            else if (worldGravity.x > 0.0f && worldGravity.y == 0.0f)
                body->ApplyForceToCenter(b2Vec2 (-body->GetMass()*GRAVITY*gravityRemovalFactor, 0));
            else if (worldGravity.x < 0.0f && worldGravity.y == 0.0f)
                body->ApplyForceToCenter(b2Vec2 (body->GetMass()*GRAVITY*gravityRemovalFactor, 0));
        }
    }
}*/


@end
