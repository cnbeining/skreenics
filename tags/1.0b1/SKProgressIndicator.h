//
//  SKProgressIndicator.h
//  Skreenics
//
//  Created by naixn on 19/09/09.
//  Copyright 2009 Thibault Martin-Lagardette. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol SKProgressAnimatorDelegate

- (void)setProgressValue:(double)value;

@end

#pragma mark -

@interface SKProgressAnimator : NSAnimation
{
    double  originalProgress;
    double  finalProgress;
}

- (id)initWithDelegate:(id <SKProgressAnimatorDelegate>)delegate from:(double)from to:(double)to;

@end

#pragma mark -

typedef struct  s_gradiant_components
{
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
}               NXGradiantComponents;

typedef enum    _SKProgressIndicatorThickness
{
    SKProgressIndicatorPreferredThickness       = 14,
    SKProgressIndicatorPreferredSmallThickness  = 10,
    SKProgressIndicatorPreferredLargeThickness  = 18
}               SKProgressIndicatorThickness;

#define kSKProgressIndicatorError -42.0

@interface SKProgressIndicator : NSView <SKProgressAnimatorDelegate>
{
    SKProgressAnimator* progressAnimation;
    double              progressValue;
    double              maxProgressValue;
}

@property double maxProgressValue;

// Progress value
- (double)progressValue;
- (void)setProgressValue:(double)value;
- (void)setAnimatedProgressValue:(double)value;
// Progress Indicator Delegate
- (void)animationDidEnd:(NSAnimation *)animation;
// Draw related
- (NXGradiantComponents)gradiantHolderComponents;
- (NXGradiantComponents)redGradiantComponents;
- (NXGradiantComponents)greenGradiantComponents;
- (NXGradiantComponents)blueGradiantComponents;
- (NSGradient *)gradiantWithColors:(NXGradiantComponents)c;
- (void)drawRect:(NSRect)dirtyRect;

@end
