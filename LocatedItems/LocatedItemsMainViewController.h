//
//  LocatedItemsMainViewController.h
//  LocatedItems
//
//  Copyright (c) 2014 Newton Japan. All rights reserved.
//

#import "LocatedItemsFlipsideViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface LocatedItemsMainViewController : UIViewController <LocatedItemsFlipsideViewControllerDelegate, CBPeripheralManagerDelegate>

@end
