//
//  TDARequestManager.h
//  TestiOSDeveloperApp
//
//  Created by Vladislava Kirichenko on 11/6/14.
//  Copyright (c) 2014 Vladislava Kirichenko. All rights reserved.
//

#import <Foundation/Foundation.h>

//This class does all work with server
@interface TDARequestManager : NSObject

+ (TDARequestManager *)sharedInstance;

///Use this method to start observing changes made in Core Data
- (void)startObservingCoreDataChanges;

@end
