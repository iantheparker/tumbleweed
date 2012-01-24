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
    
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIImageView *map;
@property (nonatomic, retain) UIImageView *avatar;
@property (nonatomic, retain) NSMutableArray *sprites;

//-- instance methods
- (void) renderJane;
-(UIImage *) selectAvatarImage:(float) position;

@end
