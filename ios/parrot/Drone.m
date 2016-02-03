//
//  Drone.m
//  parrot
//
//  Created by Patrick cremin on 1/13/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

@import UIKit;

#import "Drone.h"
#import <libARSAL/ARSAL.h>
#import <libARDiscovery/ARDiscovery.h>
#import <libARController/ARController.h>
#import <uthash/uthash.h>

#import <libARUtils/ARUTILS_Manager.h>
#import <libARDataTransfer/ARDATATRANSFER_Error.h>
#import <libARDataTransfer/ARDATATRANSFER_MediasDownloader.h>


#define TAG "SDKExample"

#define ERROR_STR_LENGTH 2048

#define JS_IP_ADDRESS "192.168.2.1"
#define JS_DISCOVERY_PORT 44444

ARSAL_Sem_t stateSem;


void stateChanged(eARCONTROLLER_DEVICE_STATE newState, eARCONTROLLER_ERROR error, void * customData)
{
  ARSAL_PRINT(ARSAL_PRINT_INFO, TAG, "    - stateChanged newState: %d .....", newState);
  
  switch (newState)
  {
    case ARCONTROLLER_DEVICE_STATE_STOPPED:
      ARSAL_Sem_Post (&(stateSem));
      //stop
      //      gIHMRun = 0;
      
      break;
      
    case ARCONTROLLER_DEVICE_STATE_RUNNING:
      ARSAL_Sem_Post (&(stateSem));
      break;
      
    default:
      break;
  }
}

void commandReceived(eARCONTROLLER_DICTIONARY_KEY commandKey, ARCONTROLLER_DICTIONARY_ELEMENT_t* elementDictionary, void* customData)
{
  ARCONTROLLER_Device_t *deviceController = customData;
  //  eARCONTROLLER_ERROR error = ARCONTROLLER_OK;
  
  if (deviceController != NULL)
  {
    // if the command received is a battery state changed
    if (commandKey == ARCONTROLLER_DICTIONARY_KEY_COMMON_COMMONSTATE_BATTERYSTATECHANGED)
    {
      ARCONTROLLER_DICTIONARY_ARG_t *arg = NULL;
      ARCONTROLLER_DICTIONARY_ELEMENT_t *singleElement = NULL;
      
      if (elementDictionary != NULL)
      {
        // get the command received in the device controller
        HASH_FIND_STR (elementDictionary, ARCONTROLLER_DICTIONARY_SINGLE_KEY, singleElement);
        
        if (singleElement != NULL)
        {
          // get the value
          HASH_FIND_STR (singleElement->arguments, ARCONTROLLER_DICTIONARY_KEY_COMMON_COMMONSTATE_BATTERYSTATECHANGED_PERCENT, arg);
          
          if (arg != NULL)
          {
            // update UI
            //            batteryStateChanged (arg->value.U8);
          }
          else
          {
            ARSAL_PRINT(ARSAL_PRINT_ERROR, TAG, "arg is NULL");
          }
        }
        else
        {
          ARSAL_PRINT(ARSAL_PRINT_ERROR, TAG, "singleElement is NULL");
        }
      }
      else
      {
        ARSAL_PRINT(ARSAL_PRINT_ERROR, TAG, "elements is NULL");
      }
    }
  }
}

@implementation Drone {
  ARDISCOVERY_Device_t* device;
  ARCONTROLLER_Device_t* deviceController;
}

