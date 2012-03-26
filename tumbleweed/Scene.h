//
//  Scene.h
//  tumbleweed
//
//  Created by Ian Parker on 2/21/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <Foundation/Foundation.h>

// Foursquare category IDs
#define GAS_TRAVEL_catId    @"4bf58dd8d48988d113951735,4d4b7105d754a06379d81259"
#define DEAL_catId          @"4d4b7105d754a06378d81259"
#define NIGHTLIFE_catId     @"4d4b7105d754a06376d81259"
#define OUTDOORS_catId      @"4d4b7105d754a06377d81259"

@interface Scene : NSObject <NSCoding>{
    
    NSString *name;
    NSString *categoryId;
    NSURL *moviePath;        
    UIImage *movieThumbnail;
    UIImage *posterArt;         
    BOOL unlocked;  
    BOOL accessible;
    NSDictionary *checkInResponse;
    NSDictionary *recentSearchVenueResults;
    NSDate *date;   //unlockDate
    // unlock location

}

@property (nonatomic, retain) NSString *name; 
@property (nonatomic, retain) NSString *categoryId; 
@property (nonatomic, retain) NSURL *moviePath;  
@property (nonatomic, retain) UIImage *movieThumbnail;
@property (nonatomic, retain) UIImage *posterArt;         
@property (nonatomic) BOOL unlocked;
@property (nonatomic) BOOL accessible;
@property (nonatomic, retain) NSDictionary *checkInResponse;
@property (nonatomic, retain) NSDictionary *recentSearchVenueResults;
@property (nonatomic, retain) NSDate *date;



@end
