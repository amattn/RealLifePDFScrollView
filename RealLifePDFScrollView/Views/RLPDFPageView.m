/******************************************************************************
 *  \file RLPDFPageView.m
 *  \author Matt Nunogawa
 *  \date 12/14/11
 *  \class RLPDFPageView
 *  \brief <#BRIEF#>
 *  \details from https://github.com/amattn/RealLifeXcode4Templates
 *  \abstract <#ABSTRACT#>
 *  \copyright Copyright Matt Nunogawa 2011. All rights reserved.
 */

#import <QuartzCore/QuartzCore.h> // Needed for all the custom TiledLayer stuff we are doing.
#import "RLPDFPageView.h"

@interface RLPDFPageView ()

@end

@implementation RLPDFPageView
{
	CGFloat _currentScale;
}
#pragma mark ** Synthesis **

@synthesize pdfPageRef = _pdfPageRef;
@synthesize pdfBoxType = _pdfBoxType;

#pragma mark ** Static Variables **

//*****************************************************************************
#pragma mark -
#pragma mark ** Lifecycle & Memory Management **

+ (Class)layerClass
{
	return [CATiledLayer class];
}

- (id)initWithFrame:(CGRect)frame;
{
	return [[RLPDFPageView alloc] initWithFrame:frame andScale:1.f];
}

- (id)initWithFrame:(CGRect)frame andScale:(CGFloat)scale
{
    self = [super initWithFrame:frame];
    if (self)
    {
		_currentScale = scale;

		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		
		self.pdfBoxType = kCGPDFCropBox; //default value
		
		//Set up tiled layer
		CATiledLayer *tiledLayer = (id)self.layer;
		NSAssert([tiledLayer isKindOfClass:[CATiledLayer class]], @"self.layer must be CATiledLayer");
				  
		// levelsOfDetail and levelsOfDetailBias determine how
		// the layer is rendered at different zoom levels.  This
		// only matters while the view is zooming, since once the 
		// the view is done zooming a new TiledPDFView is created
		// at the correct size and scale.
        tiledLayer.levelsOfDetail = 4;
		tiledLayer.levelsOfDetailBias = 4;
		tiledLayer.tileSize = CGSizeMake(512.0, 512.0);
    }
    return self;
}

