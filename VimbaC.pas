Unit VimbaC;
(*=============================================================================
  Copyright (C) 2012 - 2017 Allied Vision Technologies.  All Rights Reserved.

  Redistribution of this header file, in original or modified form, without
  prior written consent of Allied Vision Technologies is prohibited.

-------------------------------------------------------------------------------

  File:        VimbaC.h

  Description: Main header file for the VimbaC API.

-------------------------------------------------------------------------------

  THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF TITLE,
  NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR  PURPOSE ARE
  DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
  TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=============================================================================*)

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

Interface

uses
  VmbCommonTypes;

Type
  PPANSIchar = ^PAnsiChar;
  PPVmbUInt32_t = ^VmbUint32_t;
  PPByte = ^Byte;

// This file describes all necessary definitions for using Allied Vision's
// VimbaC API. These type definitions are designed to be portable from other
// languages and other operating systems.
//
// General conventions:
// - Method names are composed in the following manner:
//    - Vmb"Action"                                        example: VmbStartup()
//    - Vmb"Entity""Action" or Vmb"ActionTarget""Action"   example: VmbInterfaceOpen()
//    - Vmb"Entity""SubEntity/ActionTarget""Action"        example: VmbFeatureCommandRun()
// - Methods dealing with features, memory or registers accept a handle from the following
//   entity list as first parameter: System, Camera, Interface and AncillaryData.
//   All other methods taking handles accept only a specific handle.
// - Strings (generally declared as "const char *") are assumed to have a trailing 0 character
// - All pointer parameters should of course be valid, except if stated otherwise.
// - To ensure compatibility with older programs linked against a former version of the API,
//   all struct* parameters have an accompanying sizeofstruct parameter.
// - Functions returning lists are usually called twice: once with a zero buffer
//   to get the length of the list, and then again with a buffer of the correct length.

//===== #DEFINES ==============================================================

(*
{$ifdef WIN32}
  {$ifdef AVT_VMBAPI_C_EXPORTS}                                                 // DLL exports
    {$define IMEXPORTC} // /*__declspec(dllexport)   HINT: We export via the .def file */
  {$elseifdef AVT_VMBAPI_C_LIB}                                                 // static LIB
    {$define IMEXPORTC}
  {$else}                                                                       // import
    {$define IMEXPORTC __declspec(dllimport)}
  {$endif}
{$endif}
*)

//===== TYPES ==============================================================

{$ifdef __cplusplus}
  extern "C"
{$endif}

// Timeout parameter signaling a blocking call
const VMBINFINITE = $FFFFFFFF;
{$EXTERNALSYM VMBINFINITE}

// Constant for the Vimba handle to be able to access Vimba system features
  //gVimbaHandle = Pointer(1);                                                    //access Vimba system features
  gVimbaHandle = VmbHandle_t(1);
  VMB_CALL     = 'VimbaC.dll';

{$IFDEF WIN32}
  {$ALIGN 1}
{$ELSE} // Win64
  {$ALIGN 8}
{$ENDIF}

// Camera interface type (for instance FireWire, Ethernet);
type
  VmbInterfaceType = (
    VmbInterfaceUnknown      = 0,           // Interface is not known to this version of the API
    VmbInterfaceFirewire     = 1,           // 1394
    VmbInterfaceEthernet     = 2,           // GigE
    VmbInterfaceUsb          = 3,           // USB 3.0
    VmbInterfaceCL           = 4,           // Camera Link
    VmbInterfaceCSI2         = 5);          // CSI-2

    VmbInterface_t = VmbUint32_t;           // Type for an Interface; for values see VmbInterfaceType

  // Access mode for configurable devices (interfaces, cameras).
  // Used in VmbCameraInfo_t, VmbInterfaceInfo_t as flags, so multiple modes can be
  // announced, while in VmbCameraOpen(), no combination must be used.
  VmbAccessModeType = (
    VmbAccessModeNone       = 0,            // No access
    VmbAccessModeFull       = 1,            // Read and write access
    VmbAccessModeRead       = 2,            // Read-only access
    VmbAccessModeConfig     = 4,            // Configuration access (GeV)
    VmbAccessModeLite       = 8);           // Read and write access without feature access (only addresses)

  VmbAccessMode_t = VmbUint32_t;            // Type for an AccessMode; for values see VmbAccessModeType

  // Interface information.
  // Holds read-only information about an interface.
  VmbInterfaceInfo_t = Record
    interfaceIdString : pANSIchar;          // Unique identifier for each interface
    interfaceType     : VmbInterface_t;     // Interface type, see VmbInterfaceType
    interfaceName     : pANSIchar;          // Interface name, given by the transport layer
    serialString      : pANSIchar;          // Serial number
    permittedAccess   : VmbAccessMode_t;    // Used access mode, see VmbAccessModeType
  end;

  VmbCameraInfo_t =  Record
    cameraIdString    : pANSIchar;          // Unique identifier for each camera
    cameraName        : pANSIchar;          // Name of the camera
    modelName         : pANSIchar;          // Model name
    serialString      : pANSIchar;          // Serial number
    permittedAccess   : VmbAccessMode_t;    // Used access mode, see VmbAccessModeType
    interfaceIdString : pANSIchar;          // Unique value for each interface or bus
  end;

  // Supported feature data types
  VmbFeatureDataType = (
      VmbFeatureDataUnknown     = 0,        // Unknown feature type
      VmbFeatureDataInt         = 1,        // 64 bit integer feature
      VmbFeatureDataFloat       = 2,        // 64 bit floating point feature
      VmbFeatureDataEnum        = 3,        // Enumeration feature
      VmbFeatureDataString      = 4,        // String feature
      VmbFeatureDataBool        = 5,        // Boolean feature
      VmbFeatureDataCommand     = 6,        // Command feature
      VmbFeatureDataRaw         = 7,        // Raw (direct register access) feature
      VmbFeatureDataNone        = 8         // Feature with no data
  );
  VmbFeatureData_t = VmbUint32_t;           // Data type for a Feature; for values see VmbFeatureDataType

  // Feature visibility
  VmbFeatureVisibilityType = (
      VmbFeatureVisibilityUnknown      = 0, // Feature visibility is not known
      VmbFeatureVisibilityBeginner     = 1, // Feature is visible in feature list (beginner level)
      VmbFeatureVisibilityExpert       = 2, // Feature is visible in feature list (expert level)
      VmbFeatureVisibilityGuru         = 3, // Feature is visible in feature list (guru level)
      VmbFeatureVisibilityInvisible    = 4  // Feature is not visible in feature list
  );
  VmbFeatureVisibility_t = VmbUint32_t;     // Type for Feature visibility; for values see VmbFeatureVisibilityType

  // Feature flags
  VmbFeatureFlagsType = (
      VmbFeatureFlagsNone         = 0,      // No additional information is provided
      VmbFeatureFlagsRead         = 1,      // Static info about read access. Current status depends on access mode, check with VmbFeachtureAccessQuery()
      VmbFeatureFlagsWrite        = 2,      // Static info about write access. Current status depends on access mode, check with VmbFeachtureAccessQuery()
      VmbFeatureFlagsVolatile     = 8,      // Value may change at any time
      VmbFeatureFlagsModifyWrite  = 16      // Value may change after a write
  );
  VmbFeatureFlags_t = VmbUint32_t;          // Type for Feature flags; for values see VmbFeatureFlagsType

  // Feature information. Holds read-only information about a feature.
  VmbFeatureInfo_t = Record
    name                : pANSIchar;              // Name used in the API
    featureDataType     : VmbFeatureData_t;       // Data type of this feature
    featureFlags        : VmbFeatureFlags_t;      // Access flags for this feature
    category            : pANSIchar;              // Category this feature can be found in
    displayName         : pANSIchar;              // Feature name to be used in GUIs
    pollingTime         : VmbUint32_t;            // Predefined polling time for volatile features
    _unit               : pANSIchar;              // Measuring unit as given in the XML file
    representation      : pANSIchar;              // Representation of a numeric feature
    visibility          : VmbFeatureVisibility_t; // GUI visibility
    tooltip             : pANSIchar;              // Short description, e.g. for a tooltip
    description         : pANSIchar;              // Longer description
    sfncNamespace       : pANSIchar;              // Namespace this feature resides in
    isStreamable        : Boolean;                // Indicates if a feature can be stored to / loaded from a file
    hasAffectedFeatures : Boolean;                // Indicates if the feature potentially affects other features
    hasSelectedFeatures : Boolean;                // Indicates if the feature selects other features
  end;

  // Info about possible entries of an enumeration feature
  VmbFeatureEnumEntry_t = Record
    name          : pANSIchar;                    // Name used in the API
    displayName   : pANSIchar;                    // Enumeration entry name to be used in GUIs
    visibility    : VmbFeatureVisibility_t;       // GUI visibility
    tooltip       : pANSIchar;                    // Short description, e.g. for a tooltip
    description   : pANSIchar;                    // Longer description
    sfncNamespace : pANSIchar;                    // Namespace this feature resides in
    intValue      : VmbInt64_t;                   // Integer value of this enumeration entry
  end;

  // Status of a frame transfer
  VmbFrameStatusType_t = (
      VmbFrameStatusComplete       =  0,      // Frame has been completed without errors
      VmbFrameStatusIncomplete     = -1,      // Frame could not be filled to the end
      VmbFrameStatusTooSmall       = -2,      // Frame buffer was too small
      VmbFrameStatusInvalid        = -3       // Frame buffer was invalid
  );
  VmbFrameStatus_t = VmbInt32_t;              // Type for the frame status; for values see VmbFrameStatusType

  // Frame flags
  VmbFrameFlagsType_t = (
      VmbFrameFlagsNone       = 0,            // No additional information is provided
      VmbFrameFlagsDimension  = 1,            // Frame's dimension is provided
      VmbFrameFlagsOffset     = 2,            // Frame's offset is provided (ROI)
      VmbFrameFlagsFrameID    = 4,            // Frame's ID is provided
      VmbFrameFlagsTimestamp  = 8             // Frame's timestamp is provided
  );
  VmbFrameFlags_t = VmbUint32_t;              // Type for Frame flags; for values see VmbFrameFlagsType

  // Frame delivered by the camera
  VmbFrame_t = Record
    //----- In -----
    buffer              : Pointer;                // Image and ancillary data
    bufferSize          : VmbUint32_t;            // Size of data buffer
    context             : Array[0..3] of Pointer; // 4 void pointer that can be employed by the user (e.g. for storing handles)

    //----- Out -----
    receiveStatus       : VmbFrameStatus_t;       // Resulting status of the receive operation
    receiveFlags        : VmbFrameFlags_t;        // Flags indicating which additional frame information is available
    imageSize           : VmbUint32_t;            // Size of the image data inside the data buffer
    ancillarySize       : VmbUint32_t;            // Size of the ancillary data inside the data buffer
    pixelFormat         : VmbPixelFormat_t;       // Pixel format of the image
    width               : VmbUint32_t;            // Width of image
    height              : VmbUint32_t;            // Height of image
    offsetX             : VmbUint32_t;            // Horizontal offset of image
    offsetY             : VmbUint32_t;            // Vertical offset of image
    {$ifdef Win32}
      frameID           : VmbUint32_t;            // Unique ID of this frame in the stream
      timestamp         : VmbUint32_t;            // Timestamp set by the camera
    {$else}
      frameID           : VmbUint64_t;            // Unique ID of this frame in the stream
      timestamp         : VmbUint64_t;            // Timestamp set by the camera
    {$endif}
  end;

  // Type of features that are to be saved (persisted) to the XML file when using VmbCameraSettingsSave
  VmbFeaturePersistType = (
      VmbFeaturePersistAll        = 0,        // Save all features to XML, including look-up tables
      VmbFeaturePersistStreamable = 1,        // Save only features marked as streamable, excluding look-up tables
      VmbFeaturePersistNoLUT      = 2         // Save all features except look-up tables (default)
  );
  VmbFeaturePersist_t = VmbUint32_t;          // Type for feature persistence; for values see VmbFeaturePersistType

  // Parameters determining the operation mode of VmbCameraSettingsSave and VmbCameraSettingsLoad
  VmbFeaturePersistSettings_t = Record
    persistType     : VmbFeaturePersist_t;    // Type of features that are to be saved
    maxIterations   : VmbUint32_t;            // Number of iterations when loading settings
    loggingLevel    : VmbUint32_t;            // Determines level of detail for load/save settings logging
  end;

  PCamera = VmbCameraInfo_t;

