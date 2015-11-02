//
//  Etext2Utility.m
//  NotebookPOC
//
//  Created by Mason, Darren J on 10/21/15.
//  Copyright (c) 2015 Mason, Darren J. All rights reserved.
//

#import "Etext2Utility.h"

#define APPLICATION_STANDARD_FONT @"Avenir-Roman"
#define APPLICATION_STANDARD_ITALIC_FONT @"Avenir-Oblique"
#define APPLICATION_BOLD_ITALIC_FONT @"Avenir-HeavyOblique"
#define APPLICATION_BOLD_FONT @"Avenir-Heavy"

@implementation Etext2Utility

+(NSString*)stripOutwhiteSpace:(NSString*)dirtyString{
    
    NSString *cleanString;
    
    dirtyString = [dirtyString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    dirtyString = [dirtyString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    NSArray *parts = [dirtyString componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    cleanString = [filteredArray componentsJoinedByString:@" "];
    
    return cleanString;
}


+(NSAttributedString *)formatHTMLString:(NSString*)htmlString{
    
    htmlString = [Etext2Utility stripOutwhiteSpace:htmlString]; //strip out spaces and returns
    
    UIFont *attributeBoldFont = [UIFont fontWithName:APPLICATION_BOLD_FONT size:STANDARD_FONT_SIZE];
    UIFont *attributeRegFont = [UIFont fontWithName:APPLICATION_STANDARD_FONT size:STANDARD_FONT_SIZE];
    UIFont *attributeObliqueFont = [UIFont fontWithName:APPLICATION_STANDARD_ITALIC_FONT size:STANDARD_FONT_SIZE];
    UIFont *attributeBoldObliqueFont = [UIFont fontWithName:APPLICATION_BOLD_ITALIC_FONT size:STANDARD_FONT_SIZE];
    
    NSString *htmlPattern = @"(<b>(.*?)</b>|<i>(.*?)</i>|<u>(.*?)</u>)";
    
    NSError *error = NULL;
    NSRange range = NSMakeRange(0, htmlString.length);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:htmlPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:htmlString options:NSMatchingReportProgress range:range];

   
    NSMutableAttributedString *formattedString = [[NSMutableAttributedString alloc] initWithString:htmlString];
    
    [formattedString addAttribute:NSFontAttributeName value:attributeRegFont range:NSMakeRange(0,formattedString.length)]; //set every font to standard height first
    
    for (NSTextCheckingResult *match in matches) {
        
        NSString* substringForMatch = [htmlString substringWithRange:match.range];
        NSMutableAttributedString *formattedSubString = [[NSMutableAttributedString alloc] initWithString:substringForMatch];
        
         [formattedSubString addAttribute:NSFontAttributeName value:attributeRegFont range:NSMakeRange(0,formattedSubString.length)]; //set every font to standard height first
        
//        NSLog(@"Extracted URL: %@",substringForMatch);
        
        if([substringForMatch rangeOfString:@"<i>"].location == NSNotFound && [substringForMatch rangeOfString:@"<b>"].location != NSNotFound){//if bold
            [formattedSubString addAttribute:NSFontAttributeName value:attributeBoldFont range:NSMakeRange(0,substringForMatch.length)];
        }else if([substringForMatch rangeOfString:@"<i>"].location != NSNotFound && [substringForMatch rangeOfString:@"<b>"].location == NSNotFound){ //oblique
            [formattedSubString addAttribute:NSFontAttributeName value:attributeObliqueFont range:NSMakeRange(0,substringForMatch.length)];
        }else if([substringForMatch rangeOfString:@"<i>"].location != NSNotFound && [substringForMatch rangeOfString:@"<b>"].location != NSNotFound){ //bold oblique
            [formattedSubString addAttribute:NSFontAttributeName value:attributeBoldObliqueFont range:NSMakeRange(0,substringForMatch.length)];
        }
        
        if([substringForMatch rangeOfString:@"<u>"].location != NSNotFound){//underline
             [formattedSubString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0,substringForMatch.length)];
        }
        
        [formattedString replaceCharactersInRange:match.range withAttributedString:formattedSubString];
    }
    
    
    return formattedString;
}

+(NSAttributedString *)stringByStrippingHTML:(NSAttributedString*)htmlString
{
    NSRange range;
    
    NSMutableAttributedString *string = [htmlString mutableCopy];
    
    while ((range = [[string mutableString] rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
    {
        NSString *subString = [[string mutableString] substringWithRange:range];
        if([subString isEqualToString:@"<em>"])
        {
            NSRange range2 = [[string mutableString] rangeOfString:@"</em>"];
            long length = range2.location - range.location - range.length;
            long location = range.location + range.length;
            NSRange boldRange = NSMakeRange(location, length);
            
            [string addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:1] range:boldRange];
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0f green:0.33f blue:0.0f alpha:1.0f] range:boldRange];
        }
        
        [[string mutableString] replaceCharactersInRange:range withString:@""];
    }
    return string;
}



@end
