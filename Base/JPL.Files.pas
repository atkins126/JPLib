﻿unit JPL.Files;

{
  Jacek Pazera
  http://www.pazera-software.com
}

{$IFDEF FPC}
  {$mode objfpc}{$H+}
  {$WARN 5057 off : Local variable "$1" does not seem to be initialized}
{$ENDIF}
interface

uses
  SysUtils, Classes,
  {$IFDEF MSWINDOWS}Windows,{$ENDIF}
  {$IFDEF LINUX}BaseUnix,{$ENDIF}
  //MFPC.Classes.Streams,
  {%H-}JPL.Strings;

type
  TFileInfoRec = record
    FullFileName: string;
    Directory: string;
    // directory + path delimiter
    Path: string;
    ShortFileName: string;
    BaseFileName: string;
    Extension: string;

    StatOK: Boolean;
    DeviceNo: UInt64; // QWord;
    InodeNo: Cardinal;
    FileMode: Cardinal;
    HardLinks: UInt64; // QWord;
    OwnerUserID: Cardinal;
    OwnerGroupID: Cardinal;
    Size: Int64;
    BlockSize: Int64;
    Blocks: Int64;
    CreationTime: TDateTime;
    LastWriteTime: TDateTime;
    LastAccessTime: TDateTime;
    ReadOnly: Boolean;
  end;

procedure ClearFileInfoRec(var fir: TFileInfoRec);
function GetFileInfoRec(const FileName: string; out fir: TFileInfoRec; bOnlyNames: Boolean = False): Boolean;
function FileSizeInt(const FileName: string): int64;
{$IFDEF MSWINDOWS}
function FileGetCreationTime(const FileName: string): TDateTime;
function FileGetTimes(const FileName: string; out CreationTime, LastAccessTime, LastWriteTime: TDateTime): Boolean;
{$ENDIF}

function DelFile(const FileName: string): Boolean;
function GetIncFileName(const fName: string; NumPrefix: string = '_'; xpad: integer = 3): string;
function GetUniqueFileName(Prefix: string = ''; Len: BYTE = 10; Ext: string = ''): string;


implementation



function GetIncFileName(const fName: string; NumPrefix: string = '_'; xpad: integer = 3): string;
var
  i: integer;
  ShortName, Ext, fOut: string;
begin
  Result := '';

  if not FileExists(fName) then
  begin
    Result := fName;
    Exit;
  end;

  Ext := ExtractFileExt(fName);
  ShortName := ChangeFileExt(fName, '');

  for i := 1 to 100000 do
  begin
    fOut := ShortName + NumPrefix + Pad(IntToStr(i), xpad, '0') + Ext;
    if not FileExists(fOut) then
    begin
      Result := fOut;
      Break;
    end;
  end;
end;

function GetUniqueFileName(Prefix: string = ''; Len: BYTE = 10; Ext: string = ''): string;
var
  x: integer;
  bt: BYTE;
  s: string;
begin
  x := 0;
  s := '';
  Randomize;

  while x < Len do
  begin
    bt := Random(254) + 1;
    if not ( (bt in [48..57]) or (x in [65..90]) or (x in [97..122]) ) then Continue;
    Inc(x);
    s := s + Char(bt);
  end;

  s := Prefix + s;
  if (Ext <> '') and (Ext[1] <> '.') then Ext := '.' + Ext;
  Result := ChangeFileExt(s, Ext);
end;

{$HINTS OFF}
function DelFile(const FileName: string): Boolean;
var
  w: WORD;
begin
  Result := True;
  try

    {$IFDEF MSWINDOWS}
    if not SysUtils.DeleteFile(FileName) then
    try
      {$WARNINGS OFF}
      w := 0 and not faReadOnly and not faSysFile and not faHidden;
      FileSetAttr(FileName, w);
      {$WARNINGS ON}
      SysUtils.DeleteFile(FileName);
    except
      Result := not FileExists(FileName);
    end;
    {$ELSE}
    SysUtils.DeleteFile(FileName);
    {$ENDIF}

    Result := not FileExists(FileName);

  except
    Result := not FileExists(FileName);
  end;
end;
{$HINTS ON}


{$IFDEF MSWINDOWS}
// From DSiWin32.pas by Primož Gabrijelčič: https://github.com/gabr42/OmniThreadLibrary/tree/master/src
function DSiFileSize(const fileName: string): int64;
var
  fHandle: THandle;
begin
  fHandle := CreateFile(
    PChar(fileName), 0,
    FILE_SHARE_READ OR FILE_SHARE_WRITE OR FILE_SHARE_DELETE, nil, OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL, 0
  );
  if fHandle = INVALID_HANDLE_VALUE then Result := -1
  else
  try
    Int64Rec(Result).Lo := GetFileSize(fHandle, @Int64Rec(Result).Hi);
  finally
    CloseHandle(fHandle);
  end;
end;
{$ENDIF}

function _FileSizeInt(const FileName: string): int64;
var
  fs: TFileStream;
begin
  Result := 0;
  if not FileExists(FileName) then Exit;

  fs := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    Result := fs.Size;
  finally
    fs.Free;
  end;
end;

