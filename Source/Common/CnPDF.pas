{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2024 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ���������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnPDF;
{* |<PRE>
================================================================================
* �������ƣ�������������
* ��Ԫ���ƣ�PDF ���׽������ɵ�Ԫ
* ��Ԫ���ߣ���Х
* ��    ע���򵥵� PDF ��ʽ������Ԫ
*           �����������Խ��дʷ��������ٽ�������������ٽ�������������
*           ���ɣ��ȹ���̶��Ķ��������������ݺ�д����
*
*           ��װ�� CnJpegFilesToPDF ���̣������ JPEG �ļ�ƴ��һ�� PDF ���
*
*           �ļ�β�� Trailer �� Root ָ�� Catalog ���󣬴�������ṹ���£�
*
*           Catalog -> Pages -> Page1 -> Resource
*                   |        |      | -> Content
*                   |        |      | -> Thunbnail Image
*                   |        |      | -> Annoation
*                   |        -> Page2 ...
*                   |
*                   -> Outline Hierarchy -> Outline Entry
*                   |                  | -> Outline Entry
*                   |
*                   -> Artical Threads -> Thread
*                   |                | -> Thread
*                   -> Named Destination
*                   -> Interactive Form
*
*           ѹ�����ԣ�
*               �ⲿ PDF��2007 �����½⣬2009 �����Ͻ⣬Ŀǰ������������
*               2007 ���������ɵ� PDF���ⲿ Reader ��������2007 �����½�������2009 �����Ͻ�����
*               2009 ���������ɵ� PDF���ⲿ Reader ��������2007 �����½�������2009 �����Ͻ�����
*
* ����ƽ̨��Win 7 + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2024.02.012 V1.3
*               TCnPDFDocument �ܹ���������������߼��ṹ
*               ʵ�� CnJpegFilesToPDF ���̣������ JPEG �ļ�ƴ��һ�� PDF ���
*           2024.02.10 V1.2
*               ��������ĸ����ֵĶ�����ṹ����������֯�߼��ṹ
*           2024.02.06 V1.1
*               ������ɴʷ�����������֯�﷨��
*           2024.01.28 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Contnrs, TypInfo, jpeg, CnNative, CnStrings;

type
  ECnPDFException = class(Exception);
  {* PDF �쳣}

  ECnPDFEofException = class(Exception);
  {* ���� PDF ʱ��������β}

//==============================================================================
// ������ PDF �ļ��и��ֶ�������������̳й�ϵ
//
//  TCnPDFObject ������
//    �򵥣�TCnPDFNumberObject��TCnPDFNameObject��TCnPDFBooleanObject��
//          TCnPDFNullObject��TCnPDFStringObject��TCnPDFReferenceObject
//    ���ϣ�TCnPDFArrayObject�����԰������ TCnPDFObject
//          TCnPDFDictionaryObject��������� TCnPDFNameObject �� TCnPDFObject ��
//          TCnPDFStreamObject������һ�� TCnPDFDictionaryObject ��һƬ����������
//
//==============================================================================

  TCnPDFXRefType = (xrtNormal, xrtDeleted, xrtFree);
  {* ����Ľ����������ͣ����������á��������á���ɾ��}

  TCnPDFObject = class(TPersistent)
  {* PDF �ļ��еĶ������}
  private
    FID: Cardinal;
    FGeneration: Cardinal;
    FXRefType: TCnPDFXRefType;
    FOffset: Integer;
  protected
    function CheckWriteObjectStart(Stream: TStream): Cardinal;
    function CheckWriteObjectEnd(Stream: TStream): Cardinal;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function ToString: string; {$IFDEF OBJECT_HAS_TOSTRING} override; {$ELSE} virtual; {$ENDIF}
    {* ����ɵ����ַ���}
    procedure ToStrings(Strings: TStrings; Indent: Integer = 0); virtual;
    {* ����ɶ����ַ�����Ĭ�����ӵ��С�ʵ����Ҫ���� Array �� Dictionary ������}

    function WriteToStream(Stream: TStream): Cardinal; virtual; abstract;

    function Clone: TCnPDFObject;
    {* ����һ���¶��󲢸�������}

    property ID: Cardinal read FID write FID;
    {* ���� ID����Ϊ 0��д��ʱ��дǰ��׺}
    property Generation: Cardinal read FGeneration write FGeneration;
    {* ����Ĵ�����һ��Ϊ 0}
    property XRefType: TCnPDFXRefType read FXRefType write FXRefType;
    {* ���󽻲��������ͣ�һ��Ϊ normal}
    property Offset: Integer read FOffset write FOffset;
    {* �����е�ƫ��������������}
  end;

  TCnPDFObjectClass = class of TCnPDFObject;

  TCnPDFSimpleObject = class(TCnPDFObject)
  {* �򵥵� PDF �ļ�������࣬��һ�μ����ݣ��ɰ���ʽ���}
  private

  protected
    FContent: TBytes;
  public
    constructor Create(const AContent: AnsiString); reintroduce; overload;
    {* ��һ�����ݴ�������}
    constructor Create(const Data: TBytes); reintroduce; overload;
    {* ��һ�����ݴ�������}

    procedure Assign(Source: TPersistent); override;
    {* ��ֵ����}

    function ToString: string; override;

    function WriteToStream(Stream: TStream): Cardinal; override;
    {* �򵥶���Ĭ����ԭ�����}

    property Content: TBytes read FContent write FContent;
    {* ��������װ��ʽǰ��׺�ľ�������}
  end;

  TCnPDFNumberObject = class(TCnPDFSimpleObject)
  {* PDF �ļ��е����ֶ�����}
  public
    constructor Create(Num: Integer); reintroduce; overload;
    constructor Create(Num: Int64); reintroduce; overload;
    constructor Create(Num: Extended); reintroduce; overload;

    function AsInteger: Integer;
    function AsFloat: Extended;

    procedure SetInteger(Value: Integer);
    procedure SetFloat(Value: Extended);
  end;

  TCnPDFNameObject = class(TCnPDFSimpleObject)
  private
    function GetName: AnsiString;
  {* PDF �ļ��е����ֶ�����}
  public
    function WriteToStream(Stream: TStream): Cardinal; override;
    {* ���б�ܼ�����}

    property Name: AnsiString read GetName;
  end;

  TCnPDFBooleanObject = class(TCnPDFSimpleObject)
  {* PDF �ļ��еĲ���������}
  public
    constructor Create(IsTrue: Boolean); reintroduce;
  end;

  TCnPDFNullObject = class(TCnPDFSimpleObject)
  {* PDF �ļ��еĿն�����}
  public
    constructor Create; reintroduce;
  end;

  TCnPDFStringObject = class(TCnPDFSimpleObject)
  {* PDF �ļ��е��ַ���������}
  private
    FIsHex: Boolean;
  public
    constructor Create(const AnsiStr: AnsiString); overload;
{$IFDEF COMPILER5}
    constructor CreateW(const WideStr: WideString); // D5 ���� overload
{$ELSE}
    constructor Create(const WideStr: WideString); overload;
{$ENDIF}
{$IFDEF UNICODE}
    constructor Create(const UnicodeStr: string); overload;
{$ENDIF}

    function WriteToStream(Stream: TStream): Cardinal; override;
    {* ���һ��С���ż������ڵ��ַ���}

    property IsHex: Boolean read FIsHex write FIsHex;
    {* �����Ƿ���ʮ���������}
  end;

  TCnPDFReferenceObject = class(TCnPDFSimpleObject)
  {* PDF �ļ��е����ö�����}
  private
    FReference: TCnPDFObject;
    procedure SetReference(const Value: TCnPDFObject);
  public
    constructor Create(Obj: TCnPDFObject); reintroduce;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    {* ��ֵ����}

    function ToString: string; override;

    function WriteToStream(Stream: TStream): Cardinal; override;
    {* ������� ���� R}

    function IsReference(Obj: TCnPDFObject): Boolean;
    {* �ж��Լ��Ƿ���ָ���ⲿ��������ã�ͨ���Ƚ� ID Generation �Ȳ����ж�}

    property Reference: TCnPDFObject read FReference write SetReference;
    {* ���õĶ���}
  end;

  TCnPDFDictPair = class(TPersistent)
  {* PDF �ļ��е��ֵ�������е����ֶ���ԣ�����������ֵ��������}
  private
    FName: TCnPDFNameObject;
    FValue: TCnPDFObject;
  public
    constructor Create(const Name: string); virtual;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    {* ��ֵ����}

    procedure ChangeToArray;
    {* �� Value �Ǽ򵥶���� nil ʱ��ת�� Value ��������󣬲����� Value ��Ϊ���һ��Ԫ��}

    function WriteToStream(Stream: TStream): Cardinal;
    {* ������� ֵ}

    property Name: TCnPDFNameObject read FName;
    {* ���ֶ���}
    property Value: TCnPDFObject read FValue write FValue;
    {* ֵ���󣬿���������ã������ͷ�}
  end;

  TCnPDFArrayObject = class(TCnPDFObject)
  {* PDF �ļ��е���������࣬���������ڵ�Ԫ�ض���}
  private
    FElements: TObjectList;
    function GetItem(Index: Integer): TCnPDFObject;
    procedure SetItem(Index: Integer; const Value: TCnPDFObject);
    function GetCount: Integer;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    {* ��ֵ����}

    procedure Clear;
    function WriteToStream(Stream: TStream): Cardinal; override;
    {* ���[��ÿ������]}

    function ToString: string; override;
    procedure ToStrings(Strings: TStrings; Indent: Integer = 0); override;

    procedure AddObject(Obj: TCnPDFObject);
    {* ����һ�������ⲿ�����ͷŴ˶���}
    procedure AddNumber(Value: Integer); overload;
    procedure AddNumber(Value: Int64); overload;
    procedure AddNumber(Value: Extended); overload;
    procedure AddNul;
    procedure AddTrue;
    procedure AddFalse;
    procedure AddObjectRef(Obj: TCnPDFObject);
    procedure AddAnsiString(const Value: AnsiString);
    procedure AddWideString(const Value: WideString);
{$IFDEF UNICODE}
    procedure AddUnicodeString(const Value: string);
{$ENDIF}

    function HasObjectRef(Obj: TCnPDFObject): Boolean;
    {* �Ƿ����һ���������}

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TCnPDFObject read GetItem write SetItem;
    {* ���������Ԫ��}
  end;

  TCnPDFDictionaryObject = class(TCnPDFObject)
  {* PDF �ļ��е��ֵ�����࣬�����ڲ� Pair}
  private
    FPairs: TObjectList;
    function GetValue(const Name: string): TCnPDFObject;
    procedure SetValue(const Name: string; const Value: TCnPDFObject);
    function GetCount: Integer;
    function GetPair(Index: Integer): TCnPDFDictPair;
  protected
    function IndexOfName(const Name: string): Integer;
    procedure AddPair(APair: TCnPDFDictPair);

    function WriteDictionary(Stream: TStream): Cardinal;

    property Pairs[Index: Integer]: TCnPDFDictPair read GetPair;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    {* ��ֵ����}

    procedure Clear;
    function WriteToStream(Stream: TStream): Cardinal; override;
    {* ���<<��ÿ��Pair��>>}

    function ToString: string; override;
    procedure ToStrings(Strings: TStrings; Indent: Integer = 0); override;

    function AddName(const Name: string): TCnPDFDictPair; overload;
    {* ����һ�����ƣ�ֵ����縳ֵ����ֵ���ⲿ�����ͷŴ˶���}
    function AddName(const Name1, Name2: string): TCnPDFDictPair; overload;
    {* �����������Ʒֱ���Ϊ������ֵ}

    function AddArray(const Name: string): TCnPDFArrayObject;
    {* ����һ�������Ŀ����飬ע�ⷵ�ص������������}
    function AddDictionary(const Name: string): TCnPDFDictionaryObject;
    {* ����һ�������Ŀ��ֵ䣬ע�ⷵ�ص����ֵ������}

    function AddNumber(const Name: string; Value: Integer): TCnPDFDictPair; overload;
    function AddNumber(const Name: string; Value: Int64): TCnPDFDictPair; overload;
    function AddNumber(const Name: string; Value: Extended): TCnPDFDictPair; overload;
    function AddNull(const Name: string): TCnPDFDictPair;
    function AddTrue(const Name: string): TCnPDFDictPair;
    function AddFalse(const Name: string): TCnPDFDictPair;
    function AddObjectRef(const Name: string; Obj: TCnPDFObject): TCnPDFDictPair;
    function AddString(const Name: string; const Value: string): TCnPDFDictPair;
    function AddAnsiString(const Name: string; const Value: AnsiString): TCnPDFDictPair;
    function AddWideString(const Name: string; const Value: WideString): TCnPDFDictPair;
{$IFDEF UNICODE}
    function AddUnicodeString(const Name: string; const Value: string): TCnPDFDictPair;
{$ENDIF}

    procedure DeleteName(const Name: string);
    {* ɾ��ָ�����ּ���Ӧ Value ���ͷ�}
    function HasName(const Name: string): Boolean;
    {* �Ƿ���ָ�����ƴ���}
    procedure GetNames(Names: TStrings);
    {* ������������ Names ��}
    function GetType: string;
    {* ��װ�ĳ��õĻ�ȡ������ 'Type' �����ֵ��ַ���ֵ}
    property Count: Integer read GetCount;
    {* �ֵ��ڵ�Ԫ������}
    property Values[const Name: string]: TCnPDFObject read GetValue write SetValue; default;
    {* �����������ö���}
  end;

  TCnPDFStreamObject = class(TCnPDFDictionaryObject)
  {* PDF �ļ��е��������࣬��˵����һ�ֵ�һ��}
  private
    FStream: TBytes;
    FSupportCompress: Boolean;
  protected
    procedure SyncLength;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure SetJpegImage(const JpegFileName: string);
    {* ��һ JPEG ��ʽ���ļ����뱾����} 

    function WriteToStream(Stream: TStream): Cardinal; override;
    {* ��� stream ������ endstream}

    procedure ExtractStream(OutStream: TStream);

    procedure SetStrings(Strings: TStrings);
    {* ��ָ�� Strings �е����ݸ�ֵ����}

    procedure Compress;
    {* �� FStream ��������ѹ���ɱ�׼ Zip ��ʽ���·��� FStream�������������֪��������ݵ��ô�ѹ������
      ע���ƺ����� Delphi �汾�ߵ�Ҳ���������Ƿ��� SUPPORT_ZLIB_WINDOWBITS
      ѹ�����������ܱ� Acrobat Reader �����Ӷ���ȷ��ʾ����}

    procedure Uncompress;
    {* �� FStream �еı�׼ Zip ���ݽ�ѹ�����������·��� FStream
      ע����� Delphi �汾���ͣ��ڲ���ѹʱ���ܻ���쳣�����޺ð취}

    function ToString: string; override;
    procedure ToStrings(Strings: TStrings; Indent: Integer = 0); override;

    property SupportCompress: Boolean read FSupportCompress write FSupportCompress;
    {* �Ƿ�֧��ѹ��������ʱ�����ָ�������� PDF ʱ�����ֵ����ݵ� Filter �Ƿ� FlateDecode ָ��}
    property Stream: TBytes read FStream write FStream;
    {* ������ԭʼ�����ݣ��մ� PDF �н�������ʱ������ѹ����}
  end;

  TCnPDFObjectManager = class(TObjectList)
  {* PDFDocument ���ڲ�ʹ�õĹ���ÿ���������������}
  private
    FMaxID: Integer;
    function GetItem(Index: Integer): TCnPDFObject;
    procedure SetItem(Index: Integer; const Value: TCnPDFObject);
  public
    constructor Create;

    procedure CalcMaxID;
    {* �����������󣬱���ͳ�Ƴ������ ID}

    function AddRaw(AObject: TCnPDFObject): Integer;
    {* ����һ�ⲿ���󹩹������ڲ������� ID�����ڽ���}

    function GetObjectByIDGeneration(ObjID: Cardinal;
      ObjGeneration: Cardinal = 0): TCnPDFObject;
    {* ���� ID �ʹ������Ҷ���}

    function Add(AObject: TCnPDFObject): Integer; reintroduce;
    {* ����һ�ⲿ���󹩹������ڲ��������� ID}

    property Items[Index: Integer]: TCnPDFObject read GetItem write SetItem; default;
    property MaxID: Integer read FMaxID;
  end;

  TCnPDFPartBase = class
  public
    function WriteToStream(Stream: TStream): Cardinal; virtual; abstract;
    procedure DumpToStrings(Strings: TStrings; Verbose: Boolean = False;
      Indent: Integer = 0); virtual; abstract;
    {* �����Ϣ��Verbose ָʾ��ϸ���������ʱ�ɲ�������
      Indent �Ƕ�����Ϣ�� Verbose Ϊ True ʱ������}
  end;

  TCnPDFHeader = class(TCnPDFPartBase)
  {* PDF �ļ�ͷ�Ľ���������}
  private
    FVersion: string;
    FComment: string;
  public
    constructor Create; virtual;
    {* ���캯��}
    destructor Destroy; override;
    {* ��������}

    function WriteToStream(Stream: TStream): Cardinal; override;
    {* �������������}
    procedure DumpToStrings(Strings: TStrings; Verbose: Boolean = False; Indent: Integer = 0); override;
    {* �����Ҫ�ܽ���Ϣ������}

    property Version: string read FVersion write FVersion;
    {* �ַ�����ʽ�İ汾�ţ��� 1.7 ��}
    property Comment: string read FComment write FComment;
    {* һ�ε���ע�ͣ���һЩ�����ַ�}
  end;

  TCnPDFXRefItem = class(TCollectionItem)
  {* PDF �ļ���Ľ������ñ�����Ŀ�������Ŀ����һ����}
  private
    FObjectGeneration: Cardinal;
    FObjectXRefType: TCnPDFXRefType;
    FObjectOffset: Cardinal;
  public
    property ObjectGeneration: Cardinal read FObjectGeneration write FObjectGeneration;
    {* �������}
    property ObjectXRefType: TCnPDFXRefType read FObjectXRefType write FObjectXRefType;
    {* ������������}
    property ObjectOffset: Cardinal read FObjectOffset write FObjectOffset;
    {* �������ļ��е�ƫ����}
  end;

  TCnPDFXRefCollection = class(TCollection)
  {* PDF �ļ���Ľ������ñ��е�һ���εĽ��������ɣ����������Ŀ}
  private
    FObjectIndex: Cardinal;
    function GetItem(Index: Integer): TCnPDFXRefItem;
    procedure SetItem(Index: Integer; const Value: TCnPDFXRefItem);
  public
    constructor Create; reintroduce;
    destructor Destroy; override;

    function WriteToStream(Stream: TStream): Cardinal;
    {* �������������}

    function Add: TCnPDFXRefItem;
    {* ����һ���ս���������Ŀ}

    property ObjectIndex: Cardinal read FObjectIndex write FObjectIndex;
    {* �����ڵĶ�����ʼ���}
    property Items[Index: Integer]: TCnPDFXRefItem read GetItem write SetItem;
    {* ���ε�����������}
  end;

  TCnPDFXRefTable = class(TCnPDFPartBase)
  {* PDF �ļ��еĽ������ñ��Ľ��������ɣ�����һ��������}
  private
    FSegments: TObjectList;
    function GetSegmenet(Index: Integer): TCnPDFXRefCollection;
    function GetSegmentCount: Integer;
    procedure SetSegment(Index: Integer;
      const Value: TCnPDFXRefCollection);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Clear;

    function WriteToStream(Stream: TStream): Cardinal; override;
    {* �������������}
     procedure DumpToStrings(Strings: TStrings; Verbose: Boolean = False; Indent: Integer = 0); override;
    {* �����Ҫ�ܽ���Ϣ������}

    function AddSegment: TCnPDFXRefCollection;
    {* ����һ���ն�}

    property SegmentCount: Integer read GetSegmentCount;
    {* �������ñ��еĶ���}
    property Segments[Index: Integer]: TCnPDFXRefCollection read GetSegmenet write SetSegment;
    {* �������ñ��е�ÿһ��}
  end;

  TCnPDFTrailer = class(TCnPDFPartBase)
  {* PDF �ļ�β�Ľ���������}
  private
    FDictionary: TCnPDFDictionaryObject;
    FXRefStart: Cardinal;
    FComment: string;
  protected
    procedure GenerateID;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function WriteToStream(Stream: TStream): Cardinal; override;
    {* �������������}
     procedure DumpToStrings(Strings: TStrings; Verbose: Boolean = False; Indent: Integer = 0); override;
    {* �����Ҫ�ܽ���Ϣ������}

    property Dictionary: TCnPDFDictionaryObject read FDictionary;
    {* �ļ�β���ֵ䣬���� Size��Root��Info �ȹؼ���Ϣ}

    property XRefStart: Cardinal read FXRefStart write FXRefStart;
    {* �������ñ�����ʼ�ֽ�ƫ����������ָ�� xref ԭʼ����Ҳ������һ�� ������ XRef �� Object����ͷ����ʽ����}
    property Comment: string read FComment write FComment;
    {* ���һ��ע��}
  end;

  TCnPDFBody = class(TCnPDFPartBase)
  {* PDF ������֯��}
  private
    FObjects: TCnPDFObjectManager;     // ���ж����������Ͻ�����඼������
    FPages: TCnPDFDictionaryObject;    // ҳ��������
    FCatalog: TCnPDFDictionaryObject;  // ��Ŀ¼���󣬹� Trailer ������
    FInfo: TCnPDFDictionaryObject;     // ��Ϣ���󣬹� Trailer ������
    FXRefTable: TCnPDFXRefTable;       // �������ñ�������
    function GetPage(Index: Integer): TCnPDFDictionaryObject;
    function GetPageCount: Integer;
    function GetContent(Index: Integer): TCnPDFStreamObject;
    function GetContentCount: Integer;
    function GetResource(Index: Integer): TCnPDFDictionaryObject;
    function GetResourceCount: Integer;
  protected
    FPageList: TObjectList;            // ҳ������б�
    FResourceList: TObjectList;        // ҳ��������Դ�б����ȶ���һ�飬һ���� Dictionary
    FContentList: TObjectList;         // ҳ�����������б����ȶ���һ�飬һ���� Stream

    procedure SyncPages;
    {* ��ҳ���������ø�ֵ�� Pages �� Kids}
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure SortObjects;
    {* �������������������}

    procedure CreateResources;

    function WriteToStream(Stream: TStream): Cardinal; override;
    {* �������������}
     procedure DumpToStrings(Strings: TStrings; Verbose: Boolean = False; Indent: Integer = 0); override;
    {* �����Ҫ�ܽ���Ϣ������}

    procedure AddObject(Obj: TCnPDFObject);
    {* ��������Ӵ����õĶ��󲢽�������������ڲ�����ö���������Ч ID}
    property Objects: TCnPDFObjectManager read FObjects;
    {* ���ж��󹩷���}

    property XRefTable: TCnPDFXRefTable read FXRefTable write FXRefTable;
    {* �������ñ������ã���д����������ƫ�Ƶ�}

    // ���´�ű���
    property Info: TCnPDFDictionaryObject read FInfo write FInfo;
    {* ��Ϣ��������Ϊ�ֵ�}

    property Catalog: TCnPDFDictionaryObject read FCatalog write FCatalog;
    {* ����������Ϊ�ֵ䣬�� /Pages ָ�� Pages ����}

    property Pages: TCnPDFDictionaryObject read FPages write FPages;
    {* ҳ���б�������Ϊ�ֵ䣬�� /Kids ָ�����ҳ��}
    property PageCount: Integer read GetPageCount;
    {* ҳ���������}
    property Page[Index: Integer]: TCnPDFDictionaryObject read GetPage;
    {* ���ҳ���������Ϊ�ֵ䣬�� MediaBox������ֽ�Ŵ�С����Resources��������Դ�ȣ���
      Parent��ָ��ҳ���б����ڵ㣩��Contents��ҳ�����ݲ�������}

    property ContentCount: Integer read GetContentCount;
    {* ���ݶ����������ݲ�����ҳ��}
    property Content[Index: Integer]: TCnPDFStreamObject read GetContent;
    {* ������ݶ�������Ϊ�ֵ����}

    property ResourceCount: Integer read GetResourceCount;
    {* ��Դ�����������ݲ�����ҳ��}
    property Resource[Index: Integer]: TCnPDFDictionaryObject read GetResource;
    {* �����Դ��������Ϊ�ֵ�}

    function AddPage: TCnPDFDictionaryObject;
    {* ����һ��ҳ�沢���ظ�ҳ��}
    function AddResource(Page: TCnPDFDictionaryObject): TCnPDFDictionaryObject;
    {* ��ĳҳ����һ�� Resource��Page �� /Resources ָ�������˶���}
    function AddContent(Page: TCnPDFDictionaryObject): TCnPDFStreamObject;
    {* ��ĳҳ����һ�� Content��Page �� /Contents ָ�������˶���}

    procedure AddRawPage(APage: TCnPDFDictionaryObject);
    {* ����һ�ⲿָ��ҳ����Ϊ����}
    procedure AddRawContent(AContent: TCnPDFStreamObject);
    {* ����һ�ⲿָ��������Ϊ����}
    procedure AddRawResource(AResource: TCnPDFDictionaryObject);
    {* ����һ�ⲿָ��������Ϊ����}
  end;

//==============================================================================
//
// ������ PDF �ļ��Ľṹ�������ĸ���
//
//==============================================================================

  TCnPDFParser = class;

  TCnPDFDocument = class
  private
    FHeader: TCnPDFHeader;
    FBody: TCnPDFBody;
    FXRefTable: TCnPDFXRefTable;
    FTrailer: TCnPDFTrailer;
    function FromReference(Ref: TCnPDFReferenceObject): TCnPDFObject;
  protected
    procedure ReadTrailer(P: TCnPDFParser);
    procedure ReadTrailerStartXRef(P: TCnPDFParser);
    procedure ReadXRef(P: TCnPDFParser);

    procedure XRefDictToXRefTable(Dict: TCnPDFDictionaryObject);
    procedure ArrangeObjects;
    {* �������ж����� Root �ȴ���������}
    procedure UncompressObjects;
    {* �ж� Stream ���ݲ�������ѹ��}

    procedure SyncTrailer;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);

    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);

    procedure DumpToStrings(Strings: TStrings);
    // �� Parse �ж������ݣ����� P ���������ݵ���һ�� Token
    procedure ReadDictionary(P: TCnPDFParser; Dict: TCnPDFDictionaryObject);
    {* ����һ���ֵ䣬P ��ָ�� <<�����к����� >>}
    procedure ReadArray(P: TCnPDFParser; AnArray: TCnPDFArrayObject);
    {* ����һ�����飬P ��ָ�� [�����к����� ]}
    procedure ReadNumber(P: TCnPDFParser; Num: TCnPDFNumberObject; OverCRLF: Boolean = True);
    {* ����һ�����֣�P ��ָ�� pttNumber�����к������� pttNumber
      �÷������� OverCRLF �����򽻲����ñ�����Ҫ}
    procedure ReadReference(P: TCnPDFParser; Ref: TCnPDFReferenceObject);
    {* ����һ�����ã�P ��ָ�� pttNumber pttNumber pttR�����к������� pttR}
    procedure ReadName(P: TCnPDFParser; Name: TCnPDFNameObject);
    {* ����һ�����ƣ�P ��ָ�� pttName�����к������� pttName}
    procedure ReadString(P: TCnPDFParser; Str: TCnPDFStringObject);
    {* ����һ���ַ�����P ��ָ�� (�����к����� ) }
    procedure ReadHexString(P: TCnPDFParser; Str: TCnPDFStringObject);
    {* ����һ���ַ�����P ��ָ�� <�����к����� > }
    procedure ReadStream(P: TCnPDFParser; Stream: TCnPDFStreamObject);
    {* ����һ�������ݣ�P ��ָ�� stream �ؼ��֣����к����� endstream}

    function ReadObject(P: TCnPDFParser): TCnPDFObject;
    {* ��һ�������ļ�Ӷ��󣬲������� Manager �з���}
    function ReadObjectInner(P: TCnPDFParser): TCnPDFObject;
    {* ����Ӷ����ڵĲ��ֻ�����ֱ�Ӷ���}

    property Header: TCnPDFHeader read FHeader;
    property Body: TCnPDFBody read FBody;
    property XRefTable: TCnPDFXRefTable read FXRefTable;
    property Trailer: TCnPDFTrailer read FTrailer;
  end;

