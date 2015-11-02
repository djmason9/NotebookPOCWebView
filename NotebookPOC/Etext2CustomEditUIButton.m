//
//  Etext2CustomEditUIButton.m
//  NotebookPOC
//
//  Created by Mason, Darren J on 10/28/15.
//  Copyright (c) 2015 Mason, Darren J. All rights reserved.
//

#import "Etext2CustomEditUIButton.h"
#import "Etext2NoteBookTableViewCell.h"



@implementation Etext2CustomEditUIButton

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        _userInfo = [NSMutableDictionary new];
        _userInfo[BUTTON_SELECTED]= @(NO); //default
        
        FAIcon font;
        
        switch (self.tag) {
            case BOLD:
                font = FABold;
                break;
            case ITALIC:
                font  = FAItalic;
                break;
            case UNDERLINE:
                font = FAUnderline;
                break;
            case BULLET:
                font = FAList;
                break;
            case NUMBER_BULLET:
                font = FAListOl;
                break;
            case UNDO:
                font  = FAReply;
                [self setTitleColor:DISABLED_COLOR forState:UIControlStateNormal /*#afafaf*/];
                break;
            case REDO:
                font = FAShare;
                [self setTitleColor:DISABLED_COLOR forState:UIControlStateNormal /*#afafaf*/];
                break;
            default:
                font = FASearch;
        }

        //create button look
        self.titleLabel.font = STANDARD_BUTTON_FONT;
        [self setTitle:[NSString fontAwesomeIconStringForEnum:font] forState:UIControlStateNormal];
        [self setUpButtonStyle];
        
        [self addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)setButtonEnableState:(BOOL)isEnabled{
    if(isEnabled){
        [self setTitleColor:ENABLED_COLOR forState:UIControlStateNormal /*#afafaf*/];
        [self setEnabled:YES];
    }
    else{
        [self setTitleColor:DISABLED_COLOR forState:UIControlStateNormal /*#afafaf*/];
        [self setEnabled:NO];
    }

}

#pragma mark - actions
- (void)buttonAction:(id)sender {
    
    Etext2NoteBookTableViewCell *cell = (Etext2NoteBookTableViewCell*)self.superview.superview.superview.superview.superview;
    
    //toggle button on or off to enable or disable style
    BOOL on = [_userInfo[BUTTON_SELECTED] boolValue];
    
    if(self.tag < UNDO){
        if(!on){ //set on
            [self setUpButtonSelectedStyle];
        }else{ //set off
            [self setUpButtonUnSelectedStyle];
        }
    }
    

    [cell buttonAction:self];
}
#pragma mark - button look
-(void)setUpButtonStyle{
    
    self.layer.borderWidth = 0.5;
    self.layer.cornerRadius = 4;
    self.layer.borderColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1].CGColor;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
    self.backgroundColor = [UIColor whiteColor];
    
    self.layer.shadowColor = [UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:1].CGColor;
    self.layer.shadowOffset = CGSizeMake(0,1.5);
    self.layer.shadowRadius = 0.8;
    self.layer.shadowOpacity = 0.6f;
    self.layer.shadowPath = shadowPath.CGPath;
    
    [self setViewGradient];
}

-(void)setViewGradient{
    
    // Create the gradient
    CAGradientLayer *theViewGradient = [CAGradientLayer layer];
    theViewGradient.colors = [NSArray arrayWithObjects: (id)TOP_COLOR.CGColor, (id)BOTTOM_COLOR.CGColor, nil];
    theViewGradient.frame = self.bounds;
    
    //Add gradient to view
    [self.layer insertSublayer:theViewGradient atIndex:0];
    
}

#pragma mark - buttonStates

/**
 *  Sets the background for an OFF state of a button
 *
 *  @param currentButton
 */
-(void)setUpButtonUnSelectedStyle{
    
    _userInfo[BUTTON_SELECTED] = @(NO);

    [self doGradientWithTopcolor:TOP_COLOR andBottomColor:BOTTOM_COLOR];
}

/**
 *  Sets the background of an ON State of a button
 *
 *  @param currentButton
 */
-(void)setUpButtonSelectedStyle{
    
    _userInfo[BUTTON_SELECTED] = @(YES);
    
    [self doGradientWithTopcolor:BOTTOM_COLOR andBottomColor:TOP_COLOR];
}

-(void)doGradientWithTopcolor:(UIColor*)topColor andBottomColor:(UIColor*)bottomColor {
    
    // Create the gradient
    CAGradientLayer *theViewGradient = [CAGradientLayer layer];
    theViewGradient.colors = [NSArray arrayWithObjects: (id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    theViewGradient.frame = self.bounds;
    
    //Add gradient to view
    [self.layer replaceSublayer:self.layer.sublayers[0] with:theViewGradient];
    
}


@end
