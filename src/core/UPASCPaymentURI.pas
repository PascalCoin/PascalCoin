unit UPASCPaymentURI;

// Skybuck: Part of PIP-0026 implementation
// Interface section slightly reformatted by Skybuck Flying on 14 may 2021 !

{%region Compiler Directives}
{$IFDEF FPC}
{$UNDEF DELPHI}
{$MODE delphiunicode}
{$DEFINE USE_UNROLLED_VARIANT}
{$OVERFLOWCHECKS OFF}
{$RANGECHECKS OFF}
{$POINTERMATH ON}
{$WARNINGS OFF}
{$HINTS OFF}
{$NOTES OFF}
{$OPTIMIZATION LEVEL3}
{$OPTIMIZATION PEEPHOLE}
{$OPTIMIZATION REGVAR}
{$OPTIMIZATION LOOPUNROLL}
{$OPTIMIZATION STRENGTH}
{$OPTIMIZATION CSE}
{$OPTIMIZATION DFA}
{$IFDEF CPUI386}
{$OPTIMIZATION USEEBP}
{$ENDIF}
{$IFDEF CPUX86_64}
{$OPTIMIZATION USERBP}
{$ENDIF}
{$ELSE}
{$DEFINE USE_UNROLLED_VARIANT}
{$DEFINITIONINFO ON}
{$HINTS OFF}
{$OVERFLOWCHECKS OFF}
{$RANGECHECKS OFF}
{$POINTERMATH ON}
{$STRINGCHECKS OFF}
{$WARN DUPLICATE_CTOR_DTOR OFF}
// 2010 only
{$IF CompilerVersion = 21.0}
{$DEFINE DELPHI2010}
{$IFEND}
// 2010 and Above
{$IF CompilerVersion >= 21.0}
{$DEFINE DELPHI2010_UP}
{$IFEND}
// XE and Above
{$IF CompilerVersion >= 22.0}
{$DEFINE DELPHIXE_UP}
{$IFEND}
// XE2 and Above
{$IF CompilerVersion >= 23.0}
{$DEFINE DELPHIXE2_UP}
{$DEFINE HAS_UNITSCOPE}
{$IFEND}
// XE3 and Below
{$IF CompilerVersion <= 24.0}
{$DEFINE DELPHIXE3_DOWN}
{$IFEND}
// XE3 and Above
{$IF CompilerVersion >= 24.0}
{$DEFINE DELPHIXE3_UP}
{$LEGACYIFEND ON}
{$ZEROBASEDSTRINGS OFF}
{$IFEND}
// XE7 and Above
{$IF CompilerVersion >= 28.0}
{$DEFINE DELPHIXE7_UP}
{$IFEND}
// 10.2 Tokyo and Above
{$IF CompilerVersion >= 32.0}
{$DEFINE DELPHI10.2_TOKYO_UP}
{$IFEND}
// 2010 and Above
{$IFNDEF DELPHI2010_UP}
{$MESSAGE ERROR 'This Library requires Delphi 2010 or higher.'}
{$ENDIF}
// 10.2 Tokyo and Above
{$IFDEF DELPHI10.2_TOKYO_UP}
{$WARN COMBINING_SIGNED_UNSIGNED OFF}
{$WARN COMBINING_SIGNED_UNSIGNED64 OFF}
{$ENDIF}
{$ENDIF}
{%endregion}

interface

uses
  Math,
  StrUtils,
  SysUtils,
  Generics.Collections;

resourcestring
  SEncodingInstanceNil = 'Encoding instance cannot be nil';
  SErrorDecodingText =
    'Error decoding style (%%<hex>%%<hex>) encoded string at position %d';
  SInvalidEncodedChar = 'Invalid encoded character (%s) at position %d';
  SPASACompulsory = '"Build" cannot be called without adding a PASA';
  SInvalidPASA = 'PASA Validation failed "%s"';
  SInvalidAmount = 'Amount Validation failed "%s"';
  SPASAInvalidPartsNumber =
    'PASA must consist of only two parts, Account Number and Checksum "%s"';
  SAccountNumberNotNumeric = 'Account Number Must be Numeric "%s"';
  SAccountNumberChecksumFailed =
    'Account Number Checksum Failed. Expected "%d" as Checksum for Account Number "%d" but got "%s"';
  SAmountNegative = 'Amount cannot be negative "%0.4f"';

