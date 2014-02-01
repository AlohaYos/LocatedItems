//
//  LocatedItemsMainViewController.m
//  LocatedItems
//
//  Copyright (c) 2014 Newton Japan. All rights reserved.
//

#import "LocatedItemsMainViewController.h"


@interface LocatedItemsMainViewController ()
@property (weak, nonatomic) IBOutlet UITextField *majorNumber;
@property (weak, nonatomic) IBOutlet UITextField *minorNumber;
@property (weak, nonatomic) IBOutlet UITextField *powerValue;
@end

@implementation LocatedItemsMainViewController
{
    CBPeripheralManager *_peripheralManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	_peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (void)viewDidAppear:(BOOL)animated
{
	[self getBeaconID];
	[self beaconing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(LocatedItemsFlipsideViewController *)controller
{
	[self beaconing:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

#pragma mark - Beacon job

-(void)beaconing:(BOOL)flag
{
	NSUUID		*uuid = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
	CLBeaconRegion *region = [[CLBeaconRegion alloc]
							  initWithProximityUUID:uuid
							  major:[self.majorNumber.text intValue]
							  minor:[self.minorNumber.text intValue]
							  identifier:[uuid UUIDString]];

	NSDictionary *peripheralData;
	if([self.powerValue.text length]>0) {
		NSNumber *power = [NSNumber numberWithInt:[self.powerValue.text intValue]];
		peripheralData = [region peripheralDataWithMeasuredPower:power];
	}
	else {
		peripheralData = [region peripheralDataWithMeasuredPower:nil];
	}
	
	switch (flag) {
		case YES:
			[_peripheralManager startAdvertising:peripheralData];
			[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
			break;
		case NO:
			[_peripheralManager stopAdvertising];
			[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
			break;
	}
	
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    
}

#pragma mark - Major/Minor edit

- (IBAction)majorEditEnd:(id)sender {
	[self beaconing:NO];
	[self beaconing:YES];
	[self setBeaconID];
}

- (IBAction)minorEditEnd:(id)sender {
	[self beaconing:NO];
	[self beaconing:YES];
	[self setBeaconID];
}

- (IBAction)powerEditEnd:(id)sender {
	[self beaconing:NO];
	[self beaconing:YES];
	[self setBeaconID];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

- (void)setBeaconID
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.majorNumber.text forKey:@"majorNumber"];
    [defaults setObject:self.minorNumber.text forKey:@"minorNumber"];
    [defaults setObject:self.powerValue.text forKey:@"powerValue"];
}

- (void)getBeaconID
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *major = [defaults objectForKey:@"majorNumber"];
	if([major length]>0) {
		self.majorNumber.text = major;
	}
	NSString *minor = [defaults objectForKey:@"minorNumber"];
	if([minor length]>0) {
		self.minorNumber.text = minor;
	}
	NSString *power = [defaults objectForKey:@"powerValue"];
	if([power length]>0) {
		self.powerValue.text = power;
	}
}


@end
