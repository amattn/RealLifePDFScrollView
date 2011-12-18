/******************************************************************************
 *  \file RLPDFViewController.m
 *  \author Matt Nunogawa
 *  \date 12/14/11
 *  \class RLPDFViewController
 *  \brief <#BRIEF#>
 *  \details from https://github.com/amattn/RealLifeXcode4Templates
 *  \abstract <#ABSTRACT#> 
 *  \copyright Copyright Matt Nunogawa 2011. All rights reserved.
 */

#import "RLPDFViewController.h"
#import "RLPDFScrollView.h"
#import "RLOnDemandScrollView.h"

#pragma mark -
@interface RLPDFViewController ()
@property (nonatomic, strong) RLPDFScrollView *scrollingPDFView;
@property (nonatomic, strong) RLOnDemandScrollView *onDemandScrollView;
@end

#pragma mark -
@implementation RLPDFViewController

#pragma mark ** Synthesis **

@synthesize pdfURL = _pdfURL;
@synthesize scrollingPDFView = _scrollingPDFView;
@synthesize onDemandScrollView = _onDemandScrollView;

#pragma mark ** Static Variables **

//*****************************************************************************
#pragma mark -
#pragma mark ** Lifecycle & Memory Management **

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
	{
		
    }
    return self;
}

- (void)releaseViewResources;
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc;
{
	[self releaseViewResources];
    
}

- (void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning];
    // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

//*****************************************************************************
#pragma mark -
#pragma mark ** UIViewController Methods **

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = [self.pdfURL lastPathComponent];
	self.view.autoresizesSubviews = YES;
	self.view.backgroundColor = [UIColor darkGrayColor];

	self.scrollingPDFView = [[RLPDFScrollView alloc] initWithFrame:self.view.bounds];
	self.scrollingPDFView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.scrollingPDFView.pdfURL = self.pdfURL;
	[self.view addSubview:self.scrollingPDFView];
	
//	self.onDemandScrollView = [[RLOnDemandScrollView alloc] initWithFrame:self.view.bounds];
//	self.onDemandScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//	self.onDemandScrollView.opaque = NO;
//	self.onDemandScrollView.gutterBetweenViews = 10.f;
//	self.onDemandScrollView.dataSource = self;
//	[self.view addSubview:self.onDemandScrollView];
}

- (void)viewDidUnload;
{
	self.scrollingPDFView = nil;

    [super viewDidUnload];
}

/*
- (void)viewWillAppear:(BOOL)animated;
{
    [super viewWillAppear:animated];
}
 */
/*
- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
}
 */
/*
- (void)viewDidDisappear:(BOOL)animated;
{
    [super viewDidDisappear:animated];
}
 */

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
{
    return YES; //support all orientations
}

//*****************************************************************************
#pragma mark -
#pragma mark ** IBActions **

//*****************************************************************************
#pragma mark -
#pragma mark ** Accesssors **

@end