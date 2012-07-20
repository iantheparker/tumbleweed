//
//  AppDelegate.h
//  tumbleweed
//
//  Created by David Cascino on 1/22/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TumbleweedViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    TumbleweedViewController *viewController;
    

}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) TumbleweedViewController *viewController;

void uncaughtExceptionHandler(NSException *exception);

@end
