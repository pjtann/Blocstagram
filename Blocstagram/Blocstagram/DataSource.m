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
#import "LoginViewController.h"


// arc4random_uniform() - This function used in this application file returns a random, non-negative number less than the number supplied to it. We add 2 to the result (so all random data will have at least two characters), and use the result to create strings of random length and sentences of random word count.



@interface DataSource () {
   
    NSMutableArray *_mediaItems;
    
}

@property (nonatomic, strong) NSString *accessToken;

@property (nonatomic, strong) NSArray *mediaItems;

//  add a BOOL property to track whether a refresh is already in progress.
@property (nonatomic, assign) BOOL isRefreshing;

@property (nonatomic, assign) BOOL isLoadingOlderItems;

//Sometimes you can infinite scroll, but there are no more older messages. We'll add a new property - self.thereAreNoMoreOlderMessages - to prevent pointless requests:
@property (nonatomic, assign) BOOL thereAreNoMoreOlderMessages;




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
        // call the method to create the random data until we are able to get data from Instagram
        //[self addRandomData];
        
        // call the method to register and respond to the notification for data from Instagram
        [self registerForAccessTokenNotification];
        
    }
    return self;
    
}

// method for registering and responding to the notification for data from Instagram.
// This block will run after the login controller posts the LoginViewControllerDidGetAccessTokenNotification notification. The object that's passed in the notification is an NSString containing the access token, so all we do is store it in self.accessToken when it arrives. Normally, you would also unregister (removeObserver:…) for notifications in dealloc. However, since DataSource is a singleton, it will never get deallocated.

-(void) registerForAccessTokenNotification{
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object: nil queue:nil usingBlock:^(NSNotification *note){
        self.accessToken = note.object;
        
        /// Now that we have our data, let's take a look at it. Add a call to this method once our access token arrives. Got a token; populate the initial data
        
        [self populateDataWithParameters:nil completionHandler:nil];
        
        
        
    }];
}

#pragma mark - Key/Value Observing

-(NSUInteger) countOfMediaItems {
    
    return self.mediaItems.count;
    
}

-(id) objectInMediaItemsAtIndex:(NSUInteger)index {
    return [self.mediaItems objectAtIndex:index];
    
}

-(NSArray *) mediaItemsAtIndexes:(NSIndexSet *)indexes{
    return [self.mediaItems objectAtIndex:indexes];
    
}

-(void) insertObject:(Media *)object inMediaItemsAtIndex:(NSUInteger)index{
    [_mediaItems insertObject:object atIndex:index];
    
}

-(void) removeObjectFromMediaItemsAtIndex:(NSUInteger)index{
    [_mediaItems removeObjectAtIndex:index];
    
}

-(void) replaceObjectInMediaItemsAtIndex:(NSUInteger)index withObject:(id)object {
    [_mediaItems replaceObjectAtIndex:index withObject:object];
    
}


// The below method implementation for this method may seem odd given we know that DataSource has a reference to _mediaItems. Why do we use mutableArrayValueForKey: instead of modifying the _mediaItems array directly? If we remove the item from our underlying data source without going through KVC methods, no objects (including ImagesTableViewController) will receive a KVO notification.

-(void) deleteMediaItem: (Media *) item{
    NSMutableArray *mutableArrayWithKVO =[self mutableArrayValueForKey:@"mediaItems"];
    [mutableArrayWithKVO removeObject:item];
    
}


// called on pull-to-refresh
-(void) requestNewItemsWithCompletionHandler:(NewItemCompletionBlock)completionHandler{
    // Let's also reset thereAreNoMoreOlderMessages if the user does a pull-to-refresh:
    self.thereAreNoMoreOlderMessages = NO;
    
    // #1 - At #1, we check self.isRefreshing. If a request for recovering new items is already in progress, we return immediately. Otherwise, we set isRefreshing to YES and continue.
    if (self.isRefreshing == NO) {
        self.isRefreshing = YES;
        
    }
    
    NSString *minID = [[self.mediaItems firstObject] idNumber];
    NSDictionary *parameters;
    
    
    // Finally, we check if a completion handler was passed before calling it with nil. We do not provide an NSError because creating a fake, local piece of data like media will rarely result in an issue. The NSError will be employed once we begin communicating with Instagram.
    
    if (minID) {
        parameters = @{@"min_id": minID};
        
    }
   
//    We'll now update requestNewItemsWithCompletionHandler: (which is called on pull-to-refresh) to use this method to get newer items. We'll use the MIN_ID parameter from the last checkpoint to let Instagram know we're only interested in items with a higher ID (i.e., newer items). We'll also pass back the error object if it's there.
    
    [self populateDataWithParameters:parameters completionHandler:^(NSError *error){
        self.isRefreshing = NO;
        
        if (completionHandler){
            completionHandler(error);
            
        }
    }];
}
    
