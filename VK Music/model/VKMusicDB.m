//
//  VKMusicDB.m
//  VK Music
//
//  Created by Vitaliy Volokh on 8/28/12.
//  Copyright (c) 2012 Softheme. All rights reserved.
//

#import "VKMusicDB.h"

// singleton
static VKMusicDB *sharedSingleton;

@interface VKMusicDB (private)

// db context
- (NSManagedObjectContext *) _getContext;

- (NSArray *) _fetchRequest:(NSFetchRequest *) fetchRequest;

-(NSArray *) _getMusicIds;

- (BOOL) _deleteRecords:(NSArray *) records;
@end



@implementation VKMusicDB


// syngleton initialization
+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        sharedSingleton = [[VKMusicDB alloc] init];
    }
}

+(VKMusicDB*) sharedInstance 
{
    return sharedSingleton;
}


- (NSManagedObjectContext *) _getContext 
{
    return [[RHManagedObjectContextManager sharedInstance] managedObjectContext];
}

- (NSArray *) _fetchRequest:(NSFetchRequest *) fetchRequest 
{
    NSError *errorWhileFetching = nil;
    NSArray *fetchResult = nil;
    
    fetchResult = [[self _getContext] executeFetchRequest:fetchRequest error:&errorWhileFetching];
    
    if( errorWhileFetching != nil ) 
    {
        NSLog(@"Error occured while saving db contexts: %@", errorWhileFetching.description);
    } 
    else 
    {
        //NSLog(@"Shops is: %@", fetchResult);
    }
    
    return fetchResult;
}

-(NSArray *) _getMusicIds 
{
    NSArray *musicList = [self getAllMusic];
    NSMutableArray *idsList = [[NSMutableArray alloc] init];
    
    for (Audio *audioItem in musicList) 
    {
        [idsList addObject:audioItem.aid];
    }
    
    return [idsList autorelease];
}

- (BOOL) _deleteRecords:(NSArray *) records 
{
    BOOL result = NO;
    
    for (NSManagedObject *shopItem in records) 
    {
        [[self _getContext] deleteObject:shopItem];
    }
    
    result = [[RHManagedObjectContextManager sharedInstance] commit];
    
    return result;
}




-(BOOL) saveMusic:(NSArray *) musicList 
{
    BOOL result = NO;
    
    NSArray *existsMusicIds = [self _getMusicIds];
    
    for (NSDictionary *audioItem in musicList) 
    {
        NSNumber *aid = [NSNumber numberWithInt:[[[audioItem objectForKey:@"aid"] valueForKey:@"_content"] intValue]];
        
        if([existsMusicIds indexOfObject:aid] != NSNotFound) {
            // audio already exists
            continue;
        }
        
        Audio *newAudio = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Audio class]) inManagedObjectContext:[self _getContext]];
        
           newAudio.aid = aid;
        newAudio.artist = [[audioItem objectForKey:@"artist"] valueForKey:@"_content"];
        newAudio.duration = [[audioItem objectForKey:@"duration"] valueForKey:@"_content"];
        newAudio.lyrics_id = [NSNumber numberWithInt:[[[audioItem objectForKey:@"lyrics_id"] valueForKey:@"_content"] intValue]];
        newAudio.owner_id = [NSNumber numberWithInt:[[[audioItem objectForKey:@"owner_id"] valueForKey:@"_content"] intValue]];
        newAudio.title = [[audioItem objectForKey:@"title"] valueForKey:@"_content"];
        newAudio.url = [[audioItem objectForKey:@"url"] valueForKey:@"_content"];
    }
    
    result = [[RHManagedObjectContextManager sharedInstance] commit];
    
    return result;
}


-(NSArray *) getAllMusic 
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([Audio class]) inManagedObjectContext:[self _getContext]];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];

    
    NSArray *res = [self _fetchRequest:fetchRequest];
    [fetchRequest release];
    return res;
}


-(BOOL) deleteAllMusic 
{
    return [self _deleteRecords:[self getAllMusic]];
}

@end
