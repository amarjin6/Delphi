unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Samples.Spin,
  Vcl.ExtCtrls, Vcl.ComCtrls,ShellApi;

type
  TMas1 = array of array of string;
  TMas2 = array of array [1..3] of string;
  TMas3 = array of string;
  tree = ^node;
  node = record
           mas : array [1..32] of tree;
           element : string;
           word : string;
         end;

  TForm1 = class(TForm)
    LevelText: TStaticText;
    GameZone: TPanel;
    TBSize: TTrackBar;
    Button1: TButton;
    ListBox1: TListBox;
    RadioGroup1: TRadioGroup;
    Label2: TLabel;
    Label3: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    ListBox2: TListBox;
    Button3: TButton;
    Button2: TButton;
    Button4: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Button5: TButton;
    procedure FormCreate(Sender: TObject);
    procedure GridCreate(iSize:integer);
    procedure GridClear;
    procedure Leave(Sender: TObject);
    procedure TBSizeChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    function Access_To_Grid(Sender: TObject):boolean;
    function WordCheck(s:string):boolean;
    function Access_To_Choose(Sender: TObject):boolean;
    procedure RadioButton2Click(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure Computer();
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RadioButton1Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LoadGame;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ////////////////////////
  {Глобальные переменные необходимые для корректной работы компьютера}
  root,root1 : tree;
  tec_root : tree;
  head_root,tec_head,tec_head1 : tree;
  iSize,i11,i_maining,j_maining,i,pos_ii,pos_jj,ii,i_maining1,j_maining1 : integer;
  A : TMas1;
  BB : TMas2;
  s,s11 : string;
  vocabulary : TextFile;
  flagg : boolean = true;
  ///////////////////////
  Form1: TForm1;
  slovo,grid_number,pred_number,mean : string;
  SlovoStep : boolean;
  bool : boolean = true;
  CurrentPlayer : boolean;
  Game,Xod,f : boolean;
  UsedWords : array [0..255] of string;
  Rezerved_letters : array [1..9] of string;
  len_1,len_2,iD,jD,granicac : integer;
  granica : integer = -1;
  flash : boolean = true;
implementation

{$R *.dfm}

uses Unit2, Unit4, Unit5, Unit6;
{$MESSAGE Hint 'Вас приветствует приложение Balda'}

{Функция находящая потомка заданного родителя, если потомка нет - возвращает Nil}
function Find_child(const tec_root : tree; const main_root : tree; const s : string) : tree;
var
  Child : tree;
  i : integer;
  ss : string;

begin
  Child := Nil;
  if (tec_root = main_root) then
    begin
      ss := tec_root^.element;
    end;

  if (tec_root <> main_root)and (tec_root <> nil) then
    begin
      ss := Copy(tec_root^.element,2,(length(tec_root^.element)-1));
    end;
  i := pos(AnsiUpperCase(s),AnsiUpperCase(ss));
  if (i > 0) then
    Child := tec_root^.mas[i];
  Find_child := Child;
end;

{Процедура проверки ячейки(разрешена ли она для хода и не была ли она уже задействована при ходе)}
function IsCorrect(const A : TMas1; const C : TMas3; s : string) : boolean;
var
  i,pos_i,pos_j : integer;
  flag : boolean;
begin
  flag := True;
  for i := 0 to length(C)-1 do
    begin
      if (s = C[i]) then
        begin
          flag := false;
          break;
        end;
    end;
  pos_i := StrToInt(Copy(s,1,1));
  pos_j := StrToInt(Copy(s,2,1));
  if (A[pos_i,pos_j] = '*') then
    flag := false;
  IsCorrect := flag;
end;

{Процедура создание словарного дерева}
procedure Add_root(var tec_root : tree; const word : string; var letter_pos : integer; const main_root : tree);
var
  len,position,i,j : integer;
  s,s1 : string;

begin
  len := length(word);
  s := Copy(word,letter_pos,1);
  if (tec_root = main_root) then
    begin
      s1 := (tec_root^.element);
    end;
  if (tec_root <> main_root) then
    begin
      s1 := Copy(tec_root^.element,2,(length(tec_root^.element)-1));
    end;
  position := pos(s,s1);
  if (position = 0) then
    begin
     tec_root^.element := tec_root^.element + s;
      for i := 1 to 32 do
        begin
          if (tec_root^.mas[i] = Nil) then
            break;
        end;

      New(tec_root^.mas[i]);
      tec_root^.mas[i]^.element := s;
      for j := 1 to 32 do
        begin
          tec_root^.mas[i]^.mas[j] := Nil;
        end;
      if (letter_pos < len) then
        begin
          tec_root^.mas[i]^.word := '';
          tec_root := tec_root^.mas[i];
          inc(letter_pos);
          Add_root(tec_root,word,letter_pos,main_root);
        end;
        if (letter_pos = len) then
          begin
            if tec_root^.mas[i].word = '' then
              begin
                tec_root^.mas[i]^.word := word;
                inc(letter_pos);
              end;
          end;
    end;
  if (position > 0) then
    begin
      if (letter_pos < len) then
        begin
          tec_root := tec_root^.mas[position];
          inc(letter_pos);
          Add_root(tec_root,word,letter_pos,main_root);
        end;
      if (letter_pos = len) then
        begin
          if tec_root^.mas[position].word = '' then
              begin
                tec_root^.mas[position]^.word := word;
                inc(letter_pos);
              end;
        end;
    end;
end;

{Процедура поиска ячеек с буквами к ячейке уже с заполненной буквой}
procedure Computer_mind_2(const A : TMas1; var B : TMas2; var root_now : tree; var pos_i,pos_j : integer; var C : TMas3);
var
  hi,hj : integer;
  s11 : string;
begin
  for hi := 0 to length(C)-1 do
    begin
      if (C[hi] = '') then
        begin
          C[hi] := IntToStr(pos_i);
          C[hi] := C[hi] + IntToStr(pos_j);
          break;
        end;
    end;
   if (pos_j < (iSize-1)) and not(flagg) then  //j+1
    begin
      s11 := IntToStr(pos_i);
      s11 := s11 + IntToStr(pos_j+1);
      if (A[pos_i,(pos_j+1)] <> ' ') and (IsCorrect(A,C,s11)) then
        begin
          tec_head1 := root_now;
          root_now := Find_child(tec_head1,head_root,A[pos_i,(pos_j+1)]);
          if root_now <> Nil then
            begin
              if root_now^.word <> '' then
                begin
                  for hi := 0 to length(BB)-1 do
                    begin
                      if BB[hi][2] = '' then
                        begin
                          BB[hi][1] := (s[i]);
                          BB[hi][2] := root_now^.word;
                          BB[hi][3] := IntToStr(pos_ii);
                          BB[hi][3] := BB[hi][3] +  IntToStr(pos_jj);
                          break;
                        end;
                    end;
                end;
              pos_j := pos_j + 1;
              Computer_mind_2(A,B,root_now,pos_i,pos_j,C);
            end;

          pos_i := pos_ii;
          pos_j := pos_jj;
          for hi := granica to length(C)-1 do
            begin
              C[hi] := '';
            end;
          for hi := 0 to length(C)-1 do
            begin
              if (C[hi] = '') then
                begin
                  C[hi] := IntToStr(pos_i);
                  C[hi] := C[hi] + IntToStr(pos_j);
                  break;
                end;
            end;
          for ii := 0 to length(C)-1 do
            begin
              if (C[hi] = '') then
                begin
                  C[hi] := IntToStr(pos_i);
                  C[hi] := C[hi] + IntToStr(pos_j+1);
                  break;
                end;
            end;
          root_now := tec_head1;
        end;
    end;

  if (pos_j > 0) and not(flagg) then  //j-1
    begin
      s11 := IntToStr(pos_i);
      s11 := s11 + IntToStr(pos_j-1);
      if (A[pos_i,(pos_j-1)] <> ' ') and (IsCorrect(A,C,s11)) then
        begin
          tec_head1 := root_now;
          root_now := Find_child(tec_head1,head_root,A[pos_i,(pos_j-1)]);
          if root_now <> Nil then
            begin
              if root_now^.word <> '' then
                begin
                  for hi := 0 to length(BB)-1 do
                    begin
                      if BB[hi][2] = '' then
                        begin
                          BB[hi][1] := (s[i]);
                          BB[hi][2] := root_now^.word;
                          BB[hi][3] := IntToStr(pos_ii);
                          BB[hi][3] := BB[hi][3] +  IntToStr(pos_jj);
                          break;
                        end;
                    end;
                end;
              pos_j := pos_j - 1;
              Computer_mind_2(A,B,root_now,pos_i,pos_j,C);
            end;

          pos_i := pos_ii;
          pos_j := pos_jj;
          for hi := granica to length(C)-1 do
            begin
              C[hi] := '';
            end;
          for hi := 0 to length(C)-1 do
            begin
              if (C[hi] = '') then
                begin
                  C[hi] := IntToStr(pos_i);
                  C[hi] := C[hi] + IntToStr(pos_j);
                  break;
                end;
            end;
          for ii := 0 to length(C)-1 do
            begin
              if (C[hi] = '') then
                begin
                  C[hi] := IntToStr(pos_i);
                  C[hi] := C[hi] + IntToStr(pos_j-1);
                  break;
                end;
            end;
          root_now := tec_head1;
        end;
    end;

  if (pos_i < iSize-1) and not(flagg) then  //i+1
    begin
      s11 := IntToStr(pos_i+1);
      s11 := s11 + IntToStr(pos_j);
      if (A[(pos_i+1),(pos_j)] <> ' ') and (IsCorrect(A,C,s11)) then
        begin
          tec_head1 := root_now;
          root_now := Find_child(tec_head1,head_root,A[(pos_i+1),(pos_j)]);
          if root_now <> Nil then
            begin
              if root_now^.word <> '' then
                begin
                  for hi := 0 to length(BB)-1 do
                    begin
                      if BB[hi][2] = '' then
                        begin
                          BB[hi][1] := (s[i]);
                          BB[hi][2] := root_now^.word;
                          BB[hi][3] := IntToStr(pos_ii);
                          BB[hi][3] := BB[hi][3] +  IntToStr(pos_jj);
                          break;
                        end;
                    end;
                end;
              pos_i := pos_i + 1;
              Computer_mind_2(A,B,root_now,pos_i,pos_j,C);
            end;

          pos_i := pos_ii;
          pos_j := pos_jj;
          for hi := granica to length(C)-1 do
            begin
              C[hi] := '';
            end;
          for hi := 0 to length(C)-1 do
            begin
              if (C[hi] = '') then
                begin
                  C[hi] := IntToStr(pos_i);
                  C[hi] := C[hi] + IntToStr(pos_j);
                  break;
                end;
            end;
          for ii := 0 to length(C)-1 do
            begin
              if (C[hi] = '') then
                begin
                  C[hi] := IntToStr(pos_i+1);
                  C[hi] := C[hi] + IntToStr(pos_j);
                  break;
                end;
            end;
          root_now := tec_head1;
        end;
    end;

  if (pos_i > 0) and not(flagg) then  //i-1
    begin
      s11 := IntToStr(pos_i-1);
      s11 := s11 + IntToStr(pos_j);
      if (A[(pos_i-1),(pos_j)] <> ' ') and (IsCorrect(A,C,s11)) then
        begin
          tec_head1 := root_now;
          root_now := Find_child(tec_head1,head_root,A[(pos_i-1),(pos_j)]);
          if root_now <> Nil then
            begin
              if root_now^.word <> '' then
                begin
                  for hi := 0 to length(BB)-1 do
                    begin
                      if BB[hi][2] = '' then
                        begin
                          BB[hi][1] := (s[i]);
                          BB[hi][2] := root_now^.word;
                          BB[hi][3] := IntToStr(pos_ii);
                          BB[hi][3] := BB[hi][3] +  IntToStr(pos_jj);
                          break;
                        end;
                    end;
                end;
              pos_i := pos_i - 1;
              Computer_mind_2(A,B,root_now,pos_i,pos_j,C);
            end;
          pos_i := pos_ii;
          pos_j := pos_jj;
          for hi := granica to length(C)-1 do
            begin
              C[hi] := '';
            end;
          for hi := 0 to length(C)-1 do
            begin
              if (C[hi] = '') then
                begin
                  C[hi] := IntToStr(pos_i);
                  C[hi] := C[hi] + IntToStr(pos_j);
                  break;
                end;
            end;
          for ii := 0 to length(C)-1 do
            begin
              if (C[hi] = '') then
                begin
                  C[hi] := IntToStr(pos_i-1);
                  C[hi] := C[hi] + IntToStr(pos_j);
                  break;
                end;
            end;
          root_now := tec_head1;
        end;
    end;
end;

{Процедура поиска слова на основе заполненной ячейки}
procedure Computer_mind (const A : TMas1; var B : TMas2; var root_now : tree; var pos_i,pos_j : integer; var C : TMas3);
var
  ii : integer;
  s1 : string;
begin
  for ii := 0 to length(C)-1 do
    begin
      if (C[ii] = '') then
        begin
          C[ii] := IntToStr(pos_i);
          C[ii] := C[ii] + IntToStr(pos_j);
          break;
        end;
    end;

  if (pos_j < (iSize-1)) and (A[pos_i,(pos_j+1)] = ' ') then
    begin
      {Здесь мы в свободную ячейку вставляем букву и ищем все возможные слова с буквой находящейся на этом месте}
      {буква може находиться на любой позиции в слове}
      s1 := IntToStr(pos_i);
      s1 := s1 + IntToStr(pos_j+1);
      if (IsCorrect(A,C,s1)) and (flagg) then
        begin
          tec_head := root_now;
          if root_now <> nil then
          begin
          s := Copy(root_now^.element,2,(length(root_now^.element)-1));
          for i := 1 to length(s) do
            begin
              root_now := Find_child(tec_head,head_root,s[i]);
              if root_now^.word <> '' then
                  begin
                    for ii := 0 to length(BB)-1 do
                      begin
                        if BB[ii][2] = '' then
                          begin
                            BB[ii][1] := (s[i]);
                            BB[ii][2] := root_now^.word;
                            BB[ii][3] := IntToStr(pos_i);
                            BB[ii][3] := BB[ii][3] +  IntToStr(pos_j+1);
                            break;
                          end;
                      end;
                  end;
              flagg := false;
              pos_ii := pos_i;
              pos_jj := pos_j + 1;
              pos_j := pos_j + 1;
              for ii := 0 to length(C)-1 do
                begin
                  if C[ii] <> '' then
                    inc(granica);
                end;
              {Вызываем процедуру поиска слова если на этой позиции будет стоять данная буква}
              Computer_mind_2(A,B,root_now,pos_i,pos_j,C);
              flagg := true;
              for ii := 0 to length(C)-1 do
                begin
                  C[ii] := '';
                end;
              pos_i := i_maining;
              pos_j := j_maining;
              for ii := 0 to length(C)-1 do
                begin
                  if (C[ii] = '') then
                    begin
                      C[ii] := IntToStr(pos_i);
                      C[ii] := C[ii] + IntToStr(pos_j);
                      break;
                    end;
                end;
            end;
          end;
          for ii := 0 to length(C)-1 do
            begin
              C[ii] := '';
            end;
          pos_i := i_maining;
          pos_j := j_maining;
          for ii := 0 to length(C)-1 do
            begin
              if (C[ii] = '') then
                begin
                  C[ii] := IntToStr(pos_i);
                  C[ii] := C[ii] + IntToStr(pos_j);
                  break;
                end;
            end;
          for ii := 0 to length(C)-1 do
            begin
              if (C[ii] = '') then
                begin
                  C[ii] := IntToStr(pos_i);
                  C[ii] := C[ii] + IntToStr(pos_j+1);
                  break;
                end;
            end;
          root_now := tec_head;
        end;
      flagg := true;
     root_now := tec_head; //последнее изменение
    end;  //аналогично для всех остальных

  if (pos_j > 0) and (A[pos_i,(pos_j-1)] = ' ') then
    begin
      s1 := IntToStr(pos_i);
      s1 := s1 + IntToStr(pos_j-1);
      if (IsCorrect(A,C,s1)) and (flagg) then
        begin
          tec_head := root_now;
          if root_now <> nil then
          begin
          s := Copy(root_now^.element,2,(length(root_now^.element)-1));
          for i := 1 to length(s) do
            begin
              root_now := Find_child(tec_head,head_root,s[i]);
              if root_now^.word <> '' then
                  begin
                    for ii := 0 to length(BB)-1 do
                      begin
                        if BB[ii][2] = '' then
                          begin
                            BB[ii][1] := (s[i]);
                            BB[ii][2] := root_now^.word;
                            BB[ii][3] := IntToStr(pos_i);
                            BB[ii][3] := BB[ii][3] +  IntToStr(pos_j-1);
                            break;
                          end;
                      end;
                  end;
              flagg := false;
              pos_ii := pos_i;
              pos_jj := pos_j - 1;
              pos_j := pos_j - 1;
              for ii := 0 to length(C)-1 do
                begin
                  if C[ii] <> '' then
                    inc(granica);
                end;
              Computer_mind_2(A,B,root_now,pos_i,pos_j,C);
              flagg := true;
              for ii := 0 to length(C)-1 do
                begin
                  C[ii] := '';
                end;
              pos_i := i_maining;
              pos_j := j_maining;
              for ii := 0 to length(C)-1 do
                begin
                  if (C[ii] = '') then
                    begin
                      C[ii] := IntToStr(pos_i);
                      C[ii] := C[ii] + IntToStr(pos_j);
                      break;
                    end;
                end;
            end;
          end;
          for ii := 0 to length(C)-1 do
            begin
              C[ii] := '';
            end;
          pos_i := i_maining;
          pos_j := j_maining;
          for ii := 0 to length(C)-1 do
            begin
              if (C[ii] = '') then
                begin
                  C[ii] := IntToStr(pos_i);
                  C[ii] := C[ii] + IntToStr(pos_j);
                  break;
                end;
            end;
          for ii := 0 to length(C)-1 do
            begin
              if (C[ii] = '') then
                begin
                  C[ii] := IntToStr(pos_i);
                  C[ii] := C[ii] + IntToStr(pos_j-1);
                  break;
                end;
            end;
          root_now := tec_head;
        end;
      flagg := true;
      root_now := tec_head; //последнее изменение
    end;

  if (pos_i < iSize-1) and (A[(pos_i+1),(pos_j)] = ' ') then
    begin
      s1 := IntToStr(pos_i+1);
      s1 := s1 + IntToStr(pos_j);
      if (IsCorrect(A,C,s1)) and (flagg) then
        begin
          tec_head := root_now;
          if root_now <> nil then
          begin
          s := Copy(root_now^.element,2,(length(root_now^.element)-1));
          for i := 1 to length(s) do
            begin
              root_now := Find_child(tec_head,head_root,s[i]);
              if root_now^.word <> '' then
                  begin
                    for ii := 0 to length(BB)-1 do
                      begin
                        if BB[ii][2] = '' then
                          begin
                            BB[ii][1] := (s[i]);
                            BB[ii][2] := root_now^.word;
                            BB[ii][3] := IntToStr(pos_i+1);
                            BB[ii][3] := BB[ii][3] +  IntToStr(pos_j);
                            break;
                          end;
                      end;
                  end;
              flagg := false;
              pos_ii := pos_i+1;
              pos_jj := pos_j;
              pos_i := pos_i + 1;
              for ii := 0 to length(C)-1 do
                begin
                  if C[ii] <> '' then
                    inc(granica);
                end;
              Computer_mind_2(A,B,root_now,pos_i,pos_j,C);
              flagg := true;
              for ii := 0 to length(C)-1 do
                begin
                  C[ii] := '';
                end;
              pos_i := i_maining;
              pos_j := j_maining;
              for ii := 0 to length(C)-1 do
                begin
                  if (C[ii] = '') then
                    begin
                      C[ii] := IntToStr(pos_i);
                      C[ii] := C[ii] + IntToStr(pos_j);
                      break;
                    end;
                end;
            end;
          end;
          for ii := 0 to length(C)-1 do
            begin
              C[ii] := '';
            end;
          pos_i := i_maining;
          pos_j := j_maining;
          for ii := 0 to length(C)-1 do
            begin
              if (C[ii] = '') then
                begin
                  C[ii] := IntToStr(pos_i);
                  C[ii] := C[ii] + IntToStr(pos_j);
                  break;
                end;
            end;
          for ii := 0 to length(C)-1 do
            begin
              if (C[ii] = '') then
                begin
                  C[ii] := IntToStr(pos_i+1);
                  C[ii] := C[ii] + IntToStr(pos_j);
                  break;
                end;
            end;
          root_now := tec_head;
        end;
      flagg := true;
      root_now := tec_head; //последнее изменение
    end;

  if (pos_i > 0) and (A[(pos_i-1),(pos_j)] = ' ') then
    begin
      s1 := IntToStr(pos_i-1);
      s1 := s1 + IntToStr(pos_j);
      if (IsCorrect(A,C,s1)) and (flagg) then
        begin
          tec_head := root_now;
          if root_now <> nil then
          begin
          s := Copy(root_now^.element,2,(length(root_now^.element)-1));
          for i := 1 to length(s) do
            begin
              root_now := Find_child(tec_head,head_root,s[i]);
              if root_now^.word <> '' then
                  begin
                    for ii := 0 to length(BB)-1 do
                      begin
                        if BB[ii][2] = '' then
                          begin
                            BB[ii][1] := (s[i]);
                            BB[ii][2] := root_now^.word;
                            BB[ii][3] := IntToStr(pos_i-1);
                            BB[ii][3] := BB[ii][3] +  IntToStr(pos_j);
                            break;
                          end;
                      end;
                  end;
              flagg := false;
              pos_ii := pos_i-1;
              pos_jj := pos_j;
              pos_i := pos_i - 1;
              for ii := 0 to length(C)-1 do
                begin
                  if C[ii] <> '' then
                    inc(granica);
                end;
              Computer_mind_2(A,B,root_now,pos_i,pos_j,C);
              flagg := true;
              for ii := 0 to length(C)-1 do
                begin
                  C[ii] := '';
                end;
              pos_i := i_maining;
              pos_j := j_maining;
              for ii := 0 to length(C)-1 do
                begin
                  if (C[ii] = '') then
                    begin
                      C[ii] := IntToStr(pos_i);
                      C[ii] := C[ii] + IntToStr(pos_j);
                      break;
                    end;
                end;
            end;
          end;
          for ii := 0 to length(C)-1 do
            begin
              C[ii] := '';
            end;
          pos_i := i_maining;
          pos_j := j_maining;
          for ii := 0 to length(C)-1 do
            begin
              if (C[ii] = '') then
                begin
                  C[ii] := IntToStr(pos_i);
                  C[ii] := C[ii] + IntToStr(pos_j);
                  break;
                end;
            end;
          for ii := 0 to length(C)-1 do
            begin
              if (C[ii] = '') then
                begin
                  C[ii] := IntToStr(pos_i-1);
                  C[ii] := C[ii] + IntToStr(pos_j);
                  break;
                end;
            end;
          root_now := tec_head;
        end;
      flagg := true;
      root_now := tec_head; //последнее изменение
    end;
end;

{Процедура дополнения поиска слова на основе сложения ячеек заполненных буквами и поиска с ними слова}
procedure Computer_mindс (const A : TMas1; var B : TMas2; var root_now : tree; var pos_i,pos_j : integer; var C : TMas3);
var
  ii : integer;
  s1 : string;
begin
  for ii := 0 to length(C)-1 do
    begin
      if (C[ii] = '') then
        begin
          C[ii] := IntToStr(pos_i);
          C[ii] := C[ii] + IntToStr(pos_j);
          break;
        end;
    end;

  if (pos_j < (iSize-1)) and (A[pos_i,(pos_j+1)] = ' ') then
    begin
      s1 := IntToStr(pos_i);
      s1 := s1 + IntToStr(pos_j+1);
      if (IsCorrect(A,C,s1)) and (flagg) then
        begin
          tec_head := root_now;
          if root_now <> nil then
          begin
          {Здесь мы в свободную ячейку вставляем букву и ищем все возможные слова с буквой находящейся на этом месте}
          {буква може находиться на любой позиции в слове}
          s := Copy(root_now^.element,2,(length(root_now^.element)-1));
          for i := 1 to length(s) do
            begin
              root_now := Find_child(tec_head,head_root,s[i]);
              if root_now^.word <> '' then
                  begin
                    for ii := 0 to length(BB)-1 do
                      begin
                        if BB[ii][2] = '' then
                          begin
                            BB[ii][1] := (s[i]);
                            BB[ii][2] := root_now^.word;
                            BB[ii][3] := IntToStr(pos_i);
                            BB[ii][3] := BB[ii][3] +  IntToStr(pos_j+1);
                            break;
                          end;
                      end;
                  end;
              flagg := false;
              pos_ii := pos_i;
              pos_jj := pos_j + 1;
              pos_j := pos_j + 1;
              granica := 0;
              for ii := 0 to length(C)-1 do
                begin
                  if C[ii] <> '' then
                    inc(granica);
                end;
              Computer_mind_2(A,B,root_now,pos_i,pos_j,C);
              flagg := true;
              for ii := 0 to length(C)-1 do
                begin
                  C[ii] := '';
                end;
              pos_i := i_maining;
              pos_j := j_maining;
              for ii := 0 to length(C)-1 do
                begin
                  if (C[ii] = '') then
                    begin
                      C[ii] := IntToStr(pos_i);
                      C[ii] := C[ii] + IntToStr(pos_j);
                      break;
                    end;
                end;
            end;
          end;
          for ii := granicac to length(C)-1 do
            begin
              C[ii] := '';
            end;
          pos_i := i_maining;
          pos_j := j_maining;
          for ii := 0 to length(C)-1 do
            begin
              if (C[ii] = '') then
                begin
                  C[ii] := IntToStr(pos_i);
                  C[ii] := C[ii] + IntToStr(pos_j);
                  break;
                end;
            end;
          for ii := 0 to length(C)-1 do
            begin
              if (C[ii] = '') then
                begin
                  C[ii] := IntToStr(pos_i);
                  C[ii] := C[ii] + IntToStr(pos_j+1);
                  break;
                end;
            end;
          root_now := tec_head;
        end;
      flagg := true;
    end;  //аналогично для всех остальных

  if (pos_j > 0) and (A[pos_i,(pos_j-1)] = ' ') then
    begin
      s1 := IntToStr(pos_i);
      s1 := s1 + IntToStr(pos_j-1);
      if (IsCorrect(A,C,s1)) and (flagg) then
        begin
          tec_head := root_now;
          if root_now <> nil then
          begin
          s := Copy(root_now^.element,2,(length(root_now^.element)-1));
          for i := 1 to length(s) do
            begin
              root_now := Find_child(tec_head,head_root,s[i]);
              if root_now^.word <> '' then
                  begin
                    for ii := 0 to length(BB)-1 do
                      begin
                        if BB[ii][2] = '' then
                          begin
                            BB[ii][1] := (s[i]);
                            BB[ii][2] := root_now^.word;
                            BB[ii][3] := IntToStr(pos_i);
                            BB[ii][3] := BB[ii][3] +  IntToStr(pos_j-1);
                            break;
                          end;
                      end;
                  end;
              flagg := false;
              pos_ii := pos_i;
              pos_jj := pos_j - 1;
              pos_j := pos_j - 1;
              granica := 0;
              for ii := 0 to length(C)-1 do
                begin
                  if C[ii] <> '' then
                    inc(granica);
                end;
              Computer_mind_2(A,B,root_now,pos_i,pos_j,C);
              flagg := true;
              for ii := granicac to length(C)-1 do
                begin
                  C[ii] := '';
                end;
              pos_i := i_maining;
              pos_j := j_maining;
              for ii := 0 to length(C)-1 do
                begin
                  if (C[ii] = '') then
                    begin
                      C[ii] := IntToStr(pos_i);
                      C[ii] := C[ii] + IntToStr(pos_j);
                      break;
                    end;
                end;
            end;
          end;
          for ii := 0 to length(C)-1 do
            begin
              C[ii] := '';
            end;
          pos_i := i_maining;
          pos_j := j_maining;
          for ii := 0 to length(C)-1 do
            begin
              if (C[ii] = '') then
                begin
                  C[ii] := IntToStr(pos_i);
                  C[ii] := C[ii] + IntToStr(pos_j);
                  break;
                end;
            end;
          for ii := 0 to length(C)-1 do
            begin
              if (C[ii] = '') then
                begin
                  C[ii] := IntToStr(pos_i);
                  C[ii] := C[ii] + IntToStr(pos_j-1);
                  break;
                end;
            end;
          root_now := tec_head;
        end;
      flagg := true;
    end;

  if (pos_i < iSize-1) and (A[(pos_i+1),(pos_j)] = ' ') then
    begin
      s1 := IntToStr(pos_i+1);
      s1 := s1 + IntToStr(pos_j);
      if (IsCorrect(A,C,s1)) and (flagg) then
        begin
          tec_head := root_now;
          if root_now <> nil then
          begin
          s := Copy(root_now^.element,2,(length(root_now^.element)-1));
          for i := 1 to length(s) do
            begin
              root_now := Find_child(tec_head,head_root,s[i]);
              if root_now^.word <> '' then
                  begin
                    for ii := 0 to length(BB)-1 do
                      begin
                        if BB[ii][2] = '' then
                          begin
                            BB[ii][1] := (s[i]);
                            BB[ii][2] := root_now^.word;
                            BB[ii][3] := IntToStr(pos_i+1);
                            BB[ii][3] := BB[ii][3] +  IntToStr(pos_j);
                            break;
                          end;
                      end;
                  end;
              flagg := false;
              pos_ii := pos_i+1;
              pos_jj := pos_j;
              pos_i := pos_i + 1;
              granica := 0;
              for ii := 0 to length(C)-1 do
                begin
                  if C[ii] <> '' then
                    inc(granica);
                end;
              Computer_mind_2(A,B,root_now,pos_i,pos_j,C);
              flagg := true;
              for ii := granicac to length(C)-1 do
                begin
                  C[ii] := '';
                end;
              pos_i := i_maining;
              pos_j := j_maining;
              for ii := 0 to length(C)-1 do
                begin
                  if (C[ii] = '') then
                    begin
                      C[ii] := IntToStr(pos_i);
                      C[ii] := C[ii] + IntToStr(pos_j);
                      break;
                    end;
                end;
            end;
          end;
          for ii := 0 to length(C)-1 do
            begin
              C[ii] := '';
            end;
          pos_i := i_maining;
          pos_j := j_maining;
          for ii := 0 to length(C)-1 do
            begin
              if (C[ii] = '') then
                begin
                  C[ii] := IntToStr(pos_i);
                  C[ii] := C[ii] + IntToStr(pos_j);
                  break;
                end;
            end;
          for ii := 0 to length(C)-1 do
            begin
              if (C[ii] = '') then
                begin
                  C[ii] := IntToStr(pos_i+1);
                  C[ii] := C[ii] + IntToStr(pos_j);
                  break;
                end;
            end;
          root_now := tec_head;
        end;
      flagg := true;
    end;

  if (pos_i > 0) and (A[(pos_i-1),(pos_j)] = ' ') then
    begin
      s1 := IntToStr(pos_i-1);
      s1 := s1 + IntToStr(pos_j);
      if (IsCorrect(A,C,s1)) and (flagg) then
        begin
          tec_head := root_now;
          if root_now <> nil then
          begin
          s := Copy(root_now^.element,2,(length(root_now^.element)-1));
          for i := 1 to length(s) do
            begin
              root_now := Find_child(tec_head,head_root,s[i]);
              if root_now^.word <> '' then
                  begin
                    for ii := 0 to length(BB)-1 do
                      begin
                        if BB[ii][2] = '' then
                          begin
                            BB[ii][1] := (s[i]);
                            BB[ii][2] := root_now^.word;
                            BB[ii][3] := IntToStr(pos_i-1);
                            BB[ii][3] := BB[ii][3] +  IntToStr(pos_j);
                            break;
                          end;
                      end;
                  end;
              flagg := false;
              pos_ii := pos_i-1;
              pos_jj := pos_j;
              pos_i := pos_i - 1;
              granica := 0;
              for ii := 0 to length(C)-1 do
                begin
                  if C[ii] <> '' then
                    inc(granica);
                end;
              Computer_mind_2(A,B,root_now,pos_i,pos_j,C);
              flagg := true;
              for ii := granicac to length(C)-1 do
                begin
                  C[ii] := '';
                end;
              pos_i := i_maining;
              pos_j := j_maining;
              for ii := 0 to length(C)-1 do
                begin
                  if (C[ii] = '') then
                    begin
                      C[ii] := IntToStr(pos_i);
                      C[ii] := C[ii] + IntToStr(pos_j);
                      break;
                    end;
                end;
            end;
          end;
          for ii := 0 to length(C)-1 do
            begin
              C[ii] := '';
            end;
          pos_i := i_maining;
          pos_j := j_maining;
          for ii := 0 to length(C)-1 do
            begin
              if (C[ii] = '') then
                begin
                  C[ii] := IntToStr(pos_i);
                  C[ii] := C[ii] + IntToStr(pos_j);
                  break;
                end;
            end;
          for ii := 0 to length(C)-1 do
            begin
              if (C[ii] = '') then
                begin
                  C[ii] := IntToStr(pos_i-1);
                  C[ii] := C[ii] + IntToStr(pos_j);
                  break;
                end;
            end;
          root_now := tec_head;
        end;
      flagg := true;
    end;

end;

{Процедура поиска слова на основе сложения ячеек заполненных буквами и поиска с ними слова}
procedure Letter_go(const A : TMas1; var B : TMas2; var root_now : tree; var pos_i,pos_j : integer; var C : TMas3);
var
  ii,i_main,j_main : integer;
  s1 : string;
  buf : tree;
begin
  pos_i := i_maining;
  pos_j := j_maining;
   if (pos_j < (iSize-1)) and (A[pos_i,(pos_j+1)] <> ' ') and (flagg) then
    begin
      i_main := pos_i;
      j_main := pos_j;
      buf := root1;
      for ii := 0 to length(C)-1 do
        begin
          C[ii] := '';
        end;

      for ii := 0 to length(C)-1 do
        begin
          if (C[ii] = '') then
            begin
              C[ii] := IntToStr(pos_i);
              C[ii] := C[ii] + IntToStr(pos_j);
              break;
            end;
        end;
      s1 := IntToStr(pos_i);
      s1 := s1 + IntToStr(pos_j+1);
      if IsCorrect(A,C,s1) then
        begin
          for ii := 0 to length(C)-1 do
            begin
              if (C[ii] = '') then
                begin
                  C[ii] := IntToStr(pos_i);
                  C[ii] := C[ii] + IntToStr(pos_j+1);
                  break;
                end;
            end;
          granicac := 0;
          for ii := 0 to length(C)-1 do
            begin
              if C[ii] <> '' then
                inc(granicac);
            end;
          root_now := Find_child(root1,head_root,A[pos_i,(pos_j+1)]);
          if root_now <> Nil then
            begin
              pos_j := pos_j + 1;
              i_maining := pos_i;
              j_maining := pos_j;
              Computer_mindс(A,B,root_now,pos_i,pos_j,C);
            end;
        end;
      pos_i := i_main;
      pos_j := j_main;
      root1 := buf;
    end;
   {Ищем позиции заполненные буквами и вызываем от них поиск слова}
   if (pos_j > 0) and (A[pos_i,(pos_j-1)] <> ' ') and (flagg) then
    begin
      i_main := pos_i;
      j_main := pos_j;
      buf := root1;
      for ii := 0 to length(C)-1 do
        begin
          C[ii] := '';
        end;

      for ii := 0 to length(C)-1 do
        begin
          if (C[ii] = '') then
            begin
              C[ii] := IntToStr(pos_i);
              C[ii] := C[ii] + IntToStr(pos_j);
              break;
            end;
        end;
      s1 := IntToStr(pos_i);
      s1 := s1 + IntToStr(pos_j-1);
      if IsCorrect(A,C,s1) then
        begin
          for ii := 0 to length(C)-1 do
            begin
              if (C[ii] = '') then
                begin
                  C[ii] := IntToStr(pos_i);
                  C[ii] := C[ii] + IntToStr(pos_j-1);
                  break;
                end;
            end;
          granicac := 0;
          for ii := 0 to length(C)-1 do
            begin
              if C[ii] <> '' then
                inc(granicac);
            end;
          root_now := Find_child(root1,head_root,A[pos_i,(pos_j-1)]);
          if root_now <> Nil then
            begin
              pos_j := pos_j - 1;
              i_maining := pos_i;
              j_maining := pos_j;
              Computer_mindс(A,B,root_now,pos_i,pos_j,C);
            end;
        end;
      pos_i := i_main;
      pos_j := j_main;
      root1 := buf;
    end;

  if (pos_i < iSize-1) and (A[(pos_i+1),(pos_j)] <> ' ') and (flagg) then
    begin
      i_main := pos_i;
      j_main := pos_j;
      buf := root1;
      for ii := 0 to length(C)-1 do
        begin
          C[ii] := '';
        end;

      for ii := 0 to length(C)-1 do
        begin
          if (C[ii] = '') then
            begin
              C[ii] := IntToStr(pos_i);
              C[ii] := C[ii] + IntToStr(pos_j);
              break;
            end;
        end;
      s1 := IntToStr(pos_i+1);
      s1 := s1 + IntToStr(pos_j);
      if IsCorrect(A,C,s1) then
        begin
          for ii := 0 to length(C)-1 do
            begin
              if (C[ii] = '') then
                begin
                  C[ii] := IntToStr(pos_i+1);
                  C[ii] := C[ii] + IntToStr(pos_j);
                  break;
                end;
            end;
          granicac := 0;
          for ii := 0 to length(C)-1 do
            begin
              if C[ii] <> '' then
                inc(granicac);
            end;
          root_now := Find_child(root1,head_root,A[(pos_i+1),(pos_j)]);
          if root_now <> Nil then
            begin
              pos_i := pos_i + 1;
              i_maining := pos_i;
              j_maining := pos_j;
              Computer_mindс(A,B,root_now,pos_i,pos_j,C);
            end;
        end;
      pos_i := i_main;
      pos_j := j_main;
      root1 := buf;
    end;

  if (pos_i > 0) and (A[(pos_i-1),(pos_j)] <> ' ') and (flagg) then
    begin
      i_main := pos_i;
      j_main := pos_j;
      buf := root1;
      for ii := 0 to length(C)-1 do
        begin
          C[ii] := '';
        end;

      for ii := 0 to length(C)-1 do
        begin
          if (C[ii] = '') then
            begin
              C[ii] := IntToStr(pos_i);
              C[ii] := C[ii] + IntToStr(pos_j);
              break;
            end;
        end;
      s1 := IntToStr(pos_i-1);
      s1 := s1 + IntToStr(pos_j);
      if IsCorrect(A,C,s1) then
        begin
          for ii := 0 to length(C)-1 do
            begin
              if (C[ii] = '') then
                begin
                  C[ii] := IntToStr(pos_i-1);
                  C[ii] := C[ii] + IntToStr(pos_j);
                  break;
                end;
            end;
          granicac := 0;
          for ii := 0 to length(C)-1 do
            begin
              if C[ii] <> '' then
                inc(granicac);
            end;
          root_now := Find_child(root1,head_root,A[(pos_i-1),(pos_j)]);
          if root_now <> Nil then
            begin
              pos_i := pos_i - 1;
              i_maining := pos_i;
              j_maining := pos_j;
              Computer_mindс(A,B,root_now,pos_i,pos_j,C);
            end;
        end;
      pos_i := i_main;
      pos_j := j_main;
      root1 := buf;
    end;
end;

{Процедура для поиска слов на основе пустых ячеек(осуществляется полный перебор каждой буквы и поиска с ней слова)}
procedure Computer_brain(const A : TMas1; var B : TMas2; var tec_root : tree; const main_root : tree; var pos_i,pos_j : integer; var C : TMas3);
var
  i,j,i1 : integer;
  s1 : string;
  check_root : tree;

label
  check,cycle;

begin
  {Если ячейка пустая то перебираем на ее место все буквы и ищем слова каоторые можем составить с этой буквой}
  s1 := IntToStr(pos_i);
  s1 := s1 + IntToStr(pos_j);
  if (IsCorrect(A,C,s1)) and (A[pos_i,pos_j] = ' ') then
    begin
      if (tec_root = head_root) then
        begin
          s11 := tec_root^.element;
        end;

      if (tec_root <> head_root) then
        begin
          s11 := Copy(tec_root^.element,2,(length(tec_root^.element)-1));
        end;
      i11 := 1;
      goto cycle;
      cycle:
      if (i11 <= length(s11)) then
        begin
          tec_root := head_root;
          tec_root := tec_root^.mas[i11];
          inc(i11);
          goto check;
        end;
    end;
  {Если ячейка не пустая и ее мы не использовали то идем и ищем от нее другие ячейки}
  if (IsCorrect(A,C,s1)) and (A[pos_i,pos_j] <> ' ') and (i11 <= length(s11)) then
    begin
      goto check;
    end;

  check:
    if (i11 <= length(s11)) then
    begin
      if (pos_j < (iSize-1)) then
        begin
          s1 := IntToStr(pos_i);
          s1 := s1 + IntToStr(pos_j+1);
          if (IsCorrect(A,C,s1)) and (A[pos_i,(pos_j+1)] <> ' ') then
          begin
            check_root := Find_child(tec_root,head_root,A[pos_i,(pos_j+1)]);
            if (Check_root <> Nil) then
              begin
                tec_root := check_root;

                for j := 0 to length(C) do
                  begin
                    if (C[j] = '') then
                      begin
                        C[j] := IntToStr(pos_i);
                        C[j] := C[j] + IntToStr(pos_j);
                        break;
                      end;
                  end;

                if tec_root^.word <> '' then
                  begin
                    for j := 0 to length(B) do
                      begin
                        if (B[j][1] = '') then
                          begin
                            B[j][1] := Copy(tec_root^.word,1,1);
                            B[j][2] := tec_root^.word;
                            B[j][3] := Copy(C[0],1,1);
                            B[j][3] := B[j][3] + Copy(C[0],2,1);
                            break;
                          end;
                      end;
                  end;
                pos_j := pos_j + 1;
                Computer_brain(A,B,tec_root,main_root,pos_i,pos_j,C);
              end;
          end;
        end;

      if ((pos_j > 0)) then
        begin
          s1 := IntToStr(pos_i);
          s1 := s1 + IntToStr(pos_j-1);
          if (IsCorrect(A,C,s1)) and (A[pos_i,(pos_j-1)] <> ' ') then
          begin
            check_root := Find_child(tec_root,head_root,A[pos_i,(pos_j-1)]);
            if (Check_root <> Nil) then
              begin
                tec_root := check_root;

                for j := 0 to length(C) do
                  begin
                    if (C[j] = '') then
                      begin
                        C[j] := IntToStr(pos_i);
                        C[j] := C[j] + IntToStr(pos_j);
                        break;
                      end;
                  end;

                if tec_root^.word <> '' then
                  begin
                    for j := 0 to length(B) do
                      begin
                        if (B[j][1] = '') then
                          begin
                            B[j][1] := Copy(tec_root^.word,1,1);
                            B[j][2] := tec_root^.word;
                            B[j][3] := Copy(C[0],1,1);
                            B[j][3] := B[j][3] + Copy(C[0],2,1);
                            break;
                          end;
                      end;
                  end;
                pos_j := pos_j - 1;
                Computer_brain(A,B,tec_root,main_root,pos_i,pos_j,C);
              end;
          end;
        end;

       if ((pos_i < iSize-1)) then
        begin
          s1 := IntToStr(pos_i+1);
          s1 := s1 + IntToStr(pos_j);
          if (IsCorrect(A,C,s1)) and (A[(pos_i+1),(pos_j)] <> ' ') then
          begin
            check_root := Find_child(tec_root,head_root,A[(pos_i+1),(pos_j)]);
            if (Check_root <> Nil) then
              begin
                tec_root := check_root;

                for j := 0 to length(C) do
                  begin
                    if (C[j] = '') then
                      begin
                        C[j] := IntToStr(pos_i);
                        C[j] := C[j] + IntToStr(pos_j);
                        break;
                      end;
                  end;

                if tec_root^.word <> '' then
                  begin
                    for j := 0 to length(B) do
                      begin
                        if (B[j][1] = '') then
                          begin
                            B[j][1] := Copy(tec_root^.word,1,1);
                            B[j][2] := tec_root^.word;
                            B[j][3] := Copy(C[0],1,1);
                            B[j][3] := B[j][3] + Copy(C[0],2,1);
                            break;
                          end;
                      end;
                  end;
                pos_i := pos_i + 1;
                Computer_brain(A,B,tec_root,main_root,pos_i,pos_j,C);
              end;
          end;
        end;

       if ((pos_i > 0)) then
        begin
          s1 := IntToStr(pos_i-1);
          s1 := s1 + IntToStr(pos_j);
          if (IsCorrect(A,C,s1)) and (A[(pos_i-1),(pos_j)] <> ' ') then
          begin
            check_root := Find_child(tec_root,head_root,A[(pos_i-1),(pos_j)]);
            if (Check_root <> Nil) then
              begin
                tec_root := check_root;

                for j := 0 to length(C) do
                  begin
                    if (C[j] = '') then
                      begin
                        C[j] := IntToStr(pos_i);
                        C[j] := C[j] + IntToStr(pos_j);
                        break;
                      end;
                  end;

                if tec_root^.word <> '' then
                  begin
                    for j := 0 to length(B) do
                      begin
                        if (B[j][1] = '') then
                          begin
                            B[j][1] := Copy(tec_root^.word,1,1);
                            B[j][2] := tec_root^.word;
                            B[j][3] := Copy(C[0],1,1);
                            B[j][3] := B[j][3] + Copy(C[0],2,1);
                            break;
                          end;
                      end;
                  end;
                pos_i := pos_i - 1;
                Computer_brain(A,B,tec_root,main_root,pos_i,pos_j,C);
              end;
          end;
        end;
      for i := 0 to length(B) do
        begin
          if B[i+1][2] = '' then
            break;
        end;
      if (Check_root = Nil) and (B[i][2] <> '') then
        begin
          for i1 := 0 to length(C)-1 do
            begin
              C[i1] := '';
            end;

          for i1 := 0 to length(BB)-1 do
            begin
              if BB[i1][2] = '' then
                begin
                  BB[i1][1] := B[i][1];
                  BB[i1][2] := B[i][2];
                  BB[i1][3] := B[i][3];
                  break;
                end;
            end;
          B[i][1] := '';
          B[i][2] := '';
          B[i][3] := '';
          pos_i := i_maining; //для начальной клетки
          pos_j := j_maining;
        end;
      for i1 := 0 to length(C)-1 do
        begin
          C[i1] := '';
        end;
      pos_i := i_maining;
      pos_j := j_maining;
      goto cycle;
    end;
end;

{Процедура очистки массива ячеек которые компьютер использовал для составления слов и возврат изменных параметров цикла в свое текущее положение}
procedure Clear(const i_maining,j_maining : integer; out i,j : integer; var C : TMas3);
var
  q : integer;
begin
  i := i_maining;
  j := j_maining;
   for q := 0 to length(C)-1 do
      begin
        C[q] := '';
      end;
end;

procedure TForm1.Computer();
var
  i,j,k,max,max_i,Tip : integer;
  B : TMas2;
  C : TMas3;
  flag,d : boolean;
  WND:HWND;
  lpText,lpCaption : PChar;
begin
  {Снимаем копию игрового поля}
  SetLength(A,iSize,iSize);
  for i := 0 to iSize-1 do
    for j := 0 to iSize-1 do
      begin
        for k:=0 to ComponentCount-1 do
          if (Copy(Components[k].Name,1,6) = 'Grid' + IntToStr(i+1) + IntToStr(j+1)) then
            begin
              A[i,j] := TEdit(Components[k]).Text;
            end;
      end;
  {Установка ячеек по которым компьютер может ходить}
  for i := 0 to iSize-1 do
    begin
      for j := 0 to iSIze-1 do
        begin
          flag := false;
          if j < iSize-2 then
            if (A[i,j+1] <> ' ') and (A[i,j+1] <> '*') then
              flag := true;
          if j > 0 then
            if (A[i,j-1] <> ' ') and (A[i,j-1] <> '*') then
              flag := true;
          if i < iSize-2 then
            if (A[i+1,j] <> ' ') and (A[i+1,j] <> '*') then
              flag := true;
          if i > 0 then
            if (A[i-1,j] <> ' ') and (A[i-1,j] <> '*') then
              flag := true;
          if flag = false then
            A[i,j] := '*';
        end;
    end;
  {Обнуляем массивы поиска слов}
  SetLength(B,5000);
  SetLength(BB,5000);
  SetLength(C,((iSize)*(iSize)));
  d := false;
  for i := 0 to length(B)-1 do
    for j := 1 to 3 do
      begin
        B[i,j] := '';
      end;

  for i := 0 to length(BB)-1 do
    for j := 1 to 3 do
      begin
        BB[i,j] := '';
      end;

    for i := 0 to length(C)-1 do
      begin
        C[i] := '';
      end;
  {Здесь начинается работа компьютера}
  {проходим и отрабатываем все возможно комбинации поиска слов}
  for i := 0 to iSize-1 do
    for j := 0 to iSize-1 do
      begin
        {Работа простого перебора пустых ячеек и поиска впоследствии слов}
        if (A[i,j] = ' ') then
          begin
            i_maining := i;
            j_maining := j;
            root := head_root;
            Computer_brain(A,B,root,root,i,j,C);
            Clear(i_maining,j_maining,i,j,C);
            d := true;
          end;
        {Работа основных 2 процедур поиска слов по заполненным ячейкам}
        if (A[i,j] <> ' ') and (A[i,j] <> '*') then
          begin
            i_maining := i;
            j_maining := j;
            tec_root := head_root;
            root := Find_child(tec_root,tec_root,A[i,j]);
            tec_head := root;
            root1 := root;
            {Процедура поиска слов по 1 заполненной ячейке}
            Computer_mind(A,B,root,i,j,C);
            Clear(i_maining,j_maining,i,j,C);
            i_maining1 := i_maining;
            j_maining1 := j_maining;
            {Процедура поиска слов по всем заполненным ячейкам по очереди}
            Letter_go(A,B,root1,i,j,C);
            i_maining := i_maining1;
            j_maining := j_maining1;
            Clear(i_maining,j_maining,i,j,C);
          end;
      end;
  {Поиск среди слов найденных компьютером наибольшей длины}
  max := 0;
  max_i := 0;
  for i := 0 to length(BB) do
    begin
      if BB[i][2] <> '' then
        begin
          flag := true;
          for j := 0 to 255 do
            begin
              {Реализована проверка сверки среди слов компьютера и уже использованных}
              if (AnsiUpperCase(BB[i][2]) = AnsiUpperCase(Usedwords[j])) then
                begin
                  flag := false;
                  break;
                end;
            end;
          if (flag) then
            begin
              k := StrToInt(Copy(BB[i][3],1,1));
              j := StrToInt(Copy(BB[i][3],2,1));
              if (A[k,j] = ' ') or (A[k,j] <> '*') then
                begin
                  {Если такое слово нашлось то сохраняем его текущую позицию в массиве}
                  if length(BB[i][2]) > max then
                    begin
                      max := length(BB[i][2]);
                      max_i := i;
                    end;
                end;
            end;

        end;
    end;
  {Если компьютер больше слов не нашел соответственно больше пользователь их не найдет тоже}
  {Проверка на найденные компьютером слова}
   if (max = 0) then
     begin
       if (d) then
         begin
           lpText := 'Компьютер больше не нашел слов!';
           lpCaption := 'Игра закончена';
           Tip := MB_OK+MB_ICONWARNING;
           with Application do
             begin
               MessageBox(lpText, lpCaption, Tip);
             end;
         end;
       Form2.Show;
       Button3.Click;
     end
   else
   {Если компьютер все-таки нашел слово}
     begin
       iD := StrToInt(Copy(BB[max_i][3],1,1)) + 1;
       jD := StrToInt(Copy(BB[max_i][3],2,1)) + 1;
      for k:=0 to ComponentCount-1 do
        if (Copy(Components[k].Name,1,6) = 'Grid' + IntToStr(iD) + IntToStr(jD)) then
          begin
            TEdit(Components[k]).Text := AnsiUpperCase(BB[max_i][1]);
            TEdit(Components[k]).Color := clYellow;
          end;
      SlovoStep := False;
      slovo := AnsiUpperCase(BB[max_i][2]);
      flagg := false;
      CurrentPlayer := false;
      Button1.Click;
      Label2.Font.Style :=[fsBold];
      Label3.Font.Style :=[];
     end;
  {Очистка всех использованных массивов}
  for i := 0 to iSize-1 do
    for j := 0 to iSize-1 do
      begin
        A[i,j] := '';
      end;
  for i := 0 to length(B)-1 do
    for j := 1 to 3 do
      begin
        B[i,j] := '';
      end;

  for i := 0 to length(BB)-1 do
    for j := 1 to 3 do
      begin
        BB[i,j] := '';
      end;

    for i := 0 to length(C)-1 do
      begin
        C[i] := '';
      end;
end;

{Отработка нажатия на кнопку Выделить слово}
procedure TForm1.Button1Click(Sender: TObject);
var
  i,j,Tip : integer;
  flag,check : boolean;
  WND:HWND;
  lpText,lpCaption : PChar;
begin
if SlovoStep then
  begin
      for i:=0 to ComponentCount-1 do
         if (Copy(Components[i].Name,1,4) = 'Grid') then
            begin
              TEdit(Components[i]).Color:= clYellow;
            end;
       SlovoStep := false;
       Button1.Caption := 'Ход';
  end
else
  begin
    flag := False;
    if flagg then
    for j:=0 to ComponentCount-1 do
    if (Components[j].Name = grid_number) then
      begin
        if (TEdit(Components[j]).Color = clSkyBlue) then
          flag := True;
      end;
   if (flag) or (not(flagg)) then
     begin
       Label2.Font.Style := [];
       Label3.Font.Style := [];
       if flagg then
       for j:=0 to ComponentCount-1 do
        if (Copy(Components[j].Name,1,4) = 'Grid') then
            begin
              TEdit(Components[j]).Color:= clSkyBlue;
            end;
       Button1.Caption := 'Выделить слово';
       SlovoStep := true;
       if (WordCheck(slovo)) then
         begin
           Xod := True;
           CurrentPlayer := Not(CurrentPlayer);
           if CurrentPlayer then
             begin
               Label2.Font.Style :=[fsBold];
               ListBox1.Items.Add(slovo + ' - ' + IntToStr(length(slovo)));
               len_2 := len_2 + length(slovo);
             end
           else
             begin
               Label3.Font.Style := [fsBold];
               ListBox2.Items.Add(slovo+ ' - ' + IntToStr(length(slovo)));
               len_1 := len_1 + length(slovo);
             end;
           for i := 1 to 255 do
             begin
               if UsedWords[i] = '' then
                 begin
                   UsedWords[i] := slovo;
                   break;
                 end;
             end;
           for j:=0 to ComponentCount-1 do
           if (Copy(Components[j].Name,1,4) = 'Grid') then
            begin
              if TEdit(Components[j]).Text = ' ' then
                TEdit(Components[j]).ReadOnly := False;
            end;
           grid_number := '';
           check := False;
           for j:=0 to ComponentCount-1 do
           if (Copy(Components[j].Name,1,4) = 'Grid') then
             begin
              if TEdit(Components[j]).Text = ' ' then
                begin
                  check := True;
                  break;
                end;
             end;
           if (check = False) then
             begin
               for j:=0 to ComponentCount-1 do
                 if (Copy(Components[j].Name,1,4) = 'Grid') then
                   begin
                     TEdit(Components[j]).ReadOnly := True;
                   end;
               lpText := 'Игра закончена';
               lpCaption := ' ';
               Tip := MB_OK+MB_ICONINFORMATION;
               with Application do
                 begin
                    MessageBox(lpText, lpCaption, Tip);
                 end;
               Form2.Show;
               flash := false;
             end;

         end;
       if CurrentPlayer then
         Label2.Font.Style :=[fsBold]
       else
         Label3.Font.Style := [fsBold];
       slovo := '';
       if (flagg = false) then
         begin
           Button1.Enabled := true;
           Button2.Enabled := true;
           Button4.Enabled := true;
           flagg := true;

         end;
     end
    else
      if flash then
      begin
        //ShowMessage('В выбранном слове нет вашей буквы!');
        Tip := MB_OK+MB_ICONWARNING;
        MessageBox(Wnd,'В выбранном слове нет вашей буквы!','Ошибка!',Tip);
        slovo := '';
         for i:=0 to ComponentCount-1 do
         if (Copy(Components[i].Name,1,4) = 'Grid') then
            begin
              TEdit(Components[i]).Color:= clSkyBlue;
              SlovoStep := True;
              Button1.Caption := 'Выделить слово';
            end;
      end;
    if (Label3.Caption = 'Компьютер') and (Label3.Font.Style = [fsBold]) then
      begin
        Button2.Enabled := False;
        Button1.Enabled := False;
        Button4.Enabled := False;
        for j:=0 to ComponentCount-1 do
          if (Copy(Components[j].Name,1,4) = 'Grid') then
            begin
              TEdit(Components[j]).ReadOnly := True;
            end;
        Computer();
      end;
  end;
end;

{Отработка режима сдаться}
procedure TForm1.Button2Click(Sender: TObject);
var
  Tip : integer;
  WND : HWND;
  lpText,lpCaption : PChar;

begin
 if CurrentPlayer then
   begin
     Tip := MB_OK+MB_ICONINFORMATION;
     lpText := 'Выиграл игрок 2!';
     lpCaption := 'Игра закончена';
     with Application do
       begin
         MessageBox(lpText, lpCaption, Tip);
       end;
     Form2.Show;
   end
 else
   begin
     lpText := 'Выиграл игрок 1!';
     lpCaption := 'Игра закончена';
     Tip := MB_OK+MB_ICONINFORMATION;
     with Application do
       begin
          MessageBox(lpText, lpCaption, Tip);
       end;
     Form2.Show;
   end;
  Button3.Click;
end;

{Функция проверки наличия слова в словаре и среди использованных слов}
function TForm1.WordCheck(s:string):boolean;
  var
    i,Tip : integer;
    flag : boolean;
    slovar : TextFile;
    words : string;
    WND : HWND;
    lpText,lpCaption : PChar;
  begin
    flag := False;
    AssignFile(slovar, 'vocabulary/words.dat');
    reset(slovar);
    while (not EOF(slovar)) do
      begin
        Readln(slovar, words);
        words := AnsiUpperCase(words);
        if (s = words) then
          begin
            flag := True;
            break;
          end;
      end;
    closefile(slovar);
    if (flag = False) then
      begin
        Tip := MB_OK+MB_ICONERROR;
        lpText := 'Вашего слова нет в словаре!';
        lpCaption := 'Ошибка!';
        with Application do
          begin
            MessageBox(lpText, lpCaption, Tip);
          end;
      end
    else
      for i := 0 to 255 do
        begin
          if (UsedWords[i] = s) then
            begin
              Tip := MB_OK+MB_ICONWARNING;
              lpText := 'Слово уже было использовано!';
              lpCaption := 'Предупреждение!';
              with Application do
                begin
                  MessageBox(lpText, lpCaption, Tip);
                end;
              flag := False;
            end;
        end;
    WordCheck := flag;
  end;

{Процедура запуска новой игры или завершения предыдущей}
procedure TForm1.Button3Click(Sender: TObject);
var
  i,j : integer;
  flag : boolean;
  words : textfile;
begin
 iSize := TBSize.Position;
 if Game then
   begin
     flag := True;
     if ((Label2.Caption = 'Игрок') and (Label2.Font.Style = [fsBold])) or (Label3.Caption = 'Игрок №2') then
       begin
         Button2.Enabled := True;
         Button1.Enabled := True;
         Button4.Enabled := True;
       end;
     Button3.Caption := 'Новая игра';
     Game := False;
     if (Label3.Caption = 'Игрок №2') then
       begin
         Label2.Font.Style := [fsBold];
         Label3.Font.Style := [];
         RadioButton1.Enabled := False;
         RadioButton2.Enabled := False;
       end;
      TBSize.Enabled := false;
      if bool then
      begin
        for i := ListBox1.Items.Count - 1 downto 0 do
          begin
            ListBox1.Items.Delete(i);
          end;
        for i := ListBox2.Items.Count - 1 downto 0 do
          begin
            ListBox2.Items.Delete(i);
          end;
      end;
      bool := true;
      for i:=0 to ComponentCount-1 do
        if (Copy(Components[i].Name,1,4) = 'Grid') then
            begin
              for j := 1 to 9 do
                begin
                  if Rezerved_letters[j] = Components[i].Name then
                    flag := False;
                end;
              if flag then
                TEdit(Components[i]).ReadOnly := False;
              flag := True;
            end;
     if  (Label3.Caption = 'Компьютер') and (Label3.Font.Style = [fsBold]) then
       begin
         for j:=0 to ComponentCount-1 do
           if (Copy(Components[j].Name,1,4) = 'Grid') then
             begin
               TEdit(Components[j]).ReadOnly := True;
             end;
         Computer();
       end;
   end
 else
   begin
     for i := ListBox1.Items.Count - 1 downto 0 do
       begin
         ListBox1.Items.Delete(i);
       end;
     for i := ListBox2.Items.Count - 1 downto 0 do
       begin
         ListBox2.Items.Delete(i);
       end;
      Button2.Enabled := False;
      Button1.Enabled := False;
      Button4.Enabled := False;
      Button3.Caption := 'Начать игру';
      Game := True;
      Label2.Font.Style := [];
      Label3.Font.Style := [];
      RadioButton1.Enabled := True;
      RadioButton2.Enabled := True;
      TBSize.Enabled := True;
      TBSizeChange(Sender);
      if f then
        Form2.Show;
      Assignfile(words,'users_words');
      Rewrite(words);
      writeln(words,'слова игрока 1:');
      for i := 1 to 255 do
        begin
          if (i mod 2 <> 0) and (UsedWords[i] <> '') then
            begin
              write(words,UsedWords[i]);
              write(words,'; ');
            end;
        end;
      writeln(words,'');
      write(words,'очки:');
      writeln(words,IntToStr(len_1));
      writeln(words,'');
      writeln(words,'слова игрока 2:');
      for i := 1 to 255 do
        begin
          if (i mod 2 = 0) and (UsedWords[i] <> '') then
            begin
              write(words,UsedWords[i]);
              write(words,'; ');
            end;
        end;
      writeln(words,'');
      write(words,'очки:');
      writeln(words,IntToStr(len_2));
      writeln(words,'');
      write(words,'итого:');
      writeln(words,Form2.Label5.Caption);
      closefile(words);
   end;
end;

{Процедура отмены хода}
procedure TForm1.Button4Click(Sender: TObject);
var
  j,i : integer;
  flag: boolean;
begin
  Beep;
  for j:=0 to ComponentCount-1 do
    begin
      flag := True;
      if (Components[j].Name = grid_number) then
        begin
          TEdit(Components[j]).Text := ' ';
          TEdit(Components[j]).ReadOnly := False;
          Xod := True;
        end;
       for i := 1 to 9 do
         begin
           if Rezerved_letters[i] = Components[j].Name then
           flag := False;
         end;
      if (Copy(Components[j].Name,1,4) = 'Grid') and flag then
        TEdit(Components[j]).ReadOnly := False;
    end;
end;

{Процедура возврата на главное меню}
procedure TForm1.Button5Click(Sender: TObject);
var
  F2 : textfile;
  i,j,k : integer;
  A1 : TMas1;
  fl : boolean;
begin
  AssignFile(F2,'game_process.txt');
  Rewrite(F2);
  SetLength(A1,iSize,iSize);
  fl := false;
  for i := 0 to iSize-1 do
    for j := 0 to iSize-1 do
      begin
        for k:=0 to ComponentCount-1 do
          if (Copy(Components[k].Name,1,6) = 'Grid' + IntToStr(i+1) + IntToStr(j+1)) then
            begin
              A1[i,j] := TEdit(Components[k]).Text;
              if A1[i,j] = ' ' then
                begin
                  fl := true;
                  A1[i,j] := '*';
                end;
            end;
      end;
  if fl then
    begin
      writeln(F2,iSize);
      for i := 0 to iSize-1 do
        begin
          for j := 0 to iSize-1 do
            begin
              writeln(F2,A1[i,j]);
            end;
        end;
      for i := 0 to 255 do
        begin
          if UsedWords[i] <> '' then
            begin
              writeln(F2,UsedWords[i]);
            end;
        end;
    end;
  CloseFile(F2);
  Game := False;
  f := false;
  Button3.Click;
  Form6.Show;
  Form1.Hide;
end;

{Очистка игрового поля после закрытия}
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin

end;

{Процедура генерирования игрового пространства в момент запуска приложения}
procedure TForm1.FormCreate(Sender: TObject);
var
  vocabulary : TextFile;
  s : string;
  i : integer;
  tec_root : tree;
begin
  iSize := TBSize.Position;
  LevelText.Caption := 'Уровень сложности - ' +  IntToStr(iSize) + ' x ' + IntToStr(iSize);
  TBSizeChange(Sender);
  CurrentPlayer := True;
  Label2.Font.Style := [];
  Label3.Font.Style := [];
  SlovoStep := True;
  Game := True;
  Button2.Enabled := False;
  Button1.Enabled := False;
  Button4.Enabled := False;
  Xod := True;
  len_1 := 0;
  len_2 := 0;
  f := true;
////////////////////////////////
  s := 'my_vocabulary.dat';
   New(root);
   root^.element := '';
   root^.word := '';
   for i := 1 to 32 do
     begin
       root^.mas[i] := Nil;
     end;
  head_root := root;
  AssignFile(vocabulary, s);
  reset(vocabulary);
  while (not EOF(vocabulary)) do begin
    Readln(vocabulary, s);
    i := 1;
    tec_root := root;
    Add_root(tec_root,s,i,tec_root);
  end;
  CloseFile(vocabulary);
////////////////////////////////
end;

{Процедура возвращения в исходное положение подсвечиваемой клетки компьютера}
procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
var
  k : integer;
begin
   if Key = #13 then
  begin
  for k:=0 to ComponentCount-1 do
    if (Copy(Components[k].Name,1,6) = 'Grid' + IntToStr(iD) + IntToStr(jD)) then
      begin
        TEdit(Components[k]).Color := clSkyBlue;
      end;
  end;
  if key = #27 Then
    begin
      Button5.Click;
    end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  f := true;
end;

procedure TForm1.GridCreate(iSize:integer); //создание игрового пространства
var
  i, j: integer;
begin
  for i:=1 to iSize do
    for j:=1 to iSize do
    with TEdit.Create(Self) do
          begin
            Left:= (i-1)*(315 div iSize);
            Top:= (j-1)*(315 div iSize);
            Alignment := taCenter;
            Text:=' ';
            AutoSize := false;
            Width:= 315 div iSize;
            Height:=315 div iSize;
            Name := 'Grid' + IntToStr(j)+ IntToStr(i);
            OnClick := Click;
            OnExit := Leave;
            Enabled := True;
            Color  := clSkyBlue;
            Font.Size := Height div 3;
            MaxLength := 1;
            CharCase := ecUpperCase;
            Parent:=GameZone;
            ReadOnly := True;
          end;
end;

{Отработка нажатия на игровом поле}
procedure TForm1.Click(Sender: TObject);
var
  j : integer;
begin
  if (TEdit(Sender).ReadOnly = false) and (Access_To_Grid(Sender) = True) and (SlovoStep) and (Xod) and (TEdit(Sender).Text = ' ') then
    begin
    TEdit(Sender).Text := '';
    TEdit(Sender).Color := clWhite;
    grid_number := TEdit(Sender).Name;
   end;
  if Xod = False then
    begin
      for j:=0 to ComponentCount-1 do
        if (Copy(Components[j].Name,1,4) = 'Grid') then
            begin
              TEdit(Components[j]).ReadOnly := True;
            end;
    end;
  HideCaret(TEdit(Sender).Handle);//прячем курсор
  if TEdit(Sender).Color = clYellow then
     begin
       if (Access_To_Choose(Sender) and (TEdit(Sender).Text <> ' ')) then
         begin
           slovo := slovo + TEdit(Sender).Text;
           TEdit(Sender).Color := clSkyBlue;
           Xod := True;
         end;
     end;
end;

{Процедура очистки поля для поиска слова}
procedure TForm1.Edit1Click(Sender: TObject);
begin
  Edit1.Text := '';
end;

{Процедура поиска слова в словаре при нажатии на Enter}
procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: Char);
var
  Define : TextFile;
  flag : boolean;
