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
#import "ASIHTTPRequestDelegate.h"
//#import "ASIFormDataRequest.h"
//#import "ASIHTTPRequest.h"
//#import "Foursquare.h"
//#import "NSDictionary_JSONExtensions.h"



//this tracks the path and progress of the user
@interface Tumbleweed : NSObject <CLLocationManagerDelegate, ASIHTTPRequestDelegate>{
    
    Scene *intro;
    Scene *gasStation;
    Scene *deal;
    Scene *bar;
    Scene *riverBed1;
    Scene *riverBed2;
    Scene *desertChase;
    Scene *desertLynch;
    Scene *campFire;
    @private NSMutableDictionary *allScenes;
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

@property (nonatomic, retain) CLLocationManager *locationManager;

+ (Tumbleweed *) weed;
- (BOOL)saveChanges;
- (void) registerUser;
- (void) postToServer;

@end