type
  /// <summary>
  /// Represents a dynamic generic array of Type T.
  /// </summary>
  TPASCPaymentURIGenericArray<T> = array of T;

type
  EGuardException = class(Exception);
  ENullReferenceGuardException = class(EGuardException);
  ERFC3986URIToolsException = class(Exception);
  ERFC3986URIToolsDecodeException = class(ERFC3986URIToolsException);
  ERFC3986URIToolsConvertErrorException = class(ERFC3986URIToolsException);
  EPASCPaymentURIException = class(Exception);
  EPASCPaymentURIInvalidArgumentException = class(EPASCPaymentURIException);

type
  IPASCPaymentURI = interface(IInterface)
    ['{09EA5EE5-500F-422D-9AF9-5688B207B9B7}']

    function GetAccount: String;
    /// <summary>
    /// Gets the URI PascalCoin Account, (The account with checksum).
    /// </summary>
    /// <value>
    /// the URI PascalCoin Account
    /// </value>
    property Account: String read GetAccount;

    function GetLabel: String;
    /// <summary>
    /// Gets the URI Label. (for example the name of the receiver).
    /// </summary>
    /// <value>
    /// the URI Label
    /// </value>
    property &Label: String read GetLabel;

    function GetMessage: String;
    /// <summary>
    /// Gets the URI Message. (for example the reason for the transaction).
    /// </summary>
    /// <value>
    /// the URI Message
    /// </value>
    property &Message: String read GetMessage;

    function GetAmount: Double;
    /// <summary>
    /// Gets the URI Amount. The amount (in PASC).
    /// </summary>
    /// <value>
    /// the URI Amount
    /// </value>
    property Amount: Double read GetAmount;

    /// <summary>
    /// Gets the URI.
    /// </summary>
    /// <returns>
    /// a string with the URI. This string can be used to make a PascalCoin
    /// Payment.
    /// </returns>
    function GetURI(): String;

  end;

type
  IPASCBuilder = interface(IInterface)
    ['{AF26DBE0-852B-41D4-80D2-ACE4CFA66F34}']

    function GetAccount: String;
    property Account: String read GetAccount;
    function GetLabel: String;
    property &Label: String read GetLabel;
    function GetMessage: String;
    property &Message: String read GetMessage;
    function GetAmount: Double;
    property Amount: Double read GetAmount;

    /// <summary>
    /// Adds the account to the builder if validation passes
    /// </summary>
    /// <param name="AAccount">
    /// The account (with checksum).
    /// </param>
    /// <returns>
    /// the builder with the account.
    /// </returns>
    /// <exception cref="EPASCPaymentURIInvalidArgumentException">
    /// if PASA validation fails.
    /// </exception>
    function AddAccount(const AAccount: String): IPASCBuilder;

    /// <summary>
    /// Adds the amount to the builder if validation passes
    /// </summary>
    /// <param name="AAmount">
    /// The amount (in PASC).
    /// </param>
    /// <returns>
    /// the builder with the amount.
    /// </returns>
    /// <exception cref="EPASCPaymentURIInvalidArgumentException">
    /// if amount validation fails.
    /// </exception>
    function AddAmount(const AAmount: Double): IPASCBuilder;

    /// <summary>
    /// Adds the label to the builder
    /// </summary>
    /// <param name="ALabel">
    /// The label (for example the name of the receiver).
    /// </param>
    /// <returns>
    /// the builder with the label.
    /// </returns>
    function AddLabel(const ALabel: String): IPASCBuilder;

    /// <summary>
    /// Adds the message to the builder
    /// </summary>
    /// <param name="AMessage">
    /// The message (for example the reason for the transaction).
    /// </param>
    /// <returns>
    /// the builder with the message.
    /// </returns>
    function AddMessage(const AMessage: String): IPASCBuilder;

    /// <summary>
    /// Builds a PascalCoin Payment URI.
    /// </summary>
    /// <returns>
    /// a PascalCoin Payment URI.
    /// </returns>
    function Build(): IPASCPaymentURI;

  end;

