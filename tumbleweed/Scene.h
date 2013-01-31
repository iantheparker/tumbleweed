//
//  Scene.h
//  tumbleweed
//
//  Created by Ian Parker on 2/21/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SceneController;

@interface Scene : NSObject {
    
    
    
    UIButton *button;
    int level;
    BOOL unlocked;
    SceneController *sceneVC;
    //SceneVC details
    NSString *name;
    NSString *categoryId;
    NSString *movieName;
    NSString *movieThumbnail;
    NSString *posterArt;
    BOOL accessible;
    NSDictionary *checkInResponse;
    NSDictionary *recentSearchVenueResults;
    NSDate *date;   //unlockDate
    NSString *checkedVenue;  //location of unlock
    NSString *hintCopy;
    NSString *checkInCopy;
    NSString *bonus;

}

@property (nonatomic, retain) UIButton *button;
@property (nonatomic, retain) SceneController *sceneVC;
//SceneVC details
@property (nonatomic, retain) NSString *name; 
@property (nonatomic, retain) NSString *categoryId; 
@property (nonatomic, retain) NSString *movieName;  
@property (nonatomic, retain) NSString *movieThumbnail;
@property (nonatomic, retain) NSString *posterArt;         
@property (nonatomic) BOOL unlocked;
@property (nonatomic) BOOL accessible;
@property (nonatomic) int level;
@property (nonatomic, retain) NSDictionary *checkInResponse;
@property (nonatomic, retain) NSDictionary *recentSearchVenueResults;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *checkedVenue;
@property (nonatomic, retain) NSString *hintCopy;
@property (nonatomic, retain) NSString *checkInCopy;
@property (nonatomic, retain) NSString *bonus;

- (id) initWithDictionary:(NSMutableDictionary *) plistDict;

@end
