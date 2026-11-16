-- Creacion de la Base de datos
CREATE DATABASE IF NOT EXISTS Aspersion_Drones;
USE Aspersion_Drones;

-- Limpieza  de las tablas
-- Limpieza de las tablas (primero las hijas, luego las padres)
DROP TABLE IF EXISTS Formulario_Cierre;
DROP TABLE IF EXISTS Suspension;
DROP TABLE IF EXISTS Condicion_Clima;
DROP TABLE IF EXISTS Vuelo;
DROP TABLE IF EXISTS Item_No_Cumplido;
DROP TABLE IF EXISTS Item_Chequeo;
DROP TABLE IF EXISTS Preoperacional;
DROP TABLE IF EXISTS Orden_Producto;
DROP TABLE IF EXISTS Orden_Servicio;
DROP TABLE IF EXISTS Mantenimiento;
DROP TABLE IF EXISTS Dosis_Recomendada;
DROP TABLE IF EXISTS Dron;
DROP TABLE IF EXISTS Lote;
DROP TABLE IF EXISTS Producto;
DROP TABLE IF EXISTS Modelo_Dron;
DROP TABLE IF EXISTS Cultivo;
DROP TABLE IF EXISTS Finca;
DROP TABLE IF EXISTS Piloto;
DROP TABLE IF EXISTS Cliente;
DROP TABLE IF EXISTS Persona;


-- Creacion de las tablas
-- Personas

CREATE TABLE Persona (
	id_persona INT NOT NULL PRIMARY KEY,
    rol VARCHAR(7) NOT NULL,
    tipo_persona VARCHAR(8) NOT NULL,
    tipo_documento VARCHAR(3) NOT NULL,
    numero_documento VARCHAR(12) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    telefono VARCHAR(10),
    correo VARCHAR(25),
    fecha_registro DATE NOT NULL,
    CONSTRAINT persona_rol_uk UNIQUE (id_persona,rol),
    CONSTRAINT persona_documento_uk UNIQUE (tipo_documento, numero_documento),
    CONSTRAINT persona_rol_chk CHECK (rol IN ('CLIENTE', 'PILOTO')),
    CONSTRAINT persona_tipo_persona_chk CHECK (tipo_persona IN ('NATURAL', 'JURIDICA')),
    CONSTRAINT persona_tipo_documento_chk CHECK (tipo_documento IN ('CC', 'CE','NIT')),
    CONSTRAINT persona_numero_documento_chk CHECK (numero_documento REGEXP '^[0-9]{6,12}$'),
    CONSTRAINT persona_nombre_chk CHECK (CHAR_LENGTH(TRIM(nombre)) > 0),
    CONSTRAINT persona_telefono_chk CHECK (telefono REGEXP '^3[0-9]{9}$'),
	CONSTRAINT persona_correo_chk CHECK (correo IS NULL or correo LIKE '%@%.%')
);
CREATE TABLE Cliente (
	id_cliente INT NOT NULL PRIMARY KEY,
    rol VARCHAR (7) NOT NULL,
    segmento VARCHAR(7) NOT NULL,
    CONSTRAINT cliente_fk_rol_id_cliente FOREIGN KEY (id_cliente, rol) REFERENCES Persona(id_persona, rol),
    CONSTRAINT cliente_rol_cliente_chk CHECK (rol = 'CLIENTE'),
    CONSTRAINT cliente_segmento_chk CHECK (segmento IN ('PEQUENO', 'MEDIANO', 'GRANDE'))
);
CREATE TABLE Piloto (
	id_piloto INT NOT NULL PRIMARY KEY,
    rol VARCHAR(7) NOT NULL,
    codigo_empleado VARCHAR(7) NOT NULL UNIQUE,
    fecha_vinculacion DATE NOT NULL,
    fecha_certificacion DATE NOT NULL,
    vencimiento_certificacion DATE NOT NULL,
    estado VARCHAR(8) NOT NULL,
    CONSTRAINT piloto_fk_rol_id_piloto FOREIGN KEY (id_piloto, rol) REFERENCES Persona(id_persona, rol),
    CONSTRAINT piloto_rol_piloto_chk CHECK (rol = 'PILOTO'),
    CONSTRAINT piloto_codigo_empleado_chk CHECK (codigo_empleado REGEXP '^EMP-[0-9]{3}$'),
    CONSTRAINT piloto_vencimiento_certificacion_chk CHECK (vencimiento_certificacion > fecha_certificacion),
    CONSTRAINT piloto_estado_chk CHECK (estado IN ('ACTIVO','INACTIVO'))
);

