//
//  Scene.h
//  tumbleweed
//
//  Created by Ian Parker on 2/21/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Scene : NSObject <NSCoding>{
    
    NSString *name;
    NSString *categoryId;
    NSString *movieName;        
    NSString *movieThumbnail;
    NSString *posterArt;         
    BOOL unlocked;  
    BOOL accessible;
    NSDictionary *checkInResponse;
    NSDictionary *recentSearchVenueResults;
    NSDate *date;   //unlockDate
    NSString *checkedVenue;  //location of unlock
    NSString *hintCopy;
    NSString *checkInCopy;

}

@property (nonatomic, retain) NSString *name; 
@property (nonatomic, retain) NSString *categoryId; 
@property (nonatomic, retain) NSString *movieName;  
@property (nonatomic, retain) NSString *movieThumbnail;
@property (nonatomic, retain) NSString *posterArt;         
@property (nonatomic) BOOL unlocked;
@property (nonatomic) BOOL accessible;
@property (nonatomic, retain) NSDictionary *checkInResponse;
@property (nonatomic, retain) NSDictionary *recentSearchVenueResults;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *checkedVenue;
@property (nonatomic, retain) NSString *hintCopy;
@property (nonatomic, retain) NSString *checkInCopy;

- (id) initWithDictionary:(NSMutableDictionary *) plistDict;

@end