- (void)dealloc;
{
	// we have to nil out our CFRefs...
	self.pdfPageRef = nil;
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Methods **

- (CGAffineTransform)getPDFTransformForBoundsRect:(CGRect)boundsRect;
{
	// CGPDFPageGetDrawingTransform provides an easy way to get the transform for a PDF page. 
	// It makes a transform that allows us to convert from 1) layer coords to 2) pdfCoords
	// However it only works for downsizing, not upsizing.
	// 
	
	CGRect pdfBoxRectPDFCoordinates = CGPDFPageGetBoxRect(self.pdfPageRef, self.pdfBoxType);
	CGAffineTransform pdfTransform = CGAffineTransformIdentity;

	if (pdfBoxRectPDFCoordinates.size.width < boundsRect.size.width
		&& pdfBoxRectPDFCoordinates.size.height < boundsRect.size.height)
	{
		// we need to upscale...
		CGFloat widthRatio = boundsRect.size.width / pdfBoxRectPDFCoordinates.size.width;
		CGFloat heightRatio = boundsRect.size.height / pdfBoxRectPDFCoordinates.size.height;
		
		// use the smaller of the two ratios
		CGFloat ratio = MIN(widthRatio, heightRatio);
		pdfTransform = CGAffineTransformScale(pdfTransform, ratio, ratio);
	}
	else
	{
		pdfTransform = CGPDFPageGetDrawingTransform(self.pdfPageRef,			// The pdf page in question
													self.pdfBoxType,			// pdfs have a bunch of different flavors of "bounds" rects.  you must choose one! 
													boundsRect,					// The rect we want to draw in
													0,							// rotate, must be multiple of 90
													true);						// preserve aspect ratio
	}
	
	return pdfTransform;
}

//*****************************************************************************
#pragma mark -
#pragma mark ** UIView Methods **

- (void)drawRect:(CGRect)rect;
{
	// Need to be implemented but empty.
}

-(void)drawLayer:(CALayer*)layer inContext:(CGContextRef)context
{
	if (context == nil)
		return;
	if (self.pdfPageRef == nil)
		return;

	layer.contentsGravity = kCAGravityCenter; // We need this to support high resolution (retina) displays
	
	// We have to keep track of several different coordinate spaces,  
	// 1) the layer coordinates (which we are drawing into
	// 2) the pdf coordinates (which represent the actual pdf page)
	// 3) zoomed/scaled pdfCoordinates (which represent and zoomed in/out pdf page)
	
	// 1) layer coords
	CGRect boundsRectLayerCoordinates = layer.bounds;
		
	CGContextSaveGState(context);
	{
		// The best way to understand this code is to step through and log/watch boundsRectXYZCoordinates and pdfBoxRectXYZCoordinates

		// First we have to flip our view coords.
		CGFloat layerHeight = boundsRectLayerCoordinates.size.height;
		CGContextTranslateCTM(context, 0, layerHeight);
		CGContextScaleCTM(context, 1.0, -1.0);          //  (╯°□°）╯︵ ┻━┻

		// 2) pdf coords
		CGRect pdfBoxRectPDFCoordinates = CGPDFPageGetBoxRect(self.pdfPageRef, self.pdfBoxType);
		
		// CGPDFPageGetDrawingTransform provides an easy way to get the transform for a PDF page. 
		// It makes a transform that allows us to convert from 1) layer coords to 2) pdfCoords
		CGAffineTransform pdfTransform;
		pdfTransform = [self getPDFTransformForBoundsRect:boundsRectLayerCoordinates];

		// do some transform math
		// boundsRectPDFCoordinates, pdfBoxRectLayerCoordinates are not used, but can be useful if you are trying to keep track of what is where...
		//CGRect boundsRectPDFCoordinates = CGRectApplyAffineTransform(boundsRectLayerCoordinates, CGAffineTransformInvert(pdfTransform));
		//CGRect pdfBoxRectLayerCoordinates = CGRectApplyAffineTransform(pdfBoxRectPDFCoordinates, pdfTransform);
		
		// 3) zoomed pdf coords
		CGRect pdfBoxRectZoomedPDFCoordinates = pdfBoxRectPDFCoordinates;
		CGAffineTransform zoomScaleTransform = CGAffineTransformIdentity;
		// if necessary (are we zoomed in?), scale the contect and our rect
		if (_currentScale != 1.f)
		{
			zoomScaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, _currentScale, _currentScale);
			pdfBoxRectZoomedPDFCoordinates = CGRectApplyAffineTransform(pdfBoxRectPDFCoordinates, zoomScaleTransform);
		}
				
		// Ready... Draw!
		CGContextConcatCTM(context, pdfTransform);
		CGContextConcatCTM(context, zoomScaleTransform);

		CGContextSetGrayFillColor(context, 1.f, 1.f); // draw white background to the current context (which should match the native pdf coords)
		CGContextAddRect(context, pdfBoxRectZoomedPDFCoordinates);  // CGContextDrawPDFPage will always draw to the native pdf coords.  Our current context should match the native pdf coords, thanks to our pdf transforms...
		CGContextFillPath(context);
		CGContextDrawPDFPage(context, self.pdfPageRef);
	}
	CGContextRestoreGState(context);
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Accesssors **

- (CGRect)rectForCurrentBounds;
{
	CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(self.pdfPageRef,	// The pdf page in question
																  self.pdfBoxType,	// pdfs have a bunch of different flavors of "bounds" rects.  you must choose one! 
																  self.bounds,		// The rect we want to draw in
																  0,				// rotate, must be multiple of 90
																  true);			// preserve aspect ratio

	CGAffineTransform scaleTransform = CGAffineTransformIdentity;
	if (_currentScale != 1.f)
		scaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, _currentScale, _currentScale);


	CGRect nativePDFBoxRect = CGPDFPageGetBoxRect(self.pdfPageRef, self.pdfBoxType);
	CGRect scaledInsetRect = CGRectApplyAffineTransform(nativePDFBoxRect, pdfTransform);
	scaledInsetRect = CGRectApplyAffineTransform(scaledInsetRect, scaleTransform);
	return scaledInsetRect;
}

- (CGPDFPageRef)pdfPageRef;
{
	return _pdfPageRef;
}
- (void)setPdfPageRef:(CGPDFPageRef)newValue;
{
	if (_pdfPageRef == newValue)
		return;
	
	if (_pdfPageRef)
		CFRelease(_pdfPageRef);
	
	_pdfPageRef = newValue;
	
	if (_pdfPageRef)
		CFRetain(_pdfPageRef);
}


@end
