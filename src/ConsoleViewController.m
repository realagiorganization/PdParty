/*
 * Copyright (c) 2015 Dan Wilcox <danomatika@gmail.com>
 *
 * BSD Simplified License.
 * For information on usage and redistribution, and for a DISCLAIMER OF ALL
 * WARRANTIES, see the file, "LICENSE.txt," in this distribution.
 *
 * See https://github.com/danomatika/PdParty for documentation
 *
 */

#import "ConsoleViewController.h"

#import "Log.h"
#import "Util.h"
#import "Gui.h"
#import "TextViewLogger.h"
#import "AppDelegate.h"

@implementation ConsoleViewController

- (void)viewDidLoad {
        [super viewDidLoad];

        // transparent overlay
        self.view.backgroundColor = UIColor.clearColor;

        // console container
        self.containerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.containerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [self.view addSubview:self.containerView];

        // allow dragging
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self.containerView addGestureRecognizer:pan];

        // text view
        self.textView = [[UITextView alloc] initWithFrame:self.containerView.bounds];
        self.textView.scrollEnabled = YES;
        self.textView.showsVerticalScrollIndicator = YES;
        self.textView.editable = NO;
        self.textView.bounces = NO;
        self.textView.font = [UIFont fontWithName:GUI_FONT_NAME size:12];
        self.textView.minimumZoomScale = self.textView.maximumZoomScale; // no zooming
        self.textView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.textView.backgroundColor = UIColor.clearColor;
        self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.containerView addSubview:self.textView];

        // close button
        UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
        [close setTitle:@"Done" forState:UIControlStateNormal];
        [close addTarget:self action:@selector(donePressed:) forControlEvents:UIControlEventTouchUpInside];
        close.frame = CGRectMake(self.containerView.bounds.size.width-60, 0, 60, 30);
        close.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.containerView addSubview:close];
}

- (void)viewWillAppear:(BOOL)animated {
        Log.textViewLogger.textView = self.textView;
        [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
        [super viewDidDisappear:animated];
        Log.textViewLogger.textView = nil;
}

- (void)viewDidLayoutSubviews {
        [super viewDidLayoutSubviews];
        if(CGRectEqualToRect(self.containerView.frame, CGRectZero)) {
                CGFloat width = self.view.bounds.size.width/2.0;
                self.containerView.frame = CGRectMake(self.view.bounds.size.width - width, 0, width, self.view.bounds.size.height);
        }
}

// update the scenemanager if there are rotations while the PatchView is hidden
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {}
                                 completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                AppDelegate *app = (AppDelegate *)UIApplication.sharedApplication.delegate;
                app.sceneManager.currentOrientation = UIApplication.sharedApplication.statusBarOrientation;
        }];
        [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

// lock to orientations allowed by the current scene
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
        AppDelegate *app = (AppDelegate *)UIApplication.sharedApplication.delegate;
        if(app.sceneManager.scene && !app.sceneManager.isRotated) {
                return app.sceneManager.scene.preferredOrientations;
        }
        return UIInterfaceOrientationMaskAll;
}

#pragma mark UI

- (void)donePressed:(id)sender {
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
        UIView *piece = gesture.view;
        CGPoint translation = [gesture translationInView:self.view];
        piece.center = CGPointMake(piece.center.x + translation.x, piece.center.y + translation.y);
        [gesture setTranslation:CGPointZero inView:self.view];
}

@end

