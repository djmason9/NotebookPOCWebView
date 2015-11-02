//
//  Etext2CustomUITextView.m
//  NotebookPOC
//
//  Created by Mason, Darren J on 10/27/15.
//  Copyright (c) 2015 Mason, Darren J. All rights reserved.
//

#import "Etext2CustomUITextView.h"
@interface Etext2CustomUITextView(){

    BOOL _isSelectShowing;
}

@end

@implementation Etext2CustomUITextView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _isSelectShowing= NO;

    }
    return self;
}

- (BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(select:) && !_isSelectShowing) {
        return YES;
    }

    return NO;
}

-(void)select:(id)sender{

    [super select:sender];
    _isSelectShowing = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    _isSelectShowing = NO;
}



- (void)applyAttributeToTypingAttribute:(id)attribute forKey:(NSString *)key
{
    NSMutableDictionary *dictionary = [self.typingAttributes mutableCopy];
    [dictionary setObject:attribute forKey:key];
    [self setTypingAttributes:dictionary];
}




#pragma mark - public methods
-(void)resetSelectedRange{
    self.selectedRange = _lastSelectedRange;
}



@end
