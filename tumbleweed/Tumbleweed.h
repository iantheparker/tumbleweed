//
//  Tumbleweed.h
//  tumbleweed
//
//  Created by Ian Parker on 2/20/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Scene.h"


//this tracks the path and progress of the user
@interface Tumbleweed : NSObject{
    
    Scene *gasStation;
    Scene *deal;
    Scene *bar;
    Scene *riverBed1;
    Scene *riverBed2;
    Scene *desertChase;
    Scene *desertLynch;
    Scene *campFire;
    NSMutableDictionary *allScenes;


}

+ (Tumbleweed *) weed;
- (void) createScenes;
- (void)fetchScenesIfNecessary;
- (NSString *)sceneArchivePath;
- (BOOL)saveChanges;
- (NSMutableDictionary *) allScenes;
- (void) sceneSelector;

@end
