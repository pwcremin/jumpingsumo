//
//  Drone.h
//  parrot
//
//  Created by Patrick cremin on 1/13/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libARDiscovery/ARDISCOVERY_BonjourDiscovery.h>
#import <libARController/ARController.h>
#import <libARUtils/ARUTILS_Manager.h>

#import <libARDataTransfer/ARDATATRANSFER_Error.h>
#import <libARDataTransfer/ARDATATRANSFER_Manager.h>

#import <uthash/uthash.h>

@interface Drone : NSObject

-(void)sendJumpHigh;
-(void)sendJumpLong;
-(void)spin;

-(void) takePicture;
-(void)startMediaListThread;

-(void) stateChanged: (eARCONTROLLER_DEVICE_STATE) newState s:(eARCONTROLLER_ERROR) error t:(void *)customData;

@property (nonatomic, strong) ARService* service;
@property (nonatomic) ARCONTROLLER_Device_t *deviceController;
@property (nonatomic) dispatch_semaphore_t stateSem;
@property (nonatomic) dispatch_semaphore_t resolveSemaphore;

// BELOW code for taking photos (not working)
/*
#define DEVICE_PORT     21
#define MEDIA_FOLDER    "internal_000"

@property (nonatomic, assign) ARSAL_Thread_t threadRetreiveAllMedias;   // the thread that will do the media retrieving
@property (nonatomic, assign) ARSAL_Thread_t threadGetThumbnails;       // the thread that will download the thumbnails
@property (nonatomic, assign) ARSAL_Thread_t threadMediasDownloader;    // the thread that will download medias

@property (nonatomic, assign) ARDATATRANSFER_Manager_t *manager;        // the data transfer manager
@property (nonatomic, assign) ARUTILS_Manager_t *ftpListManager;        // an ftp that will do the list
@property (nonatomic, assign) ARUTILS_Manager_t *ftpQueueManager;       // an ftp that will do the download
*/
@end
