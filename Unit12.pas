unit Unit12;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, FileCtrl, FlCtrlEx, ImgList,ShellAPI;

type
  TForm12 = class(TForm)
    Button1: TButton;
    TreeView1: TTreeView;
    DriveComboBox1: TDriveComboBox;
    ImageList1: TImageList;
    DirectoryListBox1: TDirectoryListBox;
    procedure Button1Click(Sender: TObject);
    procedure TreeView1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure rec_list_dir(inpath: string; WinAddr1: TTreeNode);
  end;


function LastPos(SubStr, S: string): Integer;

Type
NodePtr=^Tnoderec;

TnodeRec=record
         Path:string;
         FileName:string;
         isFolder:boolean;
         end;

var
  Form12: TForm12;
  NodeData:NodePtr;
implementation

{$R *.dfm}
 procedure TForm12.rec_list_dir(inpath: string; WinAddr1: TTreeNode);
  var
    sr: TSearchRec;
    res: integer;
    TNode: TTreeNode;
    Icon: TIcon;
    FileInfo: SHFILEINFO;
begin
  // Create a temporary TIcon

  try
   Icon := TIcon.Create;
    res := FindFirst(inpath + '\*.*', faAnyFile, sr);
    while res = 0 do
      begin
        if (Sr.Name <> '.') and (Sr.Name <> '..') and (Sr.Name[1] <>'.') then
          begin
          if ((sr.Attr and faDirectory) <> faDirectory) then
           begin
            New(NodeData);
            NodeData^.Path:=inpath;
            NodeData^.FileName:=sr.Name;
            NodeData^.isFolder:=False;
            TNode :=TreeView1.Items.AddChildObject(WinAddr1, Sr.Name,NodeData);


            SHGetFileInfo(PChar(inpath+'\'+ sr.Name), 0, FileInfo,
            SizeOf(FileInfo), SHGFI_ICON or SHGFI_SMALLICON);
            icon.Handle := FileInfo.hIcon;

          TNode.ImageIndex:=ImageList1.AddIcon(Icon);
            TNode.SelectedIndex:=TNode.ImageIndex;
          // Destroy the Icon
          DestroyIcon(FileInfo.hIcon);

           end else if (sr.Attr and faDirectory) = faDirectory then
           Begin
            New(NodeData);
            NodeData^.Path:=inpath+'\'+sr.Name;
            NodeData^.FileName:=sr.Name;
            NodeData^.isFolder:=True;
            TNode := TreeView1.Items.AddChildObject(WinAddr1, Sr.Name,NodeData);
            TNode.ImageIndex:=0;
            TNode.SelectedIndex:=0;
            rec_list_dir(inpath + '\' + sr.name, TNode);
           end;
          end;
        res := FindNext(sr);
      end;  //While
    FindClose(sr);
  finally
     Icon.Free;
  end;
  end;

procedure TForm12.TreeView1DblClick(Sender: TObject);
var
path,filename,Fpath:string;
path_p:PAnsiString;
isfolder:Boolean;
selectednode,item:TTreeNode;
Nodedata:NodePtr;
i:Integer;
begin
if(TreeView1.Selected=nil) then Exit;
 if (TreeView1.Selected.Data <> nil) then { query only works on new nodes }
   begin
    isfolder:=NodePtr(TreeView1.Selected.Data)^.IsFolder;
    if not isfolder then
    begin
    path := NodePtr(TreeView1.Selected.Data)^.Path;
    filename:=NodePtr(TreeView1.Selected.Data)^.FileName;
    Fpath:=path+'\'+filename;
   ShellExecute(0,pchar('open'),PChar(Fpath),nil,nil,SHOW_FULLSCREEN);
    {
    AcroPDF1.src :=path;
    AcroPDF1.setShowToolbar(True);
     }
    end else
    begin
    {
    path := PMyRec(TreeView1.Selected.Data)^.FName;
    if (path='') then Exit;

     GetSubFolders(path);
     for i:=0 to SubfolderList.Count-1 do
     begin
     New(NodeData);
     NodeData^.FName:=SubfolderList.Strings[i];
     NodeData^.IsFolder:=True;

     if IsDuplicateName(TreeView1.Selected,getfolderfromPath(SubfolderList.Strings[i]),False) then Continue;

     Item := TreeView1.Items.AddChildObject(TreeView1.Selected,getfolderfromPath(SubfolderList.Strings[i]),NodeData);
     Item.ImageIndex:=1;
     Item.SelectedIndex:=1;
     GetFiles(TreeView1,SubfolderList.Strings[i], Item, False);
    end;
    }
    end;
   end;




end;

procedure TForm12.Button1Click(Sender: TObject);
var
TNode:TTreeNode;
FolderName:string;
startidx:Integer;

begin
  TreeView1.Items.BeginUpdate;
  TreeView1.Items.Clear;
  startidx:=LastPos('\',DirectoryListBox1.Directory);
  if(startidx<Length(DirectoryListBox1.Directory)) then
  begin
   FolderName:=copy(DirectoryListBox1.Directory,startidx+1,length(DirectoryListBox1.Directory));

  end else
  begin
  FolderName:=DirectoryListBox1.Directory;

  end;

   New(NodeData);
   NodeData^.Path:=DirectoryListBox1.Directory;
   NodeData^.FileName:=FolderName;
   NodeData^.isFolder:=True;

  TNode := TreeView1.Items.AddChildObject(nil,FolderName,NodeData);
  TNode.ImageIndex:=0;
  TNode.SelectedIndex:=0;

  rec_list_dir(DirectoryListBox1.Directory, TNode);
  TreeView1.Items.EndUpdate;
end;


function LastPos(SubStr, S: string): Integer;
var
  Found, Len, Pos: integer;
begin
  Pos := Length(S);
  Len := Length(SubStr);
  Found := 0;
  while (Pos > 0) and (Found = 0) do
  begin
    if Copy(S, Pos, Len) = SubStr then
      Found := Pos;
    Dec(Pos);
  end;
  LastPos := Found;
end;

end.
