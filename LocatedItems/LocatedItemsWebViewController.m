//
//  LocatedItemsWebViewController.m
//  LocatedItems
//
//  Copyright (c) 2014 Newton Japan. All rights reserved.
//

#import "LocatedItemsWebViewController.h"

@interface LocatedItemsWebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation LocatedItemsWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
	NSString *urlString = [NSString stringWithFormat:@"http://newtonworks.sakura.ne.jp/wp/LocatedItems/%02d-%02d/", [self.majorNumber intValue], [self.minorNumber intValue]];
	
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
