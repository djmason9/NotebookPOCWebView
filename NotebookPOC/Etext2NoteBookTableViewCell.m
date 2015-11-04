//
//  Etext2NoteBookTableViewCell.m
//  NotebookPOC
//
//  Created by Mason, Darren J on 10/23/15.
//  Copyright (c) 2015 Mason, Darren J. All rights reserved.
//

#import "Etext2NoteBookTableViewCell.h"
#import "Etext2WebClient.h"
#import "AFNetworking.h"
#import "Etext2Utility.h"
#import "Etext2NoteBookTableViewCell.h"
#import "Etext2CustomEditUIButton.h"
#import "Etext2CustomUIWebView.h"


enum EditType{
    Bold,
    Italic,
    BoldOblique,
    Underline
};

@implementation Etext2NoteBookTableViewCell

- (void)awakeFromNib {
    // Initialization code

    [self hydrateCell];
}

#pragma mark - Actions
- (void)buttonAction:(Etext2CustomEditUIButton*)selectedButton {

    
    
    UIView *parentView = selectedButton.superview.superview;
    Etext2CustomUIWebView *textView = (Etext2CustomUIWebView*)[parentView viewWithTag:TEXT_BOX];
//    NSString *selectedText = [textView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
    
    switch (selectedButton.tag) {
        case BOLD:
            [textView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Bold\")"];
            break;
        case UNDERLINE:
            [textView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Underline\")"];
            break;
        case ITALIC:
            [textView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Italic\")"];
            break;
        case BULLET:
        {
            [textView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"insertUnorderedList\")"];
            break;
        }
        case NUMBER_BULLET:
        {
            [textView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"insertOrderedList\")"];
            break;
        }
        case UNDO:
        {
            [textView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"undo\")"];
            NSLog(@"UNDO ACTION SENT!");
            [self.cellDelegate doUndo:self];
            break;
        }
        case REDO:
        {
            [textView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"redo\")"];
            NSLog(@"REDO ACTION SENT!");
            [self.cellDelegate doRedo:self];
            break;
        }

    }
}



- (IBAction)doneEditingNote:(id)sender {
    
    [self.cellDelegate doDoneEditing:self];
}

#pragma mark - Private Methods

-(void)hydrateCell{
    ((UIView*)[self viewWithTag:EDIT_BOX]).hidden = YES;
    
    UIView *editBox =((UIView*)[self viewWithTag:EDIT_BOX_INNER]);
    editBox.layer.borderColor = [UIColor colorWithRed:0.682 green:0.682 blue:0.682 alpha:1].CGColor; /*#aeaeae*/
    editBox.layer.borderWidth = 1.0;
    
    UIView *buttonBase = ((UIView*)[self viewWithTag:BUTTON_BASE]);
    [self setViewGradient:buttonBase];

    // BUTTONS
    UIButton *done = ((UIButton*)[self viewWithTag:DONE]);
    done.layer.backgroundColor = [UIColor blackColor].CGColor;

}

-(void)setUpButtonStyle:(UIButton*)currentButton{
    
    currentButton.layer.borderWidth = 0.5;
    currentButton.layer.cornerRadius = 4;
    currentButton.layer.borderColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1].CGColor;//[UIColor colorWithRed:0.875 green:0.875 blue:0.875 alpha:1].CGColor;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:currentButton.bounds];
    currentButton.backgroundColor = [UIColor whiteColor];
    
    currentButton.layer.shadowColor = [UIColor colorWithRed:0.624 green:0.624 blue:0.624 alpha:1].CGColor;
    currentButton.layer.shadowOffset = CGSizeMake(0,1.5);
    currentButton.layer.shadowRadius = 0.8;
    currentButton.layer.shadowOpacity = 0.6f;
    currentButton.layer.shadowPath = shadowPath.CGPath;
    
    [self setViewGradient:currentButton];
}
/**
 *  sets the inital background gradients for UIView
 *
 *  @param currentView
 */
-(void)setViewGradient:(UIView*)currentView{
    
    // Create the gradient
    CAGradientLayer *theViewGradient = [CAGradientLayer layer];
    theViewGradient.colors = [NSArray arrayWithObjects: (id)TOP_COLOR.CGColor, (id)BOTTOM_COLOR.CGColor, nil];
    theViewGradient.frame = currentView.bounds;
    
    //Add gradient to view
    [currentView.layer insertSublayer:theViewGradient atIndex:0];
    
}

@end