begin
  if Key = #13 then
    begin
      flag := False;
      AssignFile(Define, 'vocabulary/words_with_definition.dat');
      reset(Define);
      while (not EOF(Define)) do begin
        Readln(Define, mean);
        if AnsiUpperCase(Copy(mean,1,length(Edit1.Text))) = AnsiUpperCase(Edit1.Text) then
          begin
            flag := true;
            break;
          end;
        if flag then break;

      end;
      if (flag = false) then
        mean := 'Ничего не найдено!';
      closefile(Define);
      Form5.Show;
    end;
end;

{Функция проверяющая на возможность хода в текущей ячейке игрового поля}
function TForm1.Access_To_Grid(Sender: TObject):boolean;
var
  name,stroka,stolbec : string;
  i,j,k : integer;
  flag : boolean;
  begin
    flag := False;
    name := TEdit(Sender).Name;
    stroka := Copy(name,5,1);
    stolbec := Copy(name,6,1);
    i := StrToInt(stroka);
    j := StrToInt(stolbec);
    for k:=0 to ComponentCount-1 do
      if (Components[k].Name = 'Grid' + IntToStr(i+1) + IntToStr(j) ) then
        begin
          if (TEdit(Components[k]).Text <> ' ') then
            flag := True;
        end;
    for k:=0 to ComponentCount-1 do
      if (Components[k].Name = 'Grid' + IntToStr(i-1) + IntToStr(j) ) then
        begin
          if (TEdit(Components[k]).Text <> ' ') then
            flag := True;
        end;
    for k:=0 to ComponentCount-1 do
      if (Components[k].Name = 'Grid' + IntToStr(i) + IntToStr(j+1) ) then
        begin
          if (TEdit(Components[k]).Text <> ' ') then
            flag := True;
        end;
    for k:=0 to ComponentCount-1 do
      if (Components[k].Name = 'Grid' + IntToStr(i) + IntToStr(j-1) ) then
        begin
          if (TEdit(Components[k]).Text <> ' ') then
            flag := True;
        end;
    Access_To_Grid := flag;
  end;

