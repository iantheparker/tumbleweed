//
//  ViewController.h
//  tumbleweed
//
//  Created by David Cascino on 1/22/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIScrollViewDelegate>
{
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIImageView *map;
    IBOutlet UIImageView *avatar;
    NSMutableArray *sprites;
    IBOutlet UIButton *gasStationButton;
    int lastContentOffset;
    BOOL walkingForward;
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIImageView *map;
@property (nonatomic, retain) UIImageView *avatar;
@property (nonatomic, retain) NSMutableArray *sprites;
@property BOOL walkingForward;
@property (nonatomic, retain) UIButton *gasStationButton;

//-- instance methods
- (void) renderJane: (BOOL) direction;
- (UIImage *) selectAvatarImage:(float) position;

//-- event handlers
- (IBAction) gasStationPressed:(UIButton *)sender;
- (IBAction) foursquareConnect:(UIButton *)sender;


@end