//==============================================================================
//
// ������ PDF �ļ��Ĵʷ����﷨��������δʵ��
//
//==============================================================================

  TCnPDFTokenType = (pttUnknown, pttComment, pttBlank, pttLineBreak, pttNumber,
    pttNull, pttTrue, pttFalse, pttObj, pttEndObj, pttStream, pttEnd, pttR,
    pttN, pttD, pttF, pttXref, pttStartxref, pttTrailer,
    pttName, pttStringBegin, pttString, pttStringEnd,
    pttHexStringBegin, pttHexString, pttHexStringEnd, pttArrayBegin, pttArrayEnd,
    pttDictionaryBegin, pttDictionaryEnd, pttStreamData, pttEndStream);
  {* PDF �ļ������еķ������ͣ���Ӧ%���ո񡢻س����С����֡�
    null��true��false��obj��stream��end��R��xref��startxref��trailer
    /��(��)��<��>��[��]��<<��>>�������ݡ�endstream}

  TCnPDFParserBookmark = packed record
  {* ��¼ Parser ״̬�Ի���}
    Run: Integer;
    TokenPos: Integer;
    TokenID: TCnPDFTokenType;
    PrevNonBlankID: TCnPDFTokenType;
    StringLen: Integer;
  end;

  TCnPDFParser = class
  {* PDF ���ݽ�����}
  private
    FRun: Integer;
    FTokenPos: Integer;
    FTokenID: TCnPDFTokenType;
    FPrevNonBlankID: TCnPDFTokenType;
    FStringLen: Integer; // ��ǰ�ַ������ַ�����

    FOrigin: PAnsiChar;
    FByteLength: Integer;
    FProcTable: array[#0..#255] of procedure of object;

    procedure KeywordProc;               // obj stream end null true false �ȹ̶���ʶ��
    procedure NameBeginProc;             // /
    procedure StringBeginProc;           // (
    procedure StringEndProc;             // )
    procedure ArrayBeginProc;            // [
    procedure ArrayEndProc;              // ]
    procedure LessThanProc;              // <<
    procedure GreaterThanProc;           // >>
    procedure CommentProc;               // %
    procedure NumberProc;                // ����+-
    procedure BlankProc;                 // �ո� Tab ��
    procedure CRLFProc;                  // �س����л�س�����
    procedure UnknownProc;               // δ֪

    procedure StringProc;                // �ֹ����õ��ַ�������
    procedure HexStringProc;             // �ֹ����õ�ʮ�������ַ�������
    procedure StreamDataProc;            // �ֹ����õ������ݴ���

    function GetToken: AnsiString;
    procedure SetRunPos(const Value: Integer);
    function GetTokenLength: Integer;
  protected
    procedure Error(const Msg: string);
    function TokenEqualStr(Org: PAnsiChar; const Str: AnsiString): Boolean;
    procedure MakeMethodTable;
    procedure StepRun; {$IFDEF SUPPORT_INLINE} inline; {$ENDIF}
  public
    constructor Create; virtual;
    {* ���캯��}
    destructor Destroy; override;
    {* ��������}

    procedure SetOrigin(const PDFBuf: PAnsiChar; PDFByteSize: Integer);

    procedure LoadFromBookmark(var Bookmark: TCnPDFParserBookmark);
    procedure SaveToBookmark(var Bookmark: TCnPDFParserBookmark);

    procedure Next;
    {* ������һ�� Token ��ȷ�� TokenID}
    procedure NextNoJunk;
    {* ������һ���� Null �Լ��ǿո� Token ��ȷ�� TokenID}
    procedure NextNoJunkNoCRLF;
    {* ������һ���� Null �Լ��ǿո��Լ��ǻس����� Token ��ȷ�� TokenID}

    property Origin: PAnsiChar read FOrigin;
    {* �������� PDF ����}
    property RunPos: Integer read FRun write SetRunPos;
    {* ��ǰ����λ������� FOrigin ������ƫ��������λΪ�ֽ�����0 ��ʼ}
    property TokenID: TCnPDFTokenType read FTokenID;
    {* ��ǰ Token ����}
    property Token: AnsiString read GetToken;
    {* ��ǰ Token ���ַ������ݣ��ݲ�����}
    property TokenLength: Integer read GetTokenLength;
    {* ��ǰ Token ���ֽڳ���}
  end;

function CnLoadPDFFile(const FileName: string): TCnPDFDocument;
{* ����һ�� PDF �ļ�������һ���½��� PDFDocument ����}

procedure CnSavePDFFile(PDF: TCnPDFDocument; const FileName: string);
{* ��һ�� PDFDocument ���󱣴�� PDF �ļ�}

procedure CnJpegFilesToPDF(JpegFiles: TStrings; const FileName: string);
{* ��һ�� JPG �ļ�ƴ��һ�� PDF �ļ��������ָ���ļ���
  PDF ҳ���ڲ�������ı�׼ A4 ֽ�ųߴ粢���ñ�׼�������±߾�ֵ}

implementation

uses
  CnZip, CnRandom;

const
  IDLENGTH = 16;
  INDENTDELTA = 4;
  SPACE: AnsiChar = ' ';
  CRLF: array[0..1] of AnsiChar = (#13, #10);

  CRLFS: set of AnsiChar = [#13, #10];
  // PDF �淶�еĿհ��ַ��еĻس�����
  WHITESPACES: set of AnsiChar = [#0, #9, #12, #32];
  // PDF �淶�г��˻س�����֮��Ŀհ��ַ�
  DELIMETERS: set of AnsiChar = ['(', ')', '<', '>', '[', ']', '{', '}', '%'];
  // PDF �淶�еķָ��ַ�

  PDFHEADER: AnsiString = '%PDF-';
  OBJFMT: AnsiString = '%d %d obj';
  ENDOBJ: AnsiString = 'endobj';
  XREF: AnsiString = 'xref';
  BEGINSTREAM: AnsiString = 'stream';
  ENDSTREAM: AnsiString = 'endstream';

  TRAILER: AnsiString = 'trailer';
  STARTXREF: AnsiString = 'startxref';
  EOF: AnsiString = '%%EOF';

function WriteSpace(Stream: TStream): Cardinal;
begin
  Result := Stream.Write(SPACE, SizeOf(SPACE));
end;

function WriteCRLF(Stream: TStream): Cardinal;
begin
  Result := Stream.Write(CRLF[0], SizeOf(CRLF));
end;

function WriteLine(Stream: TStream; const Str: AnsiString): Cardinal;
begin
  if Length(Str) > 0 then
    Result := Stream.Write(Str[1], Length(Str))
  else
    Result := 0;
  Inc(Result, WriteCRLF(Stream));
end;

function WriteString(Stream: TStream; const Str: AnsiString): Cardinal;
begin
  if Length(Str) > 0 then
    Result := Stream.Write(Str[1], Length(Str))
  else
    Result := 0;
end;

function WriteBytes(Stream: TStream; const Data: TBytes): Cardinal;
begin
  if Length(Data) > 0 then
    Result := Stream.Write(Data[0], Length(Data))
  else
    Result := 0;
end;

function XRefTokenToType(XRefToken: TCnPDFTokenType): TCnPDFXRefType;
begin
  case XRefToken of
    pttN: Result := xrtNormal;
    pttD: Result := xrtDeleted;
    pttF: Result := xrtFree;
  else
    Result := xrtNormal;
  end;
end;

function XRefTypeToString(XRefType: TCnPDFXRefType): AnsiString;
begin
  case XRefType of
    xrtFree: Result := 'f';
    xrtNormal: Result := 'n';
    xrtDeleted: Result := 'd';
  else
    Result := 'n';
  end;
end;

procedure ParseError(P: TCnPDFParser; const Msg: string);
begin
  raise ECnPDFException.CreateFmt('PDF Parse Error at %d: %s', [P.RunPos, Msg]);
end;

procedure CheckExpectedToken(P: TCnPDFParser; ExpectedToken: TCnPDFTokenType);
begin
  if P.TokenID <> ExpectedToken then
    ParseError(P, Format('Expect Token %s but Meet %s',
      [GetEnumName(TypeInfo(TCnPDFTokenType), Ord(ExpectedToken)),
      GetEnumName(TypeInfo(TCnPDFTokenType), Ord(P.TokenID))]));
end;

function TrimToName(const SlashName: string): string;
begin
  Result := SlashName;
  if SlashName <> '' then
  begin
    if Result[1] = '/' then
    begin
      Delete(Result, 1, 1);
      Result := Trim(Result);
    end;
  end;
end;

{ TCnPDFTrailer }

constructor TCnPDFTrailer.Create;
begin
  inherited;
  FDictionary := TCnPDFDictionaryObject.Create;
end;

destructor TCnPDFTrailer.Destroy;
begin
  FDictionary.Free;
  inherited;
end;

procedure TCnPDFTrailer.DumpToStrings(Strings: TStrings; Verbose: Boolean;
  Indent: Integer);
var
  I: Integer;
  V: TCnPDFObject;
  N: TStringList;
begin
  Strings.Add('Trailer');
  Strings.Add('Dictionary:');
  N := TStringList.Create;
  try
    FDictionary.GetNames(N);
    for I := 0 to N.Count - 1 do
    begin
      V := FDictionary.Values[N[I]];
      if V = nil then
        N[I] := N[I] + ': nil'
      else
        N[I] := N[I] + ': ' + V.ToString;
    end;

    Strings.AddStrings(N);
  finally
    N.Free;
  end;
  Strings.Add('XRefStart ' + IntToStr(FXRefStart));
  Strings.Add(FComment);
end;

procedure TCnPDFTrailer.GenerateID;
var
  Arr: TCnPDFArrayObject;
  V: TCnPDFStringObject;
  S: AnsiString;
begin
  Arr := TCnPDFArrayObject.Create;
  SetLength(S, IDLENGTH);

  CnRandomFillBytes(@S[1], IDLENGTH);
  V := TCnPDFStringObject.Create(S);
  V.IsHex := True;
  Arr.AddObject(V);

  CnRandomFillBytes(@S[1], IDLENGTH);
  V := TCnPDFStringObject.Create(S);
  V.IsHex := True;
  Arr.AddObject(V);

  FDictionary.Values['ID'] := Arr;
end;

function TCnPDFTrailer.WriteToStream(Stream: TStream): Cardinal;
begin
  Result := 0;
  Inc(Result, WriteLine(Stream, TRAILER));
  Inc(Result, FDictionary.WriteToStream(Stream));
  Inc(Result, WriteLine(Stream, STARTXREF));
  Inc(Result, WriteLine(Stream, IntToStr(FXRefStart)));
  Inc(Result, WriteLine(Stream, EOF));
end;

{ TCnPDFXRefCollection }

function TCnPDFXRefCollection.Add: TCnPDFXRefItem;
begin
  Result := TCnPDFXRefItem(inherited Add);
end;

constructor TCnPDFXRefCollection.Create;
begin
  inherited Create(TCnPDFXRefItem);
end;

destructor TCnPDFXRefCollection.Destroy;
begin

  inherited;
end;

function TCnPDFXRefCollection.GetItem(Index: Integer): TCnPDFXRefItem;
begin
  Result := TCnPDFXRefItem(inherited GetItem(Index));
end;

procedure TCnPDFXRefCollection.SetItem(Index: Integer;
  const Value: TCnPDFXRefItem);
begin
  inherited SetItem(Index, Value);
end;

function TCnPDFXRefCollection.WriteToStream(Stream: TStream): Cardinal;
var
  I: Integer;
begin
  Result := WriteLine(Stream, Format('%d %d', [FObjectIndex, Count]));
  for I := 0 to Count - 1 do
    Inc(Result, WriteLine(Stream, Format('%10.10d %5.5d %s', [Items[I].ObjectOffset,
      Items[I].ObjectGeneration, XRefTypeToString(Items[I].ObjectXRefType)])));
end;

{ TCnPDFXRefTable }

function TCnPDFXRefTable.AddSegment: TCnPDFXRefCollection;
begin
  Result := TCnPDFXRefCollection.Create;
  FSegments.Add(Result);
end;

procedure TCnPDFXRefTable.Clear;
begin
  FSegments.Clear;
end;

constructor TCnPDFXRefTable.Create;
begin
  inherited;
  FSegments := TObjectList.Create(True);
end;

destructor TCnPDFXRefTable.Destroy;
begin
  FSegments.Free;
  inherited;
end;

procedure TCnPDFXRefTable.DumpToStrings(Strings: TStrings; Verbose: Boolean;
  Indent: Integer);
var
  I, J: Integer;
  Seg: TCnPDFXRefCollection;
begin
  Strings.Add('XRefTable');
  for I := 0 to SegmentCount - 1 do
  begin
    Seg := Segments[I];
    Strings.Add(Format('%d %d', [Seg.ObjectIndex, Seg.Count]));
    for J := 0 to Seg.Count - 1 do
      Strings.Add(Format('%10.10d %5.5d %s', [Seg.Items[J].ObjectOffset,
        Seg.Items[J].ObjectGeneration, XRefTypeToString(Seg.Items[J].ObjectXRefType)]));
  end;
end;

function TCnPDFXRefTable.GetSegmenet(Index: Integer): TCnPDFXRefCollection;
begin
  Result := TCnPDFXRefCollection(FSegments[Index]);
end;

function TCnPDFXRefTable.GetSegmentCount: Integer;
begin
  Result := FSegments.Count;
end;

procedure TCnPDFXRefTable.SetSegment(Index: Integer;
  const Value: TCnPDFXRefCollection);
begin
  FSegments[Index] := Value;
end;

function TCnPDFXRefTable.WriteToStream(Stream: TStream): Cardinal;
var
  I: Integer;
begin
  Result := WriteLine(Stream, XREF);
  for I := 0 to SegmentCount - 1 do
    Inc(Result, Segments[I].WriteToStream(Stream));
end;

{ TCnPDFParser }

procedure TCnPDFParser.ArrayBeginProc;
begin
  StepRun;
  FTokenID := pttArrayBegin;
end;

procedure TCnPDFParser.ArrayEndProc;
begin
  StepRun;
  FTokenID := pttArrayEnd;
end;

procedure TCnPDFParser.BlankProc;
begin
  repeat
    StepRun;
  until not (FOrigin[FRun] in WHITESPACES);
  FTokenID := pttBlank;
end;

procedure TCnPDFParser.CommentProc;
begin
  repeat
    StepRun;
  until (FOrigin[FRun] in [#13, #10]);
  FTokenID := pttComment;
end;

constructor TCnPDFParser.Create;
begin
  inherited;
  MakeMethodTable;
end;

procedure TCnPDFParser.CRLFProc;
begin
  repeat
    StepRun;
  until not (FOrigin[FRun] in [#13, #10]);
  FTokenID := pttLineBreak;
end;

destructor TCnPDFParser.Destroy;
begin

  inherited;
end;

procedure TCnPDFParser.LessThanProc;
begin
  StepRun;
  if FOrigin[FRun] = '<' then
  begin
    StepRun;
    FTokenID := pttDictionaryBegin;
  end
  else
    FTokenID := pttHexStringBegin;
  // Error('Dictionary Begin Corrupt');
end;

procedure TCnPDFParser.GreaterThanProc;
begin
  StepRun;
  if FOrigin[FRun] = '>' then
  begin
    StepRun;
    FTokenID := pttDictionaryEnd;
  end
  else
    FTokenID := pttHexStringEnd;
  // Error('Dictionary End Corrupt');
end;

procedure TCnPDFParser.Error(const Msg: string);
begin
  raise ECnPDFException.CreateFmt('PDF Token Parse Error at %d: %s', [FRun, Msg]);
end;

function TCnPDFParser.GetToken: AnsiString;
var
  Len: Cardinal;
  OutStr: AnsiString;
begin
  Len := FRun - FTokenPos;                         // ����ƫ����֮���λΪ�ַ���
  SetString(OutStr, (FOrigin + FTokenPos), Len);   // ��ָ���ڴ��ַ�볤�ȹ����ַ���
  Result := OutStr;
end;

function TCnPDFParser.GetTokenLength: Integer;
begin
  Result := FRun - FTokenPos;
end;

procedure TCnPDFParser.KeywordProc;
begin
  FStringLen := 0;
  repeat
    StepRun;
    Inc(FStringLen);
  until not (FOrigin[FRun] in ['a'..'z', 'A'..'Z']); // �ҵ�Сд��ĸ��ϵı�ʶ��β��

  FTokenID := pttUnknown; // ����ô��
  // �Ƚ� endstream endobj stream false null true obj end

  if FStringLen = 9 then
  begin
    if TokenEqualStr(FOrigin + FRun - FStringLen, 'endstream') then
      FTokenID := pttEndStream
    else if TokenEqualStr(FOrigin + FRun - FStringLen, 'startxref') then
      FTokenID := pttStartxref
  end
  else if FStringLen = 7 then
  begin
    if TokenEqualStr(FOrigin + FRun - FStringLen, 'trailer') then
      FTokenID := pttTrailer
  end
  else if FStringLen = 6 then
  begin
    if TokenEqualStr(FOrigin + FRun - FStringLen, 'stream') then
      FTokenID := pttStream
    else if TokenEqualStr(FOrigin + FRun - FStringLen, 'endobj') then
      FTokenID := pttEndObj
  end
  else if FStringLen = 5 then
  begin
    if TokenEqualStr(FOrigin + FRun - FStringLen, 'false') then
      FTokenID := pttFalse
  end
  else if FStringLen = 4 then
  begin
    if TokenEqualStr(FOrigin + FRun - FStringLen, 'true') then
      FTokenID := pttTrue
    else if TokenEqualStr(FOrigin + FRun - FStringLen, 'null') then
      FTokenID := pttNull
    else if TokenEqualStr(FOrigin + FRun - FStringLen, 'xref') then
      FTokenID := pttXref;
  end
  else if FStringLen = 3 then
  begin
    if TokenEqualStr(FOrigin + FRun - FStringLen, 'obj') then
      FTokenID := pttObj
    else if TokenEqualStr(FOrigin + FRun - FStringLen, 'end') then
      FTokenID := pttEnd;
  end
  else if FStringLen = 1 then
  begin
    if TokenEqualStr(FOrigin + FRun - FStringLen, 'R') then
      FTokenID := pttR
    else if TokenEqualStr(FOrigin + FRun - FStringLen, 'n') then
      FTokenID := pttN
    else if TokenEqualStr(FOrigin + FRun - FStringLen, 'd') then
      FTokenID := pttD
    else if TokenEqualStr(FOrigin + FRun - FStringLen, 'f') then
      FTokenID := pttF
  end;
end;

procedure TCnPDFParser.MakeMethodTable;
var
  I: AnsiChar;
begin
  for I := #0 to #255 do
  begin
    case I of
      '%':
        FProcTable[I] := CommentProc;
      #9, #32:
        FProcTable[I] := BlankProc;
      #10, #13:
        FProcTable[I] := CRLFProc;
      '(':
        FProcTable[I] := StringBeginProc;
      ')':
        FProcTable[I] := StringEndProc;
      '0'..'9', '+', '-':
        FProcTable[I] := NumberProc;
      '[':
        FProcTable[I] := ArrayBeginProc;
      ']':
        FProcTable[I] := ArrayEndProc;
      '<':
        FProcTable[I] := LessThanProc;
      '>':
        FProcTable[I] := GreaterThanProc;
      '/':
        FProcTable[I] := NameBeginProc;
      'f', 'n', 't', 'o', 's', 'e', 'x', 'R':
        FProcTable[I] := KeywordProc;
    else
      FProcTable[I] := UnknownProc;
    end;
  end;
end;

procedure TCnPDFParser.NameBeginProc;
begin
  repeat
    StepRun;
  until FOrigin[FRun] in CRLFS + WHITESPACES + DELIMETERS + ['/'];
  FTokenID := pttName;
end;

procedure TCnPDFParser.Next;
var
  OldId: TCnPDFTokenType;
begin
  FTokenPos := FRun;
  OldId := FTokenID;

  if (FTokenID = pttStringBegin) and (FOrigin[FRun] <> ')') then
    StringProc
  else if (FTokenID = pttHexStringBegin) and (FOrigin[FRun] <> '>') then
    HexStringProc
  else if (FTokenID = pttLineBreak) and (FPrevNonBlankID = pttStream) then
    StreamDataProc
  else
    FProcTable[FOrigin[FRun]];

  if not (FTokenID in [pttBlank, pttComment]) then // ����һ���ǿջ���
    FPrevNonBlankID := OldId;
end;

procedure TCnPDFParser.NextNoJunk;
begin
  repeat
    Next;
  until not (FTokenID in [pttBlank]);
end;

procedure TCnPDFParser.NumberProc;
begin
  repeat
    StepRun;
  until not (FOrigin[FRun] in ['0'..'9', '.']); // ���Ų����ٳ����ˣ�Ҳ���ܳ��� e ���ֿ�ѧ������
  FTokenID := pttNumber;
end;

procedure TCnPDFParser.SetOrigin(const PDFBuf: PAnsiChar; PDFByteSize: Integer);
begin
  FOrigin := PDFBuf;
  FRun := 0;
  FByteLength := PDFByteSize;

  // ���³�ʼ��
  FTokenPos := 0;
  FTokenID := pttUnknown;
  FPrevNonBlankID := pttUnknown;
  FStringLen := 0;

  Next;
end;

procedure TCnPDFParser.SetRunPos(const Value: Integer);
begin
  FRun := Value;
  Next;
end;

procedure TCnPDFParser.StepRun;
begin
  Inc(FRun);
  if FRun >= FByteLength then
    raise ECnPDFEofException.Create('PDF EOF');
end;

procedure TCnPDFParser.StreamDataProc;
var
  I, OldRun: Integer;
  Es: AnsiString;
begin
  // ��ʼ�����ݣ����س����к��жϺ��Ƿ� endstream
  SetLength(Es, 9);
  repeat
    StepRun;

    if FOrigin[FRun] in [#13, #10] then
    begin
      repeat
        StepRun;
      until not (FOrigin[FRun] in [#13, #10]);

      // ��ǰ���˸����ж��Ƿ� endstream �ؼ��֣������Ƿ�ɹ���������
      OldRun := FRun; // ��¼ԭʼλ��
      for I := 1 to 9 do
      begin
        Es[I] := FOrigin[FRun];
        StepRun;
      end;
      FRun := OldRun; // ����

      if Es = 'endstream' then // ֻ������ endstream ������
        Break;
    end;
  until False;

  // ע�� endstream ǰ������ж���Ļس����У���Ҫ���� Length �ֶ�ֵ����
  FTokenID := pttStreamData;
end;

procedure TCnPDFParser.StringBeginProc;
begin
  StepRun;
  FTokenID := pttStringBegin;
end;

procedure TCnPDFParser.StringEndProc;
begin
  StepRun;
  FTokenID := pttStringEnd;
end;

procedure TCnPDFParser.StringProc;
var
  C: Integer;
begin
  // TODO: �ж�ͷ���ֽ��Ƿ��� UTF16���������ֽ����ֽڶ�ֱ���������� ) ���򵥸���ֱ������ )
  C := 0;
  repeat
    StepRun;
    if FOrigin[FRun - 1] = '\' then
      StepRun
    else if FOrigin[FRun - 1] = '(' then
      Inc(C)
    else if FOrigin[FRun - 1] = ')' then
      Dec(C);
  until (FOrigin[FRun] = ')') and (C = 0);
  FTokenID := pttString;
end;

function TCnPDFParser.TokenEqualStr(Org: PAnsiChar; const Str: AnsiString): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to Length(Str) - 1 do
  begin
    if Org[I] <> Str[I + 1] then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

procedure TCnPDFParser.UnknownProc;
begin
  StepRun;
  FTokenID := pttUnknown;
end;

procedure TCnPDFParser.HexStringProc;
begin
  repeat
    StepRun;
  until not (FOrigin[FRun] in ['0'..'9', 'a'..'f', 'A'..'F'] + CRLFS + WHITESPACES);
  FTokenID := pttHexString;
end;

procedure TCnPDFParser.NextNoJunkNoCRLF;
begin
  repeat
    Next;
  until not (FTokenID in [pttBlank, pttLineBreak, pttComment]);
end;

procedure TCnPDFParser.LoadFromBookmark(var Bookmark: TCnPDFParserBookmark);
begin
  FRun := Bookmark.Run;
  FTokenPos := Bookmark.TokenPos;
  FTokenID := Bookmark.TokenID;
  FPrevNonBlankID := Bookmark.PrevNonBlankID;
  FStringLen := Bookmark.StringLen;
end;

procedure TCnPDFParser.SaveToBookmark(var Bookmark: TCnPDFParserBookmark);
begin
  Bookmark.Run := FRun;
  Bookmark.TokenPos := FTokenPos;
  Bookmark.TokenID := FTokenID;
  Bookmark.PrevNonBlankID := FPrevNonBlankID;
  Bookmark.StringLen := FStringLen;
end;

{ TCnPDFHeader }

constructor TCnPDFHeader.Create;
begin
  inherited;
  FVersion := '1.7';
  FComment := '�й�CnPack������';
end;

destructor TCnPDFHeader.Destroy;
begin

  inherited;
end;

procedure TCnPDFHeader.DumpToStrings(Strings: TStrings; Verbose: Boolean;
  Indent: Integer);
begin
  Strings.Add('PDF Version ' + FVersion);
  Strings.Add('PDF First Comment ' + FComment);
end;

function TCnPDFHeader.WriteToStream(Stream: TStream): Cardinal;
begin
  Result := WriteLine(Stream, '%PDF-' + FVersion);
  Inc(Result, WriteLine(Stream, '%' + FComment));
end;

{ TCnPDFObject }

function TCnPDFObject.CheckWriteObjectEnd(Stream: TStream): Cardinal;
begin
  if ID > 0 then
    Result := WriteLine(Stream, ENDOBJ)
  else
    Result := 0;
end;

function TCnPDFObject.CheckWriteObjectStart(Stream: TStream): Cardinal;
begin
  if ID > 0 then
    Result := WriteLine(Stream, Format(OBJFMT, [ID, Generation]))
  else
    Result := 0;
end;

function TCnPDFObject.Clone: TCnPDFObject;
var
  Clz: TCnPDFObjectClass;
begin
  if Self = nil then
  begin
    Result := nil;
    Exit;
  end;

  Clz := TCnPDFObjectClass(ClassType);
  try
    Result := TCnPDFObject(Clz.NewInstance);
    Result.Create;

    Result.Assign(Self);
  except
    Result := nil;
  end;
end;

constructor TCnPDFObject.Create;
begin
  inherited;

end;

destructor TCnPDFObject.Destroy;
begin

  inherited;
end;

function TCnPDFObject.ToString: string;
begin
  raise ECnPDFException.Create('NO ToString for Base PDF Object');
end;

procedure TCnPDFObject.ToStrings(Strings: TStrings; Indent: Integer);
begin
  if Strings <> nil then
  begin
    if Indent = 0 then
      Strings.Add(ToString)
    else
      Strings.Add(StringOfChar(' ', Indent) + ToString);
  end;
end;

{ TCnPDFDocument }

constructor TCnPDFDocument.Create;
begin
  inherited;
  FHeader := TCnPDFHeader.Create;
  FBody := TCnPDFBody.Create;
  FXRefTable := TCnPDFXRefTable.Create;
  FTrailer := TCnPDFTrailer.Create;

  FBody.XRefTable := FXRefTable;
//  FTrailer.Dictionary.AddObjectRef('Root', FBody.Catalog);
//  FTrailer.Dictionary.AddObjectRef('Info', FBody.Info);
end;

destructor TCnPDFDocument.Destroy;
begin
  FTrailer.Free;
  FXRefTable.Free;
  FBody.Free;
  FHeader.Free;
  inherited;
end;

procedure TCnPDFDocument.LoadFromFile(const FileName: string);
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(F);
  finally
    F.Free;
  end;
end;

procedure TCnPDFDocument.LoadFromStream(Stream: TStream);
var
  P: TCnPDFParser;
  M: TMemoryStream;
  S: AnsiString;
  X: PAnsiChar;
  Obj: TCnPDFObject;
begin
  P := nil;
  M := nil;

  try
    P := TCnPDFParser.Create;
    M := TMemoryStream.Create;
    M.LoadFromStream(Stream);
    P.SetOrigin(M.Memory, M.Size);

    try
      if P.TokenID <> pttComment then
        ParseError(P, 'NO PDF File Header!');

      // ������һ�� Comment
      S := P.Token;
      if (Length(S) < 6) or (Pos(PDFHEADER, S) <> 1) then
        ParseError(P, 'PDF File Header Corrupt');

      Delete(S, 1, Length(PDFHEADER));
      FHeader.Version := S;

      // ����������ڶ��� Comment
      P.NextNoJunk;
      if P.TokenID = pttLineBreak then
        P.NextNoJunk;
      if P.TokenID = pttComment then
      begin
        FHeader.Comment := P.Token;
        P.NextNoJunkNoCRLF;
      end;

      // ���洦�������б���
      while True do
      begin
        case P.TokenID of
          pttXref:
            begin
              // ���������ñ�
              ReadXRef(P);
            end;
          pttTrailer:
            begin
              // ��β��
              ReadTrailer(P);
            end;
          pttNumber:
            begin
              // ���֡����֡�obj ����
              ReadObject(P);
            end;
          pttStartXRef:
            begin
              // ĳЩ�������ֵ����� startxref��������˵
              ReadTrailerStartXRef(P);
            end;
        else
          P.NextNoJunk;
        end;
      end;
    except
      on E: ECnPDFEofException do // PDF ������ϵ��쳣�̵�������������
      begin
        ;
      end;
    end;

    // ���û���� xref �ؼ���ָʾ�Ľ���Ӧ�ñ������ startxref ���ٶ������͵�
    if FXRefTable.SegmentCount = 0 then
    begin
      if FTrailer.XRefStart > 0 then
      begin
        X := M.Memory;
        Inc(X, FTrailer.XRefStart);

        P.SetOrigin(X, M.Size - Integer(FTrailer.XRefStart));
        if P.TokenID = pttNumber then
        begin
          Obj := ReadObject(P);
          if (Obj <> nil) and (Obj is TCnPDFDictionaryObject) and
            ((Obj as TCnPDFDictionaryObject).GetType = 'XRef') then
          begin
            XRefDictToXRefTable(Obj as TCnPDFDictionaryObject);

            // TODO: ����� Prev��Ҫһ·����ȥ�ϲ�֮
          end;
        end;
      end;
    end;
  finally
    M.Free;
    P.Free;
  end;

  // �⿪ѹ�� Content ������
  UncompressObjects;

  // �� Trailer ����ֶ���������
  ArrangeObjects;
end;

procedure TCnPDFDocument.ReadArray(P: TCnPDFParser;
  AnArray: TCnPDFArrayObject);
var
  Obj: TCnPDFObject;
begin
  P.NextNoJunkNoCRLF;
  if P.TokenID = pttArrayEnd then
  begin
    AnArray.Clear;
    P.NextNoJunkNoCRLF;
    Exit;
  end;

  while P.TokenID <> pttArrayEnd do
  begin
    Obj := ReadObjectInner(P);
    AnArray.AddObject(Obj);
  end;
  P.NextNoJunkNoCRLF;
end;

procedure TCnPDFDocument.ReadDictionary(P: TCnPDFParser;
  Dict: TCnPDFDictionaryObject);
var
  N: TCnPDFNameObject;
  V: TCnPDFObject;
  Pair: TCnPDFDictPair;
begin
  P.NextNoJunkNoCRLF;
  if P.TokenID = pttDictionaryEnd then
  begin
    Dict.Clear;
    P.NextNoJunkNoCRLF;
    Exit;
  end;

  N := TCnPDFNameObject.Create;
  try
    while P.TokenID <> pttDictionaryEnd do
    begin
      CheckExpectedToken(P, pttName);
      ReadName(P, N);
      Pair := Dict.AddName(N.Name);

      V := ReadObjectInner(P);
      Pair.Value := V;
    end;

    P.NextNoJunkNoCRLF;
    // ����������� stream
  finally
    N.Free;
  end;
end;

procedure TCnPDFDocument.ReadName(P: TCnPDFParser; Name: TCnPDFNameObject);
begin
  Name.Content := AnsiToBytes(TrimToName(P.Token));
  P.NextNoJunkNoCRLF;
end;

procedure TCnPDFDocument.ReadNumber(P: TCnPDFParser; Num: TCnPDFNumberObject;
  OverCRLF: Boolean);
var
  S: AnsiString;
  R, E: Integer;
  F: Extended;
begin
  S := P.Token;

  if OverCRLF then
    P.NextNoJunkNoCRLF
  else
    P.NextNoJunk;

  Val(S, R, E);
  if E = 0 then
    Num.SetInteger(R)
  else
  begin
    Val(S, F, E);
    if E = 0 then
      Num.SetFloat(F)
    else
      ParseError(P, 'PDF Number Format Error');
  end;
end;

function TCnPDFDocument.ReadObject(P: TCnPDFParser): TCnPDFObject;
var
  Num: TCnPDFNumberObject;
  ID, G: Cardinal;
  Ofst: Integer;
begin
  // �� ���� ���� obj
  Num := TCnPDFNumberObject.Create;
  try
    CheckExpectedToken(P, pttNumber);
    Ofst := P.RunPos - P.TokenLength;
    ReadNumber(P, Num); // �ڲ��Ჽ��
    ID := Num.AsInteger;

    CheckExpectedToken(P, pttNumber);
    ReadNumber(P, Num);
    G := Num.AsInteger;

    CheckExpectedToken(P, pttObj);
    P.NextNoJunkNoCRLF;

    Result := ReadObjectInner(P);
    Result.ID := ID;
    Result.Generation := G;
    Result.Offset := Ofst;

    CheckExpectedToken(P, pttEndObj);
    P.NextNoJunkNoCRLF;

    FBody.Objects.AddRaw(Result);
  finally
    Num.Free;
  end;
end;

function TCnPDFDocument.ReadObjectInner(P: TCnPDFParser): TCnPDFObject;
var
  Stream: TCnPDFStreamObject;
  Bookmark: TCnPDFParserBookmark;
  IsR: Boolean;
begin
  Result := nil;
  case P.TokenID of
    pttDictionaryBegin:
      begin
        // ��һ���� Dict�������� Stream
        Result := TCnPDFDictionaryObject.Create;
        ReadDictionary(P, Result as TCnPDFDictionaryObject);

        // ��������� Stream����� Result �ĳ� TCnPDFStreamObject
        if P.TokenID = pttStream then
        begin
          P.NextNoJunkNoCRLF;
          CheckExpectedToken(P, pttStreamData);

          Stream := TCnPDFStreamObject.Create;
          Stream.Assign(Result);
          ReadStream(P, Stream);

          Result.Free;
          Result := Stream;                         // ������� endstream
        end;
      end;
    pttArrayBegin:
      begin
        Result := TCnPDFArrayObject.Create;
        ReadArray(P, Result as TCnPDFArrayObject); // ������� ]
      end;
    pttStringBegin:
      begin
        Result := TCnPDFStringObject.Create;
        ReadString(P, Result as TCnPDFStringObject); // ������� )
      end;
    pttHexStringBegin:
      begin
        Result := TCnPDFStringObject.Create;
        ReadHexString(P, Result as TCnPDFStringObject); // ������� >
      end;
    pttNumber:
      begin
        // Ҫ���� ���֡����� R ��������
        IsR := False;
        P.SaveToBookmark(Bookmark);

        if P.TokenID = pttNumber then
        begin
          P.NextNoJunk;
          if P.TokenID = pttNumber then
          begin
            P.NextNoJunk;
            if P.TokenID = pttR then
              IsR := True;
          end;
        end;
        P.LoadFromBookmark(Bookmark);

        if IsR then
        begin
          Result := TCnPDFReferenceObject.Create(nil);
          ReadReference(P, Result as TCnPDFReferenceObject);
        end
        else
        begin
          Result := TCnPDFNumberObject.Create;
          ReadNumber(P, Result as TCnPDFNumberObject);
        end;
      end;
    pttName:
      begin
        Result := TCnPDFNameObject.Create; // ȥ��б��
        ReadName(P, Result as TCnPDFNameObject);
      end;
    pttNull:
      begin
        Result := TCnPDFNullObject.Create;
        P.NextNoJunkNoCRLF;
      end;
    pttTrue:
      begin
        Result := TCnPDFBooleanObject.Create(True);
        P.NextNoJunkNoCRLF;
      end;
    pttFalse:
      begin
        Result := TCnPDFBooleanObject.Create(False);
        P.NextNoJunkNoCRLF;
      end;
  end;
end;

procedure TCnPDFDocument.ReadStream(P: TCnPDFParser; Stream: TCnPDFStreamObject);
var
  V: TCnPDFObject;
  L: Integer;
begin
  if P.TokenID = pttStreamData then
  begin
    SetLength(Stream.FStream, P.TokenLength);
    if P.TokenLength > 0 then
      Move(P.Token[1], Stream.Stream[0], P.TokenLength);
  end;
  P.NextNoJunk;

  V := Stream.Values['Length'];
  if (V <> nil) and (V is TCnPDFNumberObject) then
  begin
    L := (V as TCnPDFNumberObject).AsInteger;
    if L < Length(Stream.Stream) then
      SetLength(Stream.FStream, L);
  end;

  CheckExpectedToken(P, pttEndStream);
  P.NextNoJunkNoCRLF;
end;

procedure TCnPDFDocument.ReadHexString(P: TCnPDFParser; Str: TCnPDFStringObject);
begin
  P.NextNoJunk;
  if P.TokenID = pttHexStringEnd then
  begin
    SetLength(Str.FContent, 0);
    P.NextNoJunkNoCRLF;
    Exit;
  end;

  CheckExpectedToken(P, pttHexString);
  Str.Content := HexToBytes(P.Token);
  Str.IsHex := True;
  P.NextNoJunk;

  CheckExpectedToken(P, pttHexStringEnd);
  P.NextNoJunkNoCRLF;
end;

procedure TCnPDFDocument.ReadString(P: TCnPDFParser;
  Str: TCnPDFStringObject);
begin
  P.NextNoJunk;
  if P.TokenID = pttStringEnd then
  begin
    SetLength(Str.FContent, 0);
    P.NextNoJunkNoCRLF;
    Exit;
  end;

  CheckExpectedToken(P, pttString);

  Str.Content := AnsiToBytes(P.Token);
  P.NextNoJunk;

  CheckExpectedToken(P, pttStringEnd);
  P.NextNoJunkNoCRLF;
end;

procedure TCnPDFDocument.ReadTrailerStartXRef(P: TCnPDFParser);
var
  Num: TCnPDFNumberObject;
begin
  P.NextNoJunkNoCRLF;
  CheckExpectedToken(P, pttNumber);
  Num := TCnPDFNumberObject.Create;
  try
    ReadNumber(P, Num, False);
    FTrailer.XRefStart := Num.AsInteger;
  finally
    Num.Free;
  end;

  if P.TokenID = pttLineBreak then
    P.NextNoJunk;
  CheckExpectedToken(P, pttComment); // %%EOF
  FTrailer.Comment := P.Token;
end;

procedure TCnPDFDocument.ReadTrailer(P: TCnPDFParser);
begin
  // ���ֵ䡢�� startxref ������
  CheckExpectedToken(P, pttTrailer);
  P.NextNoJunkNoCRLF;
  CheckExpectedToken(P, pttDictionaryBegin);
  ReadDictionary(P, FTrailer.Dictionary);

  CheckExpectedToken(P, pttStartXRef);
  ReadTrailerStartXRef(P);
end;

procedure TCnPDFDocument.ReadXRef(P: TCnPDFParser);
var
  Num: TCnPDFNumberObject;
  Seg: TCnPDFXRefCollection;
  Item: TCnPDFXRefItem;
  C1, C2: Cardinal;
begin
  P.NextNoJunkNoCRLF;
  Num := TCnPDFNumberObject.Create;
  try
    Seg := nil;
    while P.TokenID = pttNumber do
    begin
      // ��Ҫ�� Number
      CheckExpectedToken(P, pttNumber);
      ReadNumber(P, Num, False);
      C1 := Num.AsInteger;

      CheckExpectedToken(P, pttNumber);
      ReadNumber(P, Num, False); // ע�ⲻҪԽ���س�����
      C2 := Num.AsInteger;

      if P.TokenID in [pttN,pttF, pttD] then
      begin
        // ������� Number �� f n d �ٻس������Ƕ�������Ŀ
        if Seg <> nil then
        begin
          Item := Seg.Add;
          Item.ObjectOffset := C1;
          Item.ObjectGeneration := C2;
          Item.ObjectXRefType := XRefTokenToType(P.TokenID);
        end;
        P.NextNoJunkNoCRLF; // Ҫ��������
      end
      else if P.TokenID = pttLineBreak then
      begin
        // ������� Number ��س��������¶�
        Seg := FXRefTable.AddSegment;
        Seg.ObjectIndex := C1;
        // �Ȳ���¼��ǰ�εĸ����ͺ��ıȶ�

        P.NextNoJunk;       // �Ѿ�����������
      end;
    end;
  finally
    Num.Free;
  end;
end;

procedure TCnPDFDocument.SaveToFile(const FileName: string);
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(F);
  finally
    F.Free;
  end;
end;

procedure TCnPDFDocument.SaveToStream(Stream: TStream);
begin
  SyncTrailer;
  FBody.SyncPages;

  FHeader.WriteToStream(Stream);
  FBody.WriteToStream(Stream);

  FTrailer.XRefStart := Stream.Position;
  FXRefTable.WriteToStream(Stream);

  FTrailer.Dictionary.Values['Size'] := TCnPDFNumberObject.Create(FBody.Objects.MaxID + 1);
  FTrailer.WriteToStream(Stream);
end;

procedure TCnPDFDocument.ReadReference(P: TCnPDFParser;
  Ref: TCnPDFReferenceObject);
var
  Num: TCnPDFNumberObject;
  C1, C2: Cardinal;
begin
  CheckExpectedToken(P, pttNumber);

  Num := TCnPDFNumberObject.Create;
  try
    ReadNumber(P, Num);
    C1 := Num.AsInteger;

    CheckExpectedToken(P, pttNumber);
    ReadNumber(P, Num);
    C2 := Num.AsInteger;

    CheckExpectedToken(P, pttR);
    P.NextNoJunkNoCRLF;

    Ref.ID := C1;
    Ref.Generation := C2;
  finally
    Num.Free;
  end;
end;

procedure TCnPDFDocument.ArrangeObjects;
var
  I: Integer;
  Obj: TCnPDFObject;
  Arr: TCnPDFArrayObject;
  Page: TCnPDFDictionaryObject;
begin
  FBody.Objects.CalcMaxID;
  if FTrailer = nil then
    Exit;

  // �� Info ����
  Obj := FTrailer.Dictionary.Values['Info'];
  if (Obj <> nil) and (Obj is TCnPDFReferenceObject) then
  begin
    Obj := FromReference(Obj as TCnPDFReferenceObject);
    if (Obj <> nil) and (Obj is TCnPDFDictionaryObject) then
      FBody.Info := Obj as TCnPDFDictionaryObject;
  end;

  // �� Catalog ����
  Obj := FTrailer.Dictionary.Values['Root'];
  if (Obj <> nil) and (Obj is TCnPDFReferenceObject) then
  begin
    Obj := FromReference(Obj as TCnPDFReferenceObject);
    if (Obj <> nil) and (Obj is TCnPDFDictionaryObject) then
    begin
      FBody.Catalog := Obj as TCnPDFDictionaryObject;
      if FBody.Catalog.GetType <> 'Catalog' then
        raise ECnPDFException.Create('Catalog Type Error');
    end;
  end;

  // �� Pages ����
  if FBody.Catalog <> nil then
  begin
    Obj := FBody.Catalog.Values['Pages'];
    if (Obj <> nil) and (Obj is TCnPDFReferenceObject) then
    begin
      Obj := FromReference(Obj as TCnPDFReferenceObject);
      if (Obj <> nil) and (Obj is TCnPDFDictionaryObject) then
      begin
        FBody.Pages := Obj as TCnPDFDictionaryObject;
        if FBody.Pages.GetType <> 'Pages' then
          raise ECnPDFException.Create('Pages Type Error');
      end;
    end;
  end;

  // �Ҹ��� Page
  if FBody.Pages <> nil then
  begin
    // �� Page ����
    Obj := FBody.Pages.Values['Kids'];
    if (Obj <> nil) and (Obj is TCnPDFArrayObject) then
    begin
      Arr := Obj as TCnPDFArrayObject;
      if Arr.Count > 0 then
      begin
        for I := 0 to Arr.Count - 1 do
        begin
          Obj := Arr.Items[I];
          if (Obj <> nil) and (Obj is TCnPDFReferenceObject) then
          begin
            Obj := FromReference(Obj as TCnPDFReferenceObject);
            if (Obj <> nil) and (Obj is TCnPDFDictionaryObject) then
              FBody.AddRawPage(Obj as TCnPDFDictionaryObject);
          end;
        end;
      end;
    end
    else if Obj <> nil then
      raise ECnPDFException.CreateFmt('Error Object Type %s for Kids', [Obj.ClassName]);
  end;

  // ��ÿ�� Page �� Content �� Resource ��
  for I := 0 to FBody.PageCount - 1 do
  begin
    Page := FBody.Page[I];

    // �� Contents
    Obj := Page.Values['Contents'];
    if (Obj <> nil) and (Obj is TCnPDFReferenceObject) then
    begin
      Obj := FromReference(Obj as TCnPDFReferenceObject);
      if (Obj <> nil) and (Obj is TCnPDFStreamObject) then
        FBody.AddRawContent(Obj as TCnPDFStreamObject);
    end
    else if Obj <> nil then
      raise ECnPDFException.CreateFmt('Error Object Type %s for Contents', [Obj.ClassName]);

    // �� Resources�����Բ������ö������ֱ���ֵ�
    Obj := Page.Values['Resources'];
    if (Obj <> nil) and (Obj is TCnPDFDictionaryObject) then
      FBody.AddRawResource(Obj as TCnPDFDictionaryObject)
    else if (Obj <> nil) and (Obj is TCnPDFReferenceObject) then
    begin
      Obj := FromReference(Obj as TCnPDFReferenceObject);
      if (Obj <> nil) and (Obj is TCnPDFDictionaryObject) then
        FBody.AddRawResource(Obj as TCnPDFDictionaryObject);
    end
    else if Obj <> nil then
      raise ECnPDFException.CreateFmt('Error Object Type %s for Resources', [Obj.ClassName]);
  end;
end;

function TCnPDFDocument.FromReference(Ref: TCnPDFReferenceObject): TCnPDFObject;
begin
  Result := nil;
  if Ref <> nil then
    Result := FBody.Objects.GetObjectByIDGeneration(Ref.ID, Ref.Generation);
end;

procedure TCnPDFDocument.XRefDictToXRefTable(Dict: TCnPDFDictionaryObject);
begin
  if Dict = nil then
    Exit;

  if FTrailer.Dictionary.Count = 0 then // �Ȱ� Info ����������ȥ
    FTrailer.Dictionary.Assign(Dict);
end;

procedure TCnPDFDocument.SyncTrailer;
begin
  if FTrailer.Dictionary.Values['Info'] <> nil then
    FTrailer.Dictionary.Values['Info'] := TCnPDFReferenceObject.Create(FBody.Info);
  if FTrailer.Dictionary.Values['Root'] <> nil then
    FTrailer.Dictionary.Values['Root'] := TCnPDFReferenceObject.Create(FBody.Catalog);
end;

procedure TCnPDFDocument.UncompressObjects;
var
  I: Integer;
begin
  for I := 0 to FBody.Objects.Count - 1 do
  begin
    if FBody.Objects[I] is TCnPDFStreamObject then
      (FBody.Objects[I] as TCnPDFStreamObject).Uncompress;
  end;
end;

procedure TCnPDFDocument.DumpToStrings(Strings: TStrings);
var
  I: Integer;
begin
  // ����ļ��ڵ�ԭʼ����
  FHeader.DumpToStrings(Strings);
  FBody.DumpToStrings(Strings, True);
  FXRefTable.DumpToStrings(Strings);
  FTrailer.DumpToStrings(Strings);

  Strings.Add('');
  Strings.Add('==============================');
  Strings.Add('');

  // ��� Info��Catalog��Pages �ȷ�����Ķ��������

  Strings.Add('--- Info ---') ;
  if FBody.Info <> nil then
    FBody.Info.ToStrings(Strings);

  Strings.Add('--- Catalog ---') ;
  if FBody.Catalog <> nil then
    FBody.Catalog.ToStrings(Strings);

  Strings.Add('--- Pages ---') ;
  if FBody.Pages <> nil then
    FBody.Pages.ToStrings(Strings);

  Strings.Add('--- Page List ---') ;
  for I := 0 to FBody.PageCount - 1 do
    FBody.Page[I].ToStrings(Strings);

  Strings.Add('--- Content List ---') ;
  for I := 0 to FBody.ContentCount - 1 do
    FBody.Content[I].ToStrings(Strings);

  Strings.Add('--- Resource List ---') ;
  for I := 0 to FBody.ResourceCount - 1 do
    FBody.Resource[I].ToStrings(Strings);
end;

{ TCnPDFDictPair }

procedure TCnPDFDictPair.Assign(Source: TPersistent);
begin
  if Source is TCnPDFDictPair then
  begin
    FName.Assign((Source as TCnPDFDictPair).Name); // Name �������ǹ̶�����

    FreeAndNil(FValue);
    FValue := (Source as TCnPDFDictPair).Value.Clone;
  end
  else
    inherited;
end;

procedure TCnPDFDictPair.ChangeToArray;
var
  Arr: TCnPDFArrayObject;
begin
  if not (FValue is TCnPDFArrayObject) then
  begin
    Arr := TCnPDFArrayObject.Create;
    if FValue <> nil then
      Arr.AddObject(FValue);
    FValue := Arr;
  end;
end;

constructor TCnPDFDictPair.Create(const Name: string);
begin
  inherited Create;
  FName := TCnPDFNameObject.Create(Name);
end;

destructor TCnPDFDictPair.Destroy;
begin
  FName.Free;
  FValue.Free; // ������û���ã���Ϊ nil����Ӱ��
  inherited;
end;

function TCnPDFDictPair.WriteToStream(Stream: TStream): Cardinal;
begin
  Result := WriteString(Stream, CRLF);
  Inc(Result, FName.WriteToStream(Stream));
  Inc(Result, WriteSpace(Stream));
  if FValue <> nil then
    Inc(Result, FValue.WriteToStream(Stream));
end;

{ TCnPDFNameObject }

function TCnPDFNameObject.GetName: AnsiString;
begin
  Result := BytesToAnsi(FContent);
end;

function TCnPDFNameObject.WriteToStream(Stream: TStream): Cardinal;
begin
  Result := WriteString(Stream, '/' + BytesToAnsi(Content));
end;

{ TCnPDFDictionaryObject }

function TCnPDFDictionaryObject.AddAnsiString(const Name: string;
  const Value: AnsiString): TCnPDFDictPair;
begin
  Result := AddName(Name);
  Result.Value := TCnPDFStringObject.Create(Value);
end;

function TCnPDFDictionaryObject.AddArray(const Name: string): TCnPDFArrayObject;
var
  Pair: TCnPDFDictPair;
begin
  Pair := AddName(Name);
  Result := TCnPDFArrayObject.Create;
  Pair.Value := Result;
end;

function TCnPDFDictionaryObject.AddDictionary(const Name: string): TCnPDFDictionaryObject;
var
  Pair: TCnPDFDictPair;
begin
  Pair := AddName(Name);
  Result := TCnPDFDictionaryObject.Create;
  Pair.Value := Result;
end;

function TCnPDFDictionaryObject.AddFalse(const Name: string): TCnPDFDictPair;
begin
  Result := AddName(Name);
  Result.Value := TCnPDFBooleanObject.Create(False);
end;

function TCnPDFDictionaryObject.AddName(const Name: string): TCnPDFDictPair;
begin
  Result := TCnPDFDictPair.Create(Name);
  AddPair(Result);
end;

function TCnPDFDictionaryObject.AddName(const Name1,
  Name2: string): TCnPDFDictPair;
begin
  Result := TCnPDFDictPair.Create(Name1);
  Result.Value := TCnPDFNameObject.Create(Name2);
  AddPair(Result);
end;

function TCnPDFDictionaryObject.AddNull(const Name: string): TCnPDFDictPair;
begin
  Result := AddName(Name);
  Result.Value := TCnPDFNullObject.Create;
end;

function TCnPDFDictionaryObject.AddNumber(const Name: string;
  Value: Int64): TCnPDFDictPair;
begin
  Result := AddName(Name);
  Result.Value := TCnPDFNumberObject.Create(Value);
end;

function TCnPDFDictionaryObject.AddNumber(const Name: string;
  Value: Integer): TCnPDFDictPair;
begin
  Result := AddName(Name);
  Result.Value := TCnPDFNumberObject.Create(Value);
end;

function TCnPDFDictionaryObject.AddNumber(const Name: string;
  Value: Extended): TCnPDFDictPair;
begin
  Result := AddName(Name);
  Result.Value := TCnPDFNumberObject.Create(Value);
end;

function TCnPDFDictionaryObject.AddObjectRef(const Name: string;
  Obj: TCnPDFObject): TCnPDFDictPair;
begin
  Result := AddName(Name);
  Result.Value := TCnPDFReferenceObject.Create(Obj);
end;

procedure TCnPDFDictionaryObject.AddPair(APair: TCnPDFDictPair);
begin
  FPairs.Add(APair);
end;

function TCnPDFDictionaryObject.AddString(const Name,
  Value: string): TCnPDFDictPair;
begin
{$IFDEF UNICODE}
  Result := AddUnicodeString(Name, Value);
{$ELSE}
  Result := AddAnsiString(Name, Value);
{$ENDIF}
end;

function TCnPDFDictionaryObject.AddTrue(const Name: string): TCnPDFDictPair;
begin
  Result := AddName(Name);
  Result.Value := TCnPDFBooleanObject.Create(True);
end;

{$IFDEF UNICODE}

function TCnPDFDictionaryObject.AddUnicodeString(const Name,
  Value: string): TCnPDFDictPair;
begin
  Result := AddName(Name);
  Result.Value := TCnPDFStringObject.Create(Value);
end;

{$ENDIF}

function TCnPDFDictionaryObject.AddWideString(const Name: string;
  const Value: WideString): TCnPDFDictPair;
begin
  Result := AddName(Name);
{$IFDEF COMPILER5}
  Result.Value := TCnPDFStringObject.CreateW(Value);
{$ELSE}
  Result.Value := TCnPDFStringObject.Create(Value);
{$ENDIF}
end;

procedure TCnPDFDictionaryObject.Assign(Source: TPersistent);
var
  I: Integer;
  Dict: TCnPDFDictionaryObject;
  Pair: TCnPDFDictPair;
begin
  if Source is TCnPDFDictionaryObject then
  begin
    Clear;

    Dict := Source as TCnPDFDictionaryObject;
    for I := 0 to Dict.Count - 1 do
    begin
      Pair := TCnPDFDictPair.Create('');
      Pair.Assign(Dict.Pairs[I]);
      AddPair(Pair);
    end;
  end
  else
    inherited;
end;

procedure TCnPDFDictionaryObject.Clear;
begin
  FPairs.Clear;
end;

constructor TCnPDFDictionaryObject.Create;
begin
  inherited;
  FPairs := TObjectList.Create(True);
end;

procedure TCnPDFDictionaryObject.DeleteName(const Name: string);
var
  I: Integer;
  Pair: TCnPDFDictPair;
begin
  for I := FPairs.Count - 1 downto 0 do
  begin
    Pair := TCnPDFDictPair(FPairs[I]);
    if (Pair <> nil) and (Pair.Name.Name = Name) then
      FPairs.Delete(I);
  end;
end;

destructor TCnPDFDictionaryObject.Destroy;
begin
  FPairs.Free;
  inherited;
end;

function TCnPDFDictionaryObject.GetCount: Integer;
begin
  Result := FPairs.Count;
end;

procedure TCnPDFDictionaryObject.GetNames(Names: TStrings);
var
  I: Integer;
begin
  Names.Clear;
  for I := 0 to FPairs.Count - 1 do
    Names.Add(Pairs[I].Name.Name);
end;

function TCnPDFDictionaryObject.GetPair(Index: Integer): TCnPDFDictPair;
begin
  Result := TCnPDFDictPair(FPairs[Index]);
end;

function TCnPDFDictionaryObject.GetType: string;
var
  V: TCnPDFObject;
begin
  V := Values['Type'];
  if (V <> nil) and (V is TCnPDFNameObject) then
    Result := (V as TCnPDFNameObject).Name
  else
    Result := '';
end;

function TCnPDFDictionaryObject.GetValue(const Name: string): TCnPDFObject;
var
  Idx: Integer;
begin
  Idx := IndexOfName(Name);
  if Idx >= 0 then
    Result := TCnPDFDictPair(FPairs[Idx]).Value
  else
    Result := nil;
end;

function TCnPDFDictionaryObject.HasName(const Name: string): Boolean;
begin
  Result := IndexOfName(Name) >= 0;
end;

function TCnPDFDictionaryObject.IndexOfName(const Name: string): Integer;
var
  I: Integer;
  Pair: TCnPDFDictPair;
  S: string;
begin
  for I := 0 to FPairs.Count - 1 do
  begin
    Pair := TCnPDFDictPair(FPairs[I]);
    S := string(BytesToAnsi(Pair.Name.Content));

    if S = Name then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

procedure TCnPDFDictionaryObject.SetValue(const Name: string;
  const Value: TCnPDFObject);
var
  Idx: Integer;
  Pair: TCnPDFDictPair;
begin
  Idx := IndexOfName(Name);
  if Idx >= 0 then
  begin
    if TCnPDFDictPair(FPairs[Idx]).Value <> nil then
      TCnPDFDictPair(FPairs[Idx]).Value.Free;
    TCnPDFDictPair(FPairs[Idx]).Value := Value;
  end
  else
  begin
    Pair := AddName(Name);
    Pair.Value := Value;
  end;
end;

function TCnPDFDictionaryObject.ToString: string;
begin
  Result := Format('<<...Count %d...>>', [Count]);
end;

procedure TCnPDFDictionaryObject.ToStrings(Strings: TStrings;
  Indent: Integer);
var
  I: Integer;
  S1, S2: string;
  Pair: TCnPDFDictPair;
begin
  S1 := StringOfChar(' ', Indent);
  Strings.Add(S1 + '<<');
  if Count > 0 then
  begin
    S2 := StringOfChar(' ', Indent + INDENTDELTA);
    for I := 0 to Count - 1 do
    begin
      Pair := Pairs[I];
      if Pair.Value is TCnPDFDictionaryObject then
      begin
        Strings.Add(S2 + Pair.Name.Name + ': <<...Count ' + IntToStr((Pair.Value as TCnPDFDictionaryObject).Count) + '...>>');
        (Pair.Value as TCnPDFDictionaryObject).ToStrings(Strings, Indent + INDENTDELTA);
      end
      else if Pair.Value is TCnPDFArrayObject then
      begin
        Strings.Add(S2 + Pair.Name.Name + ': [...Count ' + IntToStr((Pair.Value as TCnPDFArrayObject).Count) + '...]');
        (Pair.Value as TCnPDFArrayObject).ToStrings(Strings, Indent + INDENTDELTA);
      end
      else if Pair.Value <> nil then
        Strings.Add(S2 + Pair.Name.Name + ': ' + Pair.Value.ToString)
      else
        Strings.Add(S2 + Pair.Name.Name);
    end;
  end;
  Strings.Add(S1 + '>>');
end;

function TCnPDFDictionaryObject.WriteDictionary(Stream: TStream): Cardinal;
var
  I: Integer;
begin
  Result := 0;
  Inc(Result, CheckWriteObjectStart(Stream));
  if FPairs.Count <= 0 then
  begin
    Inc(Result, WriteString(Stream, '<<>>'));
    Inc(Result, WriteCRLF(Stream));
    Exit;
  end;

  Inc(Result, WriteString(Stream, '<<'));
  for I := 0 to FPairs.Count - 1 do
  begin
    Inc(Result, (FPairs[I] as TCnPDFDictPair).WriteToStream(Stream));
    // Inc(Result, WriteCRLF(Stream));
  end;
  Inc(Result, WriteCRLF(Stream));
  Inc(Result, WriteLine(Stream, '>>'));
end;

function TCnPDFDictionaryObject.WriteToStream(Stream: TStream): Cardinal;
begin
  Result := WriteDictionary(Stream);
  Inc(Result, CheckWriteObjectEnd(Stream));
end;

{ TCnPDFArrayObject }

procedure TCnPDFArrayObject.AddAnsiString(const Value: AnsiString);
begin
  AddObject(TCnPDFStringObject.Create(Value));
end;

procedure TCnPDFArrayObject.AddFalse;
begin
  AddObject(TCnPDFBooleanObject.Create(False));
end;

procedure TCnPDFArrayObject.AddNul;
begin
  AddObject(TCnPDFNullObject.Create);
end;

procedure TCnPDFArrayObject.AddNumber(Value: Extended);
begin
  AddObject(TCnPDFNumberObject.Create(Value));
end;

procedure TCnPDFArrayObject.AddNumber(Value: Integer);
begin
  AddObject(TCnPDFNumberObject.Create(Value));
end;

procedure TCnPDFArrayObject.AddNumber(Value: Int64);
begin
  AddObject(TCnPDFNumberObject.Create(Value));
end;

procedure TCnPDFArrayObject.AddObject(Obj: TCnPDFObject);
begin
  FElements.Add(Obj);
end;

procedure TCnPDFArrayObject.AddObjectRef(Obj: TCnPDFObject);
begin
  AddObject(TCnPDFReferenceObject.Create(Obj));
end;

procedure TCnPDFArrayObject.AddTrue;
begin
  AddObject(TCnPDFBooleanObject.Create(True));
end;

{$IFDEF UNICODE}

procedure TCnPDFArrayObject.AddUnicodeString(const Value: string);
begin
  AddObject(TCnPDFStringObject.Create(Value));
end;

{$ENDIF}

procedure TCnPDFArrayObject.AddWideString(const Value: WideString);
begin
  AddObject(TCnPDFStringObject.Create(Value));
end;

procedure TCnPDFArrayObject.Assign(Source: TPersistent);
var
  I: Integer;
  Obj: TCnPDFObject;
  Arr: TCnPDFArrayObject;
begin
  if Source is TCnPDFArrayObject then
  begin
    Clear;

    Arr := Source as TCnPDFArrayObject;
    for I := 0 to Arr.Count - 1 do
    begin
      Obj := Arr.Items[I];
      if Obj <> nil then
        Obj := Obj.Clone;

      AddObject(Obj);
    end;
  end
  else
    inherited;
end;

procedure TCnPDFArrayObject.Clear;
begin
  FElements.Clear;
end;

constructor TCnPDFArrayObject.Create;
begin
  inherited;
  FElements := TObjectList.Create(True);
end;

destructor TCnPDFArrayObject.Destroy;
begin
  FElements.Free;
  inherited;
end;

function TCnPDFArrayObject.GetCount: Integer;
begin
  Result := FElements.Count;
end;

function TCnPDFArrayObject.GetItem(Index: Integer): TCnPDFObject;
begin
  Result := TCnPDFObject(FElements[Index]);
end;

function TCnPDFArrayObject.HasObjectRef(Obj: TCnPDFObject): Boolean;
var
  I: Integer;
  Ref: TCnPDFReferenceObject;
begin
  for I := 0 to Count - 1 do
  begin
    if Items[I] is TCnPDFReferenceObject then
    begin
      Ref := Items[I] as TCnPDFReferenceObject;
      if Ref.IsReference(Obj) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
  Result := False;
end;

procedure TCnPDFArrayObject.SetItem(Index: Integer;
  const Value: TCnPDFObject);
begin
  FElements[Index] := Value;
end;

function TCnPDFArrayObject.ToString: string;
begin
  Result := Format('[...Count %d...]', [Count]);
end;

procedure TCnPDFArrayObject.ToStrings(Strings: TStrings; Indent: Integer);
var
  I: Integer;
  S1, S2: string;
  V: TCnPDFObject;
begin
  S1 := StringOfChar(' ', Indent);
  Strings.Add(S1 + '[');
  if Count > 0 then
  begin
    S2 := StringOfChar(' ', Indent + INDENTDELTA);
    for I := 0 to Count - 1 do
    begin
      V := Items[I];
      if V <> nil then
        V.ToStrings(Strings, Indent + INDENTDELTA);
    end;
  end;
  Strings.Add(S1 + ']');
end;

function TCnPDFArrayObject.WriteToStream(Stream: TStream): Cardinal;
var
  I: Integer;
begin
  Result := 0;
  Inc(Result, CheckWriteObjectStart(Stream));
  Inc(Result, WriteString(Stream, '['));
  for I := 0 to FElements.Count - 1 do
  begin
    Inc(Result, (FElements[I] as TCnPDFObject).WriteToStream(Stream));
    if I < FElements.Count - 1 then
      Inc(Result, WriteSpace(Stream));
  end;
  Inc(Result, WriteString(Stream, ']'));
  Inc(Result, CheckWriteObjectEnd(Stream));
end;

{ TCnPDFSimpleObject }

constructor TCnPDFSimpleObject.Create(const AContent: AnsiString);
begin
  inherited Create;
  FContent := AnsiToBytes(AContent);
end;

procedure TCnPDFSimpleObject.Assign(Source: TPersistent);
begin
  if Source is TCnPDFSimpleObject then
  begin
    SetLength(FContent, Length((Source as TCnPDFSimpleObject).Content));
    if Length(FContent) > 0 then
      Move((Source as TCnPDFSimpleObject).Content[0], FContent[0], Length(FContent));
  end
  else
    inherited;
end;

constructor TCnPDFSimpleObject.Create(const Data: TBytes);
begin
  inherited Create;
  if Length(Data) > 0 then
    FContent := NewBytesFromMemory(@Data[0], Length(Data));
end;

function TCnPDFSimpleObject.WriteToStream(Stream: TStream): Cardinal;
begin
  Result := 0;
  Inc(Result, CheckWriteObjectStart(Stream));
  Inc(Result, WriteBytes(Stream, Content));
  Inc(Result, CheckWriteObjectEnd(Stream));
end;

function TCnPDFSimpleObject.ToString: string;
begin
  Result := BytesToString(FContent);
end;

{ TCnPDFReferenceObject }

procedure TCnPDFReferenceObject.Assign(Source: TPersistent);
begin
  if Source is TCnPDFReferenceObject then
  begin
    FReference := (Source as TCnPDFReferenceObject).Reference;
  end
  else
    inherited;
end;

constructor TCnPDFReferenceObject.Create(Obj: TCnPDFObject);
begin
  inherited Create('');
  Reference := Obj;
end;

destructor TCnPDFReferenceObject.Destroy;
begin

  inherited;
end;

function TCnPDFReferenceObject.IsReference(Obj: TCnPDFObject): Boolean;
begin
  Result := False;
  if Obj <> nil then
  begin
    if (FID = Obj.ID) and (FGeneration = Obj.Generation) then
      Result := True;
  end;
end;

procedure TCnPDFReferenceObject.SetReference(const Value: TCnPDFObject);
begin
  FReference := Value;
  if FReference = nil then
  begin
    FID := 0;
    FGeneration := 0;
  end
  else
  begin
    FID := FReference.ID;
    FGeneration := FReference.Generation;
  end;
end;

function TCnPDFReferenceObject.ToString: string;
begin
  Result := Format('%d %d R', [ID, Generation]);
end;

function TCnPDFReferenceObject.WriteToStream(Stream: TStream): Cardinal;
begin
  Result := 0;

  Inc(Result, WriteString(Stream, IntToStr(FID)));
  Inc(Result, WriteSpace(Stream));
  Inc(Result, WriteString(Stream, IntToStr(FGeneration)));
  Inc(Result, WriteSpace(Stream));
  Inc(Result, WriteString(Stream, 'R'));
end;

{ TCnPDFBooleanObject }

constructor TCnPDFBooleanObject.Create(IsTrue: Boolean);
begin
  if IsTrue then
    inherited Create('true')
  else
    inherited Create('false');
end;

{ TCnPDFNullObject }

constructor TCnPDFNullObject.Create;
begin
  inherited Create('null');
end;

{ TCnPDFStringObject }

constructor TCnPDFStringObject.Create(const AnsiStr: AnsiString);
begin
  inherited Create(AnsiStr);
end;

{$IFDEF COMPILER5}

constructor TCnPDFStringObject.CreateW(const WideStr: WideString);
begin
  if Length(WideStr) > 0 then
  begin
    SetLength(FContent, Length(WideStr) * SizeOf(WideChar) + 2);
    Move(SCN_BOM_UTF16_LE[0], FContent[0], SizeOf(SCN_BOM_UTF16_LE));
    Move(WideStr[1], FContent[2], Length(WideStr) * SizeOf(WideChar));
  end;
end;

{$ELSE}

constructor TCnPDFStringObject.Create(const WideStr: WideString);
begin
  if Length(WideStr) > 0 then
  begin
    SetLength(FContent, Length(WideStr) * SizeOf(WideChar) + 2);
    Move(SCN_BOM_UTF16_LE[0], FContent[0], SizeOf(SCN_BOM_UTF16_LE));
    Move(WideStr[1], FContent[2], Length(WideStr) * SizeOf(WideChar));
  end;
end;

{$ENDIF}

{$IFDEF UNICODE}

constructor TCnPDFStringObject.Create(const UnicodeStr: string);
begin
  if Length(UnicodeStr) > 0 then
  begin
    SetLength(FContent, Length(UnicodeStr) * SizeOf(WideChar) + 2);
    Move(SCN_BOM_UTF16_LE[0], FContent[0], SizeOf(SCN_BOM_UTF16_LE));
    Move(UnicodeStr[1], FContent[2], Length(UnicodeStr) * SizeOf(WideChar));
  end;
end;

{$ENDIF}

function TCnPDFStringObject.WriteToStream(Stream: TStream): Cardinal;
var
  S: string;
begin
  Result := 0;
  if FIsHex then
  begin
    Inc(Result, WriteString(Stream, '<'));
    S := BytesToHex(Content);
    Inc(Result, WriteString(Stream, S));
    Inc(Result, WriteString(Stream, '>'));
  end
  else
  begin
    Inc(Result, WriteString(Stream, '('));
    Inc(Result, WriteBytes(Stream, Content));
    Inc(Result, WriteString(Stream, ')'));
  end;
end;

{ TCnPDFStreamObject }

constructor TCnPDFStreamObject.Create;
begin
  inherited;

end;

destructor TCnPDFStreamObject.Destroy;
begin
  SetLength(FStream, 0);
  inherited;
end;

procedure TCnPDFStreamObject.ExtractStream(OutStream: TStream);
begin
  // TODO: ��ѹ
end;

procedure TCnPDFStreamObject.SetJpegImage(const JpegFileName: string);
var
  F: TFileStream;
  S: Int64;
  J: TJPEGImage;
begin
  if FileExists(JpegFileName) then
  begin
    Clear;

    AddName('Type', 'XObject');
    AddName('Subtype', 'Image');
    AddNumber('BitsPerComponent', 8);
    AddName('ColorSpace', 'DeviceRGB');
    AddName('Filter', 'DCTDecode');

    J := TJPEGImage.Create;
    try
      J.LoadFromFile(JpegFileName);
      AddNumber('Height', J.Height);
      AddNumber('Width', J.Width);
    finally
      J.Free;
    end;

    F := TFileStream.Create(JpegFileName, fmOpenRead or fmShareDenyWrite);
    try
      S := F.Size;
      AddNumber('Length', S);
      SetLength(FStream, S);

      F.Read(FStream[0], S);
    finally
      F.Free;
    end;
  end;
end;

procedure TCnPDFStreamObject.Compress;
var
  InS, OutS: TMemoryStream;
begin
  // ������ûָ��֧��ѹ������
  if not FSupportCompress or (Length(FStream) <= 0) then
    Exit;

  Ins := nil;
  OutS := nil;

  try
    InS := TMemoryStream.Create;
    BytesToStream(FStream, InS);
    OutS := TMemoryStream.Create;

    CnZipCompressStream(InS, OutS);
    FStream := StreamToBytes(OutS);

    Values['Filter'] := TCnPDFNameObject.Create('FlateDecode');
  finally
    OutS.Free;
    InS.Free;
  end;
end;

procedure TCnPDFStreamObject.Uncompress;
var
  InS, OutS: TMemoryStream;
  V: TCnPDFObject;
begin
  if Length(FStream) <= 0 then
    Exit;

  // ���Ǳ�׼ Zip ѹ������
  V := Values['Filter'];
  if (V <> nil) and (V is TCnPDFNameObject) then
  begin
    if (V as TCnPDFNameObject).Name = 'FlateDecode' then
      FSupportCompress := True
    else
      Exit;
  end
  else
    Exit;

  Ins := nil;
  OutS := nil;

  try
    InS := TMemoryStream.Create;
    BytesToStream(FStream, InS);
    OutS := TMemoryStream.Create;

    try
      InS.Position := 0;
      CnZipUncompressStream(InS, OutS);
      FStream := StreamToBytes(OutS);

      DeleteName('Filter'); // ���˾Ͳ���Ҫ��� Filter �����
    except
      ;
    end;
  finally
    OutS.Free;
    InS.Free;
  end;
end;

procedure TCnPDFStreamObject.SetStrings(Strings: TStrings);
var
  S: AnsiString;
begin
  S := Strings.Text;
  SetLength(FStream, Length(S));
  if Length(FStream) > 0 then
    Move(S[1], FStream[0], Length(FStream));
end;

procedure TCnPDFStreamObject.SyncLength;
begin
  Values['Length'] := TCnPDFNumberObject.Create(Length(FStream));
end;

function TCnPDFStreamObject.ToString: string;
var
  V: TCnPDFObject;
  S: string;
begin
  V := Values['Length'];
  S := '';
  if (V <> nil) and (V is TCnPDFNumberObject) then
    S := ' Length: ' + IntToStr((V as TCnPDFNumberObject).AsInteger);
  Result := inherited ToString + S + ' Stream Size: ' + IntToStr(Length(FStream));
end;

procedure TCnPDFStreamObject.ToStrings(Strings: TStrings; Indent: Integer);
begin
  Strings.Add(ToString);
  inherited ToStrings(Strings, Indent);
end;

function TCnPDFStreamObject.WriteToStream(Stream: TStream): Cardinal;
begin
  SyncLength;

  Result := WriteDictionary(Stream);
  Inc(Result, WriteLine(Stream, BEGINSTREAM));
  if Length(FStream) > 0 then
    Inc(Result, Stream.Write(FStream[0], Length(FStream)));

  Inc(Result, WriteCRLF(Stream));
  Inc(Result, WriteLine(Stream, ENDSTREAM));
  Inc(Result, CheckWriteObjectEnd(Stream));
end;

{ TCnPDFBody }

function TCnPDFBody.AddContent(Page: TCnPDFDictionaryObject): TCnPDFStreamObject;
begin
  Result := TCnPDFStreamObject.Create;
  FObjects.Add(Result);
  Page['Contents'] := TCnPDFReferenceObject.Create(Result);
end;

procedure TCnPDFBody.AddObject(Obj: TCnPDFObject);
begin
  FObjects.Add(Obj);
end;

function TCnPDFBody.AddPage: TCnPDFDictionaryObject;
begin
  Result := TCnPDFDictionaryObject.Create;
  Result['Parent'] := TCnPDFReferenceObject.Create(FPages);
  Result['Resources'] := TCnPDFDictionaryObject.Create;

  FObjects.Add(Result);
  FPageList.Add(Result);
end;

procedure TCnPDFBody.AddRawContent(AContent: TCnPDFStreamObject);
begin
  FContentList.Add(AContent);
end;

procedure TCnPDFBody.AddRawPage(APage: TCnPDFDictionaryObject);
begin
  FPageList.Add(APage);
end;

procedure TCnPDFBody.AddRawResource(AResource: TCnPDFDictionaryObject);
begin
  FResourceList.Add(AResource);
end;

function TCnPDFBody.AddResource(Page: TCnPDFDictionaryObject): TCnPDFDictionaryObject;
begin
  Result := TCnPDFDictionaryObject.Create;
  FObjects.Add(Result);
  Page['Resources'] := TCnPDFReferenceObject.Create(Result);
end;

constructor TCnPDFBody.Create;
begin
  inherited;
  FObjects := TCnPDFObjectManager.Create;

  FPageList := TObjectList.Create(False);
  FContentList := TObjectList.Create(False);
  FResourceList := TObjectList.Create(False);
end;

procedure TCnPDFBody.CreateResources;
begin
  if FInfo = nil then
  begin
    FInfo := TCnPDFDictionaryObject.Create;
    FObjects.Add(FInfo);
  end;

  if FCatalog = nil then
  begin
    FCatalog := TCnPDFDictionaryObject.Create;
    FCatalog.AddName('Type', 'Catalog');
    FObjects.Add(FCatalog);
  end;

  if FPages = nil then
  begin
    FPages := TCnPDFDictionaryObject.Create;
    FPages.AddName('Type', 'Pages');
    FObjects.Add(FPages);
  end;

  FPages.AddArray('Kids');
  FCatalog.AddObjectRef('Pages', FPages);
end;

destructor TCnPDFBody.Destroy;
begin
  FResourceList.Free;
  FContentList.Free;
  FPageList.Free;

  FObjects.Free;
  inherited;
end;

procedure TCnPDFBody.DumpToStrings(Strings: TStrings; Verbose: Boolean;
  Indent: Integer);
var
  I: Integer;
  Obj, V: TCnPDFObject;
  S, Ext: string;
begin
  Strings.Add('Body');
  Strings.Add('PDF Object Count: ' + IntToStr(FObjects.Count));
  for I := 0 to FObjects.Count - 1 do
  begin
    Obj := FObjects[I];
    S := Obj.ClassName;
    S := StringReplace(S, 'TCnPDF', '', [rfReplaceAll]);
    S := StringReplace(S, 'Object', '', [rfReplaceAll]);

    if Obj is TCnPDFArrayObject then
      Ext := (Obj as TCnPDFArrayObject).ToString
    else if Obj is TCnPDFDictionaryObject then
    begin
      Ext := (Obj as TCnPDFDictionaryObject).ToString;
      V := (Obj as TCnPDFDictionaryObject).Values['Type'];
      if (V <> nil) and (V is TCnPDFNameObject) then
        Ext := Ext + ' Type: ' + V.ToString;
    end;

    Strings.Add(Format('#%d ID %d Gen %d %s Offset %d. %s',
      [I + 1, Obj.ID, Obj.Generation, S, Obj.Offset, Ext]));

    // ������� Array �� Dictionary ������
    if Verbose then
    begin
      if Obj is TCnPDFDictionaryObject then
        (Obj as TCnPDFDictionaryObject).ToStrings(Strings, INDENTDELTA)
      else if Obj is TCnPDFArrayObject then
        (Obj as TCnPDFArrayObject).ToStrings(Strings, INDENTDELTA);
    end;
  end;
end;

function TCnPDFBody.GetContent(Index: Integer): TCnPDFStreamObject;
begin
  Result := TCnPDFStreamObject(FContentList[Index]);
end;

function TCnPDFBody.GetContentCount: Integer;
begin
  Result := FContentList.Count;
end;

function TCnPDFBody.GetPage(Index: Integer): TCnPDFDictionaryObject;
begin
  Result := TCnPDFDictionaryObject(FPageList[Index]);
end;

function TCnPDFBody.GetPageCount: Integer;
begin
  Result := FPageList.Count;
end;

function PDFObjectCompare(Item1, Item2: Pointer): Integer;
var
  P1, P2: TCnPDFObject;
begin
  P1 := TCnPDFObject(Item1);
  P2 := TCnPDFObject(Item2);
  Result := P1.ID - P2.ID;
end;

function TCnPDFBody.GetResource(Index: Integer): TCnPDFDictionaryObject;
begin
  Result := TCnPDFDictionaryObject(FResourceList[Index]);
end;

function TCnPDFBody.GetResourceCount: Integer;
begin
  Result := FResourceList.Count;
end;

procedure TCnPDFBody.SortObjects;
begin
  FObjects.Sort(PDFObjectCompare);
end;

procedure TCnPDFBody.SyncPages;
var
  I: Integer;
  Arr: TCnPDFArrayObject;
begin
  if Pages <> nil then
  begin
    FPages['Count'] := TCnPDFNumberObject.Create(FPageList.Count);
    Arr := FPages['Kids'] as TCnPDFArrayObject;

    for I := 0 to FPageList.Count - 1 do
    begin
      if not Arr.HasObjectRef(FPageList[I] as TCnPDFObject) then // ��ֹҳ���ظ�
        Arr.AddObjectRef(FPageList[I] as TCnPDFObject);
    end;
  end;
end;

function TCnPDFBody.WriteToStream(Stream: TStream): Cardinal;
var
  I: Integer;
  OldID: Int64;
  Obj: TCnPDFObject;
  Collection: TCnPDFXRefCollection;
  Item: TCnPDFXRefItem;
begin
  FXRefTable.Clear;
  //SortObjects;

  Result := 0;
  OldID := -1;
  Collection := nil;

  for I := 0 to FObjects.Count - 1 do
  begin
    Obj := TCnPDFObject(FObjects[I]);
    if Obj.ID > OldID + 1 then
    begin
      // ���� Segment����� Index Ϊ�� Obj.ID
      Collection := FXRefTable.AddSegment;
      Collection.ObjectIndex := Obj.ID;
    end
    else if Obj.ID = OldID + 1 then
    begin
      // ���ڱ� Segment
    end;

    // �þ� Collection ���� Collection �½� Item
    Item := Collection.Add;
    Item.ObjectGeneration := Obj.Generation;
    Item.ObjectXRefType := Obj.XRefType;
    Item.ObjectOffset := Stream.Position;

    // ���� ID
    OldID := Obj.ID;

    Inc(Result, Obj.WriteToStream(Stream));
  end;
end;

{ TCnPDFObjectManger }

function TCnPDFObjectManager.Add(AObject: TCnPDFObject): Integer;
begin
  Result := inherited Add(AObject);
  Inc(FMaxID);
  AObject.ID := FMaxID;
end;

function TCnPDFObjectManager.AddRaw(AObject: TCnPDFObject): Integer;
begin
  Result := inherited Add(AObject);
end;

procedure TCnPDFObjectManager.CalcMaxID;
var
  I: Integer;
  Obj: TCnPDFObject;
begin
  FMaxID := 0;
  for I := 0 to Count - 1 do
  begin
    Obj := Items[I];
    if Obj.ID > FMaxID then
      FMaxID := Obj.ID;
  end;
end;

constructor TCnPDFObjectManager.Create;
begin
  inherited Create(True);
end;

function TCnPDFObjectManager.GetItem(Index: Integer): TCnPDFObject;
begin
  Result := TCnPDFObject(inherited GetItem(Index));
end;

function TCnPDFObjectManager.GetObjectByIDGeneration(ObjID,
  ObjGeneration: Cardinal): TCnPDFObject;
var
  I: Integer;
  Obj: TCnPDFObject;
begin
  for I := 0 to Count - 1 do
  begin
    Obj := Items[I];
    if (Obj.ID = ObjID) and (Obj.Generation = ObjGeneration) then
    begin
      Result := Obj;
      Exit;
    end;
  end;
  Result := nil;
end;

procedure TCnPDFObjectManager.SetItem(Index: Integer;
  const Value: TCnPDFObject);
begin
  inherited SetItem(Index, Value);
  Inc(FMaxID);
  Value.ID := FMaxID;
end;

{ TCnPDFNumberObject }

constructor TCnPDFNumberObject.Create(Num: Integer);
begin
  inherited Create(AnsiString(IntToStr(Num)));
end;

constructor TCnPDFNumberObject.Create(Num: Int64);
begin
  inherited Create(AnsiString(IntToStr(Num)));
end;

function TCnPDFNumberObject.AsFloat: Extended;
var
  S: string;
begin
  S := BytesToAnsi(FContent);
  Result := StrToFloat(S);
end;

function TCnPDFNumberObject.AsInteger: Integer;
var
  S: string;
begin
  S := BytesToAnsi(FContent);
  Result := StrToInt(S);
end;

constructor TCnPDFNumberObject.Create(Num: Extended);
begin
  inherited Create(AnsiString(FloatToStr(Num)));
end;

procedure TCnPDFNumberObject.SetFloat(Value: Extended);
begin
  FContent := AnsiToBytes(FloatToStr(Value));
end;

procedure TCnPDFNumberObject.SetInteger(Value: Integer);
begin
  FContent := AnsiToBytes(IntToStr(Value));
end;

function CnLoadPDFFile(const FileName: string): TCnPDFDocument;
begin
  Result := TCnPDFDocument.Create;
  try
    Result.LoadFromFile(FileName);
  except
    Result.Free;
    Result := nil;
  end;
end;

procedure CnSavePDFFile(PDF: TCnPDFDocument; const FileName: string);
begin
  if PDF <> nil then
    PDF.SaveToFile(FileName);
end;

procedure CnJpegFilesToPDF(JpegFiles: TStrings; const FileName: string);
var
  I: Integer;
  PDF: TCnPDFDocument;
  Page: TCnPDFDictionaryObject;
  Box: TCnPDFArrayObject;
  Stream: TCnPDFStreamObject;
  Resource: TCnPDFDictionaryObject;
  ExtGState, ResDict: TCnPDFDictionaryObject;
  Content: TCnPDFStreamObject;
  ContData: TStringList;
  W, H: Integer;

  procedure CalcImageSize(var ImageWidth, ImageHeight: Integer);
  begin
    // ҳ��� 612���� 792�����ұ߾�Ĭ�� 90�����±߾�Ĭ�� 72
    // ����м��������Ŀ�Ϊ��ҳ��� - ��߾� - �ұ߾� = 612 - 90 - 90 = 432
    // ��Ϊ��ҳ��� - �ϱ߾� - �±߾� = 792 - 72 - 72 = 648
    // ͼ������һ�߳����ó�����Ҫ�ȱ������������ٿ���һ���Ƿ񳬳�����������

    if ImageWidth > 432 then
    begin
      ImageHeight := Round(ImageHeight * 432.0 / ImageWidth);
      ImageWidth := 432;
    end;

    if ImageHeight > 648 then
    begin
      ImageWidth := Round(ImageWidth * 648.0 / ImageHeight);
      ImageHeight := 648;
    end;
  end;

begin
  PDF := TCnPDFDocument.Create;
  ContData := TStringList.Create;

  try
    PDF.Body.CreateResources;
    PDF.Body.Info.AddAnsiString('Author', 'CnPack');
    PDF.Body.Info.AddAnsiString('Producer', 'CnPDF in CnVCL');
    PDF.Body.Info.AddAnsiString('Creator', 'CnPack PDF Creator');
    PDF.Body.Info.AddAnsiString('CreationDate', 'D:' + FormatDateTime('yyyyMMddhhmmss', Now) + '+8''00''');

    PDF.Body.Info.AddWideString('Title', 'ͼ�����');
    PDF.Body.Info.AddWideString('Subject', 'ͼ������');
    PDF.Body.Info.AddWideString('Keywords', '�ؼ��֡�ͼ��');
    PDF.Body.Info.AddWideString('Company', 'CnPack������');
    PDF.Body.Info.AddWideString('Comments', '����ע��');

    // ���� ExtGState �����ҳ�湲��
    ExtGState := TCnPDFDictionaryObject.Create;
    ExtGState.AddName('Type', 'ExtGState');
    ExtGState.AddFalse('AIS');
    ExtGState.AddName('BM', 'Normal');
    ExtGState.AddNumber('CA', 1);
    ExtGState.AddNumber('ca', 1);
    PDF.Body.AddObject(ExtGState);

    for I := 0 to JpegFiles.Count - 1 do
    begin
      // �¼�һҳ
      Page := PDF.Body.AddPage;

      // ����ֽ�Ŵ�С��Ĭ�� A4����λ Points Ҳ���� 1/72 Ӣ�磬612 792 ��������� 210 297 mm
      Box := Page.AddArray('MediaBox');
      Box.AddNumber(0);
      Box.AddNumber(0);
      Box.AddNumber(612);
      Box.AddNumber(792);

      // ����ͼ������
      Stream := TCnPDFStreamObject.Create;
      Stream.SetJpegImage(JpegFiles[I]);
      PDF.Body.AddObject(Stream);

      // �������ô�ͼ�����Դ
      Resource := PDF.Body.AddResource(Page);

      // ExtGState �� Stream �� ID Ҫ��Ϊ����
      ResDict := Resource.AddDictionary('ExtGState');
      ResDict.AddObjectRef('GS' + IntToStr(ExtGState.ID), ExtGState);
      ResDict := Resource.AddDictionary('XObject');
      ResDict.AddObjectRef('IM' + IntToStr(Stream.ID), Stream);

      // ����ҳ�沼������
      Content := PDF.Body.AddContent(Page);

      // ����ҳ�沼�����ͼ���С��λ�ò����ƣ�
      ContData.Clear;
      ContData.Add('q');

      W := TCnPDFNumberObject(Stream.Values['Width']).AsInteger;
      H := TCnPDFNumberObject(Stream.Values['Height']).AsInteger;
      CalcImageSize(W, H);

      ContData.Add(Format('1 0 0 1 %d %d cm', [90, 792 - 72 - H]));
      ContData.Add(Format('%d 0 0 %d 0 0 cm', [W, H]));

      ContData.Add('/IM' + IntToStr(Stream.ID) + ' Do');
      ContData.Add('Q');
      Content.SetStrings(ContData);

      Content.SupportCompress := True;
      Content.Compress; // ʹ�� Deflate ѹ�����Ͱ汾 Delphi ���ƺ�Ҳ���� Acrobat Reader ���Ķ�����
    end;

    PDF.Trailer.GenerateID;
    PDF.SaveToFile(FileName);
  finally
    ContData.Free;
    PDF.Free;
  end;
end;

end.