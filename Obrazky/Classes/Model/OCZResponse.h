//
//  OCZResponse.h
//  Obrazky
//
//  Created by Peter Rusinak on 30/05/14.
//  Copyright (c) 2014 Peter Rusinak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCZResponse : NSObject

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) NSString *statusMessage;

@end
