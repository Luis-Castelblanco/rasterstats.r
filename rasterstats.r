#_____________________________#
#         r�ster stats        #
#_____________________________#


# Instala las bibliotecas si a�n no est�n instaladas
# install.packages(c("raster", "sf"))

library(raster)
library(sf)
setwd('C:\\Users\\luisf\\OneDrive - UNIVERSIDAD NACIONAL AUT�NOMA DE M�XICO\\Maestria\\Tesis\\SMAP L4C\\test')

# Rutas de las carpetas con rasters y el raster de categor�as
carpeta_rasters <- "C:\\Users\\luisf\\OneDrive - UNIVERSIDAD NACIONAL AUT�NOMA DE M�XICO\\Maestria\\Tesis\\SMAP L4C\\test\\"
raster_categorias <- "DeltaBosque.tif"

# Obt�n la lista de rasters en la carpeta
lista_rasters <- list.files(carpeta_rasters, pattern = "\\MEXICO.tif$", full.names = TRUE)

# Crea un data frame para almacenar los resultados
resultados_df <- data.frame(Raster = character(),
                            Categoria = integer(),
                            Media = numeric(),
                            DesviacionEstandar = numeric(),
                            Minimo = numeric(),
                            Maximo = numeric(),
                            stringsAsFactors = FALSE)

# Abre el raster de categor�as
raster_categorias <- raster(raster_categorias)

# Itera sobre cada raster en la carpeta
for (raster_path in lista_rasters) {
  # Abre el raster de inter�s
  raster_datos <- raster(raster_path)
  
  # Convierte los rasters a data frames
  datos_df <- as.data.frame(raster_datos, xy = TRUE)
  categorias_df <- as.data.frame(raster_categorias, xy = TRUE)
  
  # Combina los data frames por coordenadas
  datos_combinados <- merge(datos_df, categorias_df, by = c("x", "y"))
  
  # Etiqueta las categor�as en el raster de inter�s
  datos_combinados$Categoria <- factor(datos_combinados$layer)
  
  # Calcula las estad�sticas para cada categor�a
  estadisticas <- aggregate(cbind(layer) ~ Categoria, data = datos_combinados, FUN = function(x) c(mean(x), sd(x), min(x), max(x)))
  
  # A�ade los resultados al data frame
  resultados_df <- rbind(resultados_df, data.frame(
    Raster = basename(raster_path),
    Categoria = estadisticas$Categoria,
    Media = estadisticas$layer[, 1],
    DesviacionEstandar = estadisticas$layer[, 2],
    Minimo = estadisticas$layer[, 3],
    Maximo = estadisticas$layer[, 4]
  ))
  # Limpieza de memoria
  rm(list = ls(pattern = "raster"))
  
  gc()  # Recoge la basura para liberar memoria
}

# Guarda los resultados en un archivo CSV
write.csv(resultados_df, "/ruta/donde/guardar/resultados.csv", row.names = FALSE)
