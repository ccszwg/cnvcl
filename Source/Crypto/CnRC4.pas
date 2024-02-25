{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2024 CnPack 开发组                       }
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

unit CnRC4;
{* |<PRE>
================================================================================
* 软件名称：开发包基础库
* 单元名称：RC4 流加解密算法实现单元
* 单元作者：刘啸（liuxiao@cnpack.org)
* 备    注：
* 开发平台：Windows 7 + Delphi 5.0
* 兼容测试：PWin9X/2000/XP/7 + Delphi 5/6
* 本 地 化：该单元中的字符串均符合本地化处理方式
* 修改记录：2024.02.25 V1.0
*               移植并创建单元
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, CnNative;

const
  CN_RC4_MAX_KEY_BYTE_LENGTH = 256;
  {* 最长支持 256 字节也就是 2048 位的密钥，也是内部 S 盒的大小}

procedure RC4Encrypt(Key: Pointer; KeyByteLength: Integer; Input, Output: Pointer;
  ByteLength: Integer);
{* 对 Input 所指的长度为 ByteLength 的明文数据块，使用 Key 所指的长度 KeyByteLength 的
  RC4 密钥进行加密，密文内容放 Output 所指的数据区，该区要求长度至少也为 ByteLength
  Input Output 可以指向同一块内存，这样 Output 的内容将覆盖原有 Input 的内容}

procedure RC4Decrypt(Key: Pointer; KeyByteLength: Integer; Input, Output: Pointer;
  ByteLength: Integer);
{* 对 Input 所指的长度为 ByteLength 的密文数据块，使用 Key 所指的长度 KeyByteLength 的
  RC4 密钥进行解密，明文内容放 Output 所指的数据区，该区要求长度至少也为 ByteLength
  Input Output 可以指向同一块内存，这样 Output 的内容将覆盖原有 Input 的内容}

function RC4EncryptBytes(Key, Input: TBytes): TBytes;
{* RC4 加密字节数组，返回密文字节数组}

function RC4DecryptBytes(Key, Input: TBytes): TBytes;
{* RC4 解密字节数组，返回明文字节数组}

function RC4EncryptStrToHex(const Str, Key: AnsiString): AnsiString;
{* 传入字符串形式的明文与密钥，RC4 加密返回转换成十六进制的密文}

function DESDecryptECBStrFromHex(const HexStr, Key: AnsiString): AnsiString;
{* 传入十六进制的密文与字符串形式的密钥，RC4 解密返回明文}

implementation

type
  TCnRC4State = packed record
    Permutation: array[0..CN_RC4_MAX_KEY_BYTE_LENGTH - 1] of Byte;
    Index1: Byte;
    Index2: Byte;
  end;

procedure SwapByte(var A, B: Byte); {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
var
  T: Byte;
begin
  T := A;
  A := B;
  B := T;
end;

procedure RC4Init(var State: TCnRC4State; Key: Pointer; KeyByteLength: Integer);
var
  I: Integer;
  K: PByteArray;
  J: Byte;
begin
  for I := 0 to CN_RC4_MAX_KEY_BYTE_LENGTH - 1 do
    State.Permutation[I] := I;
  State.Index1 := 0;
  State.Index2 := 0;

  J := 0;
  K := PByteArray(Key);
  for I := 0 to CN_RC4_MAX_KEY_BYTE_LENGTH - 1 do
  begin
    J := J + K^[I mod KeyByteLength];
    SwapByte(State.Permutation[I], State.Permutation[J]);
  end;
end;

procedure RC4Crypt(var State: TCnRC4State; Input, Output: Pointer;
  ByteLength: Integer);
var
  I: Integer;
  J: Byte;
  IP, OP: PByteArray;
begin
  IP := PByteArray(Input);
  OP := PByteArray(Output);

  for I := 0 to ByteLength - 1 do
  begin
    Inc(State.Index1);
    Inc(State.Index2, State.Permutation[State.Index1]);

    SwapByte(State.Permutation[State.Index1], State.Permutation[State.Index2]);

    J := State.Permutation[State.Index1] + State.Permutation[State.Index2];
    OP^[I] := IP^[I] xor State.Permutation[J];
  end;
end;

// RC4 的流密码运算及与明文或密文的异或，Output 可以是 Input
procedure RC4(Key: Pointer; KeyByteLength: Integer; Input, Output: Pointer;
  ByteLength: Integer);
var
  State: TCnRC4State;
begin
  RC4Init(State, Key, KeyByteLength);
  RC4Crypt(State, Input, Output, ByteLength);
end;

procedure RC4Encrypt(Key: Pointer; KeyByteLength: Integer; Input, Output: Pointer;
  ByteLength: Integer);
begin
  RC4(Key, KeyByteLength, Input, Output, ByteLength);
end;

procedure RC4Decrypt(Key: Pointer; KeyByteLength: Integer; Input, Output: Pointer;
  ByteLength: Integer);
begin
  RC4(Key, KeyByteLength, Input, Output, ByteLength);
end;

function RC4EncryptBytes(Key, Input: TBytes): TBytes;
begin
  if (Length(Key) = 0) or (Length(Input) = 0) then
  begin
    Result := nil;
    Exit;
  end;

  SetLength(Result, Length(Input));
  RC4(@Key[0], Length(Key), @Input[0], @Result[0], Length(Input));
end;

function RC4DecryptBytes(Key, Input: TBytes): TBytes;
begin
  if (Length(Key) = 0) or (Length(Input) = 0) then
  begin
    Result := nil;
    Exit;
  end;

  SetLength(Result, Length(Input));
  RC4(@Key[0], Length(Key), @Input[0], @Result[0], Length(Input));
end;

function RC4EncryptStrToHex(const Str, Key: AnsiString): AnsiString;
begin

end;

function DESDecryptECBStrFromHex(const HexStr, Key: AnsiString): AnsiString;
begin

end;

end.
