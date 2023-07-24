//
//  AppDelegate.h
//  RTMPLiveStreaming
//
//  Created by Mac Mini 2021_1 on 24/07/2023.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentCloudKitContainer *persistentContainer;

- (void)saveContext;


@end

