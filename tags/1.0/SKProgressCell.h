//
//  SKProgressCell.h
//  Skreenics
//
//  Created by naixn on 17/09/09.
//  Copyright 2009 Thibault Martin-Lagardette. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SKProgressIndicator.h"


@interface SKProgressCell : NSCell
{

}

// AttributedStrings Generation
- (NSAttributedString *)attributedStringForFilename;
- (NSAttributedString *)attributedStringForProgress;
// Padding calculations
- (CGFloat)infoAreaLeftPadding;
- (CGFloat)infoAreaWidthInBounds:(NSRect)bounds;
// Bounds calculations
- (NSRect)iconRectForBounds:(NSRect)bounds;
- (NSRect)progressIndicRectForBounds:(NSRect)bounds;
- (NSRect)filenameRectForBounds:(NSRect)bounds withAttributedString:(NSAttributedString *)filenameAttributedString;
- (NSRect)progressStringRectForBounds:(NSRect)bounds withAttributedString:(NSAttributedString *)progressAttributedString;
// Draw
- (void)drawInteriorWithFrame:(NSRect)frame inView:(NSView *)controlView;

@end
