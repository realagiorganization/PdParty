/*
 * Copyright (c) 2012 Dan Wilcox <danomatika@gmail.com>
 *
 * BSD Simplified License.
 * For information on usage and redistribution, and for a DISCLAIMER OF ALL
 * WARRANTIES, see the file, "LICENSE.txt," in this distribution.
 *
 * See https://github.com/danomatika/PdParty for documentation
 *
 */
#import "NavigationController.h"

@implementation NavigationController {
        UIButton *_revealButton;
}

- (void)viewDidLoad {
        [super viewDidLoad];

        // start with the bar hidden
        [self setNavigationBarHidden:YES animated:NO];

        // semi transparent button to reveal the bar
        _revealButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _revealButton.frame = CGRectMake((self.view.bounds.size.width-60)/2.0, 0, 60, 20);
        _revealButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|
                                        UIViewAutoresizingFlexibleRightMargin|
                                        UIViewAutoresizingFlexibleBottomMargin;
        _revealButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        _revealButton.alpha = 0.5;
        [_revealButton setTitle:@"\u25BC" forState:UIControlStateNormal];
        [self.view addSubview:_revealButton];

        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(revealSwipe:)];
        swipe.direction = UISwipeGestureRecognizerDirectionDown;
        [_revealButton addGestureRecognizer:swipe];
}

- (void)revealSwipe:(UISwipeGestureRecognizer *)recognizer {
        if(recognizer.state == UIGestureRecognizerStateEnded) {
                [self setNavigationBarHidden:NO animated:YES];
                _revealButton.hidden = YES;

                // auto hide again after a short delay
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                             (int64_t)(3 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                        [self setNavigationBarHidden:YES animated:YES];
                        _revealButton.hidden = NO;
                });
        }
}

- (BOOL)shouldAutorotate {
        return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
        return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
        return self.topViewController.preferredInterfaceOrientationForPresentation;
}

@end
