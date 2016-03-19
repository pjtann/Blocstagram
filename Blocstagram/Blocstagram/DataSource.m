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
#import <UICKeyChainStore.h>
#import <AFNetworking.h>




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

// property for the AFNetworking management
@property (nonatomic, strong) AFHTTPRequestOperationManager *instagramOperationManager;




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
        
        // call the method for initializing the AFNetworking operation manager
        [self createOperationManager];
        
        
        
        // check for the token
        self.accessToken = [UICKeyChainStore stringForKey:@"access token"];
        
        // if token is not there, then register it, if it is then go through to data population
        if (!self.accessToken) {
            [self registerForAccessTokenNotification];
            
        }else{
            //[self populateDataWithParameters:nil completionHandler:nil];
            
            // read the file at launch
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                //This read code is the inverse of the write code. It tries to find the file at the path and convert it into an array. If it finds an array of at least one item, it displays it immediately. (We make a mutableCopy since the copy stored to disk is immutable.) If not, it gets the initial data from the server.
                //The only notable difference is at #1 below. Since the image download happens in a different queue, the download may not finish by the time the files are saved. If this happens, the image property will be nil when they're unarchived. To account for this, we'll re-download any images for Media objects with a nil image. (Remember that downloadImageForMediaItem: will ignore any media items which already have images attached.)
                
                NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
                NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (storedMediaItems.count > 0) {
                        NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy];
                        
                        [self willChangeValueForKey:@"mediaItems"];
                        self.mediaItems = mutableMediaItems;
                        [self didChangeValueForKey:@"mediaItems"];

                        
                    } else {
                        [self populateDataWithParameters:nil completionHandler:nil];
                    }
                });
            });
            
            
            
        }
        
    }
    return self;
    
}

// method for registering and responding to the notification for data from Instagram.
// This block will run after the login controller posts the LoginViewControllerDidGetAccessTokenNotification notification. The object that's passed in the notification is an NSString containing the access token, so all we do is store it in self.accessToken when it arrives. Normally, you would also unregister (removeObserver:…) for notifications in dealloc. However, since DataSource is a singleton, it will never get deallocated.

-(void) registerForAccessTokenNotification{
    [[NSNotificationCenter defaultCenter] addObserverForName:LoginViewControllerDidGetAccessTokenNotification object: nil queue:nil usingBlock:^(NSNotification *note){
        self.accessToken = note.object;
        
        [UICKeyChainStore setString:self.accessToken forKey:@"access token"];
        
        
        /// Now that we have our data, let's take a look at it. Add a call to this method once our access token arrives. Got a token; populate the initial data
        
        [self populateDataWithParameters:nil completionHandler:nil];
        
        
        
    }];
}

// method to initialize the AFNetworking operation manager
-(void) createOperationManager {
    NSURL *baseURL = [NSURL URLWithString:@"http://api.instagram.com/v1/"];
    self.instagramOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL ];
    
    AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
    
    AFImageResponseSerializer *imageSerializer = [AFImageResponseSerializer serializer];
    imageSerializer.imageScale = 1.0;
    
    
    // this compounder figures out what type of object we are requesting
    AFCompoundResponseSerializer *serializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonSerializer, imageSerializer]];
    self.instagramOperationManager.responseSerializer = serializer;
    
}

// method to create a string containing the absolute path to the user's documents directory (like /somedir/someotherdir/filename

-(NSString *) pathForFilename:(NSString *) filename{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    return dataPath;
    
}

#pragma mark - Liking Media Items

- (void) toggleLikeOnMediaItem:(Media *)mediaItem withCompletionHandler:(void (^)(void))completionHandler {
    NSString *urlString = [NSString stringWithFormat:@"media/%@/likes", mediaItem.idNumber];
    NSDictionary *parameters = @{@"access_token": self.accessToken};
    
    if (mediaItem.likeState == LikeStateNotLiked) {
        
        mediaItem.likeState = LikeStateLiking;
        
        [self.instagramOperationManager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            mediaItem.likeState = LikeStateLiked;
            
            if (completionHandler) {
                completionHandler();
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            mediaItem.likeState = LikeStateNotLiked;
            
            if (completionHandler) {
                completionHandler();
            }
        }];
        
    } else if (mediaItem.likeState == LikeStateLiked) {
        
        mediaItem.likeState = LikeStateUnliking;
        
        [self.instagramOperationManager DELETE:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            mediaItem.likeState = LikeStateNotLiked;
            
            if (completionHandler) {
                completionHandler();
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            mediaItem.likeState = LikeStateLiked;
            
            if (completionHandler) {
                completionHandler();
            }
        }];
    }
}



#pragma mark - Key/Value Observing

-(NSUInteger) countOfMediaItems {
    
    return self.mediaItems.count;
    
}

-(id) objectInMediaItemsAtIndex:(NSUInteger)index {
    return [self.mediaItems objectAtIndex:index];
    
}

