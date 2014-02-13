//
//  LocatedItemsFlipsideViewController.m
//  LocatedItems
//
//  Copyright (c) 2014 Newton Japan. All rights reserved.
//

#import "LocatedItemsFlipsideViewController.h"
#import "LocatedItemsWebViewController.h"

@interface LocatedItemsFlipsideViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *calibButton;
@end

@implementation LocatedItemsFlipsideViewController
{
	CLLocationManager	*_locationManager;
	NSUUID				*_uuid;
	CLBeaconRegion		*_region;
    NSMutableArray		*_beacons;
	BOOL				_showingWebPage;
	NSNumber			*_webMajorNumber;
	NSNumber			*_webMinorNumber;
	
	NSMutableArray		*_calibBeacons;
	int					_calibCounter;
	BOOL				_calibInProgress;
	NSInteger			_measuredPower;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	_uuid = [[NSUUID alloc] initWithUUIDString:kUUIDString];
	_region = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid identifier:[_uuid UUIDString]];
	_locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
	
	_beacons = [[NSMutableArray alloc] init];
	_showingWebPage = NO;

	_calibBeacons = [[NSMutableArray alloc] init];
	_calibInProgress = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
	[_locationManager startRangingBeaconsInRegion:_region];
}

- (void)viewDidDisappear:(BOOL)animated
{
	if(_showingWebPage == NO) {
		[_locationManager stopRangingBeaconsInRegion:_region];
	}
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

#pragma mark - Calibration

#define CALIB_MAX	30

- (IBAction)calibration:(id)sender {
	_calibButton.enabled = NO;
	_calibCounter = CALIB_MAX;
	_calibInProgress = YES;
}

- (void)calibCalc {
	[_calibBeacons sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"rssi" ascending:YES]]];
	NSArray *sample = [_calibBeacons subarrayWithRange:NSMakeRange(CALIB_MAX*0.1, CALIB_MAX*0.8)];
	_measuredPower = [[sample valueForKeyPath:@"@avg.rssi"] integerValue];
}

#pragma mark - Beacon job

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    [_beacons removeAllObjects];
	[_beacons addObjectsFromArray:beacons];

	if(_calibInProgress) {
		if([beacons count] == 1) {
			[_calibBeacons addObject:[beacons objectAtIndex:0]];
			_calibCounter--;
			if(_calibCounter <= 0) {
				[self calibCalc];
			}
			if(_calibCounter < -5) {
				_calibInProgress = NO;
				_calibButton.enabled = YES;
			}
		}
	}
	
    [self.tableView reloadData];

	int immediateCount = 0;
	for(CLBeacon *beacon in _beacons) {
		if(beacon.proximity == CLProximityImmediate) {
			immediateCount++;
			[self openWebPageMajor:beacon.major minor:beacon.minor];
		}
	}
	
	if(immediateCount == 0) {
		[self closeWebPage];
	}
}

#pragma mark - TableView job

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _beacons.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *identifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    
	CLBeacon *beacon = [_beacons objectAtIndex:indexPath.row];
	NSString *prox;
	switch (beacon.proximity) {
		case CLProximityImmediate:
			prox = @"Immediate";
			break;
		case CLProximityNear:
			prox = @"Near";
			break;
		case CLProximityFar:
			prox = @"Far";
			break;
		case CLProximityUnknown:
		default:
			prox = @"Unknown";
			break;
	}

	if(_calibInProgress) {
		if(_calibCounter > 0) {
			cell.textLabel.text = [NSString stringWithFormat:@"Calibration %d", _calibCounter];
		}
		else {
			cell.textLabel.text = [NSString stringWithFormat:@"Measured Power %ld", (long)_measuredPower];
		}
	}
	else {
		cell.textLabel.text = [beacon.proximityUUID UUIDString];
	}
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Major: %@, Minor: %@, Prox:%@ Acc: %.2fm RSSI:%ld", beacon.major, beacon.minor, prox, beacon.accuracy, (long)beacon.rssi];
	
    return cell;
}

#pragma mark - Web job

-(void)openWebPageMajor:(NSNumber *)majorNumber minor:(NSNumber *)minorNumber
{
	if(_showingWebPage == NO) {
		_webMajorNumber = majorNumber;
		_webMinorNumber = minorNumber;
		[self performSegueWithIdentifier:@"showWebPage" sender:self];
		_showingWebPage = YES;
		NSLog(@"Show web page of %02d-%02d", [majorNumber intValue], [minorNumber intValue]);
	}
}

-(void)closeWebPage
{
	if(_showingWebPage == YES) {
		[self dismissViewControllerAnimated:YES completion:nil];
		_showingWebPage = NO;
		NSLog(@"Hide web page");
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [[segue identifier] isEqualToString:@"showWebPage"] ) {
        LocatedItemsWebViewController *nextViewController = [segue destinationViewController];
        nextViewController.majorNumber = _webMajorNumber;
        nextViewController.minorNumber = _webMinorNumber;
    }
}

@end
