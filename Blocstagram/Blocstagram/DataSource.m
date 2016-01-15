//
//  DataSource.m
//  Blocstagram
//
//  Created by PT on 1/14/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import "DataSource.h"
#import "User.h"
#import "Media.h"
#import "Comment.h"

// arc4random_uniform() - This function used in this application file returns a random, non-negative number less than the number supplied to it. We add 2 to the result (so all random data will have at least two characters), and use the result to create strings of random length and sentences of random word count.



@interface DataSource ()

@property (nonatomic, strong) NSArray *mediaItems;

@end

@implementation DataSource

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(instancetype) init{
    self = [super init];
    
    if (self) {
        [self addRandomData];
        
    }
    return self;
    
}

// The addRandomData method:
// -loads every placeholder image in our app
// -creates a Media model for it
// -attaches a randomly generated User to it
// -adds a random caption
// -attaches a randomly generated number of Comments to it
// -puts each media item into the mediaItems array

-(void) addRandomData{
    
    NSMutableArray *randomMediaItems = [NSMutableArray array];
    
    for (int i = 1; i <= 10; i++){
        NSString *imageName = [NSString stringWithFormat:@"%d.jpg", i];
        UIImage *image = [UIImage imageNamed:imageName];
        
        if (image) {
            Media *media = [[Media alloc] init];
            media.user = [self randomUser];
            media.image = image;
            media.caption = [self randomSentence];
            
            NSUInteger commentCount = arc4random_uniform(10) + 2;
            NSMutableArray *randomComments = [NSMutableArray array];
            
            for (int i = 0; i <= commentCount; i++) {
                Comment *randomComment = [self randomComment];
                [randomComments addObject:randomComment];
                
            }
            
            media.comments = randomComments;
            
            [randomMediaItems addObject:media];
            
        }
    }
    
    self.mediaItems = randomMediaItems;
    
    
}


-(User *) randomUser{
    User *user = [[User alloc]init];
    
    user.userName = [self randomStringOfLength:arc4random_uniform(10) + 2];
    
    NSString *firstName = [self randomStringOfLength:arc4random_uniform(7) +2];
    NSString *lastName = [self randomStringOfLength:arc4random_uniform(12) + 2];
    user.fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    return user;
    
}


-(Comment *) randomComment {
    Comment *comment = [[Comment alloc] init];
    
    comment.from = [self randomUser];
    comment.text = [self randomSentence];
    
    return comment;
}

-(NSString *) randomSentence{
    
    NSUInteger wordCount = arc4random_uniform(20) + 2;
    
    NSMutableString *randomSentence = [[NSMutableString alloc]init];
    
    for (int i = 0; i <= wordCount; i++) {
        NSString *randomWord = [self randomStringOfLength:arc4random_uniform(12) +2];
        [randomSentence appendFormat:@"%@ ", randomWord];
        
    }
    return randomSentence;
}

-(NSString *) randomStringOfLength:(NSUInteger) len {
   
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyz";
    
    NSMutableString *s = [NSMutableString string];
    for (NSUInteger i = 0U; i < len; i++) {
        u_int32_t r = arc4random_uniform((u_int32_t)[alphabet length]);
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
        
    }
    
    return [NSString stringWithString:s];
    
}


@end