-- Fincas e insumos

CREATE TABLE Finca (
	id_finca INT NOT NULL PRIMARY KEY,
    id_cliente INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    municipio VARCHAR(20) NOT NULL,
    departamento VARCHAR(20) NOT NULL,
    area_total_ha FLOAT NOT NULL,
    CONSTRAINT finca_id_cliente_fk FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    CONSTRAINT finca_nombre_chk CHECK (CHAR_LENGTH(TRIM(nombre)) > 0),
    CONSTRAINT finca_municipio_chk CHECK (CHAR_LENGTH(TRIM(municipio)) > 0),
    CONSTRAINT finca_departamento_chk CHECK (CHAR_LENGTH(TRIM(departamento)) > 0),
    CONSTRAINT finca_id_cliente_nombre_uk UNIQUE (id_cliente, nombre),
    CONSTRAINT finca_area_total_chk CHECK (0<area_total_ha AND area_total_ha<=50000)
);
CREATE TABLE Cultivo (
	id_cultivo INT NOT NULL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    ciclo VARCHAR(11) NOT NULL,
    CONSTRAINT cultivo_nombre_chk CHECK (CHAR_LENGTH(TRIM(nombre)) > 0),
    CONSTRAINT cultivo_ciclo_chk CHECK (ciclo IN ('TRANSITORIO','PERMANENTE'))
);
CREATE TABLE Lote(
	id_lote INT PRIMARY KEY NOT NULL,
    id_finca INT NOT NULL,
    codigo VARCHAR(10) NOT NULL,
    id_cultivo INT NOT NULL,
    area_ha FLOAT NOT NULL,
    altitud_msnm INT,
    pendiente_pct FLOAT,
    CONSTRAINT lote_id_finca_fk FOREIGN KEY (id_finca) REFERENCES Finca(id_finca),
    CONSTRAINT lote_id_finca_codigo_uk UNIQUE (id_finca, codigo),
    CONSTRAINT lote_codigo_chk CHECK (CHAR_LENGTH(TRIM(codigo)) > 0),
    CONSTRAINT lote_id_cultivo_fk FOREIGN KEY (id_cultivo) REFERENCES Cultivo(id_cultivo),
    CONSTRAINT lote_area_chk CHECK (area_ha>0),
    CONSTRAINT lote_altitud_chk CHECK (0<=altitud_msnm AND altitud_msnm<=4000),
    CONSTRAINT lote_pendiente_pct CHECK (0<=pendiente_pct AND pendiente_pct <=100)
);
CREATE TABLE Producto(
	id_producto INT NOT NULL PRIMARY KEY,
    nombre_comercial VARCHAR(20) NOT NULL UNIQUE,
    tipo VARCHAR(11) NOT NULL,
    categoria_tox VARCHAR(3),
    registro_ica VARCHAR(20) UNIQUE,
    unidad VARCHAR(2) NOT NULL,
    CONSTRAINT producto_nombre_comercial_chk CHECK (CHAR_LENGTH(TRIM(nombre_comercial)) > 0),
    CONSTRAINT producto_tipo_chk CHECK (tipo IN ('HERBICIDA','FUNGICIDA','INSECTICIDA','FOLIAR','COADYUVANTE','BIOLOGICO')),
    CONSTRAINT producto_categoria_tox CHECK (categoria_tox IN ('I','II','III','IV')),
    CONSTRAINT producto_unidad_chk CHECK (unidad IN ('L','KG')),
    CONSTRAINT producto_plaguicida_categoria_tox_chk CHECK (categoria_tox IS NOT NULL OR tipo NOT IN ('HERBICIDA','FUNGICIDA','INSECTICIDA')),
    CONSTRAINT producto_plaguicida_registro_ica_chk CHECK (registro_ica IS NOT NULL OR tipo NOT IN ('HERBICIDA','FUNGICIDA','INSECTICIDA'))
);
CREATE TABLE Dosis_Recomendada(
	id_producto INT NOT NULL,
    id_cultivo INT NOT NULL,
    PRIMARY KEY (id_producto, id_cultivo),
    dosis_min_ha FLOAT NOT NULL,
    dosis_max_ha FLOAT NOT NULL,
    CONSTRAINT dosis_id_producto_fk FOREIGN KEY (id_producto) REFERENCES Producto(id_producto),
    CONSTRAINT dosis_id_cultivo_fk FOREIGN KEY (id_cultivo) REFERENCES Cultivo(id_cultivo),
    CONSTRAINT dosis_min_chk CHECK (dosis_min_ha>0),
    CONSTRAINT dosis_max_chk CHECK (dosis_max_ha>=dosis_min_ha)
);