- (id) init
{
  self = [super init];
  
  ARSAL_PRINT(ARSAL_PRINT_INFO, TAG, "- init discovey device ... ");
  eARDISCOVERY_ERROR errorDiscovery = ARDISCOVERY_OK;
  eARCONTROLLER_ERROR error = ARCONTROLLER_OK;
  eARCONTROLLER_DEVICE_STATE deviceState = ARCONTROLLER_DEVICE_STATE_MAX;
  
  device = ARDISCOVERY_Device_New (&errorDiscovery);
  
  if (errorDiscovery == ARDISCOVERY_OK)
  {
    ARSAL_PRINT(ARSAL_PRINT_INFO, TAG, "    - ARDISCOVERY_Device_InitWifi ...");
    // create a JumpingSumo discovery device (ARDISCOVERY_PRODUCT_JS)
    errorDiscovery = ARDISCOVERY_Device_InitWifi (device, ARDISCOVERY_PRODUCT_JS, "JS", JS_IP_ADDRESS, JS_DISCOVERY_PORT);
    
    if (errorDiscovery != ARDISCOVERY_OK)
    {
      ARSAL_PRINT(ARSAL_PRINT_ERROR, TAG, "Discovery error :%s", ARDISCOVERY_Error_ToString(errorDiscovery));
    }
  }
  else
  {
    ARSAL_PRINT(ARSAL_PRINT_ERROR, TAG, "Discovery error :%s", ARDISCOVERY_Error_ToString(errorDiscovery));
  }
  
  // create device controller
  deviceController = ARCONTROLLER_Device_New (device, &error);
  
  if (error != ARCONTROLLER_OK)
  {
    ARSAL_PRINT (ARSAL_PRINT_ERROR, TAG, "Creation of deviceController failed.");
  }

  
  ARSAL_PRINT(ARSAL_PRINT_INFO, TAG, "- delete discovey device ... ");
  ARDISCOVERY_Device_Delete (&device);
  
  // add the state change callback to be informed when the device controller starts, stops...


  
    error = ARCONTROLLER_Device_AddStateChangedCallback (deviceController, stateChanged, deviceController);
  
    if (error != ARCONTROLLER_OK)
    {
      ARSAL_PRINT (ARSAL_PRINT_ERROR, TAG, "add State callback failed.");
    }
  
  
  // add the command received callback to be informed when a command has been received from the device
  error = ARCONTROLLER_Device_AddCommandReceivedCallback (deviceController, commandReceived, deviceController);
  
  if (error != ARCONTROLLER_OK)
  {
    ARSAL_PRINT (ARSAL_PRINT_ERROR, TAG, "add callback failed.");
  }
  
  
  ARSAL_PRINT(ARSAL_PRINT_INFO, TAG, "Connecting ...");
  error = ARCONTROLLER_Device_Start (deviceController);
  
  if (error != ARCONTROLLER_OK)
  {
    ARSAL_PRINT(ARSAL_PRINT_ERROR, TAG, "- error :%s", ARCONTROLLER_Error_ToString(error));
  }
  
  
  // wait state update update
  ARSAL_Sem_Wait (&(stateSem));
  
  deviceState = ARCONTROLLER_Device_GetState (deviceController, &error);
  
  if ((error != ARCONTROLLER_OK) || (deviceState != ARCONTROLLER_DEVICE_STATE_RUNNING))
  {
    ARSAL_PRINT(ARSAL_PRINT_ERROR, TAG, "- deviceState :%d", deviceState);
    ARSAL_PRINT(ARSAL_PRINT_ERROR, TAG, "- error :%s", ARCONTROLLER_Error_ToString(error));
  }
  
  return self;
}

-(void)sendJumpHigh
{
  if(deviceController != NULL)
  {
   
    //struct ARCONTROLLER_FEATURE_JumpingSumo_t* sumo = deviceController.jumpingSumo;
    
    // send a jump command to the JS
    deviceController->jumpingSumo->sendAnimationsJump(deviceController->jumpingSumo, ARCOMMANDS_JUMPINGSUMO_ANIMATIONS_JUMP_TYPE_HIGH);
  }

}

-(void)sendJumpLong
{
  if(deviceController != NULL)
  {
    
    //struct ARCONTROLLER_FEATURE_JumpingSumo_t* sumo = deviceController.jumpingSumo;
    
    // send a jump command to the JS
    deviceController->jumpingSumo->sendAnimationsJump(deviceController->jumpingSumo, ARCOMMANDS_JUMPINGSUMO_ANIMATIONS_JUMP_TYPE_LONG);
  }
}

-(void) spin
{
  [self simpleAnimation:ARCOMMANDS_JUMPINGSUMO_ANIMATIONS_SIMPLEANIMATION_ID_SPIN];
}


/*
 typedef enum
 {
 ARCOMMANDS_JUMPINGSUMO_ANIMATIONS_SIMPLEANIMATION_ID_STOP = 0,    ///< Stop ongoing animation.
 ARCOMMANDS_JUMPINGSUMO_ANIMATIONS_SIMPLEANIMATION_ID_SPIN,    ///< Start a spin animation.
 ARCOMMANDS_JUMPINGSUMO_ANIMATIONS_SIMPLEANIMATION_ID_TAP,    ///< Start a tap animation.
 ARCOMMANDS_JUMPINGSUMO_ANIMATIONS_SIMPLEANIMATION_ID_SLOWSHAKE,    ///< Start a slow shake animation.
 ARCOMMANDS_JUMPINGSUMO_ANIMATIONS_SIMPLEANIMATION_ID_METRONOME,    ///< Start a Metronome animation.
 ARCOMMANDS_JUMPINGSUMO_ANIMATIONS_SIMPLEANIMATION_ID_ONDULATION,    ///< Start a standing dance animation.
 ARCOMMANDS_JUMPINGSUMO_ANIMATIONS_SIMPLEANIMATION_ID_SPINJUMP,    ///< Start a spin jump animation.
 ARCOMMANDS_JUMPINGSUMO_ANIMATIONS_SIMPLEANIMATION_ID_SPINTOPOSTURE,    ///< Start a spin that end in standing posture, or in jumper if it was standing animation.
 ARCOMMANDS_JUMPINGSUMO_ANIMATIONS_SIMPLEANIMATION_ID_SPIRAL,    ///< Start a spiral animation.
 ARCOMMANDS_JUMPINGSUMO_ANIMATIONS_SIMPLEANIMATION_ID_SLALOM,    ///< Start a slalom animation.
 ARCOMMANDS_JUMPINGSUMO_ANIMATIONS_SIMPLEANIMATION_ID_MAX
 } eARCOMMANDS_JUMPINGSUMO_ANIMATIONS_SIMPLEANIMATION_ID;
 */