type

  /// <summary>
  /// Object Pascal Library to handle PascalCoin payment URI. (Reference
  /// Version)
  /// </summary>
  TPASCPaymentURI = class sealed(TInterfacedObject, IPASCPaymentURI)
  strict private
    const
      SCHEME: String = 'pasc:';
      PARAMETER_AMOUNT: String = 'amount';
      PARAMETER_LABEL: String = 'label';
      PARAMETER_MESSAGE: String = 'message';
      EPSILON: Double = 0.00009;

    var
     FAccount, FLabel, FMessage: String;
     FAmount: Double;

    type
      TGuard = class sealed(TObject)
      public
        class procedure RequireNotNull(const AObject: TObject; const AMessage: String = ''); static;
      end;

    type
      TConverters = class sealed(TObject)
      public
        class function ConvertStringToBytes(const AInput: String; const AEncoding: TEncoding): TBytes; static;
        class function ConvertBytesToString(const AInput: TBytes; const AEncoding: TEncoding): String; static;
      end;

    type
      TStringUtils = class sealed(TObject)
      public
        class function SplitString(const AInput: String; ADelimiter: Char) : TPASCPaymentURIGenericArray<String>;
        class function BeginsWith(const AInput, ASubString: String; AIgnoreCase: Boolean; AOffset: Int32 = 1): Boolean; static;
      end;

    function GetAccount: String; inline;
    function GetLabel: String; inline;
    function GetAmount: Double; inline;
    function GetMessage: String; inline;

    constructor Create(const APASCBuilder: IPASCBuilder);

  public
    type
      /// <summary>
      /// <c>RFC 3986 URI</c> Encoding and Decoding Class using <c>RFC 3986
      /// Standard</c>
      /// </summary>
      TRFC3986URITools = class sealed(TObject)

      public
        class function Encode(const AInput: String; const AEncoding: TEncoding) : String; static;
        class function Decode(const AInput: String; const AEncoding: TEncoding) : String; static;
    end;

    type
      TPASCBuilder = class sealed(TInterfacedObject, IPASCBuilder)
      strict private
        FAccount, FLabel, FMessage: String;
        FAmount: Double;

        function GetAccount: String; inline;
        function GetLabel: String; inline;
        function GetAmount: Double; inline;
        function GetMessage: String; inline;

        constructor Create();
      public
        property Account: String read GetAccount;
        property &Label: String read GetLabel;
        property &Message: String read GetMessage;
        property Amount: Double read GetAmount;

        /// <summary>
        /// Adds the account to the builder if validation passes
        /// </summary>
        /// <param name="AAccount">
        /// The account (with checksum).
        /// </param>
        /// <returns>
        /// the builder with the account.
        /// </returns>
        /// <exception cref="EPASCPaymentURIInvalidArgumentException">
        /// if PASA validation fails.
        /// </exception>
        function AddAccount(const AAccount: String): IPASCBuilder;

        /// <summary>
        /// Adds the amount to the builder if validation passes
        /// </summary>
        /// <param name="AAmount">
        /// The amount (in PASC).
        /// </param>
        /// <returns>
        /// the builder with the amount.
        /// </returns>
        /// <exception cref="EPASCPaymentURIInvalidArgumentException">
        /// if amount validation fails.
        /// </exception>
        function AddAmount(const AAmount: Double): IPASCBuilder;

        /// <summary>
        /// Adds the label to the builder
        /// </summary>
        /// <param name="ALabel">
        /// The label (for example the name of the receiver).
        /// </param>
        /// <returns>
        /// the builder with the label.
        /// </returns>
        function AddLabel(const ALabel: String): IPASCBuilder;

        /// <summary>
        /// Adds the message to the builder
        /// </summary>
        /// <param name="AMessage">
        /// The message (for example the reason for the transaction).
        /// </param>
        /// <returns>
        /// the builder with the message.
        /// </returns>
        function AddMessage(const AMessage: String): IPASCBuilder;

        /// <summary>
        /// Returns a builder for the PASC Payment URI.
        /// </summary>
        class function Builder(): IPASCBuilder; static;

        /// <summary>
        /// Builds a PascalCoin Payment URI.
        /// </summary>
        /// <returns>
        /// a PascalCoin Payment URI.
        /// </returns>
        function Build(): IPASCPaymentURI; inline;
      end;

    /// <summary>
    /// Gets the URI PascalCoin Account, (The account with checksum).
    /// </summary>
    /// <value>
    /// the URI PascalCoin Account
    /// </value>
    property Account: String read GetAccount;

    /// <summary>
    /// Gets the URI Label. (for example the name of the receiver).
    /// </summary>
    /// <value>
    /// the URI Label
    /// </value>
    property &Label: String read GetLabel;

    /// <summary>
    /// Gets the URI Message. (for example the reason for the transaction).
    /// </summary>
    /// <value>
    /// the URI Message
    /// </value>
    property &Message: String read GetMessage;
    /// <summary>
    /// Gets the URI Amount. The amount (in PASC).
    /// </summary>
    /// <value>
    /// the URI Amount
    /// </value>
    property Amount: Double read GetAmount;

    /// <summary>
    /// Gets the URI.
    /// </summary>
    /// <returns>
    /// a string with the URI. This string can be used to make a PascalCoin
    /// Payment.
    /// </returns>
    function GetURI(): String;

    /// <summary>
    /// Parses a string to a PascalCoin payment URI.
    /// </summary>
    /// <param name="AURIString">
    /// The string to be parsed.
    /// </param>
    /// <returns>
    /// a PascalCoin payment URI if the URI is valid, or null for an invalid
    /// string.
    /// </returns>
    class function Parse(const AURIString: String): IPASCPaymentURI; static;
  end;