-(void) requestOldItemsWithCompletionHandler: (NewItemCompletionBlock) completionHandler {
        
        if  (self.isLoadingOlderItems == NO && self.thereAreNoMoreOlderMessages == NO){
            self.isLoadingOlderItems = YES;

            
            NSString *maxID = [[self.mediaItems lastObject] idNumber];
            NSDictionary *parameters;
            
            
            if (maxID) {
                parameters = @{@"max_id": maxID};
                
            }
            
            [self populateDataWithParameters:parameters completionHandler:^(NSError *error){
                self.isLoadingOlderItems = NO;
                if (completionHandler){
                    completionHandler (error);
                    
                }
            }];
        }
    }
    















// The addRandomData method:
// -loads every placeholder image in our app
// -creates a Media model for it
// -attaches a randomly generated User to it
// -adds a random caption
// -attaches a randomly generated number of Comments to it
// -puts each media item into the mediaItems array

/* // delete the random data methods below that are currently adding the random data when we get the connection to Instagram set.
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
 */

+(NSString *) instagramClientID{
    
    return @"d97c203c7ed74623977e555bad3a2225";
    
}

// Let's write a method to create this request, and turn the response from the Instagram API into a dictionary
// EXPLANATION OF THE BELOW METHODS - populateWithDataParameters and parseDataFromFeeDictionary
/*
 There's a lot of new stuff here. Here is a brief explanation of each new class or method.
 
 dispatch_async
 
 When you have long-running work, like network connections or complex calculations, you should do that work in the background. This allows your user interface - which always runs on the main queue - to remain responsive.
 
 A common pattern - the one you see here - is to dispatch_async on to a background queue, and then when the long-running work is completed, dispatch_async back on to the main queue.
 
 NSURLConnection
 
 So far, when we've had an NSURLRequest, we've given it to a UIWebView for loading, rendering and displaying. When you don't want to directly display the data, you can use NSURLConnection to handle connecting to a server and downloading the data.
 
 NSData
 
 NSData is an object that represents any type of data. If the data is an image, you can convert it into a UIImage. If it's a string, you can convert it into an NSString.
 
 Passing addresses into methods
 
 In this code, we pass addresses into methods. This happens in three places: &response, &webError, and &jsonError.
 
 This is a common hack implemented to allow methods to return more than one value.
 
 For example, in this line:
 
 NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&webError];
 NSURLConnection returns an NSData object. But it also wants to communicate some other information - metadata about the response (NSURLResponse) and possibly an error, if something went wrong (NSError).
 
 Since Objective-C can only return one method, we pass in addresses of other variables as arguments, and the method sets them. This is commonly called "vending" - we would say that NSURLConnection's method returns an NSData and vends an NSURLRequest and an NSError.
 
 JSON and NSJSONSerialization
 
 On the Instagram API page, press the "response" button to see a sample of what the response data looks like.
 
 The format of this data is called JSON, which is a way to organize strings, numbers, arrays, and dictionaries using standard symbols.
 
 NSJSONSerialization is a class that converts this data into the more familiar NSDictionary and NSArray objects.
 
 Serialization is the process of converting data from one format to another.
 For more info on JSON, see Bloc's Intro to Networking for Mobile Developers.
 
*/


//- (void) populateDataWithParameters:(NSDictionary *)parameters {

