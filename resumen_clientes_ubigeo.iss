Sub Main
	IgnoreWarning(True)
	Call AppendField()	'Ejemplo-Clientes.IMD
	Call AppendField1()	'Ejemplo-Clientes.IMD
	Call DirectExtraction()	'Ejemplo-Clientes.IMD
	Call AppendField2()	'EXTRACCIÓN1.IMD
	Call JoinDatabase()	'EXTRACCIÓN1.IMD
	Call Summarization()	'Ejemplo-Detalle de ventas.IMD
	Call JoinDatabase1()	'Resumen_Cliente.IMD
	Call ExportDatabaseXLSX()	'Resumen_Clientes_UBIGEO.IMD
	Client.RefreshFileExplorer
End Sub

' Anexar campo
Function AppendField
	Set db = Client.OpenDatabase("Ejemplo-Clientes.IMD")
	Set task = db.TableManagement
	Set field = db.TableDef.NewField
	field.Name = "UBIGEO1"
	field.Description = ""
	field.Type = WI_VIRT_NUM
	field.Equation = "150101"
	field.Decimals = 0
	task.AppendField field
	task.PerformTask
	Set task = Nothing
	Set db = Nothing
	Set field = Nothing
End Function

' Anexar campo
Function AppendField1
	Set db = Client.OpenDatabase("Ejemplo-Clientes.IMD")
	Set task = db.TableManagement
	Set field = db.TableDef.NewField
	field.Name = "UBIGEO2"
	field.Description = ""
	field.Type = WI_VIRT_NUM
	field.Equation = "@random(42)"
	field.Decimals = 0
	task.AppendField field
	task.PerformTask
	Set task = Nothing
	Set db = Nothing
	Set field = Nothing
End Function

' Datos: Extracción directa
Function DirectExtraction
	Set db = Client.OpenDatabase("Ejemplo-Clientes.IMD")
	Set task = db.Extraction
	task.IncludeAllFields
	dbName = "EXTRACCIÓN1.IMD"
	task.AddExtraction dbName, "", ""
	task.CreateVirtualDatabase = False
	task.PerformTask 1, db.Count
	Set task = Nothing
	Set db = Nothing
	Client.OpenDatabase (dbName)
End Function

' Anexar campo
Function AppendField2
	Set db = Client.OpenDatabase("EXTRACCIÓN1.IMD")
	Set task = db.TableManagement
	Set field = db.TableDef.NewField
	field.Name = "UBIGEO3"
	field.Description = ""
	field.Type = WI_VIRT_CHAR
	field.Equation = "@Str( (  UBIGEO1  +  UBIGEO2 );6;0)"
	field.Length = 6
	task.AppendField field
	task.PerformTask
	Set task = Nothing
	Set db = Nothing
	Set field = Nothing
End Function

' Archivo: Unir bases de datos
Function JoinDatabase
	Set db = Client.OpenDatabase("EXTRACCIÓN1.IMD")
	Set task = db.JoinDatabase
	task.FileToJoin "geodir-ubigeo-inei.IMD"
	task.IncludeAllPFields
	task.IncludeAllSFields
	task.AddMatchKey "UBIGEO3", "UBIGEO", "A"
	task.CreateVirtualDatabase = False
	dbName = "Unir bases de datos3.IMD"
	task.PerformTask dbName, "", WI_JOIN_ALL_IN_PRIM
	Set task = Nothing
	Set db = Nothing
	Client.OpenDatabase (dbName)
End Function


' Análisis: Resumen
Function Summarization
	Set db = Client.OpenDatabase("Ejemplo-Detalle de ventas.IMD")
	Set task = db.Summarization
	task.AddFieldToSummarize "NUM_CLI"
	task.AddFieldToTotal "TOTAL"
	dbName = "Resumen_Cliente.IMD"
	task.OutputDBName = dbName
	task.CreatePercentField = FALSE
	task.StatisticsToInclude = SM_SUM
	task.PerformTask
	Set task = Nothing
	Set db = Nothing
	Client.OpenDatabase (dbName)
End Function

' Archivo: Unir bases de datos
Function JoinDatabase1
	Set db = Client.OpenDatabase("Resumen_Cliente.IMD")
	Set task = db.JoinDatabase
	task.FileToJoin "Unir bases de datos3.IMD"
	task.IncludeAllPFields
	task.IncludeAllSFields
	task.AddMatchKey "NUM_CLI", "NUM_CLI", "A"
	task.CreateVirtualDatabase = False
	dbName = "Resumen_Clientes_UBIGEO.IMD"
	task.PerformTask dbName, "", WI_JOIN_ALL_IN_PRIM
	Set task = Nothing
	Set db = Nothing
	Client.OpenDatabase (dbName)
End Function

' Archivo-Exportar base de datos: XLSX
Function ExportDatabaseXLSX
	Set db = Client.OpenDatabase("Resumen_Clientes_UBIGEO.IMD")
	Set task = db.ExportDatabase
	task.IncludeAllFields
	eqn = ""
	task.PerformTask "C:\Users\Intel\Documents\Mis documentos IDEA\Samples\Exportaciones.ILB\Resumen_Clientes_UBIGEO.XLSX", "Database", "XLSX", 1, db.Count, eqn
	Set db = Nothing
	Set task = Nothing
End Function