implementation

{ TPASCPaymentURI.TGuard }

class procedure TPASCPaymentURI.TGuard.RequireNotNull(const AObject: TObject;
  const AMessage: String);
begin
  begin
    if AObject = Nil then
    begin
      raise ENullReferenceGuardException.Create(AMessage);
    end;
  end;
end;

{ TPASCPaymentURI.TConverters }

class function TPASCPaymentURI.TConverters.ConvertBytesToString
  (const AInput: TBytes; const AEncoding: TEncoding): String;
begin
  TGuard.RequireNotNull(AEncoding, SEncodingInstanceNil);
{$IFDEF FPC}
  result := String(AEncoding.GetString(AInput));
{$ELSE}
  result := AEncoding.GetString(AInput);
{$ENDIF FPC}
end;

class function TPASCPaymentURI.TConverters.ConvertStringToBytes
  (const AInput: String; const AEncoding: TEncoding): TBytes;
begin
  TGuard.RequireNotNull(AEncoding, SEncodingInstanceNil);
{$IFDEF FPC}
  result := AEncoding.GetBytes(UnicodeString(AInput));
{$ELSE}
  result := AEncoding.GetBytes(AInput);
{$ENDIF FPC}
end;

{ TPASCPaymentURI.TStringUtils }

class function TPASCPaymentURI.TStringUtils.BeginsWith(const AInput,
  ASubString: String; AIgnoreCase: Boolean; AOffset: Int32): Boolean;
var
  LLength: Int32;
  LPtrInput, LPtrSubString: PChar;
begin
  LLength := System.Length(ASubString);
  result := LLength > 0;
  LPtrInput := PChar(AInput);
  System.Inc(LPtrInput, AOffset - 1);
  LPtrSubString := PChar(ASubString);
  if result then
  begin
    if AIgnoreCase then
    begin
      result := StrLiComp(LPtrSubString, LPtrInput, LLength) = 0
    end
    else
    begin
      result := StrLComp(LPtrSubString, LPtrInput, LLength) = 0
    end;
  end;
end;

class function TPASCPaymentURI.TStringUtils.SplitString(const AInput: String;
  ADelimiter: Char): TPASCPaymentURIGenericArray<String>;
var
  LPosStart, LPosDel, LSplitPoints, LIdx, LLowPoint, LHighPoint, LLength: Int32;