{Функция проверяющая возможность выделить текущую ячейку на игровом поле для слова}
function TForm1.Access_To_Choose(Sender: TObject):boolean;
var
  i,j,i1,j1,k : integer;
  flag : boolean;
  begin
    flag := False;
     for k:=0 to ComponentCount-1 do
      if (Copy(Components[k].Name,1,4) = 'Grid') then
        begin
          if (TEdit(Components[k]).Color = clYellow) then
            begin
              flag := True;
            end;
          if (TEdit(Components[k]).Color = clSkyBlue) then
            begin
              flag := False;
              break;
            end;
        end;
    if (flag = False) then
      begin
        i := StrToInt(Copy(pred_number,5,1));
        j := StrToInt(Copy(pred_number,6,1));
        i1 := StrToInt(Copy(TEdit(Sender).Name,5,1));
        j1 := StrToInt(Copy(TEdit(Sender).Name,6,1));
        if ((j1-1 = j) and (i = i1)) then
          flag := True;
        if ((j1+1 = j) and (i = i1)) then
          flag := True;
        if ((j1 = j) and (i1 = i+1)) then
          flag := True;
        if ((j1 = j) and (i1 = i-1)) then
          flag := True;
      end;
    Access_To_Choose := flag;
  end;

{Процедура отработки выхода из текущей ячейки}
procedure TForm1.Leave(Sender: TObject);
var
  s,check : string;
  c : char;
  i : integer;
  flag : boolean;
