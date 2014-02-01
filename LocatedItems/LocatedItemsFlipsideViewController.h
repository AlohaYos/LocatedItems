//
//  LocatedItemsFlipsideViewController.h
//  LocatedItems
//
//  Copyright (c) 2014 Newton Japan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class LocatedItemsFlipsideViewController;

@protocol LocatedItemsFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(LocatedItemsFlipsideViewController *)controller;
@end

@interface LocatedItemsFlipsideViewController : UIViewController <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id <LocatedItemsFlipsideViewControllerDelegate> delegate;

@end