begin
  result := Nil;
  if AInput <> '' then
  begin
    { Determine the length of the resulting array }
    LSplitPoints := 0;
{$IFDEF DELPHIXE3_UP}
    LLowPoint := System.Low(AInput);
    LHighPoint := System.High(AInput);
{$ELSE}
    LLowPoint := 1;
    LHighPoint := System.Length(AInput);
{$ENDIF DELPHIXE3_UP}
    for LIdx := LLowPoint to LHighPoint do
    begin
      if (ADelimiter = AInput[LIdx]) then
        System.Inc(LSplitPoints);
    end;

    System.SetLength(result, LSplitPoints + 1);

    { Split the string and fill the resulting array }

    LIdx := 0;
    LLength := System.Length(ADelimiter);
{$IFDEF DELPHIXE3_UP}
    LPosStart := System.Low(AInput);
    LHighPoint := System.High(AInput);
{$ELSE}
    LPosStart := 1;
    LHighPoint := System.Length(AInput);
{$ENDIF DELPHIXE3_UP}
    LPosDel := System.Pos(ADelimiter, AInput);
    while LPosDel > 0 do
    begin
      result[LIdx] := System.Copy(AInput, LPosStart, LPosDel - LPosStart);
      LPosStart := LPosDel + LLength;
      LPosDel := PosEx(ADelimiter, AInput, LPosStart);
      System.Inc(LIdx);
    end;
    result[LIdx] := System.Copy(AInput, LPosStart, LHighPoint);
  end;
end;

{ TPASCPaymentURI.TRFC3986URITools }

class function TPASCPaymentURI.TRFC3986URITools.Encode(const AInput: String;
  const AEncoding: TEncoding): String;
// The SafeMask Set contains characters as specified in RFC 3986 section 2.3
// Unreserved Characters (January 2005).
const
  SafeMask = [Ord('A') .. Ord('Z'), Ord('a') .. Ord('z'), Ord('0') .. Ord('9'),
    Ord('-'), Ord('_'), Ord('.'), Ord('~')];

  procedure DoAppendByte(AByte: Byte;
    var ABuffer: TPASCPaymentURIGenericArray<Char>; var AIndex: Int32);
  var
    LResult: String;
  begin
    LResult := Format('%.2x', [AByte]);
    ABuffer[AIndex + 0] := '%';
    ABuffer[AIndex + 1] := LResult[1];
    ABuffer[AIndex + 2] := LResult[2];
    System.Inc(AIndex, 3);
  end;

var
  LMultiByteCharBytes: TBytes;
  LIIdx, LJIdx, LKIdx, LByteCount, LInputLength: Int32;
  LResult: TPASCPaymentURIGenericArray<Char>;

begin
  TPASCPaymentURI.TGuard.RequireNotNull(AEncoding, SEncodingInstanceNil);
  // we could call "AEncoding.GetByteCount" in the loop to get the exact
  // bytecount needed for each char but that would be very expensive so
  // we result to making a very general assumption below
  // Set result length as 4 bytes per Char, and 3 characters to represent each byte
  LInputLength := System.Length(AInput);
  System.SetLength(LResult, LInputLength * 4 * 3);

  System.SetLength(LMultiByteCharBytes, 4);
  // low index of a string in Pascal
{$IFDEF DELPHIXE3_UP}
  LJIdx := System.Low(AInput);
{$ELSE}
  LJIdx := 1;
{$ENDIF DELPHIXE3_UP}
  LKIdx := 0;

  while (LJIdx <= LInputLength) do
  begin
    if Ord(AInput[LJIdx]) in SafeMask then
    begin
      LResult[LKIdx] := AInput[LJIdx];
      System.Inc(LKIdx);
    end
    else
    begin
      if (Ord(AInput[LJIdx]) < 128) then
      begin
        // for Single byte char
        DoAppendByte(Ord(AInput[LJIdx]), LResult, LKIdx);
      end
      else
      begin
        // for Multi byte char
        LByteCount := AEncoding.GetBytes
          (TPASCPaymentURIGenericArray<Char>.Create(AInput[LJIdx]), 0, 1,
          LMultiByteCharBytes, 0);

        for LIIdx := 0 to System.Pred(LByteCount) do
        begin
          DoAppendByte(LMultiByteCharBytes[LIIdx], LResult, LKIdx);
        end;
      end
    end;
    System.Inc(LJIdx);
  end;
  System.SetString(result, PChar(@LResult[0]), LKIdx);
end;

class function TPASCPaymentURI.TRFC3986URITools.Decode(const AInput: String;
  const AEncoding: TEncoding): String;
  function GetHexByte(const AChar: Char): Byte;
  begin
    case AChar of
      '0' .. '9':
        result := Ord(AChar) - Ord('0');
      'A' .. 'F':
        result := Ord(AChar) - Ord('A') + 10;
      'a' .. 'f':
        result := Ord(AChar) - Ord('a') + 10;
    else
      begin
        raise ERFC3986URIToolsConvertErrorException.Create('');
      end;
    end;
  end;

  function DecodeHexPair(const ACharOne, ACharTwo: Char): Byte; inline;
  begin
    result := (GetHexByte(ACharOne) shl 4) + GetHexByte(ACharTwo);
  end;

