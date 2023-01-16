{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2023 CnPack 开发组                       }
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

unit CnOTP;
{* |<PRE>
================================================================================
* 软件名称：开发包基础库
* 单元名称：动态口令实现单元
* 单元作者：刘啸 (liuxiao@cnpack.org)
* 备    注：参考《GB/T 38556-2020 信息安全技术动态口令密码应用技术规范》
* 开发平台：Win 7
* 修改记录：2022.02.11 V1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  Classes, SysUtils, Math;

const
  CN_DEFAULT_PASSWORD_DIGITS = 6;
  {* 默认口令长度，6 位}

  CN_SEED_KEY_MIN_LENGTH = 16;
  {* 最小的种子长度，字节}

  CN_CHALLENGE_MIN_LENGTH = 4;
  {* 最小的挑战码长度，字节}

  CN_ID_MIN_LENGTH = 16;
  {* 最小的 ID 长度，字节}

  CN_PERIOD_MAX_SECOND = 60;
  {* 最大的口令变化周期，秒数}

type
  ECnOneTimePasswordException = class(Exception);

  TCnOnePasswordType = (copSM3, copSM4);
  {* 动态口令中间计算函数有 SM3 和 SM4 两种}

  TCnDynamicToken = class
  {* 动态口令计算器}
  private
    FSeedKey: array of Byte;
    FChallengeCode: array of Byte;
    FCounter: Integer;
    FPasswordType: TCnOnePasswordType;
    FPeriod: Integer;
    FDigits: Integer;
    procedure SetDigits(const Value: Integer);
    procedure SetPeriod(const Value: Integer);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure SetSeedKey(Key: Pointer; KeyByteLength: Integer);
    {* 设置种子密钥 K}

    procedure SetChallengeCode(Code: Pointer; CodeByteLength: Integer);
    {* 设置挑战种子 Q}

    procedure SetCounter(Counter: Integer);
    {* 设置事件因子 C}

    function OneTimePassword: string;
    {* 根据各种数据计算动态口令，返回数字组成的字符串}

    property PasswordType: TCnOnePasswordType read FPasswordType write FPasswordType;
    {* 动态口令中间计算函数类型}

    property Period: Integer read FPeriod write SetPeriod;
    {* 口令变化周期，以秒为单位，默认 60}

    property Digits: Integer read FDigits write SetDigits;
    {* 口令位数，默认 6}
  end;

implementation

uses
  CnSM3, CnSM4, CnNative;

resourcestring
  SCnInvalidDataLength = 'Invalid Data or Length';
  SCnInvalidDigits = 'Invalid Digits';
  SCnInvalidPeriod = 'Invalid Period';

function EpochSeconds: Int64;
var
  D: TDateTime;
begin
  D := EncodeDate(1970, 1, 1);
  Result := Trunc(86400 * (Now - D));
end;

{ TCnDynamicToken }

constructor TCnDynamicToken.Create;
begin
  inherited;
  FPeriod := CN_PERIOD_MAX_SECOND;
  FPasswordType := copSM3;
  FDigits := CN_DEFAULT_PASSWORD_DIGITS;
end;

destructor TCnDynamicToken.Destroy;
begin
  SetLength(FSeedKey, 0);
  SetLength(FChallengeCode, 0);
  inherited;
end;

function TCnDynamicToken.OneTimePassword: string;
var
  L, Cnt: Integer;
  T: Int64;
  ID, S, KID, SM4K, SM4ID: array of Byte;
  OD, TD: Cardinal;
  TenPow: Integer;
  Fmt: string;
  SM3Dig: TSM3Digest;
  SM4KBuf, SM4IDBuf: array[0..SM4_BLOCKSIZE - 1] of Byte;

  // 两个 128 位大端整数 A B 相加，结果放到 R 里，不考虑 128 位溢出
  procedure Add128Bits(A, B, R: PByteArray);
  var
    I: Integer;
    O: Byte;
    Sum: Word;
  begin
    O := 0;
    for I := 15 downto 0 do
    begin
      Sum := A^[I] + B^[I] + O;
      R^[I] := Byte(Sum);
      O := Byte(Sum shr 8);
    end;
  end;

begin
  // 计算动态口令过程
  T := Int64HostToNetwork(EpochSeconds div FPeriod);

  L := SizeOf(Int64) + SizeOf(Integer) + Length(FChallengeCode);
  if L < CN_ID_MIN_LENGTH then
    L := CN_ID_MIN_LENGTH;

  SetLength(ID, L);
  Move(T, ID[0], SizeOf(Int64));

  Cnt := UInt32HostToNetwork(FCounter);
  Move(Cnt, ID[SizeOf(Int64)], SizeOf(Integer));
  if Length(FChallengeCode) > 0 then
    Move(FChallengeCode[0], ID[SizeOf(Int64) + SizeOf(Integer)], Length(FChallengeCode));

  // ID = ( T || C || Q ) 拼好了，然后准备计算 S

  OD := 0;
  try
    if FPasswordType = copSM3 then // SM3 计算
    begin
      SetLength(S, SizeOf(TSM3Digest)); // 32 字节

      // K 和 ID 拼一块，做 SM3 后结果放入 S
      SetLength(KID, Length(ID) + Length(FSeedKey));
      try
        Move(FSeedKey[0], KID[0], Length(FSeedKey));
        Move(ID[0], KID[Length(FSeedKey)], Length(ID));

        SM3Dig := SM3(PAnsiChar(@KID[0]), Length(KID));
        Move(SM3Dig[0], S[0], SizeOf(TSM3Digest));
      finally
        SetLength(KID, 0);
      end;

      // 拆成 8 个 Cardinal 相加
      Move(S[0], TD, SizeOf(Cardinal));
      OD := OD + UInt32HostToNetwork(TD);
      Move(S[4], TD, SizeOf(Cardinal));
      OD := OD + UInt32HostToNetwork(TD);
      Move(S[8], TD, SizeOf(Cardinal));
      OD := OD + UInt32HostToNetwork(TD);
      Move(S[12], TD, SizeOf(Cardinal));
      OD := OD + UInt32HostToNetwork(TD);
      Move(S[16], TD, SizeOf(Cardinal));
      OD := OD + UInt32HostToNetwork(TD);
      Move(S[20], TD, SizeOf(Cardinal));
      OD := OD + UInt32HostToNetwork(TD);
      Move(S[24], TD, SizeOf(Cardinal));
      OD := OD + UInt32HostToNetwork(TD);
      Move(S[28], TD, SizeOf(Cardinal));
      OD := OD + UInt32HostToNetwork(TD);
    end
    else // SM4 计算
    begin
      SetLength(S, SM4_BLOCKSIZE); // 16 字节

      // K 和 ID 每 16 字节加密一段，两者长度不等
      Cnt := Max(Length(FSeedKey), Length(ID));           // 拿到 K 和 ID 的较长值
      Cnt := (Cnt + SM4_BLOCKSIZE - 1) div SM4_BLOCKSIZE; // 往长里取整

      // 分配两个整区，共 Cnt 块
      SetLength(SM4K, Cnt * SM4_BLOCKSIZE);
      SetLength(SM4ID, Cnt * SM4_BLOCKSIZE);

      try
        // 分别把内容塞进整区，后面已补 0
        Move(FSeedKey[0], SM4K[0], Length(FSeedKey));
        Move(ID[0], SM4ID[0], Length(ID));

        FillChar(SM4KBuf[0], SizeOf(SM4KBuf), 0);
        FillChar(SM4IDBuf[0], SizeOf(SM4IDBuf), 0);

        for L := 0 to Cnt - 1 do
        begin
          // S 的内容和 SM4K 的第 L 块内容相加放 SM4KBuf 里
          Add128Bits(PByteArray(@S[0]), PByteArray(@SM4K[L * SM4_BLOCKSIZE]), PByteArray(@SM4KBuf[0]));

          // S 的内容和 SM4ID 的第 L 块内容相加放 SM4IDBuf 里
          Add128Bits(PByteArray(@S[0]), PByteArray(@SM4ID[L * SM4_BLOCKSIZE]), PByteArray(@SM4IDBuf[0]));

          // SM4KBuf 与 SM4IDBuf 进行 SM4 加密，内容放 S 里
          SM4Encrypt(PAnsiChar(@SM4KBuf[0]), PAnsiChar(@SM4IDBuf[0]), PAnsiChar(@S[0]), SM4_BLOCKSIZE);
        end;
      finally
        SetLength(SM4K, 0);
        SetLength(SM4ID, 0);
      end;

      // 拆成 4 个 Cardinal 相加
      Move(S[0], TD, SizeOf(Cardinal));
      OD := OD + UInt32HostToNetwork(TD);
      Move(S[4], TD, SizeOf(Cardinal));
      OD := OD + UInt32HostToNetwork(TD);
      Move(S[8], TD, SizeOf(Cardinal));
      OD := OD + UInt32HostToNetwork(TD);
      Move(S[12], TD, SizeOf(Cardinal));
      OD := OD + UInt32HostToNetwork(TD);
    end;

    TenPow := Trunc(IntPower(10, FDigits));
    Fmt := Format('%%%d.%dd', [FDigits, FDigits]);
    Result := Format(Fmt, [OD mod Cardinal(TenPow)]);
  finally
    SetLength(S, 0);
    SetLength(ID, 0);
  end;
end;

procedure TCnDynamicToken.SetChallengeCode(Code: Pointer;
  CodeByteLength: Integer);
begin
  if (Code = nil) or (CodeByteLength < CN_CHALLENGE_MIN_LENGTH) then
    raise ECnOneTimePasswordException.Create(SCnInvalidDataLength);

  SetLength(FChallengeCode, CodeByteLength);
  Move(Code^, FChallengeCode[0], CodeByteLength);
end;

procedure TCnDynamicToken.SetDigits(const Value: Integer);
begin
  if Value <= 0 then
    raise ECnOneTimePasswordException.Create(SCnInvalidDigits);

  FDigits := Value;
end;

procedure TCnDynamicToken.SetCounter(Counter: Integer);
begin
  FCounter := Counter;
end;

procedure TCnDynamicToken.SetPeriod(const Value: Integer);
begin
  if (Value <= 0) or (Value > CN_PERIOD_MAX_SECOND) then
    raise ECnOneTimePasswordException.Create(SCnInvalidPeriod);

  FPeriod := Value;
end;

procedure TCnDynamicToken.SetSeedKey(Key: Pointer;
  KeyByteLength: Integer);
begin
  if (Key = nil) or (KeyByteLength < CN_SEED_KEY_MIN_LENGTH) then
    raise ECnOneTimePasswordException.Create(SCnInvalidDataLength);

  SetLength(FSeedKey, KeyByteLength);
  Move(Key^, FSeedKey[0], KeyByteLength);
end;

end.