// ----- Callbacks ------------------------------------------------------------

//
// Name: VmbInvalidationCallback
//
// Purpose: Invalidation Callback type for a function that gets called in a separate thread
//          and has been registered with VmbFeatureInvalidationRegister()
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle          Handle for an entity that exposes features
//  [in ]  const char*          name            Name of the feature
//  [in ]  void*                pUserContext    Pointer to the user context, see VmbFeatureInvalidationRegister
//
// Details:     While the callback is run, all feature data is atomic.  After the
//              callback finishes, the feature data might be updated with new values.
//
// Note:        Do not spend too much time in this thread; it will prevent the feature values
//              from being updated from any other thread or the lower-level drivers.
//
//typedef void (VMB_CALL *VmbInvalidationCallback)(
//                                const VmbHandle_t  handle,
//                                const char*  name,
//                                void*  pUserContext);

Type
   _VmbInvalidationCallback = Record
     handle      : VmbHandle_t;
     name        : pANSIchar;
     pUserContext: Pointer;
   End;

// Name: VmbFrameCallback
//
// Purpose: Frame Callback type for a function that gets called in a separate thread
//          if a frame has been queued with VmbCaptureFrameQueue()
//
// Parameters:
//
//  [in ]  const VmbHandle_t    cameraHandle    Handle of the camera
//  [out]  VmbFrame_t*          pFrame          Frame completed
//
//typedef void (VMB_CALL *VmbFrameCallback)( const VmbHandle_t  cameraHandle, VmbFrame_t*  pFrame );

  _VmbFrameCallback = record
    cameraHandle: VmbHandle_t;
    var pFrame  : VmbFrame_t
  end;
//Procedure VmbFrameCallback(cameraHandle: VmbHandle_t;
//                           var pFrame  : VmbFrame_t);
//                           {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//===== FUNCTION PROTOTYPES ===================================================

//----- API Version -----------------------------------------------------------

//
// Method:      VmbVersionQuery()
//
// Purpose:     Retrieve the version number of VimbaC.
//
// Parameters:
//
//  [out]  VmbVersionInfo_t*    pVersionInfo        Pointer to the struct where version information
//                                                  is copied
//  [in ]  VmbUint32_t          sizeofVersionInfo   Size of structure in bytes
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorStructSize:    The given struct size is not valid for this version of the API
//  - VmbErrorBadParameter:  If "pVersionInfo" is NULL.
//
// Details:     This function can be called at anytime, even before the API is
//              initialized. All other version numbers may be queried via feature access.
//
//IMEXPORTC VmbError_t VMB_CALL VmbVersionQuery ( VmbVersionInfo_t*  pVersionInfo,
//                                                VmbUint32_t        sizeofVersionInfo );
Function VmbVersionQuery(var pVersionInfo : VmbVersionInfo_t;
                         sizeofVersionInfo: VmbUint32_t): VmbError_t;
                         {$ifdef Win64} cdecl; {$else} stdcall; {$endif}


//----- API Initialization ----------------------------------------------------

//
// Method:      VmbStartup()
//
// Purpose:     Initialize the VimbaC API.
//
// Parameters:
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorInternalFault: An internal fault occurred
//
// Details:     On successful return, the API is initialized; this is a necessary call.
//
// Note:        This method must be called before any VimbaC function other than VmbVersionQuery() is run.
//
//IMEXPORTC VmbError_t VMB_CALL VmbStartup ( void );