var
  LIIdx, LJIdx, LKIdx, LInputLength: Int32;
  LBytes: TBytes;

begin
  TGuard.RequireNotNull(AEncoding, SEncodingInstanceNil);
  LInputLength := System.Length(AInput);
  System.SetLength(LBytes, LInputLength * 4);
  LIIdx := 0;
  // low index of a string in Pascal
{$IFDEF DELPHIXE3_UP}
  LJIdx := System.Low(AInput);
{$ELSE}
  LJIdx := 1;
{$ENDIF DELPHIXE3_UP}
  LKIdx := LJIdx;
  try
    while (LJIdx <= LInputLength) do
    begin
      case AInput[LJIdx] of
        '%':
          begin
            System.Inc(LJIdx);
            // Get an encoded byte, may be is a single byte (%<hex>)
            // or part of multi byte (%<hex>%<hex>...) character
            LKIdx := LJIdx;
            System.Inc(LJIdx);
            if ((LKIdx > System.Length(AInput)) or
              (LJIdx > System.Length(AInput))) then
            begin
              raise ERFC3986URIToolsDecodeException.CreateResFmt
                (@SErrorDecodingText, [LKIdx]);
            end;
            LBytes[LIIdx] := DecodeHexPair(AInput[LKIdx], AInput[LJIdx]);
          end;
      else
        begin
          if Ord(AInput[LJIdx]) < 128 then
          begin
            // for single byte char
            LBytes[LIIdx] := Byte(AInput[LJIdx]);
          end
          else
          begin
            // for multi byte char
            LIIdx := LIIdx + AEncoding.GetBytes
              (TPASCPaymentURIGenericArray<Char>.Create(AInput[LJIdx]), 0, 1,
              LBytes, LIIdx) - 1;
          end;
        end;

      end;
      System.Inc(LIIdx);
      System.Inc(LJIdx);
    end;
  except
    on E: ERFC3986URIToolsConvertErrorException do
    begin
      raise ERFC3986URIToolsConvertErrorException.CreateResFmt
        (@SInvalidEncodedChar,
        [Char('%') + AInput[LKIdx] + AInput[LJIdx], LKIdx])
    end;
  end;
  System.SetLength(LBytes, LIIdx);
  result := TPASCPaymentURI.TConverters.ConvertBytesToString(LBytes, AEncoding);
end;

{ TPASCPaymentURI.TBuilder }

function TPASCPaymentURI.TPASCBuilder.GetLabel: String;
begin
  result := FLabel;
end;

constructor TPASCPaymentURI.TPASCBuilder.Create();
begin
  Inherited Create();
end;

function TPASCPaymentURI.TPASCBuilder.AddAccount(const AAccount: String)
  : IPASCBuilder;

  function ComputePASAChecksum(AAccountNumber: Int64): Int64; inline;
  begin
    result := ((AAccountNumber * 101) mod 89) + 10;
  end;

  procedure RaiseError(const AErrorMessage: String); inline;
  begin
    raise EPASCPaymentURIInvalidArgumentException.CreateResFmt(@SInvalidPASA,
      [AErrorMessage]);
  end;

  procedure ValidatePASA(const AAccount: String);
  const
    PASA_DELIMITER = Char('-');
  var
    LTempArray: TPASCPaymentURIGenericArray<String>;
    LAccountNumber, LPASAChecksum: Int64;
    PartZero, PartOne: String;
  begin
    LAccountNumber := -1;
    LPASAChecksum := -1;
    LTempArray := TPASCPaymentURI.TStringUtils.SplitString(AAccount,
      PASA_DELIMITER);

    if (System.Length(LTempArray) <> 2) then
    begin
      RaiseError(Format(SPASAInvalidPartsNumber, [AAccount]));
    end;

    PartZero := LTempArray[0];
    PartOne := LTempArray[1];

    if not TryStrToInt64(PartZero, LAccountNumber) then
    begin
      RaiseError(Format(SAccountNumberNotNumeric, [PartZero]));
    end
    else
    begin
      LPASAChecksum := ComputePASAChecksum(LAccountNumber);
      if (IntToStr(LPASAChecksum) <> PartOne) then
      begin
        RaiseError(Format(SAccountNumberChecksumFailed,
          [LPASAChecksum, LAccountNumber, PartOne]));
      end;
    end;

  end;

