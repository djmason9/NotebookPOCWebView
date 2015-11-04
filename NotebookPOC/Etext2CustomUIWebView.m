//
//  Etext2CustomUITextView.m
//  NotebookPOC
//
//  Created by Mason, Darren J on 10/27/15.
//  Copyright (c) 2015 Mason, Darren J. All rights reserved.
//

#import "Etext2CustomUIWebView.h"
@interface Etext2CustomUIWebView(){

    BOOL _isSelectShowing;
}

@end

@implementation Etext2CustomUIWebView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _isSelectShowing= NO;        
    }
    return self;
}
/**
 *  None editable HTML
 *
 *  @param string
 *  @param baseURL
 */
-(void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL{
    
    NSURL *cssUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"default" ofType:@"css" inDirectory:@"www"]];
    
    //add some custom css stuff
    string = [NSString stringWithFormat:@"<html><head><link href=\"%@\" type=\"text/css\" rel=\"stylesheet\"/></head><body>%@</body></html>",cssUrl,string];
    
    [ super loadHTMLString:string baseURL:baseURL];
    
}

/**
 *  Editable HTML
 *
 *  @param string
 */
-(void)loadHTMLStringForEdit:(NSString *)string{
    
    NSURL *cssUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"default" ofType:@"css" inDirectory:@"www"]];
    
    
    //add some custom css stuff
    string = [NSString stringWithFormat:@"<html><head><link href=\"%@\" type=\"text/css\" rel=\"stylesheet\"/></head><body contenteditable=\"true\">%@</body></html>",cssUrl,string];

    
    [ super loadHTMLString:string baseURL:nil];
    
}



-(void)doSelect:(id)sender
{
    NSLog(@"TAP TAP TAP");
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(select:) || action == @selector(selectAll:)) {
        return YES;
    }
    
    return NO;
}

- (BOOL)becomeFirstResponder
{
    return YES;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}




@end