begin
  flag := True;
  if (TEdit(Sender).Text = '') then
    begin
      TEdit(Sender).Text := ' ';
    end
  else
    begin
      s := TEdit(Sender).Text;
      c := s[1];
      if ((ord(c)<1040) or (ord(c)>1103)) then //русские буквы
        begin
          TEdit(Sender).Text := ' ';
        end
      else
        begin
          check := TEdit(Sender).Name;
          for i := 1 to 9 do
                begin
                  if Rezerved_letters[i] = check then
                    flag := False;
                end;
          if flag then
            begin
              TEdit(Sender).ReadOnly := True;
              Xod := False;
            end;
        end;
    end;
  if  TEdit(Sender).Color <> clYellow then
    TEdit(Sender).Color := clSkyBlue;
  if  TEdit(Sender).Color = clSkyBlue then
    pred_number := TEdit(Sender).Name;
end;

procedure TForm1.RadioButton1Click(Sender: TObject);
begin
  Label2.Caption := 'Игрок №1';
  Label3.Caption := 'Игрок №2';
end;

procedure TForm1.RadioButton2Click(Sender: TObject);
begin
  Label2.Caption := 'Игрок';
  Label3.Caption := 'Компьютер';
  Form4.Show;
end;

procedure TForm1.GridClear;  //очистка старых компонентов
var
  i: integer;
  flag: boolean;