begin
  ValidatePASA(AAccount);
  FAccount := AAccount;
  result := Self;
end;

function TPASCPaymentURI.TPASCBuilder.AddAmount(const AAmount: Double)
  : IPASCBuilder;
  procedure RaiseError(const AErrorMessage: String); inline;
  begin
    raise EPASCPaymentURIInvalidArgumentException.CreateResFmt(@SInvalidAmount,
      [AErrorMessage]);
  end;

  procedure ValidateAmount(const AAmount: Double); inline;
  begin
    if Sign(AAmount) = -1 then
    begin
      RaiseError(Format(SAmountNegative, [AAmount]));
    end;
  end;

begin
  ValidateAmount(AAmount);
  FAmount := AAmount;
  result := Self;
end;

function TPASCPaymentURI.TPASCBuilder.AddLabel(const ALabel: String)
  : IPASCBuilder;
begin
  FLabel := ALabel;
  result := Self;
end;

function TPASCPaymentURI.TPASCBuilder.AddMessage(const AMessage: String)
  : IPASCBuilder;
begin
  FMessage := AMessage;
  result := Self;
end;

function TPASCPaymentURI.TPASCBuilder.Build: IPASCPaymentURI;
begin
  if FAccount = '' then
  begin
    raise EPASCPaymentURIInvalidArgumentException.CreateRes(@SPASACompulsory);
  end;
  result := TPASCPaymentURI.Create(Self);
end;

class function TPASCPaymentURI.TPASCBuilder.Builder(): IPASCBuilder;
begin
  result := TPASCPaymentURI.TPASCBuilder.Create();
end;

function TPASCPaymentURI.TPASCBuilder.GetAccount: String;
begin
  result := FAccount;
end;

function TPASCPaymentURI.TPASCBuilder.GetAmount: Double;
begin
  result := FAmount;
end;

function TPASCPaymentURI.TPASCBuilder.GetMessage: String;
begin
  result := FMessage;
end;

{ TPASCPaymentURI }

function TPASCPaymentURI.GetAccount: String;
begin
  result := FAccount;
end;

function TPASCPaymentURI.GetAmount: Double;
begin
  result := FAmount;
end;

function TPASCPaymentURI.GetLabel: String;
begin
  result := FLabel;
end;

function TPASCPaymentURI.GetMessage: String;
begin
  result := FMessage;
end;

constructor TPASCPaymentURI.Create(const APASCBuilder: IPASCBuilder);
begin
  Inherited Create();
  FAccount := APASCBuilder.Account;
  FAmount := APASCBuilder.Amount;
  FLabel := APASCBuilder.&Label;
  FMessage := APASCBuilder.Message;
end;

function TPASCPaymentURI.GetURI(): String;
var
  LQueryParameters, LSuffix: String;
  LEncoding: TEncoding;
begin
  LEncoding := TEncoding.UTF8;
  if not IsZero(FAmount, EPSILON) then
  begin
    LQueryParameters := Format('%s=%0.4f', [PARAMETER_AMOUNT, FAmount]);
  end;

  if FLabel <> '' then
  begin
    if LQueryParameters <> '' then
    begin
      LQueryParameters := Format('%s&%s=%s', [LQueryParameters, PARAMETER_LABEL,
        TRFC3986URITools.Encode(FLabel, LEncoding)]);
    end
    else
    begin
      LQueryParameters := Format('%s=%s',
        [PARAMETER_LABEL, TRFC3986URITools.Encode(FLabel, LEncoding)]);
    end;

  end;

  if FMessage <> '' then
  begin
    if LQueryParameters <> '' then
    begin
      LQueryParameters := Format('%s&%s=%s',
        [LQueryParameters, PARAMETER_MESSAGE, TRFC3986URITools.Encode(FMessage,
        LEncoding)]);
    end
    else
    begin
      LQueryParameters := Format('%s=%s',
        [PARAMETER_MESSAGE, TRFC3986URITools.Encode(FMessage, LEncoding)]);
    end;

  end;

  if LQueryParameters <> '' then
  begin
    LSuffix := Format('?%s', [LQueryParameters]);
  end
  else
  begin
    LSuffix := '';
  end;

  result := Format('%s%s%s', [SCHEME, FAccount, LSuffix]);