Function VmbStartup: VmbError_t; {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//
// Method:      VmbShutdown()
//
// Purpose:     Perform a shutdown on the API.
//
// Parameters:  none
//
// Returns:     none
//
// Details:     This will free some resources and deallocate all physical resources if applicable.
//
//IMEXPORTC void VMB_CALL VmbShutdown ( void );

Procedure VmbShutdown; {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//----- Camera Enumeration & Information --------------------------------------

//
// Method:      VmbCamerasList()
//
// Purpose:     Retrieve a list of all cameras.
//
// Parameters:
//
//  [out]  VmbCameraInfo_t*  pCameraInfo        Array of VmbCameraInfo_t, allocated by
//                                              the caller. The camera list is
//                                              copied here. May be NULL if pNumFound is used for size query.
//  [in ]  VmbUint32_t       listLength         Number of VmbCameraInfo_t elements provided
//  [out]  VmbUint32_t*      pNumFound          Number of VmbCameraInfo_t elements found.
//  [in ]  VmbUint32_t       sizeofCameraInfo   Size of the structure (if pCameraInfo == NULL this parameter is ignored)
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorStructSize:    The given struct size is not valid for this API version
//  - VmbErrorMoreData:      The given list length was insufficient to hold all available entries
//  - VmbErrorBadParameter:  If "pNumFound" was NULL
//
// Details:     Camera detection is started with the registration of the "DiscoveryCameraEvent"
//              event or the first call of VmbCamerasList(), which may be delayed if no
//              "DiscoveryCameraEvent" event is registered (see examples).
//              VmbCamerasList() is usually called twice: once with an empty array to query the
//              list length, and then again with an array of the correct length. If camera
//              lists change between the calls, pNumFound may deviate from the query return.
//
//IMEXPORTC VmbError_t VMB_CALL VmbCamerasList ( VmbCameraInfo_t*   pCameraInfo,
//                                               VmbUint32_t        listLength,
//                                               VmbUint32_t*       pNumFound,
//                                               VmbUint32_t        sizeofCameraInfo );

Function VmbCamerasList(pCameraInfo : Pointer;//VmbCameraInfo_t;//pCamera;
                        listLength      : VmbUint32_t;
                        var pNumFound   : VmbUint32_t;
                        sizeofCameraInfo: VmbUint32_t): VmbError_t;
                        {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//
// Method:      VmbCameraInfoQuery()
//
// Purpose:     Retrieve information on a camera given by an ID.
//
// Parameters:
//
//  [in ] const char*       idString           ID of the camera
//  [out] VmbCameraInfo_t*  pInfo              Structure where information will be copied. May be NULL.
//  [in ] VmbUint32_t       sizeofCameraInfo   Size of the structure
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorNotFound:      The designated camera cannot be found
//  - VmbErrorStructSize:    The given struct size is not valid for this API version
//  - VmbErrorBadParameter:  If "idString" was NULL
//
// Details:     May be called if a camera has not been opened by the application yet.
//              Examples for "idString": 
//              "DEV_81237473991" for an ID given by a transport layer,
//              "169.254.12.13" for an IP address,
//              "000F314C4BE5" for a MAC address or
//              "DEV_1234567890" for an ID as reported by Vimba
//
Function VmbCameraInfoQuery(idString        : pANSIchar;
                            var pInfo       : VmbCameraInfo_t;
                            sizeofCameraInfo: VmbUint32_t): VmbError_t;
                            {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//
// Method:      VmbCameraOpen()
//
// Purpose:     Open the specified camera.
//
// Parameters:
//
//  [in ]  const char*      idString        ID of the camera
//  [in ]  VmbAccessMode_t  accessMode      Determines the level of control you have on the camera
//  [out]  VmbHandle_t*     pCameraHandle   A camera handle
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorNotFound:      The designated camera cannot be found
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorInvalidCall:   If called from frame callback
//  - VmbErrorBadParameter:  If "idString" or "pCameraHandle" is NULL
//
// Details:     A camera may be opened in a specific access mode, which determines
//              the level of control you have on a camera.
//              Examples for "idString":
//              "DEV_81237473991" for an ID given by a transport layer,
//              "169.254.12.13" for an IP address,
//              "000F314C4BE5" for a MAC address or
//              "DEV_1234567890" for an ID as reported by Vimba
//
//IMEXPORTC VmbError_t VMB_CALL VmbCameraOpen ( const char*      idString,
//                                              VmbAccessMode_t  accessMode,
//                                              VmbHandle_t*     pCameraHandle );
Function VmbCameraOpen(idString         : pANSIchar;
                       accessMode       : VmbAccessMode_t;
                       pCameraHandle    : VmbHandle_t): VmbError_t;
                       {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//
// Method:      VmbCameraClose()
//
// Purpose:     Close the specified camera.
//
// Parameters:
//
//  [in ]  const VmbHandle_t  cameraHandle      A valid camera handle
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorInvalidCall:   If called from frame callback
//
// Details:     Depending on the access mode this camera was opened with, events are killed,
//              callbacks are unregistered, and camera control is released.
//
//IMEXPORTC VmbError_t VMB_CALL VmbCameraClose ( const VmbHandle_t  cameraHandle );
Function VmbCameraClose(cameraHandle: VmbHandle_t): VmbError_t;
                        {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//----- Features ----------------------------------------------------------

//
// Method:      VmbFeaturesList()
//
// Purpose:     List all the features for this entity.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle            Handle for an entity that exposes features
//  [out]  VmbFeatureInfo_t*    pFeatureInfoList  An array of VmbFeatureInfo_t to be filled by the API. May be NULL if pNumFund is used for size query.
//  [in ]  VmbUint32_t          listLength        Number of VmbFeatureInfo_t elements provided
//  [out]  VmbUint32_t*         pNumFound         Number of VmbFeatureInfo_t elements found. May be NULL if pFeatureInfoList is not NULL.
//  [in ]  VmbUint32_t          sizeofFeatureInfo Size of a VmbFeatureInfo_t entry
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorStructSize:    The given struct size of VmbFeatureInfo_t is not valid for this version of the API
//  - VmbErrorMoreData:      The given list length was insufficient to hold all available entries
//
// Details:     This method lists all implemented features, whether they are currently available or not.
//              The list of features does not change as long as the camera/interface is connected.
//              "pNumFound" returns the number of VmbFeatureInfo elements.
//              This function is usually called twice: once with an empty list to query the length
//              of the list, and then again with an list of the correct length.
//              
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeaturesList ( const VmbHandle_t   handle,
//                                                VmbFeatureInfo_t*   pFeatureInfoList,
//                                                VmbUint32_t         listLength,
//                                                VmbUint32_t*        pNumFound,
//                                                VmbUint32_t         sizeofFeatureInfo );
Function VmbFeaturesList(handle                 : VmbHandle_t;
                         pFeatureInfoList       : VmbFeatureInfo_t;
                         const listLength       : VmbUint32_t;
                         pNumFound              : VmbUint32_t;
                         const sizeofFeatureInfo: VmbUint32_t): VmbError_t;
                         {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

// Method:      VmbFeatureInfoQuery()
//
// Purpose:     Query information about the constant properties of a feature.
//
// Parameters:
//
//  [in ]  const VmbHandle_t        handle             Handle for an entity that exposes features
//  [in ]  const char*              name               Name of the feature
//  [out]  VmbFeatureInfo_t*        pFeatureInfo       The feature info to query
//  [in ]  VmbUint32_t              sizeofFeatureInfo  Size of the structure
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorStructSize:    The given struct size is not valid for this version of the API
//
// Details:     Users provide a pointer to VmbFeatureInfo_t, which is then set to the internal representation.
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureInfoQuery ( const VmbHandle_t   handle,
//                                                    const char*         name,
//                                                    VmbFeatureInfo_t*   pFeatureInfo,
//                                                    VmbUint32_t         sizeofFeatureInfo );

Function VmbFeatureInfoQuery(handle           : VmbHandle_t;
                             name             : PANSIChar;
                             var pFeatureInfo : VmbFeatureInfo_t;
                             sizeofFeatureInfo: VmbUint32_t): VmbError_t;
                             {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//
// Method:      VmbFeatureListAffected()
//
// Purpose:     List all the features that might be affected by changes to this feature.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle              Handle for an entity that exposes features
//  [in ]  const char*          name                Name of the feature
//  [out]  VmbFeatureInfo_t*    pFeatureInfoList    An array of VmbFeatureInfo_t to be filled by the API. May be NULL if pNumFound is used for size query.
//  [in ]  VmbUint32_t          listLength          Number of VmbFeatureInfo_t elements provided
//  [out]  VmbUint32_t*         pNumFound           Number of VmbFeatureInfo_t elements found. May be NULL is pFeatureInfoList is not NULL.
//  [in ]  VmbUint32_t          sizeofFeatureInfo   Size of a VmbFeatureInfo_t entry
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorStructSize:    The given struct size of VmbFeatureInfo_t is not valid for this version of the API
//  - VmbErrorMoreData:      The given list length was insufficient to hold all available entries
//
// Details:     This method lists all affected features, whether they are currently available or not.
//              The value of affected features depends directly or indirectly on this feature
//              (including all selected features).
//              The list of features does not change as long as the camera/interface is connected.
//              This function is usually called twice: once with an empty array to query the length
//              of the list, and then again with an array of the correct length.
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureListAffected ( const VmbHandle_t   handle,
//                                                       const char*         name,
//                                                       VmbFeatureInfo_t*   pFeatureInfoList,
//                                                       VmbUint32_t         listLength,
//                                                       VmbUint32_t*        pNumFound,
//                                                       VmbUint32_t         sizeofFeatureInfo );

Function VmbFeatureListAffected(handle              : VmbHandle_t;
                                name                : PANSIChar;
                                var pFeatureInfoList: VmbFeatureInfo_t;
                                listLength          : VmbUint32_t;
                                var pNumFound       : VmbUint32_t;
                                sizeofFeatureInfo   : VmbUint32_t):VmbError_t;
                                {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//
// Method:      VmbFeatureListSelected()
//
// Purpose:     List all the features selected by a given feature for this module.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle              Handle for an entity that exposes features
//  [in ]  const char*          name                Name of the feature
//  [out]  VmbFeatureInfo_t*    pFeatureInfoList    An array of VmbFeatureInfo_t to be filled by the API. May be NULL if pNumFound is used for size query.
//  [in ]  VmbUint32_t          listLength          Number of VmbFeatureInfo_t elements provided
//  [out]  VmbUint32_t*         pNumFound           Number of VmbFeatureInfo_t elements found. May be NULL if pFeatureInfoList is not NULL.
//  [in ]  VmbUint32_t          sizeofFeatureInfo   Size of a VmbFeatureInfo_t entry
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorStructSize:    The given struct size is not valid for this version of the API
//  - VmbErrorMoreData:      The given list length was insufficient to hold all available entries
//
// Details:     This method lists all selected features, whether they are currently available or not.
//              Features with selected features ("selectors") have no direct impact on the camera,
//              but only influence the register address that selected features point to.
//              The list of features does not change while the camera/interface is connected.
//              This function is usually called twice: once with an empty array to query the length
//              of the list, and then again with an array of the correct length.
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureListSelected ( const VmbHandle_t  handle,
//                                                       const char*        name,
//                                                       VmbFeatureInfo_t*  pFeatureInfoList,
//                                                       VmbUint32_t        listLength,
//                                                       VmbUint32_t*       pNumFound,
//                                                       VmbUint32_t        sizeofFeatureInfo );

Function VmbFeatureListSelected(handle              : VmbHandle_t;
                                name                : PANSIChar;
                                var pFeatureInfoList: VmbFeatureInfo_t;
                                listLength          : VmbUint32_t;
                                var pNumFound       : VmbUint32_t;
                                sizeofFeatureInfo   : VmbUint32_t):VmbError_t;
                                {$ifdef Win64} cdecl; {$else} stdcall; {$endif}
//
// Method:      VmbFeatureAccessQuery()
//
// Purpose:     Return the dynamic read and write capabilities of this feature.
//
// Parameters:
//
//  [in ]  const VmbHandle_t  handle          Handle for an entity that exposes features.
//  [in ]  const char *       name            Name of the feature.
//  [out]  VmbBool_t *        pIsReadable     Indicates if this feature is readable. May be NULL.
//  [out]  VmbBool_t *        pIsWriteable    Indicates if this feature is writable. May be NULL.
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorBadParameter:  If "pIsReadable" and "pIsWriteable" were both NULL
//  - VmbErrorNotFound:      The feature was not found
//
// Details:     The access mode of a feature may change. For example, if "PacketSize"
//              is locked while image data is streamed, it is only readable.
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureAccessQuery ( const VmbHandle_t   handle,
//                                                      const char*         name,
//                                                      VmbBool_t *         pIsReadable,
//                                                      VmbBool_t *         pIsWriteable );

Function VmbFeatureAccessQuery(handle          : VmbHandle_t;
                               name            : PANSIChar;
                               var pIsReadable : VmbBool_t;
                               var pIsWriteable: VmbBool_t):VmbError_t;
                              {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//-----Integer -------
//
// Method:      VmbFeatureIntGet()
//
// Purpose:     Get the value of an integer feature.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle      Handle for an entity that exposes features
//  [in ]  const char*          name        Name of the feature
//  [out]  VmbInt64_t*          pValue      Value to get
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorWrongType:     The type of feature "name" is not Integer
//  - VmbErrorNotFound:      The feature was not found
//  - VmbErrorBadParameter:  If "name" or "pValue" is NULL
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureIntGet ( const VmbHandle_t   handle,
//                                                 const char*         name,
//                                                 VmbInt64_t*         pValue );
Function VmbFeatureIntGet(handle: VmbHandle_t;
                          name  : pANSIchar;
                          var pValue: VmbInt64_t): VmbError_t; cdecl;
                         {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

// Method:      VmbFeatureIntSet()
//
// Purpose:     Set the value of an integer feature.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle    Handle for an entity that exposes features
//  [in ]  const char*          name      Name of the feature
//  [in ]  VmbInt64_t           value     Value to set
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorWrongType:     The type of feature "name" is not Integer
//  - VmbErrorInvalidValue:  If "value" is either out of bounds or not an increment of the minimum
//  - VmbErrorBadParameter:  If "name" is NULL
//  - VmbErrorNotFound:      If the feature was not found
//  - VmbErrorInvalidCall:   If called from frame callback
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureIntSet ( const VmbHandle_t   handle,
//                                                 const char*         name,
//                                                 VmbInt64_t          value );
Function VmbFeatureIntSet(handle: VmbHandle_t;
                          name  : pANSIchar;
                          value : VmbInt64_t): VmbError_t;
                          {$ifdef Win64} cdecl; {$else} stdcall; {$endif}
//
// Method:      VmbFeatureIntRangeQuery()
//
// Purpose:     Query the range of an integer feature.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle      Handle for an entity that exposes features
//  [in ]  const char*          name        Name of the feature
//  [out]  VmbInt64_t*          pMin        Minimum value to be returned. May be NULL.
//  [out]  VmbInt64_t*          pMax        Maximum value to be returned. May be NULL.
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorBadParameter:  If "name" is NULL or "pMin" and "pMax" are NULL
//  - VmbErrorWrongType:     The type of feature "name" is not Integer
//  - VmbErrorNotFound:      If the feature was not found
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureIntRangeQuery ( const VmbHandle_t   handle,
//                                                        const char*         name,
//                                                        VmbInt64_t*         pMin,
//                                                        VmbInt64_t*         pMax );
Function VmbFeatureIntRangeQuery(handle: VmbHandle_t;
                                 name  : PANSIchar;
                                 pMin  : VmbInt64_t;
                                 pMax  : VmbInt64_t): VmbError_t;
//                               {$ifdef Win64} cdecl; {$else} stdcall; {$endif}
// Method:      VmbFeatureIntIncrementQuery()
//
// Purpose:     Query the increment of an integer feature.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle         Handle for an entity that exposes features
//  [in ]  const char*          name           Name of the feature
//  [out]  VmbInt64_t*          pValue         Value of the increment to get.
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorWrongType:     The type of feature "name" is not Integer
//  - VmbErrorNotFound:      The feature was not found
//    VmbErrorBadParameter:  If "name" or "pValue" is NULL
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureIntIncrementQuery ( const VmbHandle_t   handle,
//                                                            const char*         name,
//                                                            VmbInt64_t*         pValue );
Function VmbFeatureIntIncrementQuery(handle: VmbHandle_t;
                                     name: pANSIchar;
                                     pValue: VmbInt64_t): VmbError_t;
                                     {$ifdef Win64} cdecl; {$else} stdcall; {$endif}
//-----Float --------

//
// Method:      VmbFeatureFloatGet()
//
// Purpose:     Get the value of a float feature.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle      Handle for an entity that exposes features
//  [in ]  const char*          name        Name of the feature
//  [out]  double*              pValue      Value to get
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorWrongType:     The type of feature "name" is not Float
//  - VmbErrorBadParameter:  If "name" or "pValue" is NULL
//  - VmbErrorNotFound:      The feature was not found
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureFloatGet ( const VmbHandle_t   handle,
//                                                   const char*         name,
//                                                   double*             pValue );
Function VmbFeatureFloatGet(handle    : VmbHandle_t;
                            name      : pANSIchar;
                            var pValue: Double): VmbError_t;
                            {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

// Method:      VmbFeatureFloatSet()
//
// Purpose:     Set the value of a float feature.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle      Handle for an entity that exposes features
//  [in ]  const char*          name        Name of the feature
//  [in ]  double               value       Value to set
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorWrongType:     The type of feature "name" is not Float
//  - VmbErrorInvalidValue:  If "value" is not within valid bounds
//  - VmbErrorNotFound:      The feature was not found
//  - VmbErrorBadParameter:  If "name" is NULL
//  - VmbErrorInvalidCall:   If called from frame callback
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureFloatSet ( const VmbHandle_t   handle,
//                                                   const char*         name,
//                                                   double              value );
Function VmbFeatureFloatSet(handle: VmbHandle_t;
                            name  : pANSIchar;
                            value : Double): VmbError_t;
                            {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

// Method:      VmbFeatureFloatRangeQuery()
//
// Purpose:     Query the range of a float feature.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle      Handle for an entity that exposes features
//  [in ]  const char*          name        Name of the feature
//  [out]  double*              pMin        Minimum value to be returned. May be NULL.
//  [out]  double*              pMax        Maximum value to be returned. May be NULL.
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorWrongType:     The type of feature "name" is not Float
//  - VmbErrorNotFound:      The feature was not found
//  - VmbBadParameter:       If "name" is NULL or "pMin" and "pMax" are NULL
//
// Details:     Only one of the values may be queried if the other parameter is set to NULL,
//              but if both parameters are NULL, an error is returned.
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureFloatRangeQuery ( const VmbHandle_t   handle,
//                                                          const char*         name,
//                                                          double*             pMin,
//                                                          double*             pMax );
Function VmbFeatureFloatRangeQuery(handle: VmbHandle_t;
                                   name: pANSIchar;
                                   pMin: double;
                                   pMax: double): VmbError_t;
//                                 {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

// Method:      VmbFeatureFloatIncrementQuery()
//
// Purpose:     Query the increment of an float feature.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle         Handle for an entity that exposes features
//  [in ]  const char*          name           Name of the feature
//  [out]  VmbBool_t *          pHasIncrement  "true" if this float feature has an increment.
//  [out]  double*              pValue         Value of the increment to get.
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorWrongType:     The type of feature "name" is not Integer
//  - VmbErrorNotFound:      The feature was not found
//    VmbErrorBadParameter:  If "name" or "pValue" is NULL
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureFloatIncrementQuery ( const VmbHandle_t   handle,
//                                                              const char*         name,
//                                                              VmbBool_t*          pHasIncrement,
//                                                              double*             pValue );
Function VmbFeatureFloatIncrementQuery(handle       : VmbHandle_t;
                                       name         : pANSIchar;
                                       pHasIncrement: VmbBool_t;
                                       pValue       : double): VmbError_t;
                                       {$ifdef Win64} cdecl; {$else} stdcall; {$endif}
//-----Enum --------

//
// Method:      VmbFeatureEnumGet()
//
// Purpose:     Get the value of an enumeration feature.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle      Handle for an entity that exposes features
//  [in ]  const char*          name        Name of the feature
//  [out]  const char**         pValue      The current enumeration value. The returned value
//                                          is a reference to the API value
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorWrongType:     The type of feature "name" is not Enumeration
//  - VmbErrorNotFound:      The feature was not found
//  - VmbErrorBadParameter:  If "name" or "pValue" is NULL
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureEnumGet ( const VmbHandle_t   handle,
//                                                  const char*         name,
//                                                  const char**        pValue );
Function VmbFeatureEnumGet(handle: VmbHandle_t;
                           name  : PANSIchar;
                           pValue: PPANSIchar): VmbError_t;
                           {$ifdef Win64} cdecl; {$else} stdcall; {$endif}
//
// Method:      VmbFeatureEnumSet()
//
// Purpose:     Set the value of an enumeration feature.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle      Handle for an entity that exposes features
//  [in ]  const char*          name        Name of the feature
//  [in ]  const char*          value       Value to set
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorWrongType:     The type of feature "name" is not Enumeration
//  - VmbErrorInvalidValue:  If "value" is not within valid bounds
//  - VmbErrorNotFound:      The feature was not found
//  - VmbErrorBadParameter:  If "name" ore "value" is NULL
//  - VmbErrorInvalidCall:   If called from frame callback
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureEnumSet ( const VmbHandle_t   handle,
//                                                  const char*         name,
//                                                  const char*         value );
Function VmbFeatureEnumSet(handle: VmbHandle_t;
                           name  : PANSIchar;
                           value : PANSIchar): VmbError_t;
                          {$ifdef Win64} cdecl; {$else} stdcall; {$endif}
//
// Method:      VmbFeatureEnumRangeQuery()
//
// Purpose:     Query the value range of an enumeration feature.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle          Handle for an entity that exposes features
//  [in ]  const char*          name            Name of the feature
//  [out]  const char**         pNameArray      An array of enumeration value names; may be NULL if pNumFilled is used for size query
//  [in ]  VmbUint32_t          arrayLength     Number of elements in the array
//  [out]  VmbUint32_t *        pNumFilled      Number of filled elements; may be NULL if pNameArray is not NULL
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorMoreData:      The given array length was insufficient to hold all available entries
//  - VmbErrorWrongType:     The type of feature "name" is not Enumeration
//  - VmbErrorNotFound:      The feature was not found
//  - VmbErrorBadParameter:  If "name" is NULL or "pNameArray" and "pNumFilled" are NULL
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureEnumRangeQuery ( const VmbHandle_t   handle,
//                                                         const char*         name,
//                                                         const char**        pNameArray,
//                                                         VmbUint32_t         arrayLength,
//                                                         VmbUint32_t*        pNumFilled );

Function VmbFeatureEnumRangeQuery(handle        : VmbHandle_t;
                                  name          : PANSIchar;
                                  pNameArray    : PPANSIchar;
                                  arrayLength   : VmbUint32_t;
                                  var pNumFilled: VmbUint32_t): VmbError_t;
                                  {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//
// Method:      VmbFeatureEnumIsAvailable()
//
// Purpose:     Check if a certain value of an enumeration is available.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle          Handle for an entity that exposes features
//  [in ]  const char*          name            Name of the feature
//  [in ]  const char*          value           Value to check
//  [out]  VmbBool_t *          pIsAvailable    Indicates if the given enumeration value is available
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorWrongType:     The type of feature "name" is not Enumeration
//  - VmbErrorNotFound:      The feature was not found
//  - VmbErrorBadParameter:  If "name" or "value" or "pIsAvailable" is NULL
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureEnumIsAvailable ( const VmbHandle_t   handle,
//                                                          const char*         name,
//                                                          const char*         value,
//                                                          VmbBool_t *         pIsAvailable );

Function VmbFeatureEnumIsAvailable(handle          : VmbHandle_t;
                                   name            : PANSIchar;
                                   value           : PANSIchar;
                                   var pIsAvailable:VmbBool_t): VmbError_t;
                                   {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//
// Method:      VmbFeatureEnumAsInt()
//
// Purpose:     Get the integer value for a given enumeration string value.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle     Handle for an entity that exposes features
//  [in ]  const char*          name       Name of the feature
//  [in ]  const char*          value      The enumeration value to get the integer value for
//  [out]  VmbInt64_t*          pIntVal    The integer value for this enumeration entry
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorWrongType:     The type of feature "name" is not Enumeration
//  - VmbErrorNotFound:      The feature was not found
//  - VmbErrorBadParameter:  If "name" or "value" or "pIntVal" is NULL
//
// Details:     Converts a name of an enum member into an int value ("Mono12Packed" to 0x10C0006)
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureEnumAsInt ( const VmbHandle_t   handle,
//                                                    const char*         name,
//                                                    const char*         value,
//                                                    VmbInt64_t*         pIntVal );

Function VmbFeatureEnumAsInt(handle     : VmbHandle_t;
                             name       : PANSIchar;
                             value      : PANSIchar;
                             var pIntVal: VmbInt64_t): VmbError_t;
                             {$ifdef Win64} cdecl; {$else} stdcall; {$endif}


//
// Method:      VmbFeatureEnumAsString()
//
// Purpose:     Get the enumeration string value for a given integer value.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle          Handle for an entity that exposes features
//  [in ]  const char*          name            Name of the feature
//  [in ]  VmbInt64_t           intValue        The numeric value
//  [out]  const char**         pStringValue    The string value for the numeric value
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorWrongType:     The type of feature "name" is not Enumeration
//  - VmbErrorNotFound:      The feature was not found
//  - VmbErrorBadParameter:  If "name" or "pStringValue" is NULL
//
// Details:     Converts an int value to a name of an enum member (e.g. 0x10C0006 to "Mono12Packed")
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureEnumAsString ( const VmbHandle_t   handle,
//                                                       const char*         name,
//                                                       VmbInt64_t          intValue,
//                                                       const char**        pStringValue );

Function VmbFeatureEnumAsString(handle      : VmbHandle_t;
                                name        : PANSIchar;
                                intValue    : VmbInt64_t;
                                pStringValue: PPANSIchar): VmbError_t;
                                {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//
// Method:      VmbFeatureEnumEntryGet()
//
// Purpose:     Get infos about an entry of an enumeration feature.
//
// Parameters:
//
//  [in ]  const VmbHandle_t        handle                  Handle for an entity that exposes features
//  [in ]  const char*              featureName             Name of the feature
//  [in ]  const char*              entryName               Name of the enum entry of that feature
//  [out]  VmbFeatureEnumEntry_t*   pFeatureEnumEntry       Infos about that entry returned by the API
//  [in]   VmbUint32_t              sizeofFeatureEnumEntry  Size of the structure
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorStructSize     Size of VmbFeatureEnumEntry_t is not compatible with the API version
//  - VmbErrorWrongType:     The type of feature "name" is not Enumeration
//  - VmbErrorNotFound:      The feature was not found
//  - VmbErrorBadParameter:  If "featureName" or "entryName" or "pFeatureEnumEntry" is NULL
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureEnumEntryGet ( const VmbHandle_t       handle,
//                                                       const char*             featureName,
//                                                       const char*             entryName,
//                                                       VmbFeatureEnumEntry_t*  pFeatureEnumEntry,
//                                                       VmbUint32_t             sizeofFeatureEnumEntry );

Function VmbFeatureEnumEntryGet(handle                : VmbHandle_t;
                                featurename           : PANSIchar;
                                entryName             : PANSIchar;
                                var pFeatureEnumEntry : VmbFeatureEnumEntry_t;
                                sizeofFeatureEnumEntry: VmbUint32_t): VmbError_t;
                                {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//-----String --------

//
// Method:      VmbFeatureStringGet()
//
// Purpose:     Get the value of a string feature.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle          Handle for an entity that exposes features
//  [in ]  const char*          name            Name of the string feature
//  [out]  char*                buffer          String buffer to fill. May be NULL if pSizeFilled is used for size query.
//  [in ]  VmbUint32_t          bufferSize      Size of the input buffer
//  [out]  VmbUint32_t*         pSizeFilled     Size actually filled. May be NULL if buffer is not NULL.
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorMoreData:      The given buffer size was too small
//  - VmbErrorNotFound:      The feature was not found
//  - VmbErrorWrongType:     The type of feature "name" is not String
//
// Details:     This function is usually called twice: once with an empty buffer to query the length
//              of the string, and then again with a buffer of the correct length.

//IMEXPORTC VmbError_t VMB_CALL VmbFeatureStringGet ( const VmbHandle_t   handle,
//                                                    const char*         name,
//                                                    char*               buffer,
//                                                    VmbUint32_t         bufferSize,
//                                                    VmbUint32_t*        pSizeFilled );

Function VmbFeatureStringGet(handle         : VmbHandle_t;
                             name           : PANSIchar;
                             buffer         : PANSIchar;
                             bufferSize     : VmbUint32_t;
                             var pSizeFilled: VmbUint32_t): VmbError_t;
                             {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//
// Method:    VmbFeatureStringSet()
//
// Purpose:   Set the value of a string feature.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle      Handle for an entity that exposes features
//  [in ]  const char*          name        Name of the string feature
//  [in ]  const char*          value       Value to set
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorNotFound:      The feature was not found
//  - VmbErrorWrongType:     The type of feature "name" is not String
//  - VmbErrorInvalidValue:  If length of "value" exceeded the maximum length
//  - VmbErrorBadParameter:  If "name" or "value" is NULL
//  - VmbErrorInvalidCall:   If called from frame callback
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureStringSet ( const VmbHandle_t   handle,
//                                                    const char*         name,
//                                                    const char*         value );

Function VmbFeatureStringSet(handle         : VmbHandle_t;
                             name           : PANSIchar;
                             value          : PANSIchar): VmbError_t;
                             {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//
// Method:      VmbFeatureStringMaxlengthQuery()
//
// Purpose:     Get the maximum length of a string feature.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle        Handle for an entity that exposes features
//  [in ]  const char*          name          Name of the string feature
//  [out]  VmbUint32_t*         pMaxLength    Maximum length of this string feature
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorWrongType:     The type of feature "name" is not String
//  - VmbErrorBadParameter:  If "name" or "pMaxLength" is NULL
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureStringMaxlengthQuery ( const VmbHandle_t   handle,
//                                                               const char*         name,
//                                                               VmbUint32_t*        pMaxLength );

Function VmbFeatureStringMaxlengthQuery(handle        : VmbHandle_t;
                                        name          : PANSIchar;
                                        var pMaxLength: VmbUint32_t): VmbError_t;
                                        {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//-----Boolean --------

//
// Method:      VmbFeatureBoolGet()
//
// Purpose:     Get the value of a boolean feature.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle    Handle for an entity that exposes features
//  [in ]  const char*          name      Name of the boolean feature
//  [out]  VmbBool_t *          pValue    Value to be read
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorWrongType:     The type of feature "name" is not Boolean
//  - VmbErrorNotFound:      If feature is not found
//  - VmbErrorBadParameter:  If "name" or "pValue" is NULL
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureBoolGet ( const VmbHandle_t   handle,
//                                                  const char*         name,
//                                                  VmbBool_t *         pValue );
Function VmbFeatureBoolGet(const handle: VmbHandle_t;
                           const name  : pANSIchar;
                           pValue      : Pointer{VmbBool_t}): VmbError_t;
                           {$ifdef Win64} cdecl; {$else} stdcall; {$endif}


//
// Method:      VmbFeatureBoolSet()
//
// Purpose:     Set the value of a boolean feature.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle      Handle for an entity that exposes features
//  [in ]  const char*          name        Name of the boolean feature
//  [in ]  VmbBool_t            value       Value to write
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorWrongType:     The type of feature "name" is not Boolean
//  - VmbErrorInvalidValue:  If "value" is not within valid bounds
//  - VmbErrorNotFound:      If the feature is not found
//  - VmbErrorBadParameter:  If "name" is NULL
//  - VmbErrorInvalidCall:   If called from frame callback
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureBoolSet ( const VmbHandle_t   handle,
//                                                  const char*         name,
//                                                  VmbBool_t           value );

Function VmbFeatureBoolSet(const handle: VmbHandle_t;
                           const name  : pANSIchar;
                           value       : VmbBool_t): VmbError_t;
                           {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//-----Command ------

//
// Method:    VmbFeatureCommandRun()
//
// Purpose:   Run a feature command.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle      Handle for an entity that exposes features
//  [in ]  const char*          name        Name of the command feature
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorWrongType:     The type of feature "name" is not Command
//  - VmbErrorNotFound:      Feature was not found
//  - VmbErrorBadParameter:  If "name" is NULL
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureCommandRun ( const VmbHandle_t   handle,
//                                                     const char*         name );
Function VmbFeatureCommandRun(handle: vmbHandle_t;
                              name  : pANSIchar): VmbError_t;
                              {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//
// Method:      VmbFeatureCommandIsDone()
//
// Purpose:     Check if a feature command is done.
//
// Parameters:
//
//  [in ]     const VmbHandle_t handle     Handle for an entity that exposes features
//  [in ]     const char*       name       Name of the command feature
//  [out]     VmbBool_t *       pIsDone    State of the command.
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorWrongType:     The type of feature "name" is not Command
//  - VmbErrorNotFound:      Feature was not found
//  - VmbErrorBadParameter:  If "name" or "pIsDone" is NULL
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureCommandIsDone ( const VmbHandle_t   handle,
//                                                        const char*         name,
//                                                        VmbBool_t *         pIsDone );
Function VmbFeatureCommandIsDone(handle     : VmbHandle_t;
                                 name       : pANSIchar;
                                 pIsDone    : VmbBool_t): VmbError_t;
                                 {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//-----Raw --------

//
// Method:      VmbFeatureRawGet()
//
// Purpose:     Read the memory contents of an area given by a feature name.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle         Handle for an entity that exposes features
//  [in ]  const char*          name           Name of the raw feature
//  [out]  char*                pBuffer        Buffer to fill
//  [in ]  VmbUint32_t          bufferSize     Size of the buffer to be filled
//  [out]  VmbUint32_t*         pSizeFilled    Number of bytes actually filled
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorWrongType:     The type of feature "name" is not Register
//  - VmbErrorNotFound:      Feature was not found
//  - VmbErrorBadParameter:  If "name" or "pBuffer" or "pSizeFilled" is NULL
//
// Details:     This feature type corresponds to a top-level "Register" feature in GenICam.
//              Data transfer is split up by the transport layer if the feature length is too large.
//              You can get the size of the memory area addressed by the feature "name" by VmbFeatureRawLengthQuery().
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureRawGet ( const VmbHandle_t   handle,
//                                                 const char*         name,
//                                                 char*               pBuffer,
//                                                 VmbUint32_t         bufferSize,
//                                                 VmbUint32_t*        pSizeFilled );

Function VmbFeatureRawGet(handle         : VmbHandle_t;
                          name           : pANSIchar;
                          pBuffer        : pANSIchar;
                          bufferSize     : VmbUint32_t;
                          var pSizeFilled: VmbUint32_t): VmbError_t;
                          {$ifdef Win64} cdecl; {$else} stdcall; {$endif}
//
// Method:      VmbFeatureRawSet()
//
// Purpose:     Write to a memory area given by a feature name.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle      Handle for an entity that exposes features
//  [in ]  const char*          name        Name of the raw feature
//  [in ]  const char*          pBuffer     Data buffer to use
//  [in ]  VmbUint32_t          bufferSize  Size of the buffer
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorWrongType:     The type of feature "name" is not Register
//  - VmbErrorNotFound:      Feature was not found
//  - VmbErrorBadParameter:  If "name" or "pBuffer" is NULL
//  - VmbErrorInvalidCall:   If called from frame callback
//
// Details:     This feature type corresponds to a first-level "Register" node in the XML file.
//              Data transfer is split up by the transport layer if the feature length is too large.
//              You can get the size of the memory area addressed by the feature "name" by VmbFeatureRawLengthQuery().
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureRawSet ( const VmbHandle_t   handle,
//                                                 const char*         name,
//                                                 const char*         pBuffer,
//                                                 VmbUint32_t         bufferSize );

Function VmbFeatureRawSet(handle    : VmbHandle_t;
                          name      : pANSIchar;
                          pBuffer   : pANSIchar;
                          bufferSize: VmbUint32_t): VmbError_t;
                          {$ifdef Win64} cdecl; {$else} stdcall; {$endif}
//
// Method:      VmbFeatureRawLengthQuery()
//
// Purpose:     Get the length of a raw feature for memory transfers.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle      Handle for an entity that exposes features
//  [in ]  const char*          name        Name of the raw feature
//  [out]  VmbUint32_t*         pLength     Length of the raw feature area (in bytes)
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorWrongType:     The type of feature "name" is not Register
//  - VmbErrorNotFound:      Feature not found
//  - VmbErrorBadParameter:  If "name" or "pLength" is NULL
//
// Details:     This feature type corresponds to a first-level "Register" node in the XML file.
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureRawLengthQuery ( const VmbHandle_t   handle,
//                                                         const char*         name,
//                                                         VmbUint32_t*        pLength );

Function VmbFeatureRawLengthQuery(handle     : VmbHandle_t;
                                  name       : pANSIchar;
                                  var pLength: VmbUint32_t): VmbError_t;
                                  {$ifdef Win64} cdecl; {$else} stdcall; {$endif}
//----- Feature invalidation --------------------------------------------------------

//
// Method:      VmbFeatureInvalidationRegister()
//
// Purpose:     Register a VmbInvalidationCallback callback for feature invalidation signaling.
//
// Parameters:
//
//  [in ]  const VmbHandle_t        handle          Handle for an entity that emits events
//  [in ]  const char*              name            Name of the event
//  [in ]  VmbInvalidationCallback  callback        Callback to be run, when invalidation occurs
//  [in ]  void*                    pUserContext    User context passed to function
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//
// Details:
//  Any feature change, either of its value or of its access state, may be tracked
//  by registering an invalidation callback.
//  Registering multiple callbacks for one feature invalidation event is possible because
//  only the combination of handle, name, and callback is used as key. If the same
//  combination of handle, name, and callback is registered a second time,
//  it overwrites the previous one.
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureInvalidationRegister ( const VmbHandle_t        handle,
//                                                               const char*              name,
//                                                               VmbInvalidationCallback  callback,
//                                                               void*                    pUserContext );

Function VmbFeatureInvalidationRegister(handle      : VmbHandle_t;
                                        name        : pANSIchar;
                                        callback    : Pointer; //_VmbInvalidationCallback;
                                        pUserContext: Pointer): VmbError_t;
                                        {$ifdef Win64} cdecl; {$else} stdcall; {$endif}
//
// Method:      VmbFeatureInvalidationUnregister()
//
// Purpose:     Unregister a previously registered feature invalidation callback.
//
// Parameters:
//
//  [in ]  const VmbHandle_t        handle          Handle for an entity that emits events
//  [in ]  const char*              name            Name of the event
//  [in ]  VmbInvalidationCallback  callback        Callback to be removed
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//
// Details:     Since multiple callbacks may be registered for a feature invalidation event,
//              a combination of handle, name, and callback is needed for unregistering, too.
//
//IMEXPORTC VmbError_t VMB_CALL VmbFeatureInvalidationUnregister ( const VmbHandle_t        handle,
//                                                                 const char*              name,
//                                                                 VmbInvalidationCallback  callback );

Function VmbFeatureInvalidationUnregister(handle  : VmbHandle_t;
                                          name    : pANSIchar;
                                          callback: Pointer): VmbError_t;
                                          {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//-----  Image preparation and acquisition ---------------------------------------------------

//
// Method:      VmbFrameAnnounce()
//
// Purpose:     Announce frames to the API that may be queued for frame capturing later.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    cameraHandle    Handle for a camera
//  [in ]  const VmbFrame_t*    pFrame          Frame buffer to announce
//  [in ]  VmbUint32_t          sizeofFrame     Size of the frame structure
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given camera handle is not valid
//  - VmbErrorBadParameter:  The given frame pointer is not valid or "sizeofFrame" is 0
//  - VmbErrorStructSize:    The given struct size is not valid for this version of the API
//
// Details:     Allows some preparation for frames like DMA preparation depending on the transport layer.
//              The order in which the frames are announced is not taken into consideration by the API.
//
//IMEXPORTC VmbError_t VMB_CALL VmbFrameAnnounce(const VmbHandle_t   cameraHandle,
//                                               const VmbFrame_t*   pFrame,
//                                               VmbUint32_t         sizeofFrame );
Function VmbFrameAnnounce(cameraHandle: VmbHandle_t;
                          var pFrame  : VmbFrame_t;
                          const sizeofFrame : VmbUint32_t): VmbError_t;
                          {$ifdef Win64} cdecl; {$else} stdcall; {$endif}
//
// Method:      VmbFrameRevoke()
//
// Purpose:     Revoke a frame from the API.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    cameraHandle    Handle for a camera
//  [in ]  const VmbFrame_t*    pFrame          Frame buffer to be removed from the list of announced frames
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given camera handle is not valid
//  - VmbErrorBadParameter:  The given frame pointer is not valid
//  - VmbErrorStructSize:    The given struct size is not valid for this version of the API
//
// Details:    The referenced frame is removed from the pool of frames for capturing images.
//
//IMEXPORTC VmbError_t VMB_CALL VmbFrameRevoke ( const VmbHandle_t   cameraHandle,
//                                               const VmbFrame_t*   pFrame );
Function VmbFrameRevoke(cameraHandle: VmbHandle_t;
                        var pFrame  : VmbFrame_t): VmbError_t;
                        {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//
// Method:      VmbFrameRevokeAll()
//
// Purpose:     Revoke all frames assigned to a certain camera.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    cameraHandle    Handle for a camera
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given camera handle is not valid
//
//IMEXPORTC VmbError_t VMB_CALL VmbFrameRevokeAll ( const VmbHandle_t  cameraHandle );

Function VmbFrameRevokeAll(cameraHandle: VmbHandle_t): VmbError_t;
                           {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//
// Method:      VmbCaptureStart()
//
// Purpose:     Prepare the API for incoming frames.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    cameraHandle    Handle for a camera
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorDeviceNotOpen: Camera was not opened for usage
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//
//IMEXPORTC VmbError_t VMB_CALL VmbCaptureStart ( const VmbHandle_t  cameraHandle );
Function VmbCaptureStart(cameraHandle: VmbHandle_t): VmbError_t;
                         {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//
// Method:      VmbCaptureEnd()
//
// Purpose:     Stop the API from being able to receive frames.
//
// Parameters:
//
//  [in ]  const VmbHandle_t  cameraHandle    Handle for a camera
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//
// Details:     Consequences of VmbCaptureEnd():
//                  - The frame callback will not be called anymore
//
//IMEXPORTC VmbError_t VMB_CALL VmbCaptureEnd ( const VmbHandle_t  cameraHandle );
Function VmbCaptureEnd(cameraHandle: VmbHandle_t): VmbError_t;
                       {$ifdef Win64} cdecl; {$else} stdcall; {$endif}


//
// Method:      VmbCaptureFrameQueue()
//
// Purpose:     Queue frames that may be filled during frame capturing.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    cameraHandle    Handle of the camera
//  [in ]  const VmbFrame_t*    pFrame          Pointer to an already announced frame
//  [in ]  VmbFrameCallback     callback        Callback to be run when the frame is complete.  NULL is Ok.
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given frame is not valid
//  - VmbErrorStructSize:    The given struct size is not valid for this version of the API
//
// Details:     The given frame is put into a queue that will be filled sequentially.
//              The order in which the frames are filled is determined by the order in which they are queued.
//              If the frame was announced with VmbFrameAnnounce() before, the application
//              has to ensure that the frame is also revoked by calling VmbFrameRevoke() or
//              VmbFrameRevokeAll() when cleaning up.
//
//IMEXPORTC VmbError_t VMB_CALL VmbCaptureFrameQueue ( const VmbHandle_t   cameraHandle,
//                                                     const VmbFrame_t*   pFrame,
//                                                     VmbFrameCallback    callback );
Function VmbCaptureFrameQueue(cameraHandle: VmbHandle_t;
                              var pFrame  : VmbFrame_t;
                              callback    : Pointer): VmbError_t;
                              {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

// Method:      VmbCaptureFrameWait()
//
// Purpose:     Wait for a queued frame to be filled (or dequeued).
//
// Parameters:
//
//  [in ]  const VmbHandle_t    cameraHandle    Handle of the camera
//  [in ]  const VmbFrame_t*    pFrame          Pointer to an already announced & queued frame
//  [in ]  VmbUint32_t          timeout         Timeout (in milliseconds)
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorTimeout:       Call timed out
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//IMEXPORTC VmbError_t VMB_CALL VmbCaptureFrameWait ( const VmbHandle_t   cameraHandle,
//                                                    const VmbFrame_t*   pFrame,
//                                                    VmbUint32_t         timeout);
Function VmbCaptureFrameWait(cameraHandle: VmbHandle_t;
                             var pFrame  : VmbFrame_t;
                             timeout     : VmbUint32_t): VmbError_t;
                             {$ifdef Win64} stdcall; {$else} stdcall; {$endif}
//
// Method:      VmbCaptureQueueFlush()
//
// Purpose:     Flush the capture queue.
//
// Parameters:
//
//  [in ]  const VmbHandle_t cameraHandle   Handle of the camera to flush
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//
// Details:     Control of all the currently queued frames will be returned to the user,
//              leaving no frames in the capture queue.
//              After this call, no frame notification will occur until frames are queued again.
//
//IMEXPORTC VmbError_t VMB_CALL VmbCaptureQueueFlush ( const VmbHandle_t  cameraHandle );
Function VmbCaptureQueueFlush(cameraHandle: VmbHandle_t): VmbError_t;
                              {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//----- Interface Enumeration & Information --------------------------------------

//
// Method:      VmbInterfacesList()
//
// Purpose:     List all the interfaces currently visible to VimbaC.
//
// Parameters:
//
//  [out]  VmbInterfaceInfo_t*  pInterfaceInfo          Array of VmbInterfaceInfo_t, allocated by the caller.
//                                                      The interface list is copied here. May be NULL.
//  [in ]  VmbUint32_t          listLength              Number of entries in the caller's pList array
//  [out]  VmbUint32_t*         pNumFound               Number of interfaces found (may be more than
//                                                      listLength!) returned here.
//  [in ]  VmbUint32_t          sizeofInterfaceInfo     Size of one VmbInterfaceInfo_t entry
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorStructSize:    The given struct size is not valid for this API version
//  - VmbErrorMoreData:      The given list length was insufficient to hold all available entries
//  - VmbErrorBadParameter:  If "pNumFound" was NULL
//
// Details:     All the interfaces known via GenICam TransportLayers are listed by this 
//              command and filled into the provided array. Interfaces may correspond to
//              adapter cards or frame grabber cards or, in the case of FireWire to the 
//              whole 1394 infrastructure, for instance.
//              This function is usually called twice: once with an empty array to query the length
//              of the list, and then again with an array of the correct length.
//
Function VmbInterfacesList(var pInterfaceInfo : VmbInterfaceInfo_t;
                           listLength         : VmbUint32_t;
                           var pNumFound      : VmbUint32_t;
                           sizeofInterfaceInfo: VmbUint32_t): VmbError_t;
                           {$ifdef Win64} cdecl; {$else} stdcall; {$endif}
//
// Method:      VmbInterfaceOpen()
//
// Purpose:     Open an interface handle for feature access.
//
// Parameters:
//
//  [in ]  const char*      idString           The ID of the interface to get the handle for
//                                             (returned by VmbInterfacesList())
//  [out]  VmbHandle_t*     pInterfaceHandle   The handle for this interface.
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorNotFound:      The designated interface cannot be found
//  - VmbErrorBadParameter:  If "pInterfaceHandle" was NULL
//
// Details:     An interface can be opened if interface-specific control or information
//              is required, e.g. the number of devices attached to a specific interface.
//              Access is then possible via feature access methods.
//
//IMEXPORTC VmbError_t VMB_CALL VmbInterfaceOpen ( const char*     idString,
//                                                 VmbHandle_t*    pInterfaceHandle );

Function VmbInterfaceOpen(idString        : PANSIchar;
                          pInterfaceHandle: VmbHandle_t): VmbError_t;
                          {$ifdef Win64} cdecl; {$else} stdcall; {$endif}
//
// Method:      VmbInterfaceClose()
//
// Purpose:     Close an interface.
//
// Parameters:
//
//  [in ]  const VmbHandle_t   interfaceHandle    The handle of the interface to close.
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//
// Details:     After configuration of the interface, close it by calling this function.
//
//IMEXPORTC VmbError_t VMB_CALL VmbInterfaceClose ( const VmbHandle_t  interfaceHandle );

Function VmbInterfaceClose(interfaceHandle: VmbHandle_t): VmbError_t;
                           {$ifdef Win64} cdecl; {$else} stdcall; {$endif}


//----- Ancillary data --------------------------------------------------------

//
// Method:      VmbAncillaryDataOpen()
//
// Purpose:     Get a working handle to allow access to the elements of the ancillary data via feature access.
//
// Parameters:
//
//  [in ]  VmbFrame_t*   pFrame                 Pointer to a filled frame
//  [out]  VmbHandle_t*  pAncillaryDataHandle   Handle to the ancillary data inside the frame
//
// Returns:
//
//  - VmbErrorSuccess:			No error
//  - VmbErrorBadHandle:		Chunk mode of the camera was not activated. See feature ChunkModeActive
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//
// Details:     This function can only succeed if the given frame has been filled by the API.
//
//IMEXPORTC VmbError_t VMB_CALL VmbAncillaryDataOpen ( VmbFrame_t*     pFrame,
//                                                     VmbHandle_t*    pAncillaryDataHandle );

Function VmbAncillaryDataOpen(var pFrame: VmbFrame_t;
                              var pAncillaryDataHandle: VmbHandle_t): VmbError_t;
                              {$ifdef Win64} cdecl; {$else} stdcall; {$endif}
//
// Method:      VmbAncillaryDataClose()
//
// Purpose:     Destroy the working handle to the ancillary data inside a frame.
//
// Parameters:
//
//  [in ]  VmbHandle_t  ancillaryDataHandle  Handle to ancillary frame data
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//
// Details:     After reading the ancillary data and before re-queuing the frame, ancillary data
//              must be closed.
//
//IMEXPORTC VmbError_t VMB_CALL VmbAncillaryDataClose ( VmbHandle_t  ancillaryDataHandle );

Function VmbAncillaryDataClose(ancillaryDataHandle: VmbHandle_t): VmbError_t;
                              {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

//----- Memory/Register access --------------------------------------------


//
// Method:      VmbMemoryRead()
//
// Purpose:     Read an array of bytes.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle          Handle for an entity that allows memory access
//  [in ]  VmbUint64_t          address         Address to be used for this read operation
//  [in ]  VmbUint32_t          bufferSize      Size of the data buffer to read
//  [out]  char*                dataBuffer      Buffer to be filled
//  [out]  VmbUint32_t*         pSizeComplete   Size of the data actually read
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//
//IMEXPORTC VmbError_t VMB_CALL VmbMemoryRead ( const VmbHandle_t   handle,
//                                              VmbUint64_t         address,
//                                              VmbUint32_t         bufferSize,
//                                              char*               dataBuffer,
//                                              VmbUint32_t*        pSizeComplete );

Function VmbMemoryRead(handle           : VmbHandle_t;
                       address          : VmbUint64_t;
                       bufferSize       : VmbUint32_t;
                       dataBuffer       : PANSIchar;
                       var pSizeComplete: VmbUint32_t): VmbError_t;
                                              {$ifdef Win64} cdecl; {$else} stdcall; {$endif}
//
// Method:      VmbMemoryWrite()
//
// Purpose:     Write an array of bytes.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle          Handle for an entity that allows memory access
//  [in ]  VmbUint64_t          address         Address to be used for this read operation
//  [in ]  VmbUint32_t          bufferSize      Size of the data buffer to write
//  [in ]  const char*          dataBuffer      Data to write
//  [out]  VmbUint32_t*         pSizeComplete   Number of bytes successfully written; if an
//                                              error occurs this is less than bufferSize
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorMoreData:      Not all data were written; see pSizeComplete value for the number of bytes written
//
//IMEXPORTC VmbError_t VMB_CALL VmbMemoryWrite ( const VmbHandle_t   handle,
//                                               VmbUint64_t         address,
//                                               VmbUint32_t         bufferSize,
//                                               const char*         dataBuffer,
//                                               VmbUint32_t*        pSizeComplete );

Function VmbMemoryWrite(handle: VmbHandle_t;
                        address: VmbUint64_t;
                        bufferSize: VmbUint32_t;
                        dataBuffer: PANSIchar;
                        var pSizeComplete: VmbUint32_t): VmbError_t;
                        {$ifdef Win64} cdecl; {$else} stdcall; {$endif}
//
// Method:      VmbRegistersRead()
//
// Purpose:     Read an array of registers.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle              Handle for an entity that allows register access
//  [in ]  VmbUint32_t          readCount           Number of registers to be read
//  [in ]  const VmbUint64_t*   pAddressArray       Array of addresses to be used for this read operation
//  [out]  VmbUint64_t*         pDataArray          Array of registers to be used for this read operation
//  [out]  VmbUint32_t*         pNumCompleteReads   Number of reads completed
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorIncomplete:    Not all the requested reads could be completed
//
// Details:     Two arrays of data must be provided: an array of register addresses and one
//              for corresponding values to be read. The registers are read consecutively
//              until an error occurs or all registers are written successfully.
//
//IMEXPORTC VmbError_t VMB_CALL VmbRegistersRead ( const VmbHandle_t   handle,
//                                                 VmbUint32_t         readCount,
//                                                 const VmbUint64_t*  pAddressArray,
//                                                 VmbUint64_t*        pDataArray,
//                                                 VmbUint32_t*        pNumCompleteReads );

Function VmbRegistersRead(handle               : VmbHandle_t;
                          readCount            : VmbUint32_t;
                          pAddressArray        : Pointer;
                          pDataArray           : VmbUint64_t;
                          var pNumCompleteReads: VmbUint32_t): VmbError_t;
                                                 {$ifdef Win64} cdecl; {$else} stdcall; {$endif}
//
// Method:      VmbRegistersWrite()
//
// Purpose:     Write an array of registers.
//
// Parameters:
//
//  [in ]  const VmbHandle_t    handle                  Handle for an entity that allows register access
//  [in ]  VmbUint32_t          writeCount              Number of registers to be written
//  [in ]  const VmbUint64_t*   pAddressArray           Array of addresses to be used for this write operation
//  [in ]  const VmbUint64_t*   pDataArray              Array of reads to be used for this write operation
//  [out]  VmbUint32_t*         pNumCompleteWrites      Number of writes completed
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorIncomplete:    Not all the requested writes could be completed
//
// Details:     Two arrays of data must be provided: an array of register addresses and one with the
//              corresponding values to be written to these addresses. The registers are written
//              consecutively until an error occurs or all registers are written successfully.
//
//IMEXPORTC VmbError_t VMB_CALL VmbRegistersWrite ( const VmbHandle_t   handle,
//                                                  VmbUint32_t         writeCount,
//                                                  const VmbUint64_t*  pAddressArray,
//                                                  const VmbUint64_t*  pDataArray,
//                                                  VmbUint32_t*        pNumCompleteWrites );

Function VmbRegistersWrite(handle               : VmbHandle_t;
                           writeCount: VmbUint32_t;
                           pAddressArray: Pointer;
                           pDataArray: Pointer;
                           var pNumCompleteWrites: VmbUint32_t): VmbError_t;
                           {$ifdef Win64} cdecl; {$else} stdcall; {$endif}
//
// Method:      VmbCameraSettingsSave()
//
// Purpose:     Saves all feature values to XML file.
//
// Parameters:
//
//  [in ]  const VmbHandle_t             handle              Handle for an entity that allows register access
//  [in ]  const char*                   fileName            Name of XML file to save settings
//  [in ]  VmbFeaturePersistSettings_t*  pSettings           Settings struct
//  [in ]  VmbUint32_t                   sizeofSettings      Size of settings struct
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorBadParameter:  If "fileName" is NULL
//
// Details:     Camera must be opened beforehand and function needs corresponding handle.
//              With given filename parameter path and name of XML file can be determined.
//              Additionally behaviour of function can be set with providing 'persistent struct'.
//
//IMEXPORTC VmbError_t VMB_CALL VmbCameraSettingsSave ( const VmbHandle_t               handle,
//                                                      const char *                    fileName,
//                                                      VmbFeaturePersistSettings_t *   pSettings,
//                                                      VmbUint32_t                     sizeofSettings );

Function VmbCameraSettingsSave(handle: VmbHandle_t;
                               fileName: PANSIchar;
                               var pSettings: VmbFeaturePersistSettings_t;
                               sizeofSettings: VmbUint32_t): VmbError_t;
                               {$ifdef Win64} cdecl; {$else} stdcall; {$endif}
//
// Method:      VmbCameraSettingsLoad()
//
// Purpose:     Load all feature values from XML file to device.
//
// Parameters:
//
//  [in ]  const VmbHandle_t             handle              Handle for an entity that allows register access
//  [in ]  const char*                   fileName            Name of XML file to save settings
//  [in ]  VmbFeaturePersistSettings_t*  pSettings           Settings struct
//  [in ]  VmbUint32_t                   sizeofSettings      Size of settings struct
//
// Returns:
//
//  - VmbErrorSuccess:       If no error
//  - VmbErrorApiNotStarted: VmbStartup() was not called before the current command
//  - VmbErrorBadHandle:     The given handle is not valid
//  - VmbErrorInvalidAccess: Operation is invalid with the current access mode
//  - VmbErrorBadParameter:  If "fileName" is NULL
//
// Details:     Camera must be opened beforehand and function needs corresponding handle.
//              With given filename parameter path and name of XML file can be determined.
//              Additionally behaviour of function can be set with providing 'settings struct'.
//
//IMEXPORTC VmbError_t VMB_CALL VmbCameraSettingsLoad ( const VmbHandle_t               handle,
//                                                      const char *                    fileName,
//                                                      VmbFeaturePersistSettings_t *   pSettings,
//                                                      VmbUint32_t                     sizeofSettings );

Function VmbCameraSettingsLoad(handle        : VmbHandle_t;
                               fileName      : PANSIchar;
                               var pSettings : VmbFeaturePersistSettings_t;
                               sizeofSettings: VmbUint32_t): VmbError_t;
                                                      {$ifdef Win64} cdecl; {$else} stdcall; {$endif}

Implementation

Function VmbVersionQuery; external VMB_CALL;
Function VmbFeatureBoolGet; external VMB_CALL;
Function VmbFeatureIntSet; external VMB_CALL;
Function VmbFeatureCommandRun; external VMB_CALL;
Function VmbFeaturesList; external VMB_CALL;
Function VmbCaptureFrameQueue; external VMB_CALL;
Function VmbStartup; external VMB_CALL;
Function VmbCamerasList; external VMB_CALL;
Function VmbCameraOpen; external VMB_CALL;
Function VmbFeatureCommandIsDone; external VMB_CALL;
Function VmbFeatureIntGet; external VMB_CALL;
Function VmbFrameAnnounce; external VMB_CALL;
Function VmbCaptureStart; external VMB_CALL;
Function VmbCaptureEnd; external VMB_CALL;
Function VmbCaptureQueueFlush; external VMB_CALL;
Procedure VmbShutdown; external VMB_CALL;
Function VmbFrameRevoke; external VMB_CALL;
Function VmbCameraClose; external VMB_CALL;
Function VmbCameraInfoQuery; external VMB_CALL;
Function VmbCaptureFrameWait; external VMB_CALL;
Function VmbFeatureEnumSet; external VMB_CALL;
Function VmbFeatureEnumGet; external VMB_CALL;
Function VmbFeatureIntRangeQuery; external VMB_CALL;
Function VmbFeatureIntIncrementQuery; external VMB_CALL;
Function VmbFeatureFloatGet; external VMB_CALL;
Function VmbFeatureFloatSet; external VMB_CALL;
Function VmbFeatureFloatRangeQuery; external VMB_CALL;
Function VmbFeatureFloatIncrementQuery; external VMB_CALL;
Function VmbFeatureInfoQuery; external VMB_CALL;
Function VmbFeatureListAffected; external VMB_CALL;
Function VmbFeatureListSelected; external VMB_CALL;
Function VmbFeatureAccessQuery; external VMB_CALL;
Function VmbFeatureEnumRangeQuery; external VMB_CALL;
Function VmbFeatureEnumIsAvailable; external VMB_CALL;
Function VmbFeatureEnumAsInt; external VMB_CALL;
Function VmbFeatureEnumAsString; external VMB_CALL;
Function VmbFeatureEnumEntryGet; external VMB_CALL;
Function VmbFeatureStringGet; external VMB_CALL;
Function VmbFeatureStringSet; external VMB_CALL;
Function VmbFeatureStringMaxlengthQuery; external VMB_CALL;
Function VmbFeatureBoolSet; external VMB_CALL;
Function VmbFeatureRawGet; external VMB_CALL;
Function VmbFeatureRawSet; external VMB_CALL;
Function VmbFeatureRawLengthQuery; external VMB_CALL;
Function VmbFeatureInvalidationRegister; external VMB_CALL;
Function VmbFeatureInvalidationUnregister; external VMB_CALL;
Function VmbFrameRevokeAll; external VMB_CALL;
Function VmbInterfacesList; external VMB_CALL;
Function VmbInterfaceOpen; external VMB_CALL;
Function VmbInterfaceClose; external VMB_CALL;
Function VmbAncillaryDataOpen; external VMB_CALL;
Function VmbAncillaryDataClose; external VMB_CALL;
Function VmbMemoryRead; external VMB_CALL;
Function VmbMemoryWrite; external VMB_CALL;
Function VmbRegistersRead; external VMB_CALL;
Function VmbCameraSettingsLoad; external VMB_CALL;
Function VmbCameraSettingsSave; external VMB_CALL;
Function VmbRegistersWrite; external VMB_CALL;

end.

