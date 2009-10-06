//
//  SKDragView.h
//  Skreenics
//
//  Created by naixn on 12/09/09.
//  Copyright 2009 Thibault Martin-Lagardette. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SKDragDelegateProtocol.h"


@interface SKDragView : NSView
{
    id <SKDragDelegateProtocol> dragDelegate;
    NSArray*                    acceptableMovieTypes;
}

- (void)setDragDelegate:(id <SKDragDelegateProtocol>)delegate;
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender;
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender;

@end