end;

class function TPASCPaymentURI.Parse(const AURIString: String): IPASCPaymentURI;
const
  QUESTION_MARK: Char = '?';
  AMPERSAND: Char = '&';
  EQUALS: Char = '=';
var
  LURIString, LPASCPaymentURIWithoutScheme, LQuery: String;
  LPASCPaymentURIElements, LQueryParameter, LQueryParameters
    : TPASCPaymentURIGenericArray<String>;
  LFilteredQueryParameters: TDictionary<String, String>;
  LPASCPaymentURIBuilder: IPASCBuilder;
  LFormatSettings : TFormatSettings;
begin
  // use dot as decimal seperator to ovewrite any comma on user/system/country specific systems.
  LFormatSettings.DecimalSeparator := '.'; // Little addition by Skybuck Flying

  result := Nil;
  try
    LURIString := TPASCPaymentURI.TRFC3986URITools.Decode(AURIString,
      TEncoding.UTF8);
  except
    raise;
  end;

  if LURIString = '' then
  begin
    Exit;
  end;

  if not(TPASCPaymentURI.TStringUtils.BeginsWith(LURIString, SCHEME, True)) then
  begin
    Exit;
  end;

  LPASCPaymentURIWithoutScheme := System.Copy(LURIString,
    System.Length(SCHEME) + 1, System.Length(LURIString) -
    System.Length(SCHEME));

  LPASCPaymentURIElements := TPASCPaymentURI.TStringUtils.SplitString
    (LPASCPaymentURIWithoutScheme, QUESTION_MARK);

  if not(System.Length(LPASCPaymentURIElements) in [1 .. 2]) then
  begin
    Exit;
  end;

  if LPASCPaymentURIElements[0] = '' then
  begin
    Exit;
  end;

  if (System.Length(LPASCPaymentURIElements) = 1) then
  begin
    result := TPASCPaymentURI.TPASCBuilder.Builder()
      .AddAccount(LPASCPaymentURIElements[0]).Build();
    Exit;

  end;

  LQueryParameters := TPASCPaymentURI.TStringUtils.SplitString
    (LPASCPaymentURIElements[1], AMPERSAND);

  if (System.Length(LQueryParameters) = 0) then
  begin
    Exit
  end;

  LFilteredQueryParameters := TDictionary<String, String>.Create();
  try
    for LQuery in LQueryParameters do
    begin
      LQueryParameter := TPASCPaymentURI.TStringUtils.SplitString
        (LQuery, EQUALS);
      if (System.Length(LQueryParameter) = 2) then
      begin
        LFilteredQueryParameters.AddOrSetValue(LQueryParameter[0],
          LQueryParameter[1]);
      end
      else
      begin
        Exit;
      end;

    end;

    LPASCPaymentURIBuilder := TPASCPaymentURI.TPASCBuilder.Builder()
      .AddAccount(LPASCPaymentURIElements[0]);

    if (LFilteredQueryParameters.ContainsKey(PARAMETER_AMOUNT)) then
    begin
      LPASCPaymentURIBuilder.AddAmount
        (StrToFloat(LFilteredQueryParameters[PARAMETER_AMOUNT],LFormatSettings));  // using custom LFormatSettings to avoid using comma as decimal seperator and instead of the dot as seperator

      LFilteredQueryParameters.Remove(PARAMETER_AMOUNT);
    end;

    if (LFilteredQueryParameters.ContainsKey(PARAMETER_LABEL)) then
    begin
      LPASCPaymentURIBuilder.AddLabel(LFilteredQueryParameters
        [PARAMETER_LABEL]);

      LFilteredQueryParameters.Remove(PARAMETER_LABEL);
    end;

    if (LFilteredQueryParameters.ContainsKey(PARAMETER_MESSAGE)) then
    begin
      LPASCPaymentURIBuilder.AddMessage
        (LFilteredQueryParameters[PARAMETER_MESSAGE]);

      LFilteredQueryParameters.Remove(PARAMETER_MESSAGE);
    end;

    result := LPASCPaymentURIBuilder.Build();

  finally
    LFilteredQueryParameters.Free;
  end;

end;

end.
