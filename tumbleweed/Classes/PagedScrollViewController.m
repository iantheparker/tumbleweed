//
//  PagedScrollViewController.m
//  ScrollViews
//
//  Created by Matt Galloway on 01/03/2012.
//  Copyright (c) 2012 Swipe Stack Ltd. All rights reserved.
//

#import "PagedScrollViewController.h"

#define canvas_h 960


@implementation PagedScrollViewController

@synthesize scrollView = _scrollView;



@synthesize bgImage;


#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Paged";
    
    }

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set up the content size of the scroll view
    CGSize pagesScrollViewSize = self.scrollView.frame.size;
    //self.scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * self.pageImages.count, pagesScrollViewSize.height);
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.scrollView = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Load the pages which are now on screen
    if (scrollView.contentOffset.y == 960)
    {
        [self dismissViewControllerAnimated:NO completion:^{}];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenTutorial"];
    }
    
}



@end
