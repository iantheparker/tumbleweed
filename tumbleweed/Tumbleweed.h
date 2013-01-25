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
@interface Tumbleweed : NSObject {
    
    CLLocationManager *locationManager;
    int tumbleweedLevel;
    NSMutableArray *sceneState;
    NSString *tumbleweedId;

}

@property int tumbleweedLevel;
@property (nonatomic, retain) NSString *tumbleweedId;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableArray *sceneState;

+ (Tumbleweed *) weed;
- (void) loadTumbleweed;
- (void) saveTumbleweed;

- (void) registerUser;
- (BOOL) getUserUpdates;
- (void) getUserWithBlock:(void (^)(NSDictionary *userCred, NSError *error))block;
- (void) postUserUpdates;



@end