// Since we know those methods use a completion handler (NewItemCompletionBlock), let's start by allowing populateDataWithParameters: to accept a completion block as well.
- (void) populateDataWithParameters:(NSDictionary *)parameters completionHandler:(NewItemCompletionBlock)completionHandler {
    if (self.accessToken) {
        // only try to get the data if there's an access token
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // do the network request in the background, so the UI doesn't lock up
            
            NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://api.instagram.com/v1/users/self/media/recent?access_token=%@", self.accessToken];
            
            
            for (NSString *parameterName in parameters) {
                // for example, if dictionary contains {count: 50}, append `&count=50` to the URL
                [urlString appendFormat:@"&%@=%@", parameterName, parameters[parameterName]];
            }
            
            NSURL *url = [NSURL URLWithString:urlString];
            
            if (url) {
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                
                NSURLResponse *response;
                NSError *webError;
                NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&webError];
                
                if (responseData) {
                    NSError *jsonError;
                    NSDictionary *feedDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
                    
                    if (feedDictionary) {
                        // If there's an error, pass it to completionHandler. If the request is successful, pass nil for the error object:
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // done networking, go back on the main thread
                            [self parseDataFromFeedDictionary:feedDictionary fromRequestWithParameters:parameters];
                            
                            if (completionHandler) {
                                completionHandler(nil);
                            }
                        });
                    } else if (completionHandler){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionHandler(jsonError);
                        });
                    }
                }else if (completionHandler){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(webError);
                    });

                }
            }
        });
    }
}

//we can put it all together to parse the entire Instagram feed when it arrives:

- (void) parseDataFromFeedDictionary:(NSDictionary *) feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    //NSLog(@"%@", feedDictionary);
    
    NSArray *mediaArray = feedDictionary[@"data"];
    
    NSMutableArray *tmpMediaItems = [NSMutableArray array];
    
    for (NSDictionary *mediaDictionary in mediaArray) {
        Media *mediaItem = [[Media alloc] initWithDictionary:mediaDictionary];
        
        if (mediaItem) {
            [tmpMediaItems addObject:mediaItem];
            [self downloadImageForMediaItem:mediaItem]; // This code is inefficient because it starts downloading 100 images simultaneously. The more appropriate logic, which we'll implement later, starts downloading images as users scroll through the feed.
            
        }
    }


    
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
    
    if (parameters[@"min_id"]) {
        // This was a pull-to-refresh request
        
        NSRange rangeOfIndexes = NSMakeRange(0, tmpMediaItems.count);
        NSIndexSet *indexSetOfNewObjects = [NSIndexSet indexSetWithIndexesInRange:rangeOfIndexes];
        
        [mutableArrayWithKVO insertObjects:tmpMediaItems atIndexes:indexSetOfNewObjects];
        
    } else if (parameters[@"max_id"]){
        // this was an infinite scroll request
        
        if (tmpMediaItems.count == 0) {
            // disable infinite scroll, since there are no more older messages
            self.thereAreNoMoreOlderMessages = YES;
            
            
        }else{
            [mutableArrayWithKVO addObjectsFromArray:tmpMediaItems];
            
        }
    } else {
        [self willChangeValueForKey:@"mediaItems"];
        self.mediaItems = tmpMediaItems;
        [self didChangeValueForKey:@"mediaItems"];
    }

}

// This method follows the same pattern as when we connect to the Instagram API. Notably:
// 1. dispatch_async to a background queue
// 2. Make an NSURLRequest
// 3. Use NSURLConnection to connect and get the NSData
// 4. Attempt to convert the NSData into the expected object type (a UIImage here)
// 5. If it works, dispatch_async back to the main queue, and update the data model with the results
// This data model update will trigger the KVO notification to reload the individual row in the table view.

- (void) downloadImageForMediaItem:(Media *)mediaItem {
    if (mediaItem.mediaURL && !mediaItem.image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURLRequest *request = [NSURLRequest requestWithURL:mediaItem.mediaURL];
            
            NSURLResponse *response;
            NSError *error;
            NSData *imageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if (imageData) {
                UIImage *image = [UIImage imageWithData:imageData];
                
                if (image) {
                    mediaItem.image = image;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                        NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                        [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                    });
                }
            } else {
                NSLog(@"Error downloading image: %@", error);
            }
        });
    }
}




@end
