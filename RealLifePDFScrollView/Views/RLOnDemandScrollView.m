/******************************************************************************
 *  \file RLOnDemandScrollView.m
 *  \author Matt Nunogawa
 *  \date 12/17/11
 *  \class RLOnDemandScrollView
 *  \brief <#BRIEF#>
 *  \details from https://github.com/amattn/RealLifeXcode4Templates
 *  \abstract <#ABSTRACT#>
 *  \copyright Copyright Matt Nunogawa 2011. All rights reserved.
 */

#import "RLOnDemandScrollView.h"

@interface RLOnDemandScrollView ()

@property (nonatomic, strong) NSMutableOrderedSet *visibleViews;
@property (nonatomic, strong) NSMutableOrderedSet *visibleIndices;
@property (nonatomic, strong) NSMutableDictionary *viewRects;
@property (nonatomic, strong) UIView *containerView;

// Convenience Accessors
@property (nonatomic, assign, readonly) NSUInteger numberOfViews;
@property (nonatomic, assign, readonly) CGRect scaledVisibleRect;
@property (nonatomic, assign, readonly) CGRect nativeVisibleRect;

- (UIView *)viewForIndex:(NSUInteger)index;

@end

@implementation RLOnDemandScrollView
{
	BOOL _loadedAtLeastOnce;
	NSUInteger _cachedNumberOfViews;
}

#pragma mark ** Synthesis **

@synthesize dataSource = _dataSource;


@synthesize visibleViews = _visibleViews;
@synthesize visibleIndices = _visibleIndices;
@synthesize viewRects = _viewRects;
@synthesize containerView = _containerView;
@synthesize gutterBetweenViews = _gutterBetweenViews;

#pragma mark ** Static Variables **

//*****************************************************************************
#pragma mark -
#pragma mark ** Lifecycle & Memory Management **

