//
//  Etext2NoteBookTableViewCell.m
//  NotebookPOC
//
//  Created by Mason, Darren J on 10/23/15.
//  Copyright (c) 2015 Mason, Darren J. All rights reserved.
//

#import "Etext2NoteBookTableViewCell.h"
#import "Etext2WebClient.h"
#import "Etext2Utility.h"
#import "Etext2NoteBookTableViewCell.h"
#import "Etext2CustomEditUIButton.h"
#import "Etext2CustomUIWebView.h"
#import "Etext2NoteBookServiceManager.h"


enum EditType{
    Bold,
    Italic,
    BoldOblique,
    Underline
};

@interface Etext2NoteBookTableViewCell(){
}
    @property(nonatomic,strong)NSString *beginingBodyText;
    @property(nonatomic,strong)NSString *redoTextState;
@end
@implementation Etext2NoteBookTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self hydrateCell];
}

#pragma mark - Actions
- (void)buttonAction:(Etext2CustomEditUIButton*)selectedButton {

    UIView *parentView = selectedButton.superview.superview;
    Etext2CustomUIWebView *textView = (Etext2CustomUIWebView*)[parentView viewWithTag:TEXT_BOX];
    Etext2CustomEditUIButton *redoButton = (Etext2CustomEditUIButton*)[self viewWithTag:REDO];
    Etext2CustomEditUIButton *undoButon = (Etext2CustomEditUIButton*)[self viewWithTag:UNDO];
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
            _redoTextState = [textView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
            
            [redoButton setButtonEnableState:YES]; //set redo on since we did an undo
            
            [textView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"undo\")"];
            //check button state
            if ([self canUndo]) {
                [undoButon setButtonEnableState:YES];
            }else{
                [undoButon setButtonEnableState:NO];
            }
            break;
        }
        case REDO:
        {

            [textView stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"redo\")"];

            
            //check button state
            if ([self canRedo]) {
                [redoButton setButtonEnableState:YES];
            }else{
                [redoButton setButtonEnableState:NO];
            }
            
            if ([self canUndo]) {
                [undoButon setButtonEnableState:YES];
            }else{
                [undoButon setButtonEnableState:NO];
            }
        
            break;
        }
    }
}

-(BOOL)canUndo{
    Etext2CustomUIWebView *textView = (Etext2CustomUIWebView*)[self viewWithTag:TEXT_BOX];
    NSString *currentBodyText = [textView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    return ![_beginingBodyText isEqualToString:currentBodyText];
}
-(BOOL)canRedo{
    
    Etext2CustomUIWebView *textView = (Etext2CustomUIWebView*)[self viewWithTag:TEXT_BOX];
    NSString *currentBodyText = [textView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    return ![_redoTextState isEqualToString:currentBodyText];
}

#pragma mark - webviewdelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *requestURLString = [request.URL absoluteString];
    Etext2CustomUIWebView *textView = (Etext2CustomUIWebView*)[self viewWithTag:TEXT_BOX];
    
    // If it's a pxeframe scheme used for getting messages from WEB JS, then just
    if ([requestURLString rangeOfString:@"etext2webEdit"].location != NSNotFound) //key press
    {
        //set undo state
        Etext2CustomEditUIButton *undoButon = (Etext2CustomEditUIButton*)[self viewWithTag:UNDO];
        [undoButon setButtonEnableState:YES];
        
        //TODO:auto save?
        

    }else if ([requestURLString rangeOfString:@"etext2webFocus"].location != NSNotFound) {//focus
        //take a snap shot of the box for undo
        _beginingBodyText = [textView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
//        NSLog(@"%@",_beginingBodyText);
    }
    
    return YES;
}

- (IBAction)doneEditingNote:(id)sender {
    
    //TODO: remove this when merging
    NSDictionary *endPointDictionary = [Etext2WebClient dictionaryFromPlist:@"EndPoints"];
    NSDictionary *serverList = [NSDictionary dictionaryWithObjectsAndKeys:
                                [endPointDictionary objectForKey:SERVER_DEVLOPMENT],
                                SERVER_DEVLOPMENT,[endPointDictionary objectForKey:SERVER_STAGE],
                                SERVER_STAGE,[endPointDictionary objectForKey:SERVER_PROD],
                                SERVER_PROD , nil];
    
    
    NSString  *noteBookAPI = serverList[SERVER_DEVLOPMENT][@"notebook"];
    
    Etext2CustomUIWebView *textView = (Etext2CustomUIWebView*)[self viewWithTag:TEXT_BOX];
    NSString *bodyText = [textView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];

    NSString *jsonString = [NSString stringWithFormat:@"{\"content\":\"%@\",\"autoSave\":true}",bodyText];
//    NSString *jsonString = [NSString stringWithFormat:@"{\"content\":\"%@\",\"contentType\":\"n\"}",bodyText];
    
    NSString *noteBookSave = [Etext2WebClient getEndpointURLForKey:@"notbook_sav"];
    NSString *apiURL = [noteBookAPI stringByAppendingString:[NSString stringWithFormat:noteBookSave,BOOK_ID,PAGE_ID,USER_ID,self.noteId]];

    //save to server
    [Etext2NoteBookServiceManager saveNote:apiURL bodyText:jsonString withHandler:^(NSString *successMsg, NSError *error) {
        if(!error){
            NSLog(@"SAVED %@",successMsg);
        }else{
            NSLog(@"FAIL");
        }
        //push save label
    }];
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