-- Drones

CREATE TABLE Modelo_Dron (
	id_modelo INT PRIMARY KEY NOT NULL,
    fabricante VARCHAR(50) NOT NULL,
    nombre VARCHAR (50) NOT NULL,
    capacidad_tanque_l FLOAT NOT NULL,
    ancho_franja_max_m FLOAT NOT NULL,
    viento_max_ms FLOAT NOT NULL,
    CONSTRAINT modelo_fabricante_nombre_uk UNIQUE (fabricante, nombre),
    CONSTRAINT modelo_fabricante_chk CHECK (CHAR_LENGTH(TRIM(fabricante)) > 0),
    CONSTRAINT modelo_nombre_chk CHECK (CHAR_LENGTH(TRIM(nombre)) > 0),
    CONSTRAINT modelo_capacidad_tanque_chk CHECK (capacidad_tanque_l>0 AND capacidad_tanque_l<=100),
    CONSTRAINT modelo_ancho_franja_chk CHECK (ancho_franja_max_m>0 AND ancho_franja_max_m<=20),
    CONSTRAINT modelo_viento_max_chk CHECK (viento_max_ms>0 AND viento_max_ms<=20)
);
CREATE TABLE Dron (
	id_dron INT PRIMARY KEY NOT NULL,
    id_modelo INT NOT NULL,
    numero_serie VARCHAR(20) NOT NULL UNIQUE,
    fecha_ingreso DATE NOT NULL,
    estado VARCHAR(13) NOT NULL,
    CONSTRAINT dron_id_modelo_fk FOREIGN KEY (id_modelo) REFERENCES Modelo_Dron(id_modelo),
    CONSTRAINT dron_numero_serie_chk CHECK (CHAR_LENGTH(TRIM(numero_serie)) > 0),
    CONSTRAINT dron_estado_chk CHECK (estado IN ('ACTIVO','MANTENIMIENTO','BAJA'))
);

-- Operacion