function FileSizeInt(const FileName: string): int64;
{$IFNDEF MSWINDOWS}
var
  fir: TFileInfoRec;
{$ENDIF}
begin
  //Result := 0;
  try
    Result := _FileSizeInt(FileName);
  except
    on E: Exception do
    try
      {$IFDEF MSWINDOWS}
      Result := DSiFileSize(FileName);
      {$ELSE}
      if not GetFileInfoRec(FileName, fir, False) then Exit(-1);
      Result := fir.Size;
      {$ENDIF}
    except
      Result := -1;
    end;
  end;
end;

{$IFDEF MSWINDOWS}
{$WARN SYMBOL_PLATFORM OFF}
// http://forum.lazarus.freepascal.org/index.php/topic,6705.0.html
function FileGetCreationTime(const FileName: string): TDateTime;
var
  SearchRec: TSearchRec;
  SysTime: SYSTEMTIME;
  FileTime: TFILETIME;
begin
  if FindFirst(FileName, faAnyFile, SearchRec) = 0 then
  begin
    FileTimeToLocalFileTime(SearchRec.FindData.ftCreationTime, FileTime);
    FileTimeToSystemTime(FileTime, SysTime);
    Result := SystemTimeToDateTime(SysTime);
  end
  else Result := 0;
end;

function FileGetTimes(const FileName: string; out CreationTime, LastAccessTime, LastWriteTime: TDateTime): Boolean;
var
  SearchRec: TSearchRec;
  SysTime: SYSTEMTIME;
  FileTime: TFILETIME;
begin
  if FindFirst(FileName, faAnyFile, SearchRec) = 0 then
  begin
    FileTimeToLocalFileTime(SearchRec.FindData.ftCreationTime, FileTime);
    FileTimeToSystemTime(FileTime, SysTime);
    CreationTime := SystemTimeToDateTime(SysTime); //TODO: bad dates

    FileTimeToLocalFileTime(SearchRec.FindData.ftLastAccessTime, FileTime);
    FileTimeToSystemTime(FileTime, SysTime);
    LastAccessTime := SystemTimeToDateTime(SysTime);

    FileTimeToLocalFileTime(SearchRec.FindData.ftLastWriteTime, FileTime);
    FileTimeToSystemTime(FileTime, SysTime);
    LastWriteTime := SystemTimeToDateTime(SysTime);

    Result := True;
  end
  else Result := False;
end;
{$WARN SYMBOL_PLATFORM ON}
{$ENDIF}

procedure ClearFileInfoRec(var fir: TFileInfoRec);
begin
  fir.FullFileName := '';
  fir.Directory := '';
  fir.Path := '';
  fir.ShortFileName := '';
  fir.BaseFileName := '';
  fir.Extension := '';

  fir.StatOK := False;
  fir.DeviceNo := 0;
  fir.InodeNo := 0;
  fir.FileMode := 0;
  fir.HardLinks := 0;
  fir.OwnerUserID := 0;
  fir.OwnerGroupID := 0;
  fir.Size := 0;
  fir.BlockSize := 0;
  fir.Blocks := 0;
  fir.CreationTime := 0;
  fir.LastWriteTime := 0;
  fir.LastAccessTime := 0;
  fir.ReadOnly := True;
end;

function GetFileInfoRec(const FileName: string; out fir: TFileInfoRec; bOnlyNames: Boolean = False): Boolean;
var
{$IFDEF LINUX}
  st: BaseUnix.stat;
{$ENDIF}
{$IFDEF MSWINDOWS}
  tc, ta, tw: TDateTime;
{$ENDIF}
begin
  Result := False;
  if not FileExists(FileName) then Exit;
  ClearFileInfoRec(fir{%H-});
  fir.FullFileName := ExpandFileName(FileName);
  fir.Directory := ExtractFileDir(fir.FullFileName);
  fir.Path := ExtractFilePath(fir.FullFileName);
  fir.ShortFileName := ExtractFileName(FileName);
  fir.BaseFileName := ChangeFileExt(fir.ShortFileName, '');
  fir.Extension := GetFileExt(FileName, True);
  if bOnlyNames then Exit(True);
  fir.ReadOnly := FileIsReadOnly(fir.FullFileName);

  {$IFDEF MSWINDOWS}
  fir.Size := FileSizeInt(FileName);
  if FileGetTimes(FileName, tc, ta, tw) then
  begin
    fir.CreationTime := tc;
    fir.LastAccessTime := ta;
    fir.LastWriteTime := tw;
  end;
  {$ENDIF}

  {$IFDEF LINUX}
  if FpStat(FileName, st{%H-}) = 0 then
  begin
    fir.StatOK := True;
    fir.DeviceNo := st.st_dev;
    fir.InodeNo := st.st_ino;
    fir.FileMode := st.st_mode;
    fir.HardLinks := st.st_nlink;
    fir.OwnerUserID := st.st_uid;
    fir.OwnerGroupID := st.st_gid;
    fir.Size := st.st_size;
    fir.BlockSize := st.st_blksize;
    fir.Blocks := st.st_blocks;
    fir.CreationTime := FileDateToDateTime(st.st_ctime);
    fir.LastAccessTime := FileDateToDateTime(st.st_atime);
    fir.LastWriteTime := FileDateToDateTime(st.st_mtime);
  end
  else fir.StatOK := False;
  {$ENDIF}

  Result := True;
end;



end.