begin
  repeat
    begin
      flag := true;
      for i:=0 to ComponentCount-1 do
        begin
          if (Copy(Components[i].Name,1,4) = 'Grid') then
            begin
              TPanel(Components[i]).Free;
              flag := false;
              break;
            end;
        end;
    end;
  until (flag);

end;

{Процедура изменения уровня сложности игрового поля}
procedure TForm1.TBSizeChange(Sender: TObject);
var
  j,int,i,r,k: integer;
  slovar : TextFile;
  s : string;
begin
  k := 0;
  randomize;
  r := random(100)+2;
  GridClear();
  iSize := TBSize.Position;
  LevelText.Caption := 'Уровень сложности - ' +  IntToStr(iSize) + ' x ' + IntToStr(iSize);
  GridCreate(iSize);
  AssignFile(slovar, 'vocabulary/words.dat');
  reset(slovar);
  while (not EOF(slovar)) do begin
    Readln(slovar, s);
    if (length(s)= iSize) then
      begin
        inc(k);
        if (k = r) then
          break;
      end;
  end;
  closefile(slovar);
  int := iSize div 2 + 1;

  UsedWords[0] := AnsiUpperCase(s);
  i := 1;
  k := 0;
  for j:=0 to ComponentCount-1 do
    if (Copy(Components[j].Name,1,5) = 'Grid'+ IntToStr(int)) then
      begin
        inc(k);
        TEdit(Components[j]).Text := Copy(s,i,1);
        inc(i);
        TEdit(Components[j]).ReadOnly := True;
        Rezerved_letters[k] := Components[j].Name;
      end;
