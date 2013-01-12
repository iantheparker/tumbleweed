//
//  ViewController.h
//  tumbleweed
//
//  Created by David Cascino on 1/22/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Scene.h"
//#import "Tumbleweed.h"
#import <QuartzCore/QuartzCore.h>
#import "MapButtonView.h"



@interface TumbleweedViewController : UIViewController <UIScrollViewDelegate, CLLocationManagerDelegate>
{
    //Tumbleweed *weed;
    /*
    CALayer *map0CA;
    CALayer *map1CA;
    CALayer *map1BCA;
    CALayer *map1CCA;
    CALayer *map2CA;
    CALayer *map4CA;
    CALayer *janeAvatar;
     */
    UIView *mapCAView;
    IBOutlet UIScrollView *scrollView;
    int lastContentOffset;
    BOOL walkingForward;
    //-- buttons
    IBOutlet MapButtonView *buttonContainer;
    NSMutableArray *scenes;
    IBOutlet UIButton *foursquareConnectButton;
 
}


//-- buttons
@property (nonatomic, retain) UIButton *foursquareConnectButton;

//-- instance methods
- (void) gameState;
- (void) saveAvatarPosition;

//-- event handlers
- (IBAction) foursquareConnect:(UIButton *)sender;
- (IBAction) handleSingleTap:(UIGestureRecognizer *)sender;



@end
