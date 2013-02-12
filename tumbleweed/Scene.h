//
//  Scene.h
//  tumbleweed
//
//  Created by Ian Parker on 2/21/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SceneController.h"

@class SceneController;

@interface Scene : NSObject {
    
    UIButton *button;
    int level;
    NSString *hintCopy;
    __weak SceneController *sceneVC;
    NSMutableDictionary *pListDetails;

}

@property (nonatomic, retain) UIButton *button;
@property (nonatomic ,weak) SceneController *sceneVC;
@property (nonatomic) int level;
@property (nonatomic, retain) NSString *hintCopy;
@property (nonatomic, retain) NSMutableDictionary *pListDetails;


- (id) initWithDictionary:(NSMutableDictionary *) plistDict;

@end