end;

{Загрузка игры}
procedure TForm1.LoadGame;
var
  i,j,ii,jj,i1,t : integer;
  WW : array of string;
  e,p : string;
begin
   SetLength(WW, StrToInt(Unit6.W[0])*StrToInt(Unit6.W[0]));
   for i := 0 to StrToInt(Unit6.W[0])*StrToInt(Unit6.W[0])-1 do
     begin
       WW[i] := Unit6.W[i+1];
     end;
   t := i;
   i := 0;
   ii := 1;
   jj := 1;
   i1 := 0;
   for j:=0 to ComponentCount-1 do
     if (Copy(Components[j].Name,1,6) = 'Grid' + IntToStr(ii) + IntToStr(jj)) then
       begin
         if Copy(WW[i],1,1) = '*' then
           e := ' ';
         if Copy(WW[i],1,1) <> '*' then
           e := Copy(WW[i],1,1);
         TEdit(Form1.Components[j]).Text := e;
         i := i + StrToInt(Unit6.W[0]);
         inc(ii);
         if ii > StrToInt(Unit6.W[0]) then
           begin
             inc(jj);
             ii := 1;
           end;
          if i >= StrToInt(Unit6.W[0])*StrToInt(Unit6.W[0]) then
            begin
              inc(i1);
              i := i1;
            end;

       end;
  j := 0;
  for i := 0 to 255 do
    begin
      UsedWords[i] := '';
    end;
  for i := t+1 to Length(Unit6.W)-1 do
    begin
      UsedWords[j] := Unit6.W[i];
      inc(j);
    end;
  for i := 1 to 255 do
    if UsedWords[i] <> '' then
      begin
        if i mod 2 <> 0 then
          begin
            p := UsedWords[i] + ' - ' + IntToStr(length(UsedWords[i]));
            ListBox1.Items.Add(p);
          end;
        if i mod 2 = 0 then
          begin
            p := UsedWords[i] + ' - ' + IntToStr(length(UsedWords[i]));
            ListBox2.Items.Add(p);
          end;
      end;
 bool := false;
end;
end.
