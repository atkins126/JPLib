﻿unit JPL.IniFile;

{
  Jacek Pazera
  https://www.pazera-software.com
  First version: 06.2015

  TJPIniFile - INI file with comments support

  // Co mnie napadło, żeby to zrobić na Kolekcjach?!!!


  HINTS

  1.
    If you want to perform large number of operations, do it on the TJPIniSection (or TJPIniSectionItems) object, not TJPIniFile.
    It's much faster this way.

    var
      Section: TJPIniSection;
    ...
      Section := Ini.GetSection('SectionName');
      Section.WriteInteger...
      Section.ReadString....

  2.
    The first Section (Index = 0, Name = '') stores the INI file comment(s). It's not a real INI file section!

  3.
    WriteIniComment adds one line to the end of the current INI file comment (Section 0).

  4.
    WriteComment(Section... - adds one line to the Section comment (at the beginning or the end of the given Section).

  5.
    INI_NO_GRAPHICS
    Define this condition if you don't want to use the Graphics unit and its dependencies.
    This can significantly reduce the size of the executable, especially for console applications.



  TODO
  Add support for the Key comment

}

               //{$define INI_NO_GRAPHICS}

{$I .\..\jp.inc}
{$IFDEF FPC}{$MODE DELPHI}{$ENDIF}

interface


uses
  SysUtils, Classes, StrUtils, {$IFNDEF INI_NO_GRAPHICS}Graphics, JPL.Colors,{$ENDIF}
  JPL.Strings, JPL.Conversion;


type

  TJPIniItemType = (iitNormal, iitComment, iitTextLine);
  // iitNormal: TJPIniItem.Value = Key value
  // iitComment: TJPIniItem.Value = comment
  // iitTextLine: TJPIniItem.Value = text line
  TJPIniItemTypeSet = set of TJPIniItemType;


  {$region ' ------------- TJPIniItem - collection item -------------- '}
  TJPIniItem = class(TCollectionItem)
  private
    FItemType: TJPIniItemType;
    FKey: string;
    FValue: string;
    procedure SetItemType(const Value: TJPIniItemType);
    procedure SetKey(const Value: string);
    procedure SetValue(const Value: string);
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function AsString: string;

    property ItemType: TJPIniItemType read FItemType write SetItemType;
    property Key: string read FKey write SetKey;
    property Value: string read FValue write SetValue;
  end;
  {$endregion}

  {$region ' --------------- TJPIniSectionItems - collection ---------------- '}
  TJPIniSectionItems = class(TCollection)
  private
    procedure SetItem(Index: Integer; const Value: TJPIniItem);
  protected
    function GetKeyIndex(Key: string): integer;
    function GetNewSectionCommentItem: TJPIniItem;
  public
    constructor Create({%H-}AItemClass: TCollectionItemClass);
    function GetItem(Index: Integer): TJPIniItem; overload;
    function GetItem(Key: string; CreateIfNotExists: Boolean = True): TJPIniItem; overload;
    function Add: TJPIniItem;
    procedure Delete(Index: Integer);
    function Insert(Index: Integer): TJPIniItem;
    function AsString: string;

    function ReadString(const Key, Default: string): string;
    function ReadInteger(const Key: string; Default: integer): integer;
    function ReadIntegerInRange(const Key: string; const Default, Min, Max: integer): integer;
    function ReadBool(const Key: string; Default: Boolean): Boolean;
    function ReadFloat(const Key: string; Default: Double): Double;
    function ReadDate(const Key: string; Default: TDateTime): TDateTime;
    function ReadDateTime(const Key: string; Default: TDateTime): TDateTime;
    function ReadTime(const Key: string; Default: TDateTime): TDateTime;
    function ReadBinaryStream(const Key: string; Value: TStream): integer;
    {$IFNDEF INI_NO_GRAPHICS}
    function ReadColor(const Key: string; Default: TColor): TColor;
    function ReadHtmlColor(const Key: string; const Default: TColor): TColor;
    function ReadFontStyle(const Key: string; Default: TFontStyles): TFontStyles;
    {$ENDIF}

    procedure WriteString(const Key, Value: string);
    procedure WriteInteger(const Key: string; const Value: integer);
    procedure WriteBool(const Key: string; const Value: Boolean);
    procedure WriteFloat(const Key: string; const Value: Double);
    procedure WriteDate(const Key: string; const Value: TDateTime);
    procedure WriteDateTime(const Key: string; const Value: TDateTime);
    procedure WriteTime(const Key: string; const Value: TDateTime);
    procedure WriteBinaryStream(const Key: string; Value: TStream);

    {$IFNDEF INI_NO_GRAPHICS}
    procedure WriteColor(const Key: string; const Value: TColor);
    procedure WriteHtmlColor(const Key: string; const Value: TColor);
    procedure WriteFontStyle(const Key: string; const Value: TFontStyles);
    {$ENDIF}

    procedure WriteComment(const Value: string; bAddToTop: Boolean); overload;
    procedure WriteComment(Strings: TStrings; bAddToTop: Boolean); overload;
    function RemoveSectionComment(bFromTop: Boolean): Boolean;
    procedure WriteTextLine(const Value: string);

    function DeletKey(const Key: string): Boolean;
    function RenameKey(const OldKeyName, NewKeyName: string): Boolean;
    function KeyExists(const Key: string): Boolean;
    procedure RemoveAllComments;

    property Items[Index: Integer]: TJPIniItem read GetItem write SetItem; default;
  end;
  {$endregion}

  {$region ' --------------- TJPIniSection - collection item ---------------- '}
  TJPIniSection = class(TCollectionItem)
  private
    FName: string;
    FSectionItems: TJPIniSectionItems;
    procedure SetName(const Value: string);
    procedure SetSectionItems(const Value: TJPIniSectionItems);
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    function AsString: string;

    function ReadString(const Key, Default: string): string;
    function ReadInteger(const Key: string; Default: integer): integer;
    function ReadIntegerInRange(const Key: string; const Default, Min, Max: integer): integer;
    function ReadBool(const Key: string; Default: Boolean): Boolean;
    function ReadFloat(const Key: string; Default: Double): Double;
    function ReadDate(const Key: string; Default: TDateTime): TDateTime;
    function ReadDateTime(const Key: string; Default: TDateTime): TDateTime;
    function ReadTime(const Key: string; Default: TDateTime): TDateTime;
    function ReadBinaryStream(const Key: string; Value: TStream): integer;
    {$IFNDEF INI_NO_GRAPHICS}
    function ReadColor(const Key: string; Default: TColor): TColor;
    function ReadHtmlColor(const Key: string; const Default: TColor): TColor;
    function ReadFontStyle(const Key: string; Default: TFontStyles): TFontStyles;
    {$ENDIF}

    procedure WriteString(const Key, Value: string);
    procedure WriteInteger(const Key: string; const Value: integer);
    procedure WriteBool(const Key: string; const Value: Boolean);
    procedure WriteFloat(const Key: string; const Value: Double);
    procedure WriteDate(const Key: string; const Value: TDateTime);
    procedure WriteDateTime(const Key: string; const Value: TDateTime);
    procedure WriteTime(const Key: string; const Value: TDateTime);
    procedure WriteBinaryStream(const Key: string; Value: TStream);

    {$IFNDEF INI_NO_GRAPHICS}
    procedure WriteColor(const Key: string; const Value: TColor);
    procedure WriteHtmlColor(const Key: string; const Value: TColor);
    procedure WriteFontStyle(const Key: string; const Value: TFontStyles);
    {$ENDIF}

    procedure WriteComment(const Value: string; bAddToTop: Boolean); overload;
    procedure WriteComment(Strings: TStrings; bAddToTop: Boolean); overload;
    function RemoveSectionComment(bFromTop: Boolean): Boolean;
    procedure WriteTextLine(const Value: string);

    function DeletKey(const Key: string): Boolean;
    function RenameKey(const OldKeyName, NewKeyName: string): Boolean;
    function KeyExists(const Key: string): Boolean;
    procedure RemoveAllComments;

    property SectionItems: TJPIniSectionItems read FSectionItems write SetSectionItems;
    property Name: string read FName write SetName;
  end;
  {$endregion}

  {$region ' --------------- TJPIniSections - collection ---------------- '}
  TJPIniSections = class(TCollection)
  private
    FSectionsSeparator: string;
    function GetItem(Index: Integer): TJPIniSection;
    procedure SetItem(Index: Integer; const Value: TJPIniSection);
    procedure SetSectionsSeparator(const Value: string);
  public
    constructor Create({%H-}AItemClass: TCollectionItemClass);
    function Add: TJPIniSection;
    procedure Delete(Index: Integer);
    function Insert(Index: Integer): TJPIniSection;
    function AsString: string;

    function GetSectionIndex(SectionName: string): integer;
    function GetSection(SectionName: string; CreateIfNotExists: Boolean = True): TJPIniSection;
    function SectionExists(const SectionName: string): Boolean;


    function ReadString(const SectionName, Key, Default: string): string;
    function ReadInteger(const SectionName, Key: string; Default: integer): integer;
    function ReadBool(const SectionName, Key: string; Default: Boolean): Boolean;
    function ReadFloat(const SectionName, Key: string; Default: Double): Double;
    function ReadDate(const SectionName, Key: string; Default: TDateTime): TDateTime;
    function ReadDateTime(const SectionName, Key: string; Default: TDateTime): TDateTime;
    function ReadTime(const SectionName, Key: string; Default: TDateTime): TDateTime;
    function ReadBinaryStream(const SectionName, Key: string; Value: TStream): integer;
    {$IFNDEF INI_NO_GRAPHICS}
    function ReadColor(const SectionName, Key: string; Default: TColor): TColor;
    function ReadFontStyle(const SectionName, Key: string; Default: TFontStyles): TFontStyles;
    {$ENDIF}


    procedure WriteString(const SectionName, Key, Value: string);
    procedure WriteInteger(const SectionName, Key: string; const Value: integer);
    procedure WriteBool(const SectionName, Key: string; const Value: Boolean);
    procedure WriteFloat(const SectionName, Key: string; const Value: Double);
    procedure WriteDate(const SectionName, Key: string; const Value: TDateTime);
    procedure WriteDateTime(const SectionName, Key: string; const Value: TDateTime);
    procedure WriteTime(const SectionName, Key: string; const Value: TDateTime);
    procedure WriteBinaryStream(const SectionName, Key: string; Value: TStream);

    {$IFNDEF INI_NO_GRAPHICS}
    procedure WriteColor(const SectionName, Key: string; const Value: TColor);
    procedure WriteFontStyle(const SectionName, Key: string; const Value: TFontStyles);
    {$ENDIF}

    procedure WriteComment(const SectionName, Value: string; bAddToTop: Boolean); overload;
    procedure WriteComment(const SectionName: string; Strings: TStrings; bAddToTop: Boolean); overload;
    procedure WriteTextLine(const SectionName, Value: string);

    function DeletKey(const SectionName, Key: string): Boolean;
    function RenameKey(const SectionName, OldKeyName, NewKeyName: string): Boolean;
    function KeyExists(const SectionName, Key: string): Boolean;

    property Items[Index: Integer]: TJPIniSection read GetItem write SetItem; default;
    property SectionsSeparator: string read FSectionsSeparator write SetSectionsSeparator;
  end;
  {$endregion}

  {$region ' -------------- TJPIniFile ---------------- '}
  TJPIniFile = class(TObject)
  private
    FFileName: string;
    FSections: TJPIniSections;
    FSectionsSeparator: string;
    FCurrentSection: string;
    FEncoding: TEncoding;
    FUpdateFileOnExit: Boolean;
    FIgnoreExceptionsOnSave: Boolean;
    {$IFDEF HAS_TSTRINGS_WRITEBOM}FWriteBOM: Boolean;{$ENDIF}
    procedure LoadFile;
    procedure ParseText(Source: string);
    procedure SetSectionsSeparator(const Value: string);
    procedure SetCurrentSection(const Value: string);
    procedure SetText(const Value: string);
    function GetText: string;
    procedure SetEncoding(const Value: TEncoding);
    procedure SetUpdateFileOnExit(const Value: Boolean);
    procedure SetIgnoreExceptionsOnSave(const Value: Boolean);
    {$IFDEF HAS_TSTRINGS_WRITEBOM}procedure SetWriteBOM(AValue: Boolean);{$ENDIF}
  public
    constructor Create(const FileName: string); overload;
    constructor Create(const FileName: string; Encoding: TEncoding); overload;
    constructor Create(const FileName: string; Encoding: TEncoding; bIgnoreExceptionsOnSave: Boolean); overload;
    destructor Destroy; override;

    procedure Clear;
    procedure Rename(const FileName: string; Reload: Boolean);
    procedure UpdateFile;
    procedure SaveToFile(const FileName: string);
    function GetSectionItems(const SectionName: string): TJPIniSectionItems; // returns reference to TJPIniSectionItems or nil
    function GetSection(const SectionName: string; CreateIfNotExists: Boolean): TJPIniSection; // returns reference to TJPIniSection or nil
    procedure ClearSection(const SectionName: string); // Clears section, but does not remove
    procedure ClearSectionComments(const SectionName: string); // Removes all comments from the given section
    procedure ClearSectionKeys(const SectionName: string);

    function ReadString(const SectionName, Key, Default: string): string; overload;
    function ReadString(const Key, Default: string): string; overload;
    function ReadInteger(const SectionName, Key: string; Default: integer): integer; overload;
    function ReadInteger(const Key: string; Default: integer): integer; overload;
    function ReadBool(const SectionName, Key: string; Default: Boolean): Boolean; overload;
    function ReadBool(const Key: string; Default: Boolean): Boolean; overload;
    function ReadFloat(const SectionName, Key: string; Default: Double): Double; overload;
    function ReadFloat(const Key: string; Default: Double): Double; overload;
    function ReadDate(const SectionName, Key: string; Default: TDateTime): TDateTime; overload;
    function ReadDate(const Key: string; Default: TDateTime): TDateTime; overload;
    function ReadDateTime(const SectionName, Key: string; Default: TDateTime): TDateTime; overload;
    function ReadDateTime(const Key: string; Default: TDateTime): TDateTime; overload;
    function ReadTime(const SectionName, Key: string; Default: TDateTime): TDateTime; overload;
    function ReadTime(const Key: string; Default: TDateTime): TDateTime; overload;
    function ReadBinaryStream(const SectionName, Key: string; Value: TStream): integer; overload;
    function ReadBinaryStream(const Key: string; Value: TStream): integer; overload;
    {$IFNDEF INI_NO_GRAPHICS}
    function ReadColor(const SectionName, Key: string; Default: TColor): TColor; overload;
    function ReadColor(const Key: string; Default: TColor): TColor; overload;
    function ReadFontStyle(const SectionName, Key: string; Default: TFontStyles): TFontStyles; overload;
    function ReadFontStyle(const Key: string; Default: TFontStyles): TFontStyles; overload;
    {$ENDIF}

    procedure WriteString(const SectionName, Key, Value: string); overload;
    procedure WriteString(const Key, Value: string); overload;
    procedure WriteInteger(const SectionName, Key: string; const Value: integer); overload;
    procedure WriteInteger(const Key: string; const Value: integer); overload;
    procedure WriteBool(const SectionName, Key: string; const Value: Boolean); overload;
    procedure WriteBool(const Key: string; const Value: Boolean); overload;
    procedure WriteFloat(const SectionName, Key: string; const Value: Double); overload;
    procedure WriteFloat(const Key: string; const Value: Double); overload;
    procedure WriteDate(const SectionName, Key: string; const Value: TDateTime); overload;
    procedure WriteDate(const Key: string; const Value: TDateTime); overload;
    procedure WriteDateTime(const SectionName, Key: string; const Value: TDateTime); overload;
    procedure WriteDateTime(const Key: string; const Value: TDateTime); overload;
    procedure WriteTime(const SectionName, Key: string; const Value: TDateTime); overload;
    procedure WriteTime(const Key: string; const Value: TDateTime); overload;
    procedure WriteBinaryStream(const SectionName, Key: string; Value: TStream); overload;
    procedure WriteBinaryStream(const Key: string; Value: TStream); overload;
    {$IFNDEF INI_NO_GRAPHICS}
    procedure WriteColor(const SectionName, Key: string; const Value: TColor); overload;
    procedure WriteColor(const Key: string; const Value: TColor); overload;
    procedure WriteFontStyle(const SectionName, Key: string; const Value: TFontStyles); overload;
    procedure WriteFontStyle(const Key: string; const Value: TFontStyles); overload;
    {$ENDIF}

    // bAddToTop
    //   If True, the comment will be added at the TOP of the Section
    //   If False, the omment will be added at the END of the section
    procedure WriteComment(const SectionName, Value: string; bAddToTop: Boolean); overload;
    procedure WriteComment(const Value: string; bAddToTop: Boolean); overload; // writes comment to the CurrentSection
    procedure WriteComment(const SectionName: string; Strings: TStrings; bAddToTop: Boolean); overload;
    procedure WriteComment(Strings: TStrings; bAddToTop: Boolean); overload;
    function RemoveSectionComment(const SectionName: string; bFromTop: Boolean): Boolean;
    procedure WriteTextLine(const SectionName, Value: string); overload;
    procedure WriteTextLine(const Value: string); overload;


    // INI comment - comment lines before the first section
    procedure ReadIniComment(Strings: TStrings);
    procedure WriteIniComment(Strings: TStrings); overload;
    procedure WriteIniComment(const Value: string); overload;
    procedure ClearIniComment;


    procedure ReadSectionKeys(const SectionName: string; Strings: TStrings); // returns list of keys in given section
    procedure ReadSection(const SectionName: string; Strings: TStrings); // = ReadSectionKeys; Added for combatibility with TIniFile
    procedure ReadSections(Strings: TStrings); // returns list of section names
    procedure ReadSectionValues(const SectionName: string; Strings: TStrings); // returns list key=value
    procedure ReadSectionComments(const SectionName: string; Strings: TStrings);
    procedure EraseSection(const SectionName: string); // Clears and removes section
    function DeleteKey(const SectionName, Key: string): Boolean;
    function RenameKeyKey(const SectionName, OldKeyName, NewKeyName: string): Boolean;
    function KeyExists(const SectionName, Key: string): Boolean;
    function ValueExists(const SectionName, Key: string): Boolean; // = KeyExists; Added for compatibility with TIniFile
    function SectionExists(const SectionName: string): Boolean;
    function AddSection(const SectionName: string): Boolean; // Adds new section. Returns False if section already exists or if SectionName = ''
    function RenameSection(const OldName, NewName: string): Boolean;


    function ItemsCount(const SectionName: string): integer; overload;
    function ItemsCount: integer; overload;
    function HasItems(const SectionName: string): Boolean; overload;
    function HasItems: Boolean; overload;
    function KeysCount(const SectionName: string): integer; overload;
    function KeysCount: integer; overload;
    function HasKeys(const SectionName: string): Boolean; overload;
    function HasKeys: Boolean; overload;
    function CommentsCount(const SectionName: string): integer; overload;
    function CommentsCount: integer; overload;
    function HasComments(const SectionName: string): Boolean; overload;
    function HasComments: Boolean; overload;
    function TextLinesCount(const SectionName: string): integer; overload;
    function TextLinesCount: integer; overload;
    function HasTextLines(const SectionName: string): Boolean; overload;
    function HasTextLines: Boolean; overload;

    property FileName: string read FFileName;
    property Sections: TJPIniSections read FSections;
    property SectionsSeparator: string read FSectionsSeparator write SetSectionsSeparator; //Sections separator within INI file. Default blank line (#13#10)
    property CurrentSection: string read FCurrentSection write SetCurrentSection; // Used in Read/Write routines without SectionName
    property Text: string read GetText write SetText; // Reads/sets INI source
    property Encoding: TEncoding read FEncoding write SetEncoding;
    property UpdateFileOnExit: Boolean read FUpdateFileOnExit write SetUpdateFileOnExit; // if True, FileName will be saved on Destroy. Default True
    property IgnoreExceptionsOnSave: Boolean read FIgnoreExceptionsOnSave write SetIgnoreExceptionsOnSave;
    {$IFDEF HAS_TSTRINGS_WRITEBOM}
    property WriteBOM: Boolean read FWriteBOM write SetWriteBOM;
    {$ENDIF}
  end;
  {$endregion TJPIniFile}




{$IFNDEF INI_NO_GRAPHICS}
function FontStylesToStr(FontStyles: TFontStyles): string;
function StrToFontStyles(s: string): TFontStyles;
{$ENDIF}


implementation

{$region ' ------- helpers ---------- '}
{$IFNDEF INI_NO_GRAPHICS}
function FontStylesToStr(FontStyles: TFontStyles): string;
var
  s: string;
begin
  s := '';
  if fsBold in FontStyles then s := 'Bold';
  if fsItalic in FontStyles then s := s + ',Italic';
  if fsUnderline in FontStyles then s := s + ',Underline';
  if fsStrikeOut in FontStyles then s := s + ',StrikeOut';
  s := TrimFromStart(s, ',');
  Result := s;
end;

function StrToFontStyles(s: string): TFontStyles;
begin
  Result := [];
  s := UpperCase(s);
  if Pos('BOLD', s) > 0 then Result := Result + [fsBold];
  if Pos('ITALIC', s) > 0 then Result := Result + [fsItalic];
  if Pos('UNDERLINE', s) > 0 then Result := Result + [fsUnderline];
  if Pos('STRIKEOUT', s) > 0 then Result := Result + [fsStrikeOut];
end;
{$ENDIF}
{$endregion helpers}


{$region ' ------------------------------------ TJPIniFile ---------------------------------------- '}

constructor TJPIniFile.Create(const FileName: string; Encoding: TEncoding; bIgnoreExceptionsOnSave: Boolean);
begin
  inherited Create;
  FEncoding := Encoding;
  {$IFDEF HAS_TSTRINGS_WRITEBOM}FWriteBOM := True;{$ENDIF}
  FFileName := FileName;
  FSectionsSeparator := ENDL; //#13#10
  FSections := TJPIniSections.Create(TJPIniSection);
  FSections.SectionsSeparator := FSectionsSeparator;
  FUpdateFileOnExit := True;
  FIgnoreExceptionsOnSave := bIgnoreExceptionsOnSave;
  LoadFile;
end;

constructor TJPIniFile.Create(const FileName: string);
begin
  Create(FileName, nil, False);
end;

constructor TJPIniFile.Create(const FileName: string; Encoding: TEncoding);
begin
  Create(FileName, Encoding, False);
end;





destructor TJPIniFile.Destroy;
begin
  //FSections.Clear;
  if FUpdateFileOnExit then UpdateFile;
  if Assigned(FSections) then FSections.Free;
  inherited;
end;

procedure TJPIniFile.Clear;
begin
  if Assigned(FSections) then FSections.Clear;
end;

  {$region ' ------- TJPIniFile.LoadFile & ParseText -------- '}
procedure TJPIniFile.LoadFile;
var
  sl: TStringList;
begin
  Clear;
  if not FileExists(FFileName) then Exit;

  sl := TStringList.Create;
  try
    {$IFDEF DCC}sl.LoadFromFile(FFileName, FEncoding);{$ENDIF}
    {$IFDEF FPC}
      {$IFDEF HAS_INIFILE_WITH_ENCODING}sl.LoadFromFile(FFileName, FEncoding);{$ELSE}sl.LoadFromFile(FFileName); {$ENDIF}
    {$ENDIF}
    ParseText(sl.Text);
  finally
    sl.Free;
  end;
end;


procedure TJPIniFile.ParseText(Source: string);
var
  sl: TStringList;
  i, x: integer;
  Line: string;
  Section: TJPIniSection;
  IniItem: TJPIniItem;
begin
  Clear;

  sl := TStringList.Create;
  try
    sl.Text := Source;

    Section := Sections.Add;
    Section.Name := '';

    for i := 0 to sl.Count - 1 do
    begin

      Line := Trim(sl[i]);
      if Line = '' then Continue;

      // ------------ section -----------------
      if IsBoundedWith(Line, '[', ']') then
      begin
        Section := Sections.Add;
        Section.Name := Trim(TrimBounds(Line, '[', ']'));
      end

      // ---------- comment --------------
      else if Line[1] = ';' then
      begin
        IniItem := Section.SectionItems.Add;
        IniItem.ItemType := iitComment;
        IniItem.Value := Copy(Line, 2, Length(Line) - 1);
      end

      else

      begin
        IniItem := Section.SectionItems.Add;
        x := Pos('=', Line);
        // -------------- key=value ---------------
        if x > 0 then
        begin
          IniItem.ItemType := iitNormal;
          IniItem.Key := Copy(Line, 1, x - 1);
          IniItem.Value := Copy(Line, x + 1, Length(Line));
        end
        else
        // ------------- text line --------------
        begin
          IniItem.ItemType := iitTextLine;
          IniItem.Value := Line;
        end;
      end;

    end;

  finally
    sl.Free;
  end;
end;

  {$endregion}


procedure TJPIniFile.ClearIniComment;
begin
  ClearSection('');
end;

procedure TJPIniFile.ClearSection(const SectionName: string);
var
  Section: TJPIniSection;
begin
  Section := GetSection(SectionName, False);
  if Section <> nil then Section.SectionItems.Clear;
end;

procedure TJPIniFile.ClearSectionComments(const SectionName: string);
var
  Items: TJPIniSectionItems;
begin
  Items := GetSectionItems(SectionName);
  if Items = nil then Exit;
  Items.RemoveAllComments;
end;

procedure TJPIniFile.ClearSectionKeys(const SectionName: string);
var
  Items: TJPIniSectionItems;
  i: integer;
begin
  Items := GetSectionItems(SectionName);
  if Items = nil then Exit;
  for i := Items.Count - 1 downto 0 do
    if Items[i].ItemType = iitNormal then Items.Delete(i);
end;

function TJPIniFile.CommentsCount: integer;
begin
  Result := CommentsCount(FCurrentSection);
end;

function TJPIniFile.CommentsCount(const SectionName: string): integer;
var
  Items: TJPIniSectionItems;
  i: integer;
begin
  Result := 0;
  //if SectionName.Trim = '' then Exit;
  if Trim(SectionName) = '' then Exit;
  Items := GetSectionItems(SectionName);
  if Items = nil then Exit;
  for i := 0 to Items.Count - 1 do
    if Items[i].ItemType = iitComment then Inc(Result);
end;

function TJPIniFile.DeleteKey(const SectionName, Key: string): Boolean;
begin
  Result := Sections.DeletKey(SectionName, Key);
end;

function TJPIniFile.RenameKeyKey(const SectionName, OldKeyName, NewKeyName: string): Boolean;
begin
  Result := Sections.RenameKey(SectionName, OldKeyName, NewKeyName);
end;

function TJPIniFile.GetSection(const SectionName: string; CreateIfNotExists: Boolean): TJPIniSection;
begin
  Result := Sections.GetSection(SectionName, CreateIfNotExists);
end;

function TJPIniFile.GetSectionItems(const SectionName: string): TJPIniSectionItems;
var
  Section: TJPIniSection;
begin
  Section := GetSection(SectionName, False);
  if Section <> nil then Result := Section.SectionItems
  else Result := nil;
end;

function TJPIniFile.GetText: string;
begin
  if Assigned(FSections) then Result := FSections.AsString
  else Result := '';
end;

function TJPIniFile.HasComments(const SectionName: string): Boolean;
var
  Items: TJPIniSectionItems;
  i: integer;
begin
  Result := False;
  //if SectionName.Trim = '' then Exit;
  if Trim(SectionName) = '' then Exit;
  Items := GetSectionItems(SectionName);
  if Items = nil then Exit;
  for i := 0 to Items.Count - 1 do
    if Items[i].ItemType = iitComment then
    begin
      Result := True;
      Break;
    end;
end;

function TJPIniFile.HasComments: Boolean;
begin
  Result := HasComments(FCurrentSection);
end;

function TJPIniFile.HasItems(const SectionName: string): Boolean;
begin
  Result := ItemsCount(SectionName) > 0;
end;

function TJPIniFile.HasItems: Boolean;
begin
  Result := HasItems(FCurrentSection);
end;

function TJPIniFile.HasKeys: Boolean;
begin
  Result := HasKeys(FCurrentSection);
end;

function TJPIniFile.HasTextLines: Boolean;
begin
  Result := HasTextLines(FCurrentSection);
end;

function TJPIniFile.HasTextLines(const SectionName: string): Boolean;
var
  Items: TJPIniSectionItems;
  i: integer;
begin
  Result := False;
  //if SectionName.Trim = '' then Exit;
  if Trim(SectionName) = '' then Exit;
  Items := GetSectionItems(SectionName);
  if Items = nil then Exit;
  for i := 0 to Items.Count - 1 do
    if Items[i].ItemType = iitTextLine then
    begin
      Result := True;
      Break;
    end;
end;

function TJPIniFile.HasKeys(const SectionName: string): Boolean;
var
  Items: TJPIniSectionItems;
  i: integer;
begin
  Result := False;
  //if SectionName.Trim = '' then Exit;
  if Trim(SectionName) = '' then Exit;
  Items := GetSectionItems(SectionName);
  if Items = nil then Exit;
  for i := 0 to Items.Count - 1 do
    if Items[i].ItemType = iitNormal then
    begin
      Result := True;
      Break;
    end;
end;

function TJPIniFile.ItemsCount: integer;
begin
  Result := ItemsCount(FCurrentSection);
end;

function TJPIniFile.ItemsCount(const SectionName: string): integer;
var
  Section: TJPIniSection;
begin
  Result := 0;
  //if SectionName.Trim = '' then Exit;
  if Trim(SectionName) = '' then Exit;
  Section := GetSection(SectionName, False);
  if Section <> nil then Result := Section.SectionItems.Count;
end;

procedure TJPIniFile.Rename(const FileName: string; Reload: Boolean);
begin
  FFileName := FileName;
  if Reload then LoadFile;
end;

function TJPIniFile.RenameSection(const OldName, NewName: string): Boolean;
var
  Section: TJPIniSection;
begin
  Result := False;

  //if (OldName.Trim = '') or (NewName.Trim = '') then Exit;
  if (Trim(OldName) = '') or (Trim(NewName) = '') then Exit;
  if SectionExists(NewName) then Exit;

  Section := GetSection(OldName, False);
  if Section = nil then Exit;

  //Section.Name := NewName.Trim;
  Section.Name := Trim(NewName);
  Result := True;

end;

procedure TJPIniFile.EraseSection(const SectionName: string);
var
  x: integer;
begin
  x := Sections.GetSectionIndex(SectionName);
  if x >= 0 then Sections.Delete(x);
end;

function TJPIniFile.KeyExists(const SectionName, Key: string): Boolean;
begin
  Result := Sections.KeyExists(SectionName, Key);
end;

function TJPIniFile.KeysCount: integer;
begin
  Result := KeysCount(FCurrentSection);
end;

function TJPIniFile.KeysCount(const SectionName: string): integer;
var
  Items: TJPIniSectionItems;
  i: integer;
begin
  Result := 0;
  //if SectionName.Trim = '' then Exit;
  if Trim(SectionName) = '' then Exit;
  Items := GetSectionItems(SectionName);
  if Items = nil then Exit;
  for i := 0 to Items.Count - 1 do
    if Items[i].ItemType = iitNormal then Inc(Result);
end;

function TJPIniFile.AddSection(const SectionName: string): Boolean;
begin
  //if (SectionExists(SectionName)) or (SectionName.Trim = '') then Result := False
  if (SectionExists(SectionName)) or (Trim(SectionName) = '') then Result := False
  else Result := GetSection(SectionName, True) <> nil;
end;

function TJPIniFile.SectionExists(const SectionName: string): Boolean;
begin
  Result := Sections.SectionExists(SectionName);
end;

procedure TJPIniFile.SetCurrentSection(const Value: string);
begin
  FCurrentSection := Value;
end;

procedure TJPIniFile.SetEncoding(const Value: TEncoding);
begin
  FEncoding := Value;
end;

procedure TJPIniFile.SetIgnoreExceptionsOnSave(const Value: Boolean);
begin
  FIgnoreExceptionsOnSave := Value;
end;

{$IFDEF HAS_TSTRINGS_WRITEBOM}
procedure TJPIniFile.SetWriteBOM(AValue: Boolean);
begin
  FWriteBOM := AValue;
end;
{$ENDIF}

procedure TJPIniFile.SetSectionsSeparator(const Value: string);
begin
  FSectionsSeparator := Value;
end;

procedure TJPIniFile.SetText(const Value: string);
begin
  ParseText(Value);
end;

procedure TJPIniFile.SetUpdateFileOnExit(const Value: Boolean);
begin
  FUpdateFileOnExit := Value;
end;

function TJPIniFile.TextLinesCount: integer;
begin
  Result := TextLinesCount(FCurrentSection);
end;

function TJPIniFile.TextLinesCount(const SectionName: string): integer;
var
  Items: TJPIniSectionItems;
  i: integer;
begin
  Result := 0;
  //if SectionName.Trim = '' then Exit;
  if Trim(SectionName) = '' then Exit;
  Items := GetSectionItems(SectionName);
  if Items = nil then Exit;
  for i := 0 to Items.Count - 1 do
    if Items[i].ItemType = iitTextLine then Inc(Result);
end;

procedure TJPIniFile.SaveToFile(const FileName: string);
var
  sl: TStringList;
begin
  //if FileName.Trim = '' then Exit; //raise Exception.Create('File name can not be blank!');
  if Trim(FileName) = '' then Exit;
  sl := TStringList.Create;
  try
    {$IFDEF HAS_TSTRINGS_WRITEBOM}sl.WriteBOM := FWriteBOM;{$ENDIF}

    {$IFDEF DCC}
    sl.Text := Text;
    if FIgnoreExceptionsOnSave then
      try
        sl.SaveToFile(FileName, FEncoding);
      except
      end
    else sl.SaveToFile(FileName, FEncoding);
    {$ELSE}
    sl.Text := Text;
    if FIgnoreExceptionsOnSave then
      try
        {$IFDEF HAS_INIFILE_WITH_ENCODING}sl.SaveToFile(FileName, FEncoding);{$ELSE}sl.SaveToFile(FileName);{$ENDIF}
      except
      end
    else {$IFDEF HAS_INIFILE_WITH_ENCODING}sl.SaveToFile(FileName, FEncoding);{$ELSE}sl.SaveToFile(FileName);{$ENDIF}
    {$ENDIF}

  finally
    sl.Free;
  end;
end;

procedure TJPIniFile.UpdateFile;
begin
  SaveToFile(FFileName);
end;

function TJPIniFile.ValueExists(const SectionName, Key: string): Boolean;
begin
  Result := KeyExists(SectionName, Key);
end;

  {$region ' --------- Read XXX --------- '}
function TJPIniFile.ReadBinaryStream(const SectionName, Key: string; Value: TStream): integer;
begin
  Result := Sections.ReadBinaryStream(SectionName, Key, Value);
end;

function TJPIniFile.ReadBinaryStream(const Key: string; Value: TStream): integer;
begin
  Result := ReadBinaryStream(FCurrentSection, Key, Value);
end;

function TJPIniFile.ReadBool(const Key: string; Default: Boolean): Boolean;
begin
  Result := ReadBool(FCurrentSection, Key, Default);
end;

function TJPIniFile.ReadBool(const SectionName, Key: string; Default: Boolean): Boolean;
begin
  Result := Sections.ReadBool(SectionName, Key, Default);
end;

{$IFNDEF INI_NO_GRAPHICS}
function TJPIniFile.ReadColor(const Key: string; Default: TColor): TColor;
begin
  Result := ReadColor(FCurrentSection, Key, Default);
end;

function TJPIniFile.ReadColor(const SectionName, Key: string; Default: TColor): TColor;
begin
  Result := Sections.ReadColor(SectionName, Key, Default);
end;
{$ENDIF}

function TJPIniFile.ReadDate(const SectionName, Key: string; Default: TDateTime): TDateTime;
begin
  Result := Sections.ReadDate(SectionName, Key, Default);
end;

function TJPIniFile.ReadDate(const Key: string; Default: TDateTime): TDateTime;
begin
  Result := ReadDate(FCurrentSection, Key, Default);
end;

function TJPIniFile.ReadDateTime(const Key: string; Default: TDateTime): TDateTime;
begin
  Result := ReadDateTime(FCurrentSection, Key, Default);
end;

function TJPIniFile.ReadDateTime(const SectionName, Key: string; Default: TDateTime): TDateTime;
begin
  Result := Sections.ReadDateTime(SectionName, Key, Default);
end;

function TJPIniFile.ReadFloat(const SectionName, Key: string; Default: Double): Double;
begin
  Result := Sections.ReadFloat(SectionName, Key, Default);
end;

function TJPIniFile.ReadFloat(const Key: string; Default: Double): Double;
begin
  Result := ReadFloat(FCurrentSection, Key, Default);
end;

{$IFNDEF INI_NO_GRAPHICS}
function TJPIniFile.ReadFontStyle(const Key: string; Default: TFontStyles): TFontStyles;
begin
  Result := ReadFontStyle(FCurrentSection, Key, Default);
end;

function TJPIniFile.ReadFontStyle(const SectionName, Key: string; Default: TFontStyles): TFontStyles;
begin
  Result := Sections.ReadFontStyle(SectionName, Key, Default);
end;
{$ENDIF}

procedure TJPIniFile.ReadIniComment(Strings: TStrings);
var
  i: integer;
  Items: TJPIniSectionItems;
begin
  Strings.Clear;
  Items := GetSectionItems('');
  if Items = nil then Exit;
  for i := 0 to Items.Count - 1 do
    if Items[i].ItemType = iitComment then Strings.Add(Items[i].Value);
end;

function TJPIniFile.ReadInteger(const Key: string; Default: integer): integer;
begin
  Result := ReadInteger(FCurrentSection, Key, Default);
end;

function TJPIniFile.ReadInteger(const SectionName, Key: string; Default: integer): integer;
begin
  Result := Sections.ReadInteger(SectionName, Key, Default);
end;

function TJPIniFile.ReadString(const SectionName, Key, Default: string): string;
begin
  Result := Sections.ReadString(SectionName, Key, Default);
end;

function TJPIniFile.ReadTime(const SectionName, Key: string; Default: TDateTime): TDateTime;
begin
  Result := Sections.ReadTime(SectionName, Key, Default);
end;

procedure TJPIniFile.ReadSection(const SectionName: string; Strings: TStrings);
begin
  ReadSectionKeys(SectionName, Strings);
end;

procedure TJPIniFile.ReadSectionComments(const SectionName: string; Strings: TStrings);
var
  Items: TJPIniSectionItems;
  i: integer;
begin
  Strings.Clear;
  Items := GetSectionItems(SectionName);
  if Items = nil then Exit;
  for i := 0 to Items.Count - 1 do
    if Items[i].ItemType = iitComment then Strings.Add(Items[i].Value);
end;

procedure TJPIniFile.ReadSectionKeys(const SectionName: string; Strings: TStrings);
var
  Section: TJPIniSection;
  IniItem: TJPIniItem;
  i: integer;
begin
  Strings.Clear;
  Section := Sections.GetSection(SectionName, False);
  if Section = nil then Exit;
  for i := 0 to Section.SectionItems.Count - 1 do
  begin
    IniItem := Section.SectionItems[i];
    if IniItem.ItemType = iitNormal then Strings.Add(IniItem.Key);
  end;
end;


procedure TJPIniFile.ReadSections(Strings: TStrings);
var
  i: integer;
begin
  Strings.Clear;
  for i := 0 to Sections.Count - 1 do
    if Sections[i].Name <> '' then Strings.Add(Sections[i].Name);
end;

procedure TJPIniFile.ReadSectionValues(const SectionName: string; Strings: TStrings);
var
  Section: TJPIniSection;
  IniItem: TJPIniItem;
  i: integer;
begin
  Strings.Clear;
  Section := Sections.GetSection(SectionName, False);
  if Section = nil then Exit;
  for i := 0 to Section.SectionItems.Count - 1 do
  begin
    IniItem := Section.SectionItems[i];
    if IniItem.ItemType = iitNormal then Strings.Add(IniItem.Key + '=' + IniItem.Value);
  end;
end;

function TJPIniFile.ReadString(const Key, Default: string): string;
begin
  Result := ReadString(FCurrentSection, Key, Default);
end;

function TJPIniFile.ReadTime(const Key: string; Default: TDateTime): TDateTime;
begin
  Result := ReadTime(FCurrentSection, Key, Default);
end;

{$endregion}


  {$region ' ---------- Write XXX ----------- '}
procedure TJPIniFile.WriteBinaryStream(const SectionName, Key: string; Value: TStream);
begin
  Sections.WriteBinaryStream(SectionName, Key, Value);
  FCurrentSection := SectionName;
end;

procedure TJPIniFile.WriteBinaryStream(const Key: string; Value: TStream);
begin
  WriteBinaryStream(FCurrentSection, Key, Value);
end;

procedure TJPIniFile.WriteBool(const Key: string; const Value: Boolean);
begin
  WriteBool(FCurrentSection, Key, Value);
end;

procedure TJPIniFile.WriteBool(const SectionName, Key: string; const Value: Boolean);
begin
  Sections.WriteBool(SectionName, Key, Value);
  FCurrentSection := SectionName;
end;

{$IFNDEF INI_NO_GRAPHICS}
procedure TJPIniFile.WriteColor(const SectionName, Key: string; const Value: TColor);
begin
  Sections.WriteColor(SectionName, Key, Value);
  FCurrentSection := SectionName;
end;

procedure TJPIniFile.WriteColor(const Key: string; const Value: TColor);
begin
  WriteColor(FCurrentSection, Key, Value);
end;
{$ENDIF}

procedure TJPIniFile.WriteComment(const SectionName: string; Strings: TStrings; bAddToTop: Boolean);
begin
  Sections.WriteComment(SectionName, Strings, bAddToTop);
  FCurrentSection := SectionName;
end;

procedure TJPIniFile.WriteComment(Strings: TStrings; bAddToTop: Boolean);
begin
  WriteComment(FCurrentSection, Strings, bAddToTop);
end;

function TJPIniFile.RemoveSectionComment(const SectionName: string; bFromTop: Boolean): Boolean;
var
  Section: TJPIniSection;
begin
  Result := False;
  Section := GetSection(SectionName, False);
  if not Assigned(Section) then Exit;
  Result := Section.RemoveSectionComment(bFromTop);
end;

procedure TJPIniFile.WriteComment(const Value: string; bAddToTop: Boolean);
begin
  WriteComment(FCurrentSection, Value, bAddToTop);
end;

procedure TJPIniFile.WriteComment(const SectionName, Value: string; bAddToTop: Boolean);
begin
  Sections.WriteComment(SectionName, Value, bAddToTop);
  FCurrentSection := SectionName;
end;

procedure TJPIniFile.WriteDate(const SectionName, Key: string; const Value: TDateTime);
begin
  Sections.WriteDate(SectionName, Key, Value);
  FCurrentSection := SectionName;
end;

procedure TJPIniFile.WriteDate(const Key: string; const Value: TDateTime);
begin
  WriteDate(FCurrentSection, Key, Value);
end;

procedure TJPIniFile.WriteDateTime(const Key: string; const Value: TDateTime);
begin
  WriteDateTime(FCurrentSection, Key, Value);
end;

procedure TJPIniFile.WriteDateTime(const SectionName, Key: string; const Value: TDateTime);
begin
  Sections.WriteDateTime(SectionName, Key, Value);
  FCurrentSection := SectionName;
end;

procedure TJPIniFile.WriteFloat(const SectionName, Key: string; const Value: Double);
begin
  Sections.WriteFloat(SectionName, Key, Value);
  FCurrentSection := SectionName;
end;

procedure TJPIniFile.WriteFloat(const Key: string; const Value: Double);
begin
  WriteFloat(FCurrentSection, Key, Value);
end;

{$IFNDEF INI_NO_GRAPHICS}
procedure TJPIniFile.WriteFontStyle(const Key: string; const Value: TFontStyles);
begin
  WriteFontStyle(FCurrentSection, Key, Value);
end;

procedure TJPIniFile.WriteFontStyle(const SectionName, Key: string; const Value: TFontStyles);
begin
  Sections.WriteFontStyle(SectionName, Key, Value);
  FCurrentSection := SectionName;
end;
{$ENDIF}

procedure TJPIniFile.WriteIniComment(Strings: TStrings);
begin
  WriteComment('', Strings, True);
end;

procedure TJPIniFile.WriteIniComment(const Value: string);
begin
  WriteComment('', Value, True);
end;

procedure TJPIniFile.WriteInteger(const Key: string; const Value: integer);
begin
  WriteInteger(FCurrentSection, Key, Value);
end;

procedure TJPIniFile.WriteInteger(const SectionName, Key: string; const Value: integer);
begin
  Sections.WriteInteger(SectionName, Key, Value);
  FCurrentSection := SectionName;
end;

procedure TJPIniFile.WriteString(const Key, Value: string);
begin
  WriteString(FCurrentSection, Key, Value);
end;

procedure TJPIniFile.WriteTextLine(const SectionName, Value: string);
begin
  Sections.WriteTextLine(SectionName, Value);
  FCurrentSection := SectionName;
end;

procedure TJPIniFile.WriteTextLine(const Value: string);
begin
  WriteTextLine(FCurrentSection, Value);
end;

procedure TJPIniFile.WriteTime(const Key: string; const Value: TDateTime);
begin
  WriteTime(FCurrentSection, Key, Value);
end;

procedure TJPIniFile.WriteString(const SectionName, Key, Value: string);
begin
  Sections.WriteString(SectionName, Key, Value);
  FCurrentSection := SectionName;
end;

procedure TJPIniFile.WriteTime(const SectionName, Key: string; const Value: TDateTime);
begin
  Sections.WriteTime(SectionName, Key, Value);
  FCurrentSection := SectionName;
end;
  {$endregion}

{$endregion TJPIniFile}


{$region ' ------------------------------ TJPIniItem - collection item ---------------------------------- '}

constructor TJPIniItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FKey := '';
  FValue := '';
  FItemType := iitNormal;
end;

destructor TJPIniItem.Destroy;
begin
  inherited;
end;

procedure TJPIniItem.Assign(Source: TPersistent);
begin
  if Source is TJPIniItem then
  begin
    FItemType := TJPIniItem(Source).ItemType;
    FKey := TJPIniItem(Source).Key;
    FValue := TJPIniItem(Source).Value;
  end
  else inherited;
end;

function TJPIniItem.AsString: string;
begin
  if FItemType = iitNormal then Result := FKey + '=' + FValue
  else if FItemType = iitComment then Result := ';' + FValue
  else Result := FValue;
end;

procedure TJPIniItem.SetItemType(const Value: TJPIniItemType);
begin
  FItemType := Value;
end;

procedure TJPIniItem.SetKey(const Value: string);
begin
  FKey := Value;
end;

procedure TJPIniItem.SetValue(const Value: string);
begin
  FValue := Value;
end;

{$endregion TJPIniItem}


{$region ' ---------------------------------- TJPIniSectionItems - collection ----------------------------------------- '}

function TJPIniSectionItems.Add: TJPIniItem;
begin
  Result := TJPIniItem(inherited Add);
end;

function TJPIniSectionItems.Insert(Index: Integer): TJPIniItem;
begin
  Result := TJPIniItem(inherited Insert(Index));
end;

function TJPIniSectionItems.KeyExists(const Key: string): Boolean;
begin
  Result := GetKeyIndex(Key) >= 0;
end;

procedure TJPIniSectionItems.RemoveAllComments;
var
  i: integer;
begin
  for i := Count - 1 downto 0 do
    if Items[i].ItemType = iitComment then Delete(i);
end;

function TJPIniSectionItems.AsString: string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to Count - 1 do
    Result := Result + Items[i].AsString + #13#10;
end;

constructor TJPIniSectionItems.Create(AItemClass: TCollectionItemClass);
begin
  inherited Create(TJPIniItem);
end;

procedure TJPIniSectionItems.Delete(Index: Integer);
begin
  inherited Delete(Index);
end;

function TJPIniSectionItems.DeletKey(const Key: string): Boolean;
var
  x: integer;
begin
  Result := False;
  x := GetKeyIndex(Key);
  if x >= 0 then
  begin
    Delete(x);
    Result := True;
  end;
end;

function TJPIniSectionItems.RenameKey(const OldKeyName, NewKeyName: string): Boolean;
var
  Item: TJPIniItem;
begin
  Result := False;
  if not KeyExists(OldKeyName) then Exit;
  if KeyExists(NewKeyName) then Exit;
  Item := GetItem(OldKeyName, False);
  if not Assigned(Item) then Exit;
  Item.Key := NewKeyName;
  Result := True;
end;

function TJPIniSectionItems.GetItem(Index: Integer): TJPIniItem;
begin
  Result := TJPIniItem(inherited GetItem(Index));
end;

function TJPIniSectionItems.GetItem(Key: string; CreateIfNotExists: Boolean): TJPIniItem;
var
  Index: integer;
begin
  Index := GetKeyIndex(Key);
  if Index >= 0 then Result := Items[Index]
  else
    if CreateIfNotExists then Result := Add
    else Result := nil;
end;

function TJPIniSectionItems.GetKeyIndex(Key: string): integer;
var
  i: integer;
begin
  Key := UpperCase(Key);
  Result := -1;
  for i := 0 to Count - 1 do
    if (Items[i].ItemType = iitNormal) and (UpperCase(Items[i].Key) = Key) then
    begin
      Result := i;
      Break;
    end;
end;



procedure TJPIniSectionItems.SetItem(Index: Integer; const Value: TJPIniItem);
begin
  inherited SetItem(Index, Value);
end;

{$IFDEF DCC}
{$IFDEF DELPHIXE3_OR_ABOVE}
function TJPIniSectionItems.ReadBinaryStream(const Key: string; Value: TStream): integer;
var
  Text: string;
  Stream: TMemoryStream;
  Pos: Integer;
  dataLen: Integer;
  DataBytes: TBytes;
begin
  Text := ReadString(Key, '');
  if Text <> '' then
  begin
    if Value is TMemoryStream then Stream := TMemoryStream(Value)
    else Stream := TMemoryStream.Create;

    try
      dataLen := Length(Text) div 2;
      SetLength(DataBytes, dataLen);
      Pos := Stream.Position;
      System.Classes.HexToBin(BytesOf(Text), 0, DataBytes, 0, dataLen);
      Stream.Write(DataBytes[0], dataLen);
      Stream.Position := Pos;
      if Value <> Stream then Value.CopyFrom(Stream, dataLen);
      Result := Stream.Size - Pos;
    finally
      if Value <> Stream then Stream.Free;
    end;
  end
  else
    Result := 0;
end;
{$ELSE}
function TJPIniSectionItems.ReadBinaryStream(const Key: string; Value: TStream): integer;
var
  Text: string;
  Stream: TMemoryStream;
  Pos: Integer;
begin
  Text := ReadString(Key, '');
  if Text <> '' then
  begin
    if Value is TMemoryStream then Stream := TMemoryStream(Value)
    else Stream := TMemoryStream.Create;

    try
      Pos := Stream.Position;
      Stream.SetSize(Stream.Size + Length(Text) div 2);
      Classes.HexToBin(PChar(Text), Pointer(Integer(Stream.Memory) + Stream.Position)^, Length(Text) div 2);
      Stream.Position := Pos;
      if Value <> Stream then Value.CopyFrom(Stream, Length(Text) div 2);
      Result := Stream.Size - Pos;
    finally
      if Value <> Stream then Stream.Free;
    end;
  end
  else
    Result := 0;
end;
{$ENDIF}

{$ENDIF} // DCC

{$IFDEF FPC}
function TJPIniSectionItems.ReadBinaryStream(const Key: string; Value: TStream): integer;
var
  //M: TMemoryStream;
  S: String;
  PB, PR: PByte;
  PC: PChar;
  H : String[3];
  i, {l2,} code : Integer;
begin
  S := ReadString(Key, '');
  Setlength(H, 3);
  H[1] := '$';
  Result := Length(S) div 2;
  if Result > 0 then
  begin
    GetMem(PR, Result);
    try
      PC := PChar(S);
      PB := PR;
      for I := 1 to Result do
      begin
        H[2] := PC[0];
        H[3] := PC[1];
        Val(H, PB^, code);
        Inc(PC, 2);
        Inc(PB);
      end;
      Value.WriteBuffer(PR^, Result);
    finally
      FreeMem(PR);
    end;
  end;
end;
{$ENDIF} // FPC

function TJPIniSectionItems.ReadBool(const Key: string; Default: Boolean): Boolean;
var
  s, sDefault: string;
begin
  if Default then sDefault := '1' else sDefault := '0';
  s := Trim(ReadString(Key, sDefault));
  Result := s = '1';
end;

{$IFNDEF INI_NO_GRAPHICS}
function TJPIniSectionItems.ReadColor(const Key: string; Default: TColor): TColor;
var
  sColor: string;
  xColor: integer;
begin
  sColor := ReadString(Key, ColorToString(Default));
  if not IdentToColor(sColor, xColor) then
  try
    xColor := StringToColor(sColor);
  except
    xColor := Default;
  end;

  Result := xColor;
end;

function TJPIniSectionItems.ReadHtmlColor(const Key: string; const Default: TColor): TColor;
var
  s: string;
begin
  s := ReadString(Key, '');
  if s = '' then Exit(Default);
  if not TryHtmlStrToColor(s, Result) then Result := Default;
end;
{$ENDIF}

function TJPIniSectionItems.ReadDate(const Key: string; Default: TDateTime): TDateTime;
var
  s: string;
begin
  Result := Default;
  s := Trim(ReadString(Key, ''));
  if s = '' then Exit;
  try
    Result := StrToDate(s);
  except
  end;
end;

function TJPIniSectionItems.ReadDateTime(const Key: string; Default: TDateTime): TDateTime;
var
  s: string;
begin
  Result := Default;
  s := Trim(ReadString(Key, ''));
  if s = '' then Exit;
  try
    Result := StrToDateTime(s);
  except
  end;
end;

function TJPIniSectionItems.ReadFloat(const Key: string; Default: Double): Double;
var
  s, sDefault: string;
begin
  Result := Default;
  sDefault := FloatToStr(Default);
  sDefault := StringReplace(sDefault, GetDecimalSeparator, '.', []);
  s := Trim(ReadString(Key, sDefault));
  if s = '' then Exit;
  s := StringReplace(s, '.', GetDecimalSeparator, []);
  try
    Result := StrToFloat(s);
  except
  end;
end;

{$IFNDEF INI_NO_GRAPHICS}
function TJPIniSectionItems.ReadFontStyle(const Key: string; Default: TFontStyles): TFontStyles;
var
  s: string;
begin
  s := FontStylesToStr(Default);
  s := ReadString(Key, s);
  Result := StrToFontStyles(s);
end;
{$ENDIF}

function TJPIniSectionItems.ReadInteger(const Key: string; Default: integer): integer;
var
  s: string;
begin
  s := ReadString(Key, '');
  s := ReplaceFirst(s, '0x', '$', True);
  //if (s.Length > 2) and (s.StartsWith('0x', True)) then s := '$' + s.Substring(2);
  Result := StrToIntDef(s, Default);
end;

function TJPIniSectionItems.ReadIntegerInRange(const Key: string; const Default, Min, Max: integer): integer;
var
  x: integer;
begin
  x := ReadInteger(Key, Default);
  Result := GetIntInRange(x, Min, Max);
end;

function TJPIniSectionItems.ReadString(const Key, Default: string): string;
var
  IniItem: TJPIniItem;
begin
  IniItem := GetItem(Key, False);
  if IniItem <> nil then Result := IniItem.Value
  else Result := Default;
end;


function TJPIniSectionItems.ReadTime(const Key: string; Default: TDateTime): TDateTime;
var
  s: string;
begin
  Result := Default;
  s := Trim(ReadString(Key, ''));
  if s = '' then Exit;
  try
    Result := StrToTime(s);
  except
  end;
end;

  {$region ' ------ Write XXX ------- '}

{$IFDEF DCC}
{$IFDEF DELPHIXE3_OR_ABOVE}
procedure TJPIniSectionItems.WriteBinaryStream(const Key: string; Value: TStream);
var
  Text: string;
  Stream: TMemoryStream;
  Buffer: TBytes;

begin
  SetLength(Text, (Value.Size - Value.Position) * 2);
  if Text.Length > 0 then
  begin
    if Value is TMemoryStream then Stream := TMemoryStream(Value)
    else Stream := TMemoryStream.Create;

    try
      if Stream <> Value then
      begin
        Stream.CopyFrom(Value, Value.Size - Value.Position);
        Stream.Position := 0;
      end;
      SetLength(Buffer, Stream.Size * 2);
      System.Classes.BinToHex(TBytes(Stream.Memory), Stream.Position, Buffer, 0, Stream.Size - Stream.Position);
      Text := StringOf(Buffer);

    finally
      if Value <> Stream then Stream.Free;
    end;
  end;
  WriteString(Key, Text);
end;
{$ELSE}
procedure TJPIniSectionItems.WriteBinaryStream(const Key: string; Value: TStream);
var
  Text: string;
  Stream: TMemoryStream;
begin
  SetLength(Text, (Value.Size - Value.Position) * 2);
  if Length(Text) > 0 then
  begin
    if Value is TMemoryStream then Stream := TMemoryStream(Value)
    else Stream := TMemoryStream.Create;

    try
      if Stream <> Value then
      begin
        Stream.CopyFrom(Value, Value.Size - Value.Position);
        Stream.Position := 0;
      end;
      Classes.BinToHex(Pointer(Integer(Stream.Memory) + Stream.Position)^, PChar(Text),
      Stream.Size - Stream.Position);

    finally
      if Value <> Stream then Stream.Free;
    end;
  end;
  WriteString(Key, Text);
end;
{$ENDIF}
{$ENDIF} // DCC

{$IFDEF FPC}
procedure TJPIniSectionItems.WriteBinaryStream(const Key: string; Value: TStream);
var
  M: TMemoryStream;
  S: String;
  PB: PByte;
  PC: PChar;
  H: String[2];
  i: Integer;

begin
  M := TMemoryStream.Create;
  try
    M.CopyFrom(Value, 0);
    SetLength(S, M.Size * 2);
    if (length(S) > 0) then
    begin
      PB := M.Memory;
      PC := PChar(S);
      for I := 1 to Length(S) div 2 do
        begin
          H := HexStr(PB^, 2);
          PC[0] := H[1];
          PC[1] := H[2];
          Inc(PC, 2);
          Inc(PB);
        end;
    end;
    WriteString(Key, S);
  finally
    M.Free;
  end;
end;
{$ENDIF} // FPC

procedure TJPIniSectionItems.WriteBool(const Key: string; const Value: Boolean);
begin
  if Value then WriteString(Key, '1') else WriteString(Key, '0');
end;

{$IFNDEF INI_NO_GRAPHICS}
procedure TJPIniSectionItems.WriteColor(const Key: string; const Value: TColor);
begin
  WriteString(Key, ColorToString(Value));
end;
{$ENDIF}

function TJPIniSectionItems.GetNewSectionCommentItem: TJPIniItem;
var
  i: integer;
  Item: TJPIniItem;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    Item := Items[i];
    if Item.ItemType = iitNormal then
    begin
      Result := Insert(Item.Index);
      Break;
    end;
  end; // for

  if not Assigned(Result) then Result := Add;
  Result.ItemType := iitComment;
end;

procedure TJPIniSectionItems.WriteComment(Strings: TStrings; bAddToTop: Boolean);
var
  i: integer;
begin
  for i := 0 to Strings.Count - 1 do WriteComment(Strings[i], bAddToTop);
end;

function TJPIniSectionItems.RemoveSectionComment(bFromTop: Boolean): Boolean;
var
  i, x: integer;
begin
  Result := False;
  x := -1;

  // Usuwanie kmentarza z początku sekcji
  if bFromTop then
  begin
    for i := 0 to Count - 1 do
      if Items[i].ItemType = iitNormal then
      begin
        x := i - 1;
        Break;
      end;

    if x < 0 then Exit;

    for i := x downto 0 do
      if Items[i].ItemType = iitComment then
      begin
        Delete(i);
        Result := True;
      end;
  end

  else

  // Usuwanie komentarza na końcu sekcji
  begin
    for i := Count - 1 downto 0 do
      if Items[i].ItemType = iitNormal then
      begin
        x := i + 1;
        Break;
      end;

    if x < 0 then Exit;
    if x = Count - 1 then Exit; //<-- na końcu sekcji brak komentarza

    for i := Count - 1 downto x do
      if Items[i].ItemType = iitComment then
      begin
        Delete(i);
        Result := True;
      end;
  end;
end;

procedure TJPIniSectionItems.WriteComment(const Value: string; bAddToTop: Boolean);
var
  IniItem: TJPIniItem;
begin
  if bAddToTop then IniItem := GetNewSectionCommentItem
  else IniItem := Add;
  IniItem.ItemType := iitComment;
  IniItem.Value := Value;
end;

procedure TJPIniSectionItems.WriteDate(const Key: string; const Value: TDateTime);
begin
  WriteString(Key, DateToStr(Value));
end;

procedure TJPIniSectionItems.WriteDateTime(const Key: string; const Value: TDateTime);
begin
  WriteString(Key, DateTimeToStr(Value));
end;

procedure TJPIniSectionItems.WriteFloat(const Key: string; const Value: Double);
var
  s: string;
begin
  s := FloatToStr(Value);
  s := StringReplace(s, GetDecimalSeparator, '.', []);
  WriteString(Key, s);
end;

{$IFNDEF INI_NO_GRAPHICS}
procedure TJPIniSectionItems.WriteFontStyle(const Key: string; const Value: TFontStyles);
begin
  WriteString(Key, FontStylesToStr(Value));
end;

procedure TJPIniSectionItems.WriteHtmlColor(const Key: string; const Value: TColor);
begin
  WriteString(Key, ColorToHtmlColorStr(Value, '#', True));
end;
{$ENDIF}

procedure TJPIniSectionItems.WriteInteger(const Key: string; const Value: integer);
begin
  WriteString(Key, itos(Value));
end;

procedure TJPIniSectionItems.WriteString(const Key, Value: string);
var
  IniItem: TJPIniItem;
begin
  IniItem := GetItem(Key, True);
  IniItem.ItemType := iitNormal;
  IniItem.Key := Key;
  IniItem.Value := Value;
end;

procedure TJPIniSectionItems.WriteTextLine(const Value: string);
var
  IniItem: TJPIniItem;
begin
  IniItem := Add;
  IniItem.ItemType := iitTextLine;
  IniItem.Value := Value;
end;

procedure TJPIniSectionItems.WriteTime(const Key: string; const Value: TDateTime);
begin
  WriteString(Key, TimeToStr(Value));
end;
  {$endregion}

{$endregion}


{$region ' ----------------------------------- TJPIniSection - collection item ------------------------------- '}

constructor TJPIniSection.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FName := '';
  FSectionItems := TJPIniSectionItems.Create(TJPIniItem);
end;

destructor TJPIniSection.Destroy;
begin
  FSectionItems.Free;
  inherited;
end;

function TJPIniSection.KeyExists(const Key: string): Boolean;
begin
  Result := SectionItems.KeyExists(Key);
end;

procedure TJPIniSection.RemoveAllComments;
begin
  SectionItems.RemoveAllComments;
end;

procedure TJPIniSection.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TJPIniSection.SetSectionItems(const Value: TJPIniSectionItems);
begin
  FSectionItems := Value;
end;

function TJPIniSection.DeletKey(const Key: string): Boolean;
begin
  Result := SectionItems.DeletKey(Key);
end;

function TJPIniSection.RenameKey(const OldKeyName, NewKeyName: string): Boolean;
begin
  Result := SectionItems.RenameKey(OldKeyName, NewKeyName);
end;

function TJPIniSection.AsString: string;
begin
  if FName = '' then Result := SectionItems.AsString
  else Result := '[' + FName + ']' + #13#10 + SectionItems.AsString;
end;

function TJPIniSection.ReadBinaryStream(const Key: string; Value: TStream): integer;
begin
  Result := SectionItems.ReadBinaryStream(Key, Value);
end;

function TJPIniSection.ReadBool(const Key: string; Default: Boolean): Boolean;
begin
  Result := SectionItems.ReadBool(Key, Default);
end;

{$IFNDEF INI_NO_GRAPHICS}
function TJPIniSection.ReadColor(const Key: string; Default: TColor): TColor;
begin
  Result := SectionItems.ReadColor(Key, Default);
end;

function TJPIniSection.ReadHtmlColor(const Key: string; const Default: TColor): TColor;
begin
  Result := SectionItems.ReadHtmlColor(Key, Default);
end;
{$ENDIF}

function TJPIniSection.ReadDate(const Key: string; Default: TDateTime): TDateTime;
begin
  Result := SectionItems.ReadDate(Key, Default);
end;

function TJPIniSection.ReadDateTime(const Key: string; Default: TDateTime): TDateTime;
begin
  Result := SectionItems.ReadDateTime(Key, Default);
end;

function TJPIniSection.ReadFloat(const Key: string; Default: Double): Double;
begin
  Result := SectionItems.ReadFloat(Key, Default);
end;

{$IFNDEF INI_NO_GRAPHICS}
function TJPIniSection.ReadFontStyle(const Key: string; Default: TFontStyles): TFontStyles;
begin
  Result := SectionItems.ReadFontStyle(Key, Default);
end;
{$ENDIF}

function TJPIniSection.ReadInteger(const Key: string; Default: integer): integer;
begin
  Result := SectionItems.ReadInteger(Key, Default);
end;

function TJPIniSection.ReadIntegerInRange(const Key: string; const Default, Min, Max: integer): integer;
begin
  Result := SectionItems.ReadIntegerInRange(Key, Default, Min, Max);
end;

function TJPIniSection.ReadString(const Key, Default: string): string;
begin
  Result := SectionItems.ReadString(Key, Default);
end;

function TJPIniSection.ReadTime(const Key: string; Default: TDateTime): TDateTime;
begin
  Result := SectionItems.ReadTime(Key, Default);
end;


{$region ' -------- Write XXX ------- '}
procedure TJPIniSection.WriteBinaryStream(const Key: string; Value: TStream);
begin
  SectionItems.WriteBinaryStream(Key, Value);
end;

procedure TJPIniSection.WriteBool(const Key: string; const Value: Boolean);
begin
  SectionItems.WriteBool(Key, Value);
end;

{$IFNDEF INI_NO_GRAPHICS}
procedure TJPIniSection.WriteColor(const Key: string; const Value: TColor);
begin
  SectionItems.WriteColor(Key, Value);
end;
{$ENDIF}

procedure TJPIniSection.WriteComment(Strings: TStrings; bAddToTop: Boolean);
begin
  SectionItems.WriteComment(Strings, bAddToTop);
end;

function TJPIniSection.RemoveSectionComment(bFromTop: Boolean): Boolean;
begin
  Result := SectionItems.RemoveSectionComment(bFromTop);
end;

procedure TJPIniSection.WriteComment(const Value: string; bAddToTop: Boolean);
begin
  SectionItems.WriteComment(Value, bAddToTop);
end;

procedure TJPIniSection.WriteDate(const Key: string; const Value: TDateTime);
begin
  SectionItems.WriteDate(Key, Value);
end;

procedure TJPIniSection.WriteDateTime(const Key: string; const Value: TDateTime);
begin
  SectionItems.WriteDateTime(Key, Value);
end;

procedure TJPIniSection.WriteFloat(const Key: string; const Value: Double);
begin
  SectionItems.WriteFloat(Key, Value);
end;

{$IFNDEF INI_NO_GRAPHICS}
procedure TJPIniSection.WriteFontStyle(const Key: string; const Value: TFontStyles);
begin
  SectionItems.WriteFontStyle(Key, Value);
end;

procedure TJPIniSection.WriteHtmlColor(const Key: string; const Value: TColor);
begin
  SectionItems.WriteHtmlColor(Key, Value);
end;
{$ENDIF}

procedure TJPIniSection.WriteInteger(const Key: string; const Value: integer);
begin
  SectionItems.WriteInteger(Key, Value);
end;

procedure TJPIniSection.WriteString(const Key, Value: string);
begin
  SectionItems.WriteString(Key, Value);
end;

procedure TJPIniSection.WriteTextLine(const Value: string);
begin
  SectionItems.WriteTextLine(Value);
end;

procedure TJPIniSection.WriteTime(const Key: string; const Value: TDateTime);
begin
  SectionItems.WriteTime(Key, Value);
end;
  {$endregion}


{$endregion TJPIniSection}


{$region ' ---------------------------------- TJPIniSections - collection ----------------------------------------- '}

function TJPIniSections.Add: TJPIniSection;
begin
  Result := TJPIniSection(inherited Add);
end;

function TJPIniSections.Insert(Index: Integer): TJPIniSection;
begin
  Result := TJPIniSection(inherited Insert(Index));
end;

function TJPIniSections.KeyExists(const SectionName, Key: string): Boolean;
var
  Section: TJPIniSection;
begin
  Result := False;
  Section := GetSection(SectionName, False);
  if Section <> nil then Result := Section.KeyExists(Key);
end;

function TJPIniSections.AsString: string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to Count - 1 do
    Result := Result + Items[i].AsString + SectionsSeparator;
end;

constructor TJPIniSections.Create(AItemClass: TCollectionItemClass);
begin
  inherited Create(TJPIniSection);
end;

procedure TJPIniSections.Delete(Index: Integer);
begin
  inherited Delete(Index);
end;

function TJPIniSections.DeletKey(const SectionName, Key: string): Boolean;
var
  Section: TJPIniSection;
begin
  Result := False;
  Section := GetSection(SectionName, False);
  if Section <> nil then Result := Section.DeletKey(Key);
end;

function TJPIniSections.RenameKey(const SectionName, OldKeyName, NewKeyName: string): Boolean;
var
  Section: TJPIniSection;
begin
  Result := False;
  Section := GetSection(SectionName, False);
  if Section <> nil then Result := Section.RenameKey(OldKeyName, NewKeyName);
end;

function TJPIniSections.GetItem(Index: Integer): TJPIniSection;
begin
  Result := TJPIniSection(inherited GetItem(Index));
end;

function TJPIniSections.GetSection(SectionName: string; CreateIfNotExists: Boolean): TJPIniSection;
var
  Index: integer;
begin
  Index := GetSectionIndex(SectionName);
  if Index >= 0 then Result := Items[Index]
  else
    if CreateIfNotExists then
    begin
      Result := Add;
      Result.Name := SectionName;
    end
    else Result := nil;
end;

function TJPIniSections.GetSectionIndex(SectionName: string): integer;
var
  i: integer;
begin
  Result := -1;
  SectionName := UpperCase(SectionName);
  for i := 0 to Count - 1 do
    if UpperCase(Items[i].Name) = SectionName then
    begin
      Result := i;
      Break;
    end;
end;

function TJPIniSections.SectionExists(const SectionName: string): Boolean;
begin
  Result := GetSectionIndex(SectionName) >= 0;
end;

procedure TJPIniSections.SetItem(Index: Integer; const Value: TJPIniSection);
begin
  inherited SetItem(Index, Value);
end;

procedure TJPIniSections.SetSectionsSeparator(const Value: string);
begin
  FSectionsSeparator := Value;
end;

function TJPIniSections.ReadBinaryStream(const SectionName, Key: string; Value: TStream): integer;
var
  Section: TJPIniSection;
begin
  Section := GetSection(SectionName, False);
  if Section <> nil then Result := Section.ReadBinaryStream(Key, Value)
  else Result := 0;
end;

function TJPIniSections.ReadBool(const SectionName, Key: string; Default: Boolean): Boolean;
var
  Section: TJPIniSection;
begin
  Section := GetSection(SectionName, False);
  if Section <> nil then Result := Section.ReadBool(Key, Default)
  else Result := Default;
end;

{$IFNDEF INI_NO_GRAPHICS}
function TJPIniSections.ReadColor(const SectionName, Key: string; Default: TColor): TColor;
var
  Section: TJPIniSection;
begin
  Section := GetSection(SectionName, False);
  if Section <> nil then Result := Section.ReadColor(Key, Default)
  else Result := Default;
end;
{$ENDIF}

function TJPIniSections.ReadDate(const SectionName, Key: string; Default: TDateTime): TDateTime;
var
  Section: TJPIniSection;
begin
  Section := GetSection(SectionName, False);
  if Section <> nil then Result := Section.ReadDate(Key, Default)
  else Result := Default;
end;

function TJPIniSections.ReadDateTime(const SectionName, Key: string; Default: TDateTime): TDateTime;
var
  Section: TJPIniSection;
begin
  Section := GetSection(SectionName, False);
  if Section <> nil then Result := Section.ReadDateTime(Key, Default)
  else Result := Default;
end;

function TJPIniSections.ReadFloat(const SectionName, Key: string; Default: Double): Double;
var
  Section: TJPIniSection;
begin
  Section := GetSection(SectionName, False);
  if Section <> nil then Result := Section.ReadFloat(Key, Default)
  else Result := Default;
end;

{$IFNDEF INI_NO_GRAPHICS}
function TJPIniSections.ReadFontStyle(const SectionName, Key: string; Default: TFontStyles): TFontStyles;
var
  Section: TJPIniSection;
begin
  Section := GetSection(SectionName, False);
  if Section <> nil then Result := Section.ReadFontStyle(Key, Default)
  else Result := Default;
end;
{$ENDIF}

function TJPIniSections.ReadInteger(const SectionName, Key: string; Default: integer): integer;
var
  Section: TJPIniSection;
begin
  Section := GetSection(SectionName, False);
  if Section <> nil then Result := Section.ReadInteger(Key, Default)
  else Result := Default;
end;

function TJPIniSections.ReadString(const SectionName, Key, Default: string): string;
var
  Section: TJPIniSection;
begin
  Section := GetSection(SectionName, False);
  if Section <> nil then Result := Section.ReadString(Key, Default)
  else Result := Default;
end;

function TJPIniSections.ReadTime(const SectionName, Key: string; Default: TDateTime): TDateTime;
var
  Section: TJPIniSection;
begin
  Section := GetSection(SectionName, False);
  if Section <> nil then Result := Section.ReadTime(Key, Default)
  else Result := Default;
end;

  {$region ' --------- Write XXX ---------- '}
procedure TJPIniSections.WriteBinaryStream(const SectionName, Key: string; Value: TStream);
begin
  GetSection(SectionName, True).WriteBinaryStream(Key, Value);
end;

procedure TJPIniSections.WriteBool(const SectionName, Key: string; const Value: Boolean);
begin
  GetSection(SectionName, True).WriteBool(Key, Value);
end;

{$IFNDEF INI_NO_GRAPHICS}
procedure TJPIniSections.WriteColor(const SectionName, Key: string; const Value: TColor);
begin
  GetSection(SectionName, True).WriteColor(Key, Value);
end;
{$ENDIF}

procedure TJPIniSections.WriteComment(const SectionName: string; Strings: TStrings; bAddToTop: Boolean);
begin
  GetSection(SectionName, True).WriteComment(Strings, bAddToTop);
end;

procedure TJPIniSections.WriteComment(const SectionName, Value: string; bAddToTop: Boolean);
begin
  GetSection(SectionName, True).WriteComment(Value, bAddToTop);
end;

procedure TJPIniSections.WriteDate(const SectionName, Key: string; const Value: TDateTime);
begin
  GetSection(SectionName, True).WriteDate(Key, Value);
end;

procedure TJPIniSections.WriteDateTime(const SectionName, Key: string; const Value: TDateTime);
begin
  GetSection(SectionName, True).WriteDateTime(Key, Value);
end;

procedure TJPIniSections.WriteFloat(const SectionName, Key: string; const Value: Double);
begin
  GetSection(SectionName, True).WriteFloat(Key, Value);
end;

{$IFNDEF INI_NO_GRAPHICS}
procedure TJPIniSections.WriteFontStyle(const SectionName, Key: string; const Value: TFontStyles);
begin
  GetSection(SectionName, True).WriteFontStyle(Key, Value);
end;
{$ENDIF}

procedure TJPIniSections.WriteInteger(const SectionName, Key: string; const Value: integer);
begin
  GetSection(SectionName, True).WriteInteger(Key, Value);
end;

procedure TJPIniSections.WriteString(const SectionName, Key, Value: string);
begin
  GetSection(SectionName, True).WriteString(Key, Value);
end;

procedure TJPIniSections.WriteTextLine(const SectionName, Value: string);
begin
  GetSection(SectionName, True).WriteTextLine(Value);
end;

procedure TJPIniSections.WriteTime(const SectionName, Key: string; const Value: TDateTime);
begin
  GetSection(SectionName, True).WriteTime(Key, Value);
end;
  {$endregion}

{$endregion}




end.
