/******************************************************************************
 *  \file RLMasterViewController.m
 *  \author Matt Nunogawa
 *  \date 12/14/11
 *  \class RLMasterViewController
 *  \brief <#BRIEF#>
 *  \details from https://github.com/amattn/RealLifeXcode4Templates
 *  \abstract <#ABSTRACT#> 
 *  \copyright Copyright Matt Nunogawa 2011. All rights reserved.
 */

#import "RLMasterViewController.h"
#import "RLPDFViewController.h"

#pragma mark ** Constant Defines **

#pragma mark ** Protocols & Declarations **

@interface RLMasterViewController ()
@property (nonatomic, readonly) NSArray *pdfNames;
@end

@implementation RLMasterViewController
#pragma mark ** Synthesis **
#pragma mark ** Static Variables **

//*****************************************************************************
#pragma mark -
#pragma mark ** Lifecycle & Memory Management **

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}
 */

- (void)dealloc;
{
	
}

- (void)didReceiveMemoryWarning;
{
    [super didReceiveMemoryWarning];
    // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


//*****************************************************************************
#pragma mark -
#pragma mark ** UIView Lifecycle **

- (void)viewDidLoad;
{
    [super viewDidLoad];
    // Uncomment the following line to display an Edit button in the navigation 
    // bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload;
{
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

//*****************************************************************************
#pragma mark -
#pragma mark ** UIView Methods **


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES; //support all orientations
}
 */

//*****************************************************************************
#pragma mark -
#pragma mark ** UITableViewData Helper Methods **

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (cell == nil)
        return;
	
	cell.textLabel.text = [self.pdfNames objectAtIndex:indexPath.row];
}

//*****************************************************************************
#pragma mark -
#pragma mark ** UITableViewDataSource **

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [self.pdfNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pdf_name_cell"];
    if (cell == nil)
    {
		if (self.storyboard)
		{
			NSAssert(NO, @"cell should not be nil");
			// double check that the cell identifier is correct in the storyboard
		}
		else
		{
			NSAssert(NO, @"self.storyboard should not be nil");
			// double check your storyboard is configured correctly
		}
    }
    
    // You may need to configure cell attrirbutes that differ based on the row 
    // from different places.  Thus, configureCell:forRowAtIndexPath: is
    // factored out into its own helper method.
    [self configureCell:cell forRowAtIndexPath:indexPath];

    return cell;
}

//*****************************************************************************
#pragma mark -
#pragma mark ** UITableViewDelegate **

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
	RLPDFViewController *pdfViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
	NSURL *pdfURL = [[NSBundle mainBundle] URLForResource:[self.pdfNames objectAtIndex:indexPath.row]
											withExtension:@"pdf"];
	pdfViewController.pdfURL = pdfURL;
	
	[self.navigationController pushViewController:pdfViewController animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
 */

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}
 */

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
{

}
 */

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
 */

//*****************************************************************************
#pragma mark -
#pragma mark ** Utilities **

//*****************************************************************************
#pragma mark -
#pragma mark ** IBActions **

//*****************************************************************************
#pragma mark -
#pragma mark ** Accesssors **

- (NSArray *)pdfNames;
{
	static NSArray *__names = nil;
	if (__names == nil)
	{
		__names = [NSArray arrayWithObjects:
				   @"test_001p",
				   @"test_003p",
				   @"test_120p",
				   @"test_env_101p",
				   @"test_venv_100p",
				   nil];
	}
	return __names;
}

@end

