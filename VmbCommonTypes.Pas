unit VmbCommonTypes;
(*=============================================================================
  Copyright (C) 2012 Allied Vision Technologies.  All Rights Reserved.

  Redistribution of this header file, in original or modified form, without
  prior written consent of Allied Vision Technologies is prohibited.

-------------------------------------------------------------------------------

  File:        VmbCommonTypes.h

  Description: Main header file for the common types of the Vimba APIs.

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

// This file describes all necessary definitions for types used within
// Allied Vision's Vimba APIs. These type definitions are designed to be
// portable from other languages and other operating systems.

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

Interface

type
  VmbInt8_t   = ShortInt;                     // 8 bit signed integer on Microsoft systems
  VmbUint8_t  = Byte;                         // 8 bit unsigned integer on Microsoft systems
  VmbInt16_t  = SmallInt;                     // 16 bit signed integer on Microsoft systems
  VmbUint16_t = Word;                         // 16 bit unsigned integer on Microsoft systems
  VmbInt32_t  = Integer;                      // 32 bit signed integer on Microsoft systems
  VmbUint32_t = Uint32;                      // 32 bit unsigned integer on Microsoft systems
  VmbInt64_t  = Int64;                        // 64 bit signed integer on Microsoft systems
  VmbUint64_t = UInt64;                       // 64 bit unsigned integer on Microsoft systems
  VmbHandle_t = Pointer;                      // Handle; e.g. for a camera
  VmbBool_t   = Boolean;                      // 1 means true and 0 means false
  VmbBoolVal  = Boolean;                      //(VmbBoolFalse = 0, VmbBoolTrue = 1);
  VmbUchar_t  = Char;

  //Error codes, returned by most functions: (not yet complete)
  VmbErrorType = (
      VmbErrorSuccess         =  0,           // No error
      VmbErrorInternalFault   = -1,           // Unexpected fault in VimbaC or driver
      VmbErrorApiNotStarted   = -2,           // "VmbStartup" was not called before the current command
      VmbErrorNotFound        = -3,           // The designated instance (camera, feature etc.) cannot be found
      VmbErrorBadHandle       = -4,           // The given handle is not valid
      VmbErrorDeviceNotOpen   = -5,           // Device was not opened for usage
      VmbErrorInvalidAccess   = -6,           // Operation is invalid with the current access mode
      VmbErrorBadParameter    = -7,           // One of the parameters is invalid (usually an illegal pointer)
      VmbErrorStructSize      = -8,           // The given struct size is not valid for this version of the API
      VmbErrorMoreData        = -9,           // More data available in a string/list than space is provided
      VmbErrorWrongType       = -10,          // Wrong feature type for this access function
      VmbErrorInvalidValue    = -11,          // The value is not valid; either out of bounds or not an increment of the minimum
      VmbErrorTimeout         = -12,          // Timeout during wait
      VmbErrorOther           = -13,          // Other error
      VmbErrorResources       = -14,          // Resources not available (e.g. memory)
      VmbErrorInvalidCall     = -15,          // Call is invalid in the current context (e.g. callback)
      VmbErrorNoTL            = -16,          // No transport layers are found
      VmbErrorNotImplemented  = -17,          // API feature is not implemented
      VmbErrorNotSupported    = -18,          // API feature is not supported
      VmbErrorIncomplete      = -19,          // A multiple registers read or write is partially completed
      VmbErrorIO              = -20           // low level IO error in transport layer
  );
  VmbError_t = VmbInt32_t;                    // Type for an error returned by API methods; for values see VmbErrorType

  VmbVersionInfo_t = Record
    major: VmbUint32_t;                       // Major version number
    minor: VmbUint32_t;                       // Minor version number
    patch: VmbUint32_t;                       // Patch version number
  end;

  //Indicate if pixel is monochrome or RGB
  VmbPixelType = (
    VmbPixelMono  = $01000000,                // Monochrome pixel
    VmbPixelColor = $02000000);               // Pixel bearing color information

  //Indicate number of bits for a pixel. Needed for building values of VmbPixelFormatType
  VmbPixelOccupyType = (
    VmbPixelOccupy8Bit  = $00080000,          // Pixel effectively occupies 8 bits
    VmbPixelOccupy10Bit = $000A0000,          // Pixel effectively occupies 10 bits
    VmbPixelOccupy12Bit = $000C0000,          // Pixel effectively occupies 12 bits
    VmbPixelOccupy14Bit = $000E0000,          // Pixel effectively occupies 14 bits
    VmbPixelOccupy16Bit = $00100000,          // Pixel effectively occupies 16 bits
    VmbPixelOccupy24Bit = $00180000,          // Pixel effectively occupies 24 bits
    VmbPixelOccupy32Bit = $00200000,          // Pixel effectively occupies 32 bits
    VmbPixelOccupy48Bit = $00300000,          // Pixel effectively occupies 48 bits
    VmbPixelOccupy64Bit = $00400000);         // Pixel effectively occupies 48 bits

   //Pixel format types.
   //As far as possible, the Pixel Format Naming Convention (PFNC) has been followed, allowing a few deviations.
   //If data spans more than one byte, it is always LSB aligned, except if stated differently.
   VmbPixelFormatType = (
    // Mono formats
    VmbPixelFormatMono8               = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy8Bit) + $0001, // Monochrome, 8 bits (PFNC:Mono8)
    VmbPixelFormatMono10              = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy16Bit) + $0003,  // Monochrome, 10 bits in 16 bits (PFNC:Mono10)
    VmbPixelFormatMono10p             = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy10Bit) + $0046,  // Monochrome, 4x10 bits continuously packed in 40 bits (PFNC:Mono10p)
    VmbPixelFormatMono12              = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy16Bit) + $0005,  // Monochrome, 12 bits in 16 bits (PFNC:Mono12)
    VmbPixelFormatMono12Packed        = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy12Bit) + $0006,  // Monochrome, 2x12 bits in 24 bits (GEV:Mono12Packed)
    VmbPixelFormatMono12p             = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy12Bit) + $0047,  // Monochrome, 2x12 bits continuously packed in 24 bits (PFNC:Mono12p)
    VmbPixelFormatMono14              = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy16Bit) + $0025,  // Monochrome, 14 bits in 16 bits (PFNC:Mono14)
    VmbPixelFormatMono16              = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy16Bit) + $0007,  // Monochrome, 16 bits (PFNC:Mono16)
    // Bayer formats
    VmbPixelFormatBayerGR8            = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy8Bit)  + $0008,  // Bayer-color, 8 bits, starting with GR line (PFNC:BayerGR8)
    VmbPixelFormatBayerRG8            = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy8Bit)  + $0009,  // Bayer-color, 8 bits, starting with RG line (PFNC:BayerRG8)
    VmbPixelFormatBayerGB8            = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy8Bit)  + $000A,  // Bayer-color, 8 bits, starting with GB line (PFNC:BayerGB8)
    VmbPixelFormatBayerBG8            = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy8Bit)  + $000B,  // Bayer-color, 8 bits, starting with BG line (PFNC:BayerBG8)
    VmbPixelFormatBayerGR10           = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy16Bit) + $000C,  // Bayer-color, 10 bits in 16 bits, starting with GR line (PFNC:BayerGR10)
    VmbPixelFormatBayerRG10           = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy16Bit) + $000D,  // Bayer-color, 10 bits in 16 bits, starting with RG line (PFNC:BayerRG10)
    VmbPixelFormatBayerGB10           = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy16Bit) + $000E,  // Bayer-color, 10 bits in 16 bits, starting with GB line (PFNC:BayerGB10)
    VmbPixelFormatBayerBG10           = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy16Bit) + $000F,  // Bayer-color, 10 bits in 16 bits, starting with BG line (PFNC:BayerBG10)
    VmbPixelFormatBayerGR12           = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy16Bit) + $0010,  // Bayer-color, 12 bits in 16 bits, starting with GR line (PFNC:BayerGR12)
    VmbPixelFormatBayerRG12           = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy16Bit) + $0011,  // Bayer-color, 12 bits in 16 bits, starting with RG line (PFNC:BayerRG12)
    VmbPixelFormatBayerGB12           = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy16Bit) + $0012,  // Bayer-color, 12 bits in 16 bits, starting with GB line (PFNC:BayerGB12)
    VmbPixelFormatBayerBG12           = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy16Bit) + $0013,  // Bayer-color, 12 bits in 16 bits, starting with BG line (PFNC:BayerBG12)
    VmbPixelFormatBayerGR12Packed     = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy12Bit) + $002A,  // Bayer-color, 2x12 bits in 24 bits, starting with GR line (GEV:BayerGR12Packed)
    VmbPixelFormatBayerRG12Packed     = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy12Bit) + $002B,  // Bayer-color, 2x12 bits in 24 bits, starting with RG line (GEV:BayerRG12Packed)
    VmbPixelFormatBayerGB12Packed     = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy12Bit) + $002C,  // Bayer-color, 2x12 bits in 24 bits, starting with GB line (GEV:BayerGB12Packed)
    VmbPixelFormatBayerBG12Packed     = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy12Bit) + $002D,  // Bayer-color, 2x12 bits in 24 bits, starting with BG line (GEV:BayerBG12Packed)
    VmbPixelFormatBayerGR10p          = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy10Bit) + $0056,  // Bayer-color, 4x10 bits continuously packed in 40 bits, starting with GR line (PFNC:BayerGR10p)
    VmbPixelFormatBayerRG10p          = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy10Bit) + $0058,  // Bayer-color, 4x10 bits continuously packed in 40 bits, starting with RG line (PFNC:BayerRG10p)
    VmbPixelFormatBayerGB10p          = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy10Bit) + $0054,  // Bayer-color, 4x10 bits continuously packed in 40 bits, starting with GB line (PFNC:BayerGB10p)
    VmbPixelFormatBayerBG10p          = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy10Bit) + $0052,  // Bayer-color, 4x10 bits continuously packed in 40 bits, starting with BG line (PFNC:BayerBG10p)
    VmbPixelFormatBayerGR12p          = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy12Bit) + $0057,  // Bayer-color, 2x12 bits continuously packed in 24 bits, starting with GR line (PFNC:BayerGR12p)
    VmbPixelFormatBayerRG12p          = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy12Bit) + $0059,  // Bayer-color, 2x12 bits continuously packed in 24 bits, starting with RG line (PFNC:BayerRG12p)
    VmbPixelFormatBayerGB12p          = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy12Bit) + $0055,  // Bayer-color, 2x12 bits continuously packed in 24 bits, starting with GB line (PFNC:BayerGB12p)
    VmbPixelFormatBayerBG12p          = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy12Bit) + $0053,  // Bayer-color, 2x12 bits continuously packed in 24 bits, starting with BG line (PFNC:BayerBG12p)
    VmbPixelFormatBayerGR16           = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy16Bit) + $002E,  // Bayer-color, 16 bits, starting with GR line (PFNC:BayerGR16)
    VmbPixelFormatBayerRG16           = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy16Bit) + $002F,  // Bayer-color, 16 bits, starting with RG line (PFNC:BayerRG16)
    VmbPixelFormatBayerGB16           = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy16Bit) + $0030,  // Bayer-color, 16 bits, starting with GB line (PFNC:BayerGB16)
    VmbPixelFormatBayerBG16           = VmbUint16_t(VmbPixelType.VmbPixelMono) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy16Bit) + $0031,  // Bayer-color, 16 bits, starting with BG line (PFNC:BayerBG16)
    // RGB formats
    VmbPixelFormatRgb8                = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy24Bit) + $0014,  // RGB, 8 bits x 3 (PFNC:RGB8)
    VmbPixelFormatBgr8                = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy24Bit) + $0015,  // BGR, 8 bits x 3 (PFNC:Bgr8)
    VmbPixelFormatRgb10               = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy48Bit) + $0018,  // RGB, 10 bits in 16 bits x 3 (PFNC:RGB10)
    VmbPixelFormatBgr10               = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy48Bit) + $0019,  // BGR, 10 bits in 16 bits x 3 (PFNC:BGR10)
    VmbPixelFormatRgb12               = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy48Bit) + $001A,  // RGB, 12 bits in 16 bits x 3 (PFNC:RGB12)
    VmbPixelFormatBgr12               = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy48Bit) + $001B,  // BGR, 12 bits in 16 bits x 3 (PFNC:BGR12)
    VmbPixelFormatRgb14               = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy48Bit) + $005E,  // RGB, 14 bits in 16 bits x 3 (PFNC:RGB14)
    VmbPixelFormatBgr14               = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy48Bit) + $004A,  // BGR, 14 bits in 16 bits x 3 (PFNC:BGR14)
    VmbPixelFormatRgb16               = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy48Bit) + $0033,  // RGB, 16 bits x 3 (PFNC:RGB16)
    VmbPixelFormatBgr16               = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy48Bit) + $004B,  // BGR, 16 bits x 3 (PFNC:BGR16)
    // RGBA formats
    VmbPixelFormatArgb8               = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy32Bit) + $0016,   // ARGB, 8 bits x 4 (PFNC:RGBa8)
    VmbPixelFormatRgba8               = VmbPixelFormatArgb8,                                                                                    // RGBA, 8 bits x 4, legacy name
    VmbPixelFormatBgra8               = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy32Bit) + $0017,  // BGRA, 8 bits x 4 (PFNC:BGRa8)
    VmbPixelFormatRgba10              = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy64Bit) + $005F,  // RGBA, 10 bits in 16 bits x 4
    VmbPixelFormatBgra10              = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy64Bit) + $004C,  // BGRA, 10 bits in 16 bits x 4
    VmbPixelFormatRgba12              = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy64Bit) + $0061,  // RGBA, 12 bits in 16 bits x 4
    VmbPixelFormatBgra12              = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy64Bit) + $004E,  // BGRA, 12 bits in 16 bits x 4
    VmbPixelFormatRgba14              = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy64Bit) + $0063,  // RGBA, 14 bits in 16 bits x 4
    VmbPixelFormatBgra14              = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy64Bit) + $0050,  // BGRA, 14 bits in 16 bits x 4
    VmbPixelFormatRgba16              = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy64Bit) + $0064,  // RGBA, 16 bits x 4
    VmbPixelFormatBgra16              = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy64Bit) + $0051,  // BGRA, 16 bits x 4
    // YUV/YCbCr formats
    VmbPixelFormatYuv411              = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy12Bit) + $001E,  // YUV 411 with 8 bits (GEV:YUV411Packed)
    VmbPixelFormatYuv422              = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy16Bit) + $001F,  // YUV 422 with 8 bits (GEV:YUV422Packed)
    VmbPixelFormatYuv444              = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy24Bit) + $0020,  // YUV 444 with 8 bits (GEV:YUV444Packed)
    VmbPixelFormatYCbCr411_8_CbYYCrYY = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy12Bit) + $003C,  // Y´CbCr 411 with 8 bits (PFNC:YCbCr411_8_CbYYCrYY) - identical to VmbPixelFormatYuv411
    VmbPixelFormatYCbCr422_8_CbYCrY   = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy16Bit) + $0043,  // Y´CbCr 422 with 8 bits (PFNC:YCbCr422_8_CbYCrY) - identical to VmbPixelFormatYuv422
    VmbPixelFormatYCbCr8_CbYCr        = VmbUint16_t(VmbPixelType.VmbPixelColor) + VmbUint16_t(VmbPixelOccupyType.VmbPixelOccupy24Bit) + $003A,  // Y´CbCr 444 with 8 bits (PFNC:YCbCr8_CbYCr) - identical to VmbPixelFormatYuv444
    VmbPixelFormatLast);

  VmbPixelFormat_t = VmbUint32_t;                                               // Type for the pixel format

