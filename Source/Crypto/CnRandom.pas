{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2022 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnRandom;
{* |<PRE>
================================================================================
* 软件名称：开发包基础库
* 单元名称：随机数填充单元
* 单元作者：刘啸
* 备    注：
* 开发平台：Win7 + Delphi 5.0
* 兼容测试：暂未进行
* 本 地 化：该单元无需本地化处理
* 修改记录：2022.08.22 V1.1
*               优先使用操作系统提供的随机数发生器
*           2020.03.27 V1.0
*               创建单元，从 CnPrimeNumber 中独立出来
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils {$IFDEF MSWINDOWS}, Windows {$ENDIF}, Classes, CnNative;

type
  ECnRandomAPIError = class(Exception);

function RandomUInt64: TUInt64;
{* 返回 UInt64 范围内的随机数，在不支持 UInt64 的平台上用 Int64 代替}

function RandomUInt64LessThan(HighValue: TUInt64): TUInt64;
{* 返回大于等于 0 且小于指定 UInt64 值的随机数}

function RandomInt64: Int64;
{* 返回大于等于 0 且小于 Int64 上限的随机数}

function RandomInt64LessThan(HighValue: Int64): Int64;
{* 返回大于等于 0 且小于指定 Int64 值的随机数}

function CnRandomFillBytes(Buf: PAnsiChar; Len: Integer): Boolean;
{* 使用 Windows API 或 /dev/random 设备实现区块随机填充，内部单次初始化随机数引擎并释放}

function CnRandomFillBytes2(Buf: PAnsiChar; Len: Integer): Boolean;
{* 使用 Windows API 或 /dev/urandom 设备实现区块随机填充，
  Windows 下使用已预先初始化好的引擎以提速}

implementation

{$IFDEF MSWINDOWS}

const
  ADVAPI32 = 'advapi32.dll';

  CRYPT_VERIFYCONTEXT = $F0000000;
  CRYPT_NEWKEYSET = $8;
  CRYPT_DELETEKEYSET = $10;

  PROV_RSA_FULL = 1;
  NTE_BAD_KEYSET = $80090016;

function CryptAcquireContext(phProv: PULONG; pszContainer: PAnsiChar;
  pszProvider: PAnsiChar; dwProvType: LongWord; dwFlags: LongWord): BOOL;
  stdcall; external ADVAPI32 name 'CryptAcquireContextA';

function CryptReleaseContext(hProv: ULONG; dwFlags: LongWord): BOOL;
  stdcall; external ADVAPI32 name 'CryptReleaseContext';

function CryptGenRandom(hProv: ULONG; dwLen: LongWord; pbBuffer: PAnsiChar): BOOL;
  stdcall; external ADVAPI32 name 'CryptGenRandom';

var
  FHProv: THandle;

{$ENDIF}

function CnRandomFillBytes(Buf: PAnsiChar; Len: Integer): Boolean;
var
{$IFDEF MSWINDOWS}
  HProv: THandle;
  Res: DWORD;
{$ELSE}
  F: TFileStream;
{$ENDIF}
begin
  Result := False;
{$IFDEF MSWINDOWS}
  // 使用 Windows API 实现区块随机填充
  HProv := 0;
  if not CryptAcquireContext(@HProv, nil, nil, PROV_RSA_FULL, 0) then
  begin
    Res := GetLastError;
    if Res = NTE_BAD_KEYSET then // KeyContainer 不存在，用新建的方式
    begin
      if not CryptAcquireContext(@HProv, nil, nil, PROV_RSA_FULL, CRYPT_NEWKEYSET) then
        raise ECnRandomAPIError.CreateFmt('Error CryptAcquireContext NewKeySet $%8.8x', [GetLastError]);
    end
    else
        raise ECnRandomAPIError.CreateFmt('Error CryptAcquireContext $%8.8x', [Res]);
  end;

  if HProv <> 0 then
  begin
    try
      Result := CryptGenRandom(HProv, Len, Buf);
      if not Result then
        raise ECnRandomAPIError.CreateFmt('Error CryptGenRandom $%8.8x', [GetLastError]);
    finally
      CryptReleaseContext(HProv, 0);
    end;
  end;
{$ELSE}
  // MacOS 下的随机填充实现，采用读取 /dev/random 内容的方式
  F := nil;
  try
    F := TFileStream.Create('/dev/random', fmOpenRead);
    Result := F.Read(Buf^, Len) = Len;
  finally
    F.Free;
  end;
{$ENDIF}
end;

function CnRandomFillBytes2(Buf: PAnsiChar; Len: Integer): Boolean;
{$IFNDEF MSWINDOWS}
var
  F: TFileStream;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  Result := CryptGenRandom(FHProv, Len, Buf);
{$ELSE}
  // MacOS 下的随机填充实现，采用读取 /dev/urandom 内容的方式，不阻塞
  F := nil;
  try
    F := TFileStream.Create('/dev/urandom', fmOpenRead);
    Result := F.Read(Buf^, Len) = Len;
  finally
    F.Free;
  end;
{$ENDIF}
end;

function RandomUInt64: TUInt64;
var
  HL: array[0..1] of Cardinal;
begin
  // 优先用系统的随机数发生器
  if not CnRandomFillBytes2(@HL[0], SizeOf(TUInt64)) then
  begin
    // 直接 Random * High(TUInt64) 可能会精度不够导致 Lo 全 FF，因此分开处理
    Randomize;
    HL[0] := Trunc(Random * High(Cardinal) - 1) + 1;
    HL[1] := Trunc(Random * High(Cardinal) - 1) + 1;
  end;

  Result := (TUInt64(HL[0]) shl 32) + HL[1];
end;

function RandomUInt64LessThan(HighValue: TUInt64): TUInt64;
begin
  Result := UInt64Mod(RandomUInt64, HighValue);
end;

function RandomInt64LessThan(HighValue: Int64): Int64;
var
  HL: array[0..1] of Cardinal;
begin
  // 优先用系统的随机数发生器
  if not CnRandomFillBytes2(@HL[0], SizeOf(Int64)) then
  begin
    // 直接 Random * High(Int64) 可能会精度不够导致 Lo 全 FF，因此分开处理
    Randomize;
    HL[0] := Trunc(Random * High(Integer) - 1) + 1;   // Int64 最高位不能是 1，避免负数
    HL[1] := Trunc(Random * High(Cardinal) - 1) + 1;
  end
  else
    HL[0] := HL[0] mod (Cardinal(High(Integer)) + 1);    // Int64 最高位不能是 1，避免负数

  Result := (Int64(HL[0]) shl 32) + HL[1];
  Result := Result mod HighValue;
end;

function RandomInt64: Int64;
begin
  Result := RandomInt64LessThan(High(Int64));
end;

{$IFDEF MSWINDOWS}

procedure StartRandom;
var
  Res: DWORD;
begin
  FHProv := 0;
  if not CryptAcquireContext(@FHProv, nil, nil, PROV_RSA_FULL, 0) then
  begin
    Res := GetLastError;
    if Res = NTE_BAD_KEYSET then // KeyContainer 不存在，用新建的方式
    begin
      if not CryptAcquireContext(@FHProv, nil, nil, PROV_RSA_FULL, CRYPT_NEWKEYSET) then
        raise ECnRandomAPIError.CreateFmt('Error CryptAcquireContext NewKeySet $%8.8x', [GetLastError]);
    end
    else
        raise ECnRandomAPIError.CreateFmt('Error CryptAcquireContext $%8.8x', [Res]);
  end;
end;

procedure StopRandom;
begin
  CryptReleaseContext(FHProv, 0);
  FHProv := 0;
end;

initialization
  StartRandom;

finalization
  StopRandom;

{$ENDIF}

end.
