//
//  Tumbleweed.h
//  tumbleweed
//
//  Created by Ian Parker on 2/20/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFTumbleweedClient.h"
#import "Foursquare.h"
#import <RCLocationManager.h>
#import <CoreLocation/CoreLocation.h>


//this tracks the path and progress of the user
@interface Tumbleweed : NSObject {
    
    int tumbleweedLevel;
    NSString *tumbleweedId;
    NSDate *lastLevelUpdate;
    CLLocation *lastKnownLocation;

}

@property int tumbleweedLevel;
@property (nonatomic, retain) NSString *tumbleweedId;
@property (nonatomic, retain) NSDate *lastLevelUpdate;
@property (nonatomic, retain) CLLocation *lastKnownLocation;

+ (Tumbleweed *) sharedClient;
- (void) saveTumbleweed;
- (void) updateLevel : (int) toLevel;

- (void) registerUser;
- (BOOL) getUserUpdates;
- (void) postUserUpdates;



@end