var
  VmbErrorStr: Array[-19..0] of String;

implementation

initialization
  VmbErrorStr[0]:= '';
  VmbErrorStr[-1]:= 'Unexpected fault in Vimba or driver';
  VmbErrorStr[-2]:= 'VmbStartup was not called before the current command';
  VmbErrorStr[-3]:= 'The designated instance (camera, feature, etc.) ' +
                    'cannot be found';
  VmbErrorStr[-4]:= 'The given handle is not valid';
  VmbErrorStr[-5]:= 'Device was not opened for usage';
  VmbErrorStr[-6]:= 'Operation is invalid with the current access mode';
  VmbErrorStr[-7]:= 'One of the parameters is invalid (usually an illegal ' +
                    'pointer)';
  VmbErrorStr[-8]:= 'The given struct size is not valid for this version ' +
                    'of the API';                                                //-
  VmbErrorStr[-9]:= 'More data available in a string/list than space is provided';
  VmbErrorStr[-10]:= 'Wrong feature type for this access function';
  VmbErrorStr[-11]:= 'The value is not valid; either out of bounds or not ' +
                     'an increment of the minimum';
  VmbErrorStr[-12]:= 'Timeout during wait';
  VmbErrorStr[-13]:= 'Other error';
  VmbErrorStr[-14]:= 'Resources not available e.g., memory)';
  VmbErrorStr[-15]:= 'Call is invalid in the current context (e.g. callback)';
  VmbErrorStr[-16]:= 'No transport layers are found';           //-16
  VmbErrorStr[-17]:= 'API feature is not implemented';
  VmbErrorStr[-18]:= 'API feature is not supported';
  VmbErrorStr[-19]:= 'VmbErrorIncomplete -19 A multiple registers read or ' +
                     'write is partially completed)';
end.