-(NSArray *) mediaItemsAtIndexes:(NSIndexSet *)indexes{
    return [self.mediaItems objectsAtIndexes:indexes];
    
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
    


+(NSString *) instagramClientID{
    
    return @"d97c203c7ed74623977e555bad3a2225"; // my logon key
    //return @"ac6921d2952f4140968635727471fb4d"; // donniebloc / bloc1234 key for other student

    
}

// Since we know those methods use a completion handler (NewItemCompletionBlock), let's start by allowing populateDataWithParameters: to accept a completion block as well.

- (void) populateDataWithParameters:(NSDictionary *)parameters completionHandler:(NewItemCompletionBlock)completionHandler {
    if (self.accessToken) {
        // only try to get the data if there's an access token
        
    
        // create a paramters dictionary for the access token and add in other parameters that might be passed such as min_id and max_id. The request operation manager gets the resource, and if it's successful, responseObject is passed to parseDataFromFeedDictionary:fromRequestWithParameters: for parsing.
        
        NSMutableDictionary *mutableParameters = [@{@"access_token": self.accessToken} mutableCopy];
        
        [mutableParameters addEntriesFromDictionary:parameters];
        
        [self.instagramOperationManager GET:@"users/self/media/recent"
                                 parameters:mutableParameters
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                            [self parseDataFromFeedDictionary:responseObject fromRequestWithParameters:parameters];
                                        }
                                        
                                        if (completionHandler) {
                                            completionHandler(nil);
                                        }
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        if (completionHandler) {
                                            completionHandler(error);
                                        }
                                    }];
        
        
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
    
    [self saveImages];

}

-(void) saveImages{
    
    if (self.mediaItems.count > 0) {
        // write the changes to disk
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // make an array to hold 50 items at a time, convert the array into NSData and save it to disk
            NSUInteger numberOfItemsToSave = MIN(self.mediaItems.count, 50);
            NSArray *mediaItemsToSave = [self.mediaItems subarrayWithRange:NSMakeRange(0, numberOfItemsToSave)];
            
            NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(mediaItems))];
            NSData *mediaItemData = [NSKeyedArchiver archivedDataWithRootObject:mediaItemsToSave];
  
            // NSDataWritingAtomic ensures a complete file is saved. Without it, we might corrupt our file if the app crashes while writing to disk. NSDataWritingFileProtectionCompleteUnlessOpen encrypts the data. This helps protect the user's privacy.
            
            NSError *dataError;
            BOOL wroteSuccessfully = [mediaItemData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
            
            if (!wroteSuccessfully) {
                NSLog(@"Couldn't write file: %@", dataError);
            }
        });
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
        
        // set the download state when the download begins
        mediaItem.downloadState = MediaDownloadStateDownloadInProgress;
        
        
       
        // similar to the AFnteworking implementation in the populateDateWithParameters method we implement here too for download of images into the array 
        
        [self.instagramOperationManager GET:mediaItem.mediaURL.absoluteString
                                 parameters:nil
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                        if ([responseObject isKindOfClass:[UIImage class]]) {
                                            mediaItem.image = responseObject;
                                            
                                            // if download is successful set the download state to has image
                                            mediaItem.downloadState = MediaDownloadStateHasImage;
                                            
                                            NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"mediaItems"];
                                            NSUInteger index = [mutableArrayWithKVO indexOfObject:mediaItem];
                                            if (index != NSNotFound) {
                                                [mutableArrayWithKVO replaceObjectAtIndex:index withObject:mediaItem];
                                            } else {
                                                [mutableArrayWithKVO addObject:mediaItem];
                                            }
                                            [self saveImages];
                                            
                                            
                                            
                                            
                                        }else {
                                            mediaItem.downloadState = MediaDownloadStateNonRecoverableError;
                                            
                                        }
                                        
                                        [self saveImages];
                                        
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        NSLog(@"Error downloading image: %@", error);
                                        
                                // if there's an error during download we set the download state to has error
                                        mediaItem.downloadState = MediaDownloadStateNonRecoverableError;
                                        
                                    // but, if the error is a recoverable type error we set the download state to retry the download with needs image again.
                                        if ([error.domain isEqualToString:NSURLErrorDomain]) {
                                            // A networking problem
                                            if (error.code == NSURLErrorTimedOut ||
                                                error.code == NSURLErrorCancelled ||
                                                error.code == NSURLErrorCannotConnectToHost ||
                                                error.code == NSURLErrorNetworkConnectionLost ||
                                                error.code == NSURLErrorNotConnectedToInternet ||
                                                error.code == kCFURLErrorInternationalRoamingOff ||
                                                error.code == kCFURLErrorCallIsActive ||
                                                error.code == kCFURLErrorDataNotAllowed ||
                                                error.code == kCFURLErrorRequestBodyStreamExhausted) {
                                                
                                                // It might work if we try again
                                                mediaItem.downloadState = MediaDownloadStateNeedsImage;
                                            }
                                        }
                                        
                                        
                                        
                                    }];
       
        
    }
}

@end