- (void)setup;
{
	self.delegate = self;

	// Settings these values will "enable" zooming.
	self.maximumZoomScale = 10.0;
	self.minimumZoomScale = 1.0;
	
	self.backgroundColor = [UIColor clearColor];
	
	self.visibleViews = [[NSMutableOrderedSet alloc] init];
	self.visibleIndices = [[NSMutableOrderedSet alloc] init];
	self.viewRects = [[NSMutableDictionary alloc] init];
	self.containerView = [[UIView alloc] initWithFrame:self.bounds];
	self.containerView.opaque = NO;
	[self addSubview:self.containerView];
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
	
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Methods **

- (void)reloadData;
{
	_cachedNumberOfViews = [self.dataSource numberOfViews];
	CGSize contentSize = CGSizeZero;
	contentSize.width = self.bounds.size.width;
	
	for (NSUInteger i = 0; i < self.numberOfViews; i++)
	{
		CGRect viewRect = CGRectZero;
		viewRect.origin.y = contentSize.height;
		viewRect.size.height = [self.dataSource heightForViewAtIndex:i];
		viewRect.size.width = self.bounds.size.width;
		[self.viewRects setObject:[NSValue valueWithCGRect:viewRect] forKey:RLQUICK_INTEGER(i)];

		contentSize.height += viewRect.size.height;
		contentSize.height += self.gutterBetweenViews;
	}

	if (self.numberOfViews > 0)
		contentSize.height -= self.gutterBetweenViews;  // there is no gutter after the last view

	self.containerView.frame = CGRectMake(0.f, 0.f, contentSize.width, contentSize.height);
	self.contentSize = contentSize;
	[self setNeedsLayout];
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Helpers **

- (CGRect)rectForViewAtIndex:(NSUInteger)index;
{
	NSValue *rectValue = [self.viewRects objectForKey:RLQUICK_INTEGER(index)];
	return [rectValue CGRectValue];
}


- (void)insertViewForIndex:(NSUInteger)index;
{
	UIView *view = [self.dataSource viewForIndex:index];
	[self.visibleViews insertObject:view atIndex:0];
	[self.visibleIndices insertObject:RLQUICK_INTEGER(index) atIndex:0];
	view.frame = [self rectForViewAtIndex:index];
	[self.containerView addSubview:view];
}

- (void)addViewForIndex:(NSUInteger)index;
{
	UIView *view = [self.dataSource viewForIndex:index];
	[self.visibleViews addObject:view];
	[self.visibleIndices addObject:RLQUICK_INTEGER(index)];
	view.frame = [self rectForViewAtIndex:index];
	[self.containerView addSubview:view];
}

- (void)removeViewForIndex:(NSUInteger)index;
{
	NSUInteger visibleIndex = [self.visibleIndices indexOfObject:RLQUICK_INTEGER(index)];
	UIView *view = [self.visibleViews objectAtIndex:visibleIndex];
	[view removeFromSuperview];
	[self.visibleViews removeObjectAtIndex:visibleIndex];
	[self.visibleIndices removeObjectAtIndex:visibleIndex];
}

- (void)updateVisibleViews;
{
	// we need at least one view
	if ([self.visibleViews count] == 0 && self.numberOfViews > 0)
	{
		[self addViewForIndex:0];
	}
	
	// just an arbitrary amount of padding, so in the case of itty bitty scrolling, we don't have to load/unload views as much.
	CGRect visisbleRectWithPadding = CGRectInset(self.nativeVisibleRect, 0, -50.f);
	
	// Add any views in the visible area
	
	// is the visible rect "before" the first visible view?
	{
		UIView *firstVisibleView = [self.visibleViews firstObject];
		NSUInteger firstVisibleViewAbsoluteIndex = [[self.visibleIndices firstObject] unsignedIntegerValue];
		
		// add in any views we need to...
		while (visisbleRectWithPadding.origin.y < firstVisibleView.frame.origin.y)
		{
			// add in the view "above" firstVisibleView
			if (firstVisibleViewAbsoluteIndex > 0)
			{
				NSUInteger previousAbsoluteIndex = firstVisibleViewAbsoluteIndex - 1;
				[self insertViewForIndex:previousAbsoluteIndex];
			}
			else
			{
				// we are at the first index... give up
				break;
			}
			
			firstVisibleView = [self.visibleViews firstObject];
			firstVisibleViewAbsoluteIndex = [[self.visibleIndices firstObject] unsignedIntegerValue];
		}
	}
	
	// add in any views after the last view
	{
		UIView *lastVisibleView = [self.visibleViews lastObject];
		NSUInteger lastVisibleViewAbsoluteIndex = [[self.visibleIndices lastObject] unsignedIntegerValue];
		
		while (CGRectGetMaxY(lastVisibleView.frame) < CGRectGetMaxY(visisbleRectWithPadding))
		{
			// we have some space... should add in more views.
			NSUInteger nextViewIndex = lastVisibleViewAbsoluteIndex + 1;
			if (nextViewIndex < self.numberOfViews)
			{
				[self addViewForIndex:nextViewIndex]; // add, not insert.  add... puts it at the bottom.
			}
			else
			{
				// we are at the last index, give up
				break;
			}
			
			lastVisibleView = [self.visibleViews lastObject];
			lastVisibleViewAbsoluteIndex = [[self.visibleIndices lastObject] unsignedIntegerValue];
		}
	}
	
	// remove any views not in the visible area
	for (NSUInteger visibleIndex = 0; visibleIndex < [self.visibleIndices count]; visibleIndex++)
	{
		UIView *view = [self.visibleViews objectAtIndex:visibleIndex];
		NSUInteger absoluteIndex = [[self.visibleIndices objectAtIndex:visibleIndex] unsignedIntegerValue];
		if (CGRectIntersectsRect(visisbleRectWithPadding, view.frame) == NO)
			[self removeViewForIndex:absoluteIndex];
	}
}

//*****************************************************************************
#pragma mark -
#pragma mark ** UIView Methods **

- (void)layoutSubviews;
{
	[super layoutSubviews];
	
	if (_loadedAtLeastOnce == NO)
	{
		[self reloadData];
		_loadedAtLeastOnce = YES;
		return;
	}
	
	[self updateVisibleViews];
}

//*****************************************************************************
#pragma mark -
#pragma mark ** UIScrollViewDelegate **

// A UIScrollView delegate callback, called when the user starts zooming. 
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.containerView;
}

// A UIScrollView delegate callback, called when the user stops zooming.
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	
}

// A UIScrollView delegate callback, called when the user begins zooming.
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
	
}

//*****************************************************************************
#pragma mark -
#pragma mark ** Accesssors **

- (CGRect)scaledVisibleRect;
{
	// scaledVisibleRect is relative to zoom scale.
	CGRect scaledVisibleRect = CGRectZero;
	scaledVisibleRect.origin = self.contentOffset;
	scaledVisibleRect.size = self.bounds.size;
	return scaledVisibleRect;
}
- (CGRect)nativeVisibleRect;
{
	// nativeVisibleRect is relative to the native, unscaled scroll view coordinates
	CGRect nativeVisibleRect = self.scaledVisibleRect;
	CGFloat zoomScale = self.zoomScale;
	nativeVisibleRect.origin.x /= zoomScale;
	nativeVisibleRect.origin.y /= zoomScale;
	nativeVisibleRect.size.width /= zoomScale;
	nativeVisibleRect.size.height /= zoomScale;
	return nativeVisibleRect;
}

- (UIView *)viewForIndex:(NSUInteger)index;
{
	return [self.dataSource viewForIndex:index];
}

- (NSUInteger)numberOfViews;
{
	return _cachedNumberOfViews;
}

@end
