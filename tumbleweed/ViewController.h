//
//  ViewController.h
//  tumbleweed
//
//  Created by David Cascino on 1/22/12.
//  Copyright (c) 2012 AI Capital. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    IBOutlet UIScrollView *scrollView;
    IBOutlet UILabel *crazyLabel;
    
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UILabel *crazyLabel;

@end
