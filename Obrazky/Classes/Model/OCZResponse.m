//
//  OCZResponse.m
//  Obrazky
//
//  Created by Peter Rusinak on 30/05/14.
//  Copyright (c) 2014 Peter Rusinak. All rights reserved.
//

#import "OCZResponse.h"

@implementation OCZResponse

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [self init])
    {
        self.status = [decoder decodeIntegerForKey:@"status"];
        self.statusMessage = [decoder decodeObjectForKey:@"statusMessage"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInteger:self.status forKey:@"status"];
    [encoder encodeObject:self.statusMessage forKey:@"statusMessage"];
}

@end
