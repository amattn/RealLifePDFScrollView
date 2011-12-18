/******************************************************************************
 *  \file RLPDFScrollView.m
 *  \author Matt Nunogawa
 *  \date 12/14/11
 *  \class RLPDFScrollView
 *  \brief <#BRIEF#>
 *  \details from https://github.com/amattn/RealLifeXcode4Templates
 *  \abstract <#ABSTRACT#>
 *  \copyright Copyright __MyCompanyName__ 2011. All rights reserved.
 */

#import "RLPDFScrollView.h"
#import "RLPDFPageView.h"

@interface RLPDFScrollView ()
@property (nonatomic, assign) NSURL *internalPdfURL;
@property (nonatomic, assign) CGPDFDocumentRef pdfDocumentRef;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) RLOnDemandScrollView *onDemandScrollView;
@end

@implementation RLPDFScrollView
{
	CGRect _lastKnownBounds;
}

#pragma mark ** Synthesis **

@synthesize internalPdfURL = _internalPdfURL;
@synthesize pdfDocumentRef = _pdfDocumentRef;
@synthesize spinner = _spinner;
@synthesize onDemandScrollView = _onDemandScrollView;

#pragma mark ** Static Variables **

//*****************************************************************************
#pragma mark -
#pragma mark ** Lifecycle & Memory Management **

- (void)setup;
{
	// Initialization code
	// [self addSubview:self.spinner];
	
	// This should load asynchroundously...
	self.onDemandScrollView = [[RLOnDemandScrollView alloc] initWithFrame:self.bounds];
	self.onDemandScrollView.dataSource = self;
	self.onDemandScrollView.gutterBetweenViews = 15.f;
	[self addSubview:self.onDemandScrollView];
}

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder;
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)dealloc;
{
	// we have to nil out our CFRefs...
	self.pdfDocumentRef = nil;
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Methods **

+ (NSString *)reasonForPDFOpenErrorForDocument:(CGPDFDocumentRef)pdfDocumentRef;
{
	if (CGPDFDocumentIsEncrypted(pdfDocumentRef))
	{
		return @"PDF is encrypted";
	}
	if (!CGPDFDocumentIsUnlocked(pdfDocumentRef))
	{
		return @"PDF is locked";
	}
	if (CGPDFDocumentGetNumberOfPages(pdfDocumentRef) == 0)
	{
		return @"PDF is empty, no pages.";
	}
	return nil;
}

+ (BOOL)hasErrorOpeningPDFDocument:(CGPDFDocumentRef)pdfDocumentRef;
{
	if ([self reasonForPDFOpenErrorForDocument:pdfDocumentRef])
		return YES;
	return NO;
}

//*****************************************************************************
#pragma mark -
#pragma mark ** UIView Methods **

//*****************************************************************************
#pragma mark -
#pragma mark ** RLOnDemandScrollViewDataSource **

- (UIView *)viewForIndex:(NSUInteger)zeroIndex;
{
	if (self.pdfDocumentRef == nil)
		return nil;

	// pdf pages are 1 based index!!!!!
	NSUInteger pdfIndex = zeroIndex + 1;
	CGPDFPageRef pageRef = CGPDFDocumentGetPage(_pdfDocumentRef, pdfIndex);
	RLPDFPageView *pdfPage = [[RLPDFPageView alloc] initWithFrame:self.bounds andScale:1.0];
	pdfPage.pdfPageRef = pageRef;
	return pdfPage;
}

- (CGFloat)heightForViewAtIndex:(NSUInteger)zeroIndex;
{
	// pdf pages are 1 based index!!!!!
	NSUInteger pdfIndex = zeroIndex + 1;
	CGPDFPageRef pageRef = CGPDFDocumentGetPage(_pdfDocumentRef, pdfIndex);
	CGRect pdfPageRect = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox);
	CGFloat pdfPageAspectRatio = pdfPageRect.size.width / pdfPageRect.size.height;
	CGFloat boundsAspectRatio = self.bounds.size.width / self.bounds.size.height;
		
	if (pdfPageAspectRatio > boundsAspectRatio)
	{
		// the page is wider than the screen, should use normalized height
		CGFloat normalizedHeight = pdfPageRect.size.height * self.bounds.size.width / pdfPageRect.size.width;
		return normalizedHeight;
	}
	else
	{
		// if the page is narrow than the screen, we should clip so that the entire page is visible.
		// user can zoom in to see more if necessary.
		// return self.bounds.size.height;
		
		CGFloat widthRatio = self.bounds.size.width / pdfPageRect.size.width;
		
		return pdfPageRect.size.height * widthRatio;
	}
}
- (NSUInteger)numberOfViews;
{
	if (self.pdfDocumentRef)
		return CGPDFDocumentGetNumberOfPages(self.pdfDocumentRef);
	return 0;
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Accesssors **

- (CGPDFDocumentRef)pdfDocumentRef;
{
	return _pdfDocumentRef;
}
- (void)setPdfDocumentRef:(CGPDFDocumentRef)newValue;
{
	if (_pdfDocumentRef == newValue)
		return;

	if (_pdfDocumentRef)
		CFRelease(_pdfDocumentRef);

	_pdfDocumentRef = newValue;

	if (_pdfDocumentRef)
		CFRetain(_pdfDocumentRef);
}

- (NSURL *)pdfURL;
{
	return self.internalPdfURL;
}
- (void)setPdfURL:(NSURL *)newValue;
{
	self.internalPdfURL = newValue;

	CGPDFDocumentRef pdfDocRef = CGPDFDocumentCreateWithURL((__bridge CFURLRef)self.internalPdfURL);
	self.pdfDocumentRef = pdfDocRef;
	CFRelease(pdfDocRef);

	if ([RLPDFScrollView hasErrorOpeningPDFDocument:self.pdfDocumentRef])
	{
		self.pdfDocumentRef = nil;
		return;
	}
}

- (UIActivityIndicatorView *)spinner;
{
	if (_spinner == nil)
	{
		_spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_spinner.hidesWhenStopped = YES;
		[_spinner startAnimating];
	}
	return _spinner;
}

@end