CREATE TABLE Mantenimiento (
    id_mantenimiento INT NOT NULL PRIMARY KEY,
    id_dron INT NOT NULL,
    fecha DATE NOT NULL,
    tipo VARCHAR(10) NOT NULL,
    horas_vuelo_acum FLOAT,
    descripcion VARCHAR(200),
    CONSTRAINT mantenimiento_id_dron_fk FOREIGN KEY (id_dron) REFERENCES Dron(id_dron),
    CONSTRAINT mantenimiento_tipo_chk CHECK (tipo IN ('PREVENTIVO','CORRECTIVO')),
    CONSTRAINT mantenimiento_horas_vuelo_acum_chk CHECK (horas_vuelo_acum >= 0)
);
CREATE TABLE Orden_Servicio (
    id_orden INT NOT NULL PRIMARY KEY,
    id_lote INT NOT NULL,
    fecha_solicitud DATE NOT NULL,
    fecha_programada DATE NOT NULL,
    area_contratada_ha FLOAT NOT NULL,
    caldo_objetivo_l_ha FLOAT NOT NULL,
    objetivo VARCHAR(100),
    estado VARCHAR(12) NOT NULL,
    CONSTRAINT orden_id_lote_fk FOREIGN KEY (id_lote) REFERENCES Lote(id_lote),
    CONSTRAINT orden_fecha_programada_chk CHECK (fecha_programada >= fecha_solicitud),
    CONSTRAINT orden_area_contratada_chk CHECK (area_contratada_ha > 0),
    CONSTRAINT orden_caldo_objetivo_chk CHECK (caldo_objetivo_l_ha > 0 AND caldo_objetivo_l_ha <= 100),
    CONSTRAINT orden_estado_chk CHECK (estado IN ('PROGRAMADA','EN_EJECUCION','SUSPENDIDA','EJECUTADA','CANCELADA'))
);
CREATE TABLE Orden_Producto (
    id_orden INT NOT NULL,
    id_producto INT NOT NULL,
    dosis_formulada FLOAT NOT NULL,
    PRIMARY KEY (id_orden, id_producto),
    CONSTRAINT orden_producto_id_orden_fk FOREIGN KEY (id_orden) REFERENCES Orden_Servicio(id_orden),
    CONSTRAINT orden_producto_id_producto_fk FOREIGN KEY (id_producto) REFERENCES Producto(id_producto),
    CONSTRAINT orden_producto_dosis_chk CHECK (dosis_formulada > 0)
);
CREATE TABLE Item_Chequeo (
    id_item INT NOT NULL PRIMARY KEY,
    codigo VARCHAR(5) NOT NULL UNIQUE,
    nivel INT NOT NULL,
    descripcion VARCHAR(200) NOT NULL,
    obligatorio INT NOT NULL,
    CONSTRAINT item_chequeo_codigo_chk CHECK (codigo REGEXP '^N[0-3]-[0-9]{2}$'),
    CONSTRAINT item_chequeo_nivel_chk CHECK (nivel IN (0,1,2,3)),
    CONSTRAINT item_chequeo_descripcion_chk CHECK (CHAR_LENGTH(TRIM(descripcion)) > 0),
    CONSTRAINT item_chequeo_obligatorio_chk CHECK (obligatorio IN (0,1))
);
CREATE TABLE Preoperacional (
    id_preop INT NOT NULL PRIMARY KEY,
    id_orden INT NOT NULL,
    id_dron INT NOT NULL,
    id_piloto INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    resultado VARCHAR(9) NOT NULL,
    CONSTRAINT preop_id_orden_fk FOREIGN KEY (id_orden) REFERENCES Orden_Servicio(id_orden),
    CONSTRAINT preop_id_dron_fk FOREIGN KEY (id_dron) REFERENCES Dron(id_dron),
    CONSTRAINT preop_id_piloto_fk FOREIGN KEY (id_piloto) REFERENCES Piloto(id_piloto),
    CONSTRAINT preop_id_dron_fecha_hora_uk UNIQUE (id_dron, fecha_hora),
    CONSTRAINT preop_resultado_chk CHECK (resultado IN ('PENDIENTE','APTO','NO_APTO'))
);
CREATE TABLE Item_No_Cumplido (
    id_preop INT NOT NULL,
    id_item INT NOT NULL,
    razon VARCHAR(200) NOT NULL,
    codigo_imagen VARCHAR(15) NOT NULL UNIQUE,
    accion_correctiva VARCHAR(200),
    PRIMARY KEY (id_preop, id_item),
    CONSTRAINT item_no_cumplido_id_preop_fk FOREIGN KEY (id_preop) REFERENCES Preoperacional(id_preop),
    CONSTRAINT item_no_cumplido_id_item_fk FOREIGN KEY (id_item) REFERENCES Item_Chequeo(id_item),
    CONSTRAINT item_no_cumplido_razon_chk CHECK (CHAR_LENGTH(TRIM(razon)) > 0),
    CONSTRAINT item_no_cumplido_codigo_imagen_chk CHECK (codigo_imagen REGEXP '^IMG-[0-9]{4}-[0-9]{6}$')
);
CREATE TABLE Vuelo (
    id_vuelo INT NOT NULL PRIMARY KEY,
    id_preop INT NOT NULL,
    inicio DATETIME NOT NULL,
    fin DATETIME NOT NULL,
    area_aplicada_ha FLOAT NOT NULL,
    volumen_aplicado_l FLOAT NOT NULL,
    altura_m FLOAT,
    velocidad_ms FLOAT,
    ancho_franja_m FLOAT,
    bateria_inicio_pct INT,
    bateria_fin_pct INT,
    CONSTRAINT vuelo_id_preop_fk FOREIGN KEY (id_preop) REFERENCES Preoperacional(id_preop),
    CONSTRAINT vuelo_fin_chk CHECK (fin > inicio AND TIMESTAMPDIFF(SECOND, inicio, fin) <= 7200),
    CONSTRAINT vuelo_area_aplicada_chk CHECK (area_aplicada_ha > 0 AND area_aplicada_ha <= 50),
    CONSTRAINT vuelo_volumen_aplicado_chk CHECK (volumen_aplicado_l > 0),
    CONSTRAINT vuelo_altura_chk CHECK (altura_m >= 0.5 AND altura_m <= 30),
    CONSTRAINT vuelo_velocidad_chk CHECK (velocidad_ms > 0 AND velocidad_ms <= 15),
    CONSTRAINT vuelo_ancho_franja_chk CHECK (ancho_franja_m > 0 AND ancho_franja_m <= 20),
    CONSTRAINT vuelo_bateria_inicio_chk CHECK (bateria_inicio_pct >= 0 AND bateria_inicio_pct <= 100),
    CONSTRAINT vuelo_bateria_fin_chk CHECK (bateria_fin_pct >= 0 AND bateria_fin_pct <= bateria_inicio_pct)
);
CREATE TABLE Condicion_Clima (
    id_vuelo INT NOT NULL PRIMARY KEY,
    viento_ms FLOAT NOT NULL,
    rafaga_ms FLOAT,
    temperatura_c FLOAT,
    humedad_pct FLOAT,
    fuente VARCHAR(13) NOT NULL,
    CONSTRAINT clima_id_vuelo_fk FOREIGN KEY (id_vuelo) REFERENCES Vuelo(id_vuelo),
    CONSTRAINT clima_viento_chk CHECK (viento_ms >= 0 AND viento_ms <= 40),
    CONSTRAINT clima_rafaga_chk CHECK (rafaga_ms >= viento_ms),
    CONSTRAINT clima_temperatura_chk CHECK (temperatura_c >= -5 AND temperatura_c <= 50),
    CONSTRAINT clima_humedad_chk CHECK (humedad_pct >= 0 AND humedad_pct <= 100),
    CONSTRAINT clima_fuente_chk CHECK (fuente IN ('ANEMOMETRO','ESTACION','API_HISTORICA'))
);
CREATE TABLE Suspension (
    id_suspension INT NOT NULL PRIMARY KEY,
    id_orden INT NOT NULL,
    id_piloto INT NOT NULL,
    inicio DATETIME NOT NULL,
    fin DATETIME,
    causa VARCHAR(12) NOT NULL,
    descripcion VARCHAR(200),
    area_pendiente_ha FLOAT NOT NULL,
    CONSTRAINT suspension_id_orden_fk FOREIGN KEY (id_orden) REFERENCES Orden_Servicio(id_orden),
    CONSTRAINT suspension_id_piloto_fk FOREIGN KEY (id_piloto) REFERENCES Piloto(id_piloto),
    CONSTRAINT suspension_fin_chk CHECK (fin IS NULL OR fin > inicio),
    CONSTRAINT suspension_causa_chk CHECK (causa IN ('VIENTO','LLUVIA','FALLA_EQUIPO','CLIENTE','OTRA')),
    CONSTRAINT suspension_descripcion_otra_chk CHECK (causa <> 'OTRA' OR (descripcion IS NOT NULL AND CHAR_LENGTH(TRIM(descripcion)) > 0)),
    CONSTRAINT suspension_area_pendiente_chk CHECK (area_pendiente_ha >= 0)
);
CREATE TABLE Formulario_Cierre (
    id_cierre INT NOT NULL PRIMARY KEY,
    id_orden INT NOT NULL UNIQUE,
    id_piloto INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    resultado VARCHAR(8) NOT NULL,
    area_reportada_ha FLOAT NOT NULL,
    caldo_sobrante_l FLOAT NOT NULL,
    conformidad_cliente VARCHAR(2) NOT NULL,
    area_facturada_ha FLOAT,
    observaciones VARCHAR(200),
    CONSTRAINT cierre_id_orden_fk FOREIGN KEY (id_orden) REFERENCES Orden_Servicio(id_orden),
    CONSTRAINT cierre_id_piloto_fk FOREIGN KEY (id_piloto) REFERENCES Piloto(id_piloto),
    CONSTRAINT cierre_resultado_chk CHECK (resultado IN ('COMPLETA','PARCIAL')),
    CONSTRAINT cierre_area_reportada_chk CHECK (area_reportada_ha > 0),
    CONSTRAINT cierre_caldo_sobrante_chk CHECK (caldo_sobrante_l >= 0),
    CONSTRAINT cierre_conformidad_chk CHECK (conformidad_cliente IN ('SI','NO')),
    CONSTRAINT cierre_area_facturada_chk CHECK (area_facturada_ha IS NULL OR (area_facturada_ha > 0 AND area_facturada_ha <= area_reportada_ha))
);