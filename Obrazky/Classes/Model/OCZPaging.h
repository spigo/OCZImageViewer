//
//  OCZPaging.h
//  Obrazky
//
//  Created by Peter Rusinak on 01/06/14.
//  Copyright (c) 2014 Peter Rusinak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCZPaging : NSObject

@property (nonatomic, strong) NSNumber *pageSize;
@property (nonatomic, strong) NSNumber *resultSize;
@property (nonatomic, strong) NSNumber *from;
@property (nonatomic, strong) NSNumber *to;

@end
