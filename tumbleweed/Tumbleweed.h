//
//  Tumbleweed.h
//  tumbleweed
//
//  Created by Ian Parker on 2/20/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Scene.h"
#import <CoreLocation/CoreLocation.h>




//this tracks the path and progress of the user
@interface Tumbleweed : NSObject <CLLocationManagerDelegate>{
    
    Scene *intro;
    Scene *gasStation;
    Scene *deal;
    Scene *bar;
    Scene *riverBed1;
    Scene *riverBed2;
    Scene *desertChase;
    Scene *desertLynch;
    Scene *campFire;
    CLLocationManager *locationManager;

}

@property (nonatomic, retain) Scene *intro;
@property (nonatomic, retain) Scene *gasStation;
@property (nonatomic, retain) Scene *deal;
@property (nonatomic, retain) Scene *bar;
@property (nonatomic, retain) Scene *riverBed1;
@property (nonatomic, retain) Scene *riverBed2;
@property (nonatomic, retain) Scene *desertChase;
@property (nonatomic, retain) Scene *desertLynch;
@property (nonatomic, retain) Scene *campFire;

@property int tumbleweedLevel;
@property (nonatomic, retain) CLLocationManager *locationManager;

+ (Tumbleweed *) weed;

- (void) registerUser;
- (void) getUser;
- (void) getUserWithBlock:(void (^)(NSDictionary *userCred, NSError *error))block;
- (void) updateUser;

@end
