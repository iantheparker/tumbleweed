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
#import <QuartzCore/QuartzCore.h>



@interface TumbleweedViewController : UIViewController <UIScrollViewDelegate, CLLocationManagerDelegate>
{
    NSMutableArray *parallaxLayers;
    UIView *mapCAView;
    IBOutlet UIScrollView *scrollView;
    
    //-- buttons
    IBOutlet UIButton *buttonContainer;
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
- (void) handleSingleTap:(UIGestureRecognizer *)sender;



@end
