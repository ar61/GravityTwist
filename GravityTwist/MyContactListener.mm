//
//  b2ContactListener+ContactListener.m
//  GravityTwist
//
//  Created by Abhinav Rathod on 6/9/13.
//  Copyright (c) 2013 526. All rights reserved.
//

#import "MyContactListener.h"
#import "ButtonData.h"

MyContactListener::MyContactListener() : _contacts() {
}

MyContactListener::~MyContactListener() {
}

void MyContactListener::BeginContact(b2Contact* contact) {
    // We need to copy out the data because the b2Contact passed in
    // is reused.
    MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    _contacts.push_back(myContact);
    
    if(contact->GetFixtureB()->GetFilterData().categoryBits == 6) {
        // mark the box for freezing
        contact->GetFixtureA()->GetBody()->SetUserData([NSNumber numberWithBool:YES]);
        [(ButtonData*)contact->GetFixtureB()->GetUserData() setButtonPressed:YES];
    }
}

void MyContactListener::EndContact(b2Contact* contact) {
    MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    std::vector<MyContact>::iterator pos;
    pos = std::find(_contacts.begin(), _contacts.end(), myContact);
    if (pos != _contacts.end()) {
        _contacts.erase(pos);
    }
}

void MyContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {
}

void MyContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
}
