//
//  ViewController.h
//  tumbleweed
//
//  Created by David Cascino on 1/22/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Scene.h"
#import "Tumbleweed.h"


@interface TumbleweedViewController : UIViewController <UIScrollViewDelegate>
{
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *map;
    IBOutlet UIImageView *avatar;
    NSMutableArray *sprites;
    IBOutlet UIButton *gasStationButton;
    IBOutlet UIButton *foursquareConnectButton;
    int lastContentOffset;
    BOOL walkingForward;
    Tumbleweed *weed;
    
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIImageView *map;
@property (nonatomic, retain) UIImageView *avatar;
@property (nonatomic, retain) NSMutableArray *sprites;
@property BOOL walkingForward;
@property (nonatomic, retain) UIButton *gasStationButton;
@property (nonatomic, retain) UIButton *foursquareConnectButton;
@property (nonatomic, retain) Tumbleweed *weed;


//-- instance methods
- (void) renderJane: (BOOL) direction;
- (UIImage *) selectAvatarImage:(float) position;
- (void) saveAvatarPosition;
//- (void) initScenes;

//-- event handlers
- (IBAction) foursquareConnect:(UIButton *)sender;
- (IBAction) gasStationPressed:(UIButton *)sender;
- (IBAction) dealPressed:(UIButton *)sender;
- (IBAction) barPressed:(UIButton *)sender;
- (IBAction) riverbedPressed:(UIButton *)sender;

//--game state
- (void) sceneSelector;



@end
