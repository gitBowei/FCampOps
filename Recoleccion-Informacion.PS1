# En el marco del soporte ofrecido por los servicios de Microsoft Premier Services, Recorremos su infraestructura realizando una revisión de la plataforma directorio activo, y Exchange.
# Identificar los servidores
# Controladores de dominio

# Cuál es el nivel funcional del dominio?

# Qué nivel funcional tiene el Forest?

# Cuantos servidores hay? Cuales?

# Cuantos Sites componen este dominio?
 
# Hay subdominios?
 
# Que políticas existen?
  
# Cuantos clientes hay?
 
# Que administradores hay?
 
# Hay procedimientos de backup?
 
# Cuando se actualizo por última vez estos equipos?
 
# Cuál de los servidores tiene los roles FSMO.?
 
# Tiene monitoreo de performance?
  
# Cuanto espacio libre tiene en disco duro?
Get-Volume | Select-Object –Property DriveLetter,  @{    n='Size(GB)';    e={'{0:N2}' -f ($PSItem.Size / 1GB)}  },  @{    n='FreeSpace(GB)';    e={'{0:N2}' -f ($PSItem.SizeRemaining / 1GB)}  }
  
# Que tamaño tiene el archivo c:\windows\system32\ntds\ntds.dit?
  
# Que errores visibles hay en el visor de eventos?
   
# Que solución de antivirus tiene?
  
# Como está la distribución de las unidades Organizacionales? 

# Exchange
# Que versión está instalada?
  
# Cuantos servidores hay?
  
# Que roles tiene cada servidor?
  
# Cuantas bases de datos hay?
  
# Cuáles son las direcciones públicas (mx)?
  
# Que proveedor de certificados digitales usa?
  
# Qué fecha de vencimiento tiene el certificado de correo?
  
# Hay protección antiSpam?
  
# Que tamaño tienen los buzones?

# Cuál es el tamaño máximo de envió?
  
# Como se llama el sitio de acceso web?
  
# Está habilitado el ECP? El anywhere? 

# Hay un esquema de backup?
  
# Se ha actualizado el sistema operativo? La aplicación de Exchange?
  
# Como esta de espacio en disco duro?
Get-Volume | Select-Object –Property DriveLetter,  @{    n='Size(GB)';    e={'{0:N2}' -f ($PSItem.Size / 1GB)}  },  @{    n='FreeSpace(GB)';    e={'{0:N2}' -f ($PSItem.SizeRemaining / 1GB)}  }

# Que tal anda de performance?
  
# Que proveedor de internet usa?
  
# Que ancho de banda tiene?
