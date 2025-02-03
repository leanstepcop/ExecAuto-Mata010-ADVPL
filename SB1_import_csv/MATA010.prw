#Include 'Totvs.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} xImpProd
@description Função para execução da rotina.
@type function
@author Leandro Augusto da Silva Azevedo    
@since 27/01/2025
/*/
//-------------------------------------------------------------------

User Function xImpProd()

	Local aDados := CsvRead()

	if aDados != NIL
		createProd(aDados)
	endif
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CsvRead
@description Função para import de dados vindos de arquivos csv.
@type function
@author Leandro Augusto da Silva Azevedo    
@since 27/01/2025
/*/
//-------------------------------------------------------------------

Static Function  CsvRead()

	Local   cFile   := ""
	Local   nHandle := 0
	Local   cLinha  := ""
	Local   aLinha  := {}
	Local   lPrim   := .T.
	Local   aCampos := {}
	Local   aDados  := {}

//selecionar o caminho do arquivo
	cFile   := cGetFile("Files CSV|*.csv", "Select csv File", 0, , .F., GETF_LOCALHARD, .T., .T.)

//trava o arquivo para uso
	nHandle := FT_FUSE(cFile)

//valida se há erro na abertura do arquivo 
	if nHandle = -1
		Return(NIL)
	endif

//Posiciona para a primeira linha
	FT_FGoTop()

//Enquanto não for o final do arquivo, continua o processo
	Do While !FT_FEOF()

		//le o conteudo da linha poscionada - no caso o cabeçalho
		cLinha  := FT_FREADLN()

		if lPrim
			aCampos = Separa(cLinha, ";", .T.)
			lPrim := .F.
		else
			aLinha = Separa(cLinha, ";", .T.)
			AAdd(aDados, aLinha)
		endif

		//Passa para a próxima linha
		FT_FSKIP()
	EndDo

//fecha o arquivo
	FT_FUSE()
Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} createProd
@description Função para inclusão de dados (Produtos) vindos do arquivo csv lido..
@type function
@author Leandro Augusto da Silva Azevedo    
@since 30/01/2025
/*/
//-------------------------------------------------------------------

Static Function createProd(aDados)

	Local   aMata010  		:= {}
	Local   nI      		:= 0
	Local	lMsErroAuto		:= .F.
	Local 	cMensagem		:= ""

	//loop para inclusão dos dados nos respectivos campos da tabela SB1
	for nI := 1 to Len(aDados)

	//Zera o conteúdo do array aMata010 para incluir o próximo produto
		aMata010 = {}

		aMata010 := { AAdd(aMata010, {'B1_COD', aDados[nI][1], NIL}),;
			AAdd(aMata010, {'B1_DESC', aDados[nI][2], NIL}),;
			AAdd(aMata010, {'B1_TIPO', aDados[nI][3], NIL}),;
			AAdd(aMata010, {'B1_UM', aDados[nI][4], NIL}),;
			AAdd(aMata010, {'B1_LOCPAD', aDados[nI][5], NIL}),;
			AAdd(aMata010, {'B1_GRUPO', aDados[nI][6], NIL})}

	//Inclusão dos registros do array via MSExecAuto
		MSExecAuto({ |x,y| mata010(x,y)}, aMata010, 3)
	next nI

	//Trativa de erros
	If lMsErroAuto
		Mostraerro()
		Return .F.
	else
		cMensagem := "Incluído na data de hoje - " + dToC(Date())
		FWAlertSuccess(cMensagem, "Produto(s) cadastrado com sucesso!")
	endif
Return .T.