-(void) simpleAnimation:(eARCOMMANDS_JUMPINGSUMO_ANIMATIONS_SIMPLEANIMATION_ID) animationType
{
  if(deviceController != NULL)
  {
    
    //struct ARCONTROLLER_FEATURE_JumpingSumo_t* sumo = deviceController.jumpingSumo;
    
    // send a jump command to the JS
    deviceController->jumpingSumo->sendAnimationsSimpleAnimation(deviceController->jumpingSumo, animationType);
  }
}

// BELOW code for taking photos (not working)
/*
//---------------------------------------------------------------------------------
//  PICTURES
//---------------------------------------------------------------------------------

-(void) takePicture
{
  deviceController->jumpingSumo->sendMediaRecordPicture(deviceController->jumpingSumo, 0);
}


- (void)createDataTransferManager
{
  NSString *productIP = @JS_IP_ADDRESS;  // TODO: get this address from libARController
  
  eARDATATRANSFER_ERROR result = ARDATATRANSFER_OK;
  _manager = ARDATATRANSFER_Manager_New(&result);
  
  if (result == ARDATATRANSFER_OK)
  {
    eARUTILS_ERROR ftpError = ARUTILS_OK;
    _ftpListManager = ARUTILS_Manager_New(&ftpError);
    if(ftpError == ARUTILS_OK)
    {
      _ftpQueueManager = ARUTILS_Manager_New(&ftpError);
    }
    
    if(ftpError == ARUTILS_OK)
    {
      ftpError = ARUTILS_Manager_InitWifiFtp(_ftpListManager, [productIP UTF8String], DEVICE_PORT, ARUTILS_FTP_ANONYMOUS, "");
    }
    
    if(ftpError == ARUTILS_OK)
    {
      ftpError = ARUTILS_Manager_InitWifiFtp(_ftpQueueManager, [productIP UTF8String], DEVICE_PORT, ARUTILS_FTP_ANONYMOUS, "");
    }
    
    if(ftpError != ARUTILS_OK)
    {
      result = ARDATATRANSFER_ERROR_FTP;
    }
  }
  // NO ELSE
  
  if (result == ARDATATRANSFER_OK)
  {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    
    result = ARDATATRANSFER_MediasDownloader_New(_manager, _ftpListManager, _ftpQueueManager, MEDIA_FOLDER, [path UTF8String]);
  }
}

- (void)startMediaListThread
{
  // first retrieve Medias without their thumbnails
  ARSAL_Thread_Create(&_threadRetreiveAllMedias, ARMediaStorage_retreiveAllMediasAsync, (__bridge void *)self);
}

static void* ARMediaStorage_retreiveAllMediasAsync(void* arg)
{
  
  Drone *self = (__bridge Drone *)(arg);
  [self getAllMediaAsync];
  return NULL;
}

- (void)getAllMediaAsync
{
  eARDATATRANSFER_ERROR result = ARDATATRANSFER_OK;
  int mediaListCount = 0;
  
  if (result == ARDATATRANSFER_OK)
  {
    mediaListCount = ARDATATRANSFER_MediasDownloader_GetAvailableMediasSync(_manager,0,&result);
    if (result == ARDATATRANSFER_OK)
    {
      for (int i = 0 ; i < mediaListCount && result == ARDATATRANSFER_OK; i++)
      {
        ARDATATRANSFER_Media_t * mediaObject = ARDATATRANSFER_MediasDownloader_GetAvailableMediaAtIndex(_manager, i, &result);
        NSLog(@"Media %i: %s", i, mediaObject->name);
        // Do what you want with this mediaObject
      }
    }
  }
}

- (void)startMediaThumbnailDownloadThread
{
  // first retrieve Medias without their thumbnails
  ARSAL_Thread_Create(&_threadGetThumbnails, ARMediaStorage_retreiveMediaThumbnailsSync, (__bridge void *)self);
}

static void* ARMediaStorage_retreiveMediaThumbnailsSync(void* arg)
{
  Drone *self = (__bridge Drone *)(arg);
  [self downloadThumbnails];
  return NULL;
}

- (void)downloadThumbnails
{
  ARDATATRANSFER_MediasDownloader_GetAvailableMediasAsync(_manager, availableMediaCallback, (__bridge void *)self);
}

void availableMediaCallback (void* arg, ARDATATRANSFER_Media_t *media, int index)
{
  if (NULL != arg)
  {
    //Drone *self = (__bridge Drone *)(arg);
    // you can alternatively call updateThumbnailWithARDATATRANSFER_Media_t if you use the ARMediaObjectDelegate
    UIImage *newThumbnail = [UIImage imageWithData:[NSData dataWithBytes:media->thumbnail length:media->thumbnailSize]];
    // Do what you want with the image
  }
}
*/
@end
