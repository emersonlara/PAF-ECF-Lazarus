unit SessaoUsuario;

interface

uses Classes, Forms, Windows, IniFiles, SysUtils, UsuarioVO, EmpresaVO, Biblioteca, md5;

type
  TSessaoUsuario = class
  private
    FUrl: String;
    FIdSessao: String;
    FUsuario: TUsuarioVO;
    FEmpresa: TEmpresaVO;

    class var FInstance: TSessaoUsuario;
  public
    constructor Create;
    destructor Destroy; override;

    class function Instance: TSessaoUsuario;

    function AutenticaUsuario(pLogin, pSenha: String): Boolean;

    //Permiss�es
    function Autenticado: Boolean;

    property URL: String read FUrl;
    property IdSessao: String read FIdSessao;
    property Usuario: TUsuarioVO read FUsuario;
    property Empresa: TEmpresaVO read FEmpresa write FEmpresa;
  end;

implementation

{ TSessaoUsuario }

constructor TSessaoUsuario.Create;
var
  Ini: TIniFile;
  Servidor: String;
  Porta: Integer;
begin
  inherited Create;

  Ini := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'Conexao.ini');
  try
    with Ini do
    begin
      if not SectionExists('ServidorApp') then
      begin
        WriteString('ServidorApp','Servidor','localhost');
        WriteInteger('ServidorApp','Porta',8080);
      end;

      Servidor := ReadString('ServidorApp','Servidor','localhost');
      Porta := ReadInteger('ServidorApp','Porta',8080);
    end;
  finally
    Ini.Free;
  end;

  FUrl := 'http://' + Servidor + ':' + IntToStr(Porta) + '/cgi-bin/servidorT2Ti.cgi/';
end;

destructor TSessaoUsuario.Destroy;
begin
  FUsuario.Free;
  FEmpresa.Free;

  inherited;
end;

class function TSessaoUsuario.Instance: TSessaoUsuario;
begin
  if not Assigned(FInstance) then
  begin
    FInstance := TSessaoUsuario.Create;
    FInstance.Empresa := TEmpresaVO.Create;
    FInstance.Empresa.Id := 1;
    FInstance.Empresa.RazaoSocial := 'EMPRESA MATRIZ PARA TESTES';
    FInstance.Empresa.Cnpj := '00000000000191';
  end;

  Result := FInstance;
end;

function TSessaoUsuario.Autenticado: Boolean;
begin
  Result := Assigned(FUsuario);
end;

function TSessaoUsuario.AutenticaUsuario(pLogin, pSenha: String): Boolean;
var
  SenhaCript: String;
begin
  FIdSessao := CriaGuidStr;
  FIdSessao := MD5Print(MD5String(FIdSessao));
  try
    //Senha � criptografada com a senha digitada + login
//    SenhaCript := TUsuarioController.CriptografarLoginSenha(pLogin,pSenha);

//    FUsuario := TUsuarioController.Usuario(pLogin,pSenha);
    FUsuario.Senha := pSenha;

    Result := Assigned(FUsuario);
  except
    Application.MessageBox('Erro ao autenticar usu�rio.','Erro de Login', MB_OK+MB_ICONERROR);
    raise;
  end;
end;

end.
