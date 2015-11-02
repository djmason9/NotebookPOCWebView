//
//  FontIcon.m
//  iFRDDomotics
//
//  Created by Sebastien on 5/15/13.
//  Copyright (c) 2013 Sebastien. All rights reserved.
//

#import "IcoMoon.h"


@implementation IcoMoon

+(NSString *)iconString:(char *)icon
{
    NSString *string = [NSString stringWithUTF8String:icon];
    return string;
}

+(char *)getIconFromString:(NSString*)defineName{
    char *theChar = 0;
    if([defineName isEqualToString:@"k12_TWENTY_FIRST_CENTURY_SKILLS"])
      theChar = "\uE600";
    else if([defineName isEqualToString:@"k12_AUDIO"])
      theChar = "\uE601";
    else if([defineName isEqualToString:@"k12_AUTHOR"])
      theChar = "\uE602";
    else if([defineName isEqualToString:@"k12_CALENDAR"])
      theChar = "\uE603";
    else if([defineName isEqualToString:@"k12_CHECKLIST"])
      theChar = "\uE604";
    else if([defineName isEqualToString:@"k12_FULL_CLASS"])
      theChar = "\uE605";
    else if([defineName isEqualToString:@"k12_COMMON_CORE"])
      theChar = "\uE606";
//    else if([defineName isEqualToString:@"k12_MINUTES_SIXTY"])
//      k12_MINUTES_SIXTY "\uE607";
//    else if([defineName isEqualToString:@"k12_DIFFERENTIATION"])
//      k12_DIFFERENTIATION "\uE608";
//    else if([defineName isEqualToString:@"k12_CLOSE_READ"])
//      k12_CLOSE_READ "\uE609";
//    else if([defineName isEqualToString:@"k12_GAME_2"])
//      k12_GAME_2 "\uE60A";
//    else if([defineName isEqualToString:@"k12_LEARNER_LEVEL_ONE"])
//      k12_LEARNER_LEVEL_ONE "\uE60B";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//      k12_LEARNER_LEVEL_TWO "\uE60C";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//      k12_LEARNER_LEVEL_THREE "\uE60D";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//      k12_PROFESSIONAL_DEVELOPMENT "\uE60E";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//      k12_STUDENT_ACTIVITY_BOOK "\uE60F";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//      k12_DISCUSSION "\uE610";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//      k12_PRESENT "\uE611";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//      k12_ERROR_INTERVENTION "\uE612";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//      k12_ESSENTIAL_QUESTION "\uE613";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//      k12_FOCUS_COHERENCE_RIGOR "\uE614";
    else if([defineName isEqualToString:@"k12_GLOSSARY"])
      theChar =  "\uE615";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_GOAL "\uE616";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_KEY_CONCEPT "\uE617";
    else if([defineName isEqualToString:@"k12_DOWNLOAD"])
        theChar = "\uE618";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_LESS "\uE619";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_LISTED_INFORMATION "\uE61A";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_MATH_WORDS_IDEAS "\uE61B";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_MORE "\uE61C";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_MYWORLD "\uE61D";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_NEXT_GEN_SCIENCE "\uE61E";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_NOTEBOOK "\uE61F";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_OTHER_STRATEGIES "\uE620";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_POLL "\uE621";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_RESPONSE_TO_INTERVENTION "\uE622";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_RUBRIC "\uE623";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_STEM "\uE624";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_LAB "\uE625";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_INFO_VARIOUS_USES "\uE626";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_TEACHER_SUPPORT "\uE627";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_VIRTUAL_NERD "\uE628";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_WORD_NETWORK "\uE629";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_ACTIVITY "\uE62A";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_ASSESSMENT "\uE62B";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_GAME "\uE62C";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_LETTER "\uE62D";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_VISUAL_LEARNING_ANIMATION "\uE62E";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_PDF "\uE62F";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_PORTFOLIO "\uE630";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_READING "\uE631";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_TOOLS "\uE632";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_VIDEO "\uE633";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_VIRTUAL_LAB "\uE634";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_PRACTICE_HOMEWORK "\uE635";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_INDIVIDUALS "\uE636";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_SMALL_GROUPS "\uE637";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_PAIRS "\uE638";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_MINUTES_FIVE "\uE639";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_MINUTES_TEN "\uE63A";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_MINUTES_FIFTEEN "\uE63B";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_MINUTES_TWENTY "\uE63C";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_MINUTES_TWENTY_FIVE "\uE63D";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_MINUTES_THIRTY "\uE63E";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_MINUTES_THIRTY_FIVE "\uE63F";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_MINUTES_FORTY "\uE640";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_MINUTES_FORTY_FIVE "\uE641";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_MINUTES_FIFTY "\uE642";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_MINUTES_FIFTY_FIVE "\uE643";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_PERFORMANCE_TASK "\uE644";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_GO_ONLINE "\uE645";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_OPEN_ACTIVITY "\uE646";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_NN_FIFTEEN "\uE647";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_NN_FIFTY_FIVE "\uE648";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_NN_FIFTY "\uE649";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_NN_FIVE "\uE64A";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_NN_FORTY_FIVE "\uE64B";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_NN_FORTY "\uE64C";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_NN_SIXTY "\uE64D";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_NN_TEN "\uE64E";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_NN_THIRTY_FIVE "\uE64F";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_NN_THIRTY "\uE650";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_NN_TWENTY_FIVE "\uE651";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_NN_TWENTY "\uE652";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_PRINT "\uE653";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_OBSERVATIONAL_ASSESSMENT "\uE654";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_SUBMIT "\uE655";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_CARDS "\uE656";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_ANNOTATE "\uE657";
    else if([defineName isEqualToString:@"k12_BOOKSHELF"])
        theChar =  "\uE659";
    else if([defineName isEqualToString:@"k12_BOOKMARK"])
        theChar =  "\uE65A";
    else if([defineName isEqualToString:@"k12_NOTES"])
        theChar = "\uE65B";//k12_HIGHLIGHT "\uE65B"
    else if([defineName isEqualToString:@"k12_TOC"])
        theChar = "\uE65C";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_MENU_OPEN "\uE65D";
//    else if([defineName isEqualToString:@"k12_AUDIO"])
//        k12_MENU_CLOSE "\uE65E";
    //    else if([defineName isEqualToString:@"k12_AUDIO"])
//      k12_GO_BACK "\uE65F";
    else if([defineName isEqualToString:@"k12_MENU_OPTION"])
        theChar = "\uE662";
    else
        theChar = "\uE65F";

    return theChar;
}

@end
