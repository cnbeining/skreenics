//
//  SKProgressCell.m
//  Skreenics
//
//  Created by naixn on 17/09/09.
//  Copyright 2009 Thibault Martin-Lagardette. All rights reserved.
//

#import "SKProgressCell.h"
#import "SKVideoItem.h"
#import "SKProgressIndicator.h"
#import "SKDefines.h"

#define VERTICAL_PADDING 5.0
#define HORIZ_PADDING 13.0
#define IMAGE_SIZE 45.0
#define FILENAME_Y_PADDING 4.0
#define PROGRESS_Y_PADDING 22.0
#define PROGSTR_Y_PADDING 37.0

#pragma mark -

@implementation SKProgressCell

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder])
    {
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [super copyWithZone:zone];
}

#pragma mark AttributedStrings Generation

- (NSAttributedString *)attributedStringForFilename
{
    NSString*                   filename;
    NSMutableDictionary*        stringAttributes;
    NSMutableParagraphStyle*    paragraphStyle;

    filename = [[self representedObject] filename];

    stringAttributes = [NSMutableDictionary dictionary];
    [stringAttributes setObject:[NSFont fontWithName:@"Lucida Grande" size:11.0] forKey:NSFontAttributeName];
    [stringAttributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];

    paragraphStyle = [[[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    [stringAttributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];

    return [[[NSAttributedString alloc] initWithString:(filename ? filename : @"") attributes:stringAttributes] autorelease];
}

- (NSAttributedString *)attributedStringForProgress
{
    NSString*                   progressString;
    NSMutableDictionary*        stringAttributes;
    NSMutableParagraphStyle*    paragraphStyle;

    progressString = [[self representedObject] progressString];
    stringAttributes = [NSMutableDictionary dictionary];
    [stringAttributes setObject:[NSFont fontWithName:@"Lucida Grande" size:9.0] forKey:NSFontAttributeName];
    [stringAttributes setObject:[NSColor grayColor] forKey:NSForegroundColorAttributeName];

    paragraphStyle = [[[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    [stringAttributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    
    return [[[NSAttributedString alloc] initWithString:(progressString ? progressString : @"") attributes:stringAttributes] autorelease];
}

#pragma mark Padding calculations

- (CGFloat)infoAreaLeftPadding
{
    static CGFloat lpadding = (2 * HORIZ_PADDING) + IMAGE_SIZE;

    return lpadding;
}

- (CGFloat)infoAreaWidthInBounds:(NSRect)bounds
{
    static CGFloat  nonInfoAreaSpace = (3 * HORIZ_PADDING) + IMAGE_SIZE;

    return NSWidth(bounds) - nonInfoAreaSpace;
}

#pragma mark Bounds calculations

- (NSRect)iconRectForBounds:(NSRect)bounds
{
    NSRect  iconRect;

    iconRect.size = NSMakeSize(IMAGE_SIZE, IMAGE_SIZE);
    iconRect.origin = bounds.origin;
    iconRect.origin.x += HORIZ_PADDING;
    iconRect.origin.y += (NSHeight(bounds) / 2) - (IMAGE_SIZE / 2);

    return iconRect;
}

- (NSRect)progressIndicRectForBounds:(NSRect)bounds
{
    NSRect progressIndicRect;

    progressIndicRect.size.height = NSProgressIndicatorPreferredThickness;
    progressIndicRect.size.width = [self infoAreaWidthInBounds:bounds];
    progressIndicRect.origin = bounds.origin;
    progressIndicRect.origin.x = [self infoAreaLeftPadding];
    progressIndicRect.origin.y += PROGRESS_Y_PADDING;

    return progressIndicRect;
}

- (NSRect)filenameRectForBounds:(NSRect)bounds withAttributedString:(NSAttributedString *)filenameAttributedString
{
    NSRect  filenameRect;
    
    filenameRect.size = [filenameAttributedString size];
    filenameRect.size.width = [self infoAreaWidthInBounds:bounds];
    filenameRect.origin = bounds.origin;
    filenameRect.origin.x += [self infoAreaLeftPadding];
    filenameRect.origin.y += FILENAME_Y_PADDING;
    
    return filenameRect;
}

- (NSRect)progressStringRectForBounds:(NSRect)bounds withAttributedString:(NSAttributedString *)progressAttributedString
{
    NSRect  progressStringRect;

    progressStringRect.size = [progressAttributedString size];
    progressStringRect.size.width = [self infoAreaWidthInBounds:bounds];
    progressStringRect.origin = bounds.origin;
    progressStringRect.origin.x = [self infoAreaLeftPadding];
    progressStringRect.origin.y += PROGSTR_Y_PADDING;

    return progressStringRect;
}

#pragma mark Draw

- (void)drawInteriorWithFrame:(NSRect)frame inView:(NSView *)controlView
{
    NSAttributedString* filenameAttributedString;
    NSAttributedString* progressAttributedString;
    NSRect              progressIndicRect;
    NSRect              progressStringRect;
    NSRect              iconRect;
    NSRect              filenameRect;

    filenameAttributedString = [self attributedStringForFilename];
    progressAttributedString = [self attributedStringForProgress];

    // Draw the icon
    iconRect = [self iconRectForBounds:frame];
    NSImage* icon = [[self representedObject] icon];
    if (icon)
    {
        [icon setFlipped:[controlView isFlipped]];
        [icon drawInRect:iconRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
    else
    {
        // If there is no icon, just draw a square
        [NSBezierPath strokeRect:iconRect];
    }

    // Draw the filename
    filenameRect = [self filenameRectForBounds:frame withAttributedString:filenameAttributedString];
    NSString* filename = [[self representedObject] filename];
    if ([filename length] > 0)
    {
        [filenameAttributedString drawInRect:filenameRect];
    }

    // Draw the progress indicator
    progressIndicRect = [self progressIndicRectForBounds:frame];
    SKProgressIndicator* progressIndicator = [[self representedObject] progressIndicator];
    if (progressIndicator)
    {
        if ([progressIndicator superview] == nil)
        {
            [controlView addSubview:progressIndicator];
        }
        [progressIndicator setFrame:progressIndicRect];
    }

    // Draw the progress string
    progressStringRect = [self progressStringRectForBounds:frame withAttributedString:progressAttributedString];
    NSString* progressString = [[self representedObject] progressString];
    if ([progressString length] > 0)
    {
        [progressAttributedString drawInRect:progressStringRect];
    }
}


@end
