
/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
/*
Proyecto Final - Grupo 4

Integrantes:
Camacho Serrano Josué Alberto
Vargas Arias Cristopher
Arguello Selva Dylan
*/

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------BASE DE DATOS SOUNDHUB------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------CREACION DE USUARIOS------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- Creacion de usuarios del sistema 
//Se crea el usuario SOUNDHUB_ADMIN
CREATE USER SOUNDHUB_ADMIN IDENTIFIED BY "12345";

//Se crea el usuario SOUNDHUB_USER
CREATE USER SOUNDHUB_USER IDENTIFIED BY "12345";

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------CREACION DE PERFILES------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
CREATE PROFILE PROFILE_SOUNDHUB_ADMIN LIMIT
   SESSIONS_PER_USER          UNLIMITED  -- Sesiones concurrentes ilimitadas
   CPU_PER_SESSION            UNLIMITED
   CPU_PER_CALL               UNLIMITED
   CONNECT_TIME               UNLIMITED
   IDLE_TIME                  30         -- 30 minutos de inactividad
   LOGICAL_READS_PER_SESSION  UNLIMITED
   LOGICAL_READS_PER_CALL     UNLIMITED
   COMPOSITE_LIMIT           UNLIMITED
   PRIVATE_SGA               UNLIMITED
   FAILED_LOGIN_ATTEMPTS      5          -- 5 intentos fallidos antes de bloquear
   PASSWORD_LIFE_TIME        60         -- Cambio de contraseña cada 60 días
   PASSWORD_REUSE_TIME       30         -- No reutilizar contraseña antes de 30 días
   PASSWORD_REUSE_MAX        UNLIMITED
   PASSWORD_LOCK_TIME        1/24       -- Bloqueo por 1 hora después de intentos fallidos
   PASSWORD_GRACE_TIME       7          -- 7 días de gracia para cambiar contraseña

CREATE PROFILE PROFILE_SOUNDHUB_USER LIMIT
   SESSIONS_PER_USER          3         -- Máximo 3 sesiones concurrentes
   CPU_PER_SESSION            UNLIMITED
   CPU_PER_CALL               3000      -- 3000 unidades de CPU por llamada
   CONNECT_TIME               480       -- 8 horas máximo de conexión
   IDLE_TIME                  15        -- 15 minutos de inactividad
   LOGICAL_READS_PER_SESSION  DEFAULT
   LOGICAL_READS_PER_CALL     DEFAULT
   COMPOSITE_LIMIT           DEFAULT
   PRIVATE_SGA               DEFAULT
   FAILED_LOGIN_ATTEMPTS      3         -- 3 intentos fallidos antes de bloquear
   PASSWORD_LIFE_TIME        90         -- Cambio de contraseña cada 90 días
   PASSWORD_REUSE_TIME       60         -- No reutilizar contraseña antes de 60 días
   PASSWORD_REUSE_MAX        5         -- No reutilizar las últimas 5 contraseñas
   PASSWORD_LOCK_TIME        1/24      -- Bloqueo por 1 hora después de intentos fallidos
   PASSWORD_GRACE_TIME       5         -- 5 días de gracia para cambiar contraseña

-- Asignar perfil de administrador
ALTER USER SOUNDHUB_ADMIN PROFILE PROFILE_SOUNDHUB_ADMIN;

-- Asignar perfil de usuario normal
ALTER USER SOUNDHUB_USER PROFILE PROFILE_SOUNDHUB_USER;

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------CREACION DE TABLESPACES----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- Creacion de usuarios del sistema 
//Tablespace TS_SOUNDHUB_DATOS
CREATE TABLESPACE TS_SOUNDHUB_DATOS DATAFILE 'D:\ORACLE\ORACLEXE\ORADATA\XE\XEPDB1\TS_SOUNDHUB_DATOS01.DBF'
SIZE 16M AUTOEXTEND ON NEXT 16M MAXSIZE UNLIMITED
BLOCKSIZE 8K;

//Tablespace TS_SOUNDHUB_INDICES
CREATE TABLESPACE TS_SOUNDHUB_INDICES DATAFILE 'D:\ORACLE\ORACLEXE\ORADATA\XE\XEPDB1\TS_SOUNDHUB_INDICES01.DBF'
SIZE 16M AUTOEXTEND ON NEXT 16M MAXSIZE UNLIMITED
BLOCKSIZE 8K;

//Tablespace TS_SOUNDHUB_TEMPORAL
CREATE TEMPORARY TABLESPACE TS_SOUNDHUB_TEMPORAL 
TEMPFILE 'D:\ORACLE\ORACLEXE\ORADATA\XE\XEPDB1\TS_SOUNDHUB_TEMPORAL01.TMP' SIZE 16M AUTOEXTEND ON NEXT 16M MAXSIZE UNLIMITED
TABLESPACE GROUP TMP_SOUNDHUB
EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M;

//Se le cambia el parametro del tablespace default y temp a los usuarios
ALTER USER SOUNDHUB_ADMIN DEFAULT TABLESPACE TS_SOUNDHUB_DATOS;
ALTER USER SOUNDHUB_ADMIN TEMPORARY TABLESPACE TS_SOUNDHUB_TEMPORAL;
GRANT UNLIMITED TABLESPACE TO SOUNDHUB_ADMIN;

ALTER USER SOUNDHUB_USER DEFAULT TABLESPACE TS_SOUNDHUB_DATOS;
ALTER USER SOUNDHUB_USER TEMPORARY TABLESPACE TS_SOUNDHUB_TEMPORAL;
GRANT UNLIMITED TABLESPACE TO SOUNDHUB_USER;

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------CREACION DE TABLAS-------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- Creacion de secuencia para las tablas (aumentar los Ids atumaticamente de las tablas, menos usuarios, artistas y tablas intermedias)
CREATE SEQUENCE seq_genero START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_album START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_cancion START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_podcast START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_factura START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_facturadet START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_comentario START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_episodio START WITH 1 INCREMENT BY 1;

-- Tabla de Géneros
CREATE TABLE T_Generos (
  ID_Genero NUMBER PRIMARY KEY,
  Nombre_Genero VARCHAR2(100)
)
TABLESPACE TS_SOUNDHUB_DATOS
INITRANS 10;

-- Tabla de Artistas
CREATE TABLE T_Artistas (
  ID_Artista NUMBER PRIMARY KEY,
  Nombre VARCHAR2(100),
  Nombre_Artistico VARCHAR2(100),
  Biografica VARCHAR2(1000)
)
TABLESPACE TS_SOUNDHUB_DATOS
INITRANS 10;

-- Tabla de Álbumes
CREATE TABLE T_Albumes (
  ID_Album NUMBER PRIMARY KEY,
  ID_Artista NUMBER,
  Titulo VARCHAR2(150),
  Fecha_Lanzamiento DATE,
  URL VARCHAR2(255),
  Precio NUMBER(10,2),
  FOREIGN KEY (ID_Artista) REFERENCES T_Artistas(ID_Artista) ON DELETE CASCADE
)
TABLESPACE TS_SOUNDHUB_DATOS
INITRANS 10;

-- Tabla de Canciones
CREATE TABLE T_Canciones (
  ID_Cancion NUMBER PRIMARY KEY,
  ID_Album NUMBER,
  Titulo VARCHAR2(150),
  Duracion NUMBER(5,2),
  Precio NUMBER(10,2),
  ID_Artista NUMBER,
  FOREIGN KEY (ID_Album) REFERENCES T_Albumes(ID_Album) ON DELETE CASCADE,
  FOREIGN KEY (ID_Artista) REFERENCES T_Artistas(ID_Artista) ON DELETE CASCADE
)
TABLESPACE TS_SOUNDHUB_DATOS
INITRANS 10;

-- Tabla de Podcasts
CREATE TABLE T_Podcasts (
  ID_Podcast NUMBER PRIMARY KEY,
  ID_Artista NUMBER,
  Titulo VARCHAR2(150),
  Descripcion VARCHAR2(1000),
  URL VARCHAR2(255),
  Precio NUMBER(10,2),
  FOREIGN KEY (ID_Artista) REFERENCES T_Artistas(ID_Artista) ON DELETE CASCADE
)
TABLESPACE TS_SOUNDHUB_DATOS
INITRANS 10;

-- Tabla de Episodios
CREATE TABLE T_Episodios (
  ID_Episodio NUMBER PRIMARY KEY,
  ID_Podcast NUMBER,
  ID_Artista NUMBER,
  Duracion NUMBER(5,2),
  Precio NUMBER(10,2),
  URL VARCHAR2(255),
  Titulo VARCHAR2(150),
  FOREIGN KEY (ID_Podcast) REFERENCES T_Podcasts(ID_Podcast) ON DELETE CASCADE,
  FOREIGN KEY (ID_Artista) REFERENCES T_Artistas(ID_Artista) ON DELETE CASCADE
)
TABLESPACE TS_SOUNDHUB_DATOS
INITRANS 10;

-- Tablas intermedias con generos
CREATE TABLE T_Albumes_Generos (
  ID_Album NUMBER,
  ID_Genero NUMBER,
  PRIMARY KEY (ID_Album, ID_Genero),
  FOREIGN KEY (ID_Album) REFERENCES T_Albumes(ID_Album) ON DELETE CASCADE,
  FOREIGN KEY (ID_Genero) REFERENCES T_Generos(ID_Genero) ON DELETE CASCADE
)
TABLESPACE TS_SOUNDHUB_DATOS
INITRANS 10;

CREATE TABLE T_Canciones_Generos (
  ID_Cancion NUMBER,
  ID_Genero NUMBER,
  PRIMARY KEY (ID_Cancion, ID_Genero),
  FOREIGN KEY (ID_Cancion) REFERENCES T_Canciones(ID_Cancion) ON DELETE CASCADE,
  FOREIGN KEY (ID_Genero) REFERENCES T_Generos(ID_Genero) ON DELETE CASCADE
)
TABLESPACE TS_SOUNDHUB_DATOS
INITRANS 10;

CREATE TABLE T_Episodios_Generos (
  ID_Episodio NUMBER,
  ID_Genero NUMBER,
  PRIMARY KEY (ID_Episodio, ID_Genero),
  FOREIGN KEY (ID_Episodio) REFERENCES T_Episodios(ID_Episodio) ON DELETE CASCADE,
  FOREIGN KEY (ID_Genero) REFERENCES T_Generos(ID_Genero) ON DELETE CASCADE
)
TABLESPACE TS_SOUNDHUB_DATOS
INITRANS 10;

CREATE TABLE T_Podcast_Generos (
  ID_Podcast NUMBER,
  ID_Genero NUMBER,
  PRIMARY KEY (ID_Podcast, ID_Genero),
  FOREIGN KEY (ID_Podcast) REFERENCES T_Podcasts(ID_Podcast) ON DELETE CASCADE,
  FOREIGN KEY (ID_Genero) REFERENCES T_Generos(ID_Genero) ON DELETE CASCADE
)
TABLESPACE TS_SOUNDHUB_DATOS
INITRANS 10;

-- Tabla de Usuarios
CREATE TABLE T_Usuarios (
  ID_Usuario NUMBER PRIMARY KEY,
  Nombre VARCHAR2(100),
  Email VARCHAR2(100) UNIQUE,
  Contrasena VARCHAR2(100),
  Telefono VARCHAR2(20),
  Fecha_Registro DATE
)
TABLESPACE TS_SOUNDHUB_DATOS
INITRANS 10;

-- Tabla de Facturas
CREATE TABLE T_Factura (
  ID_Factura NUMBER PRIMARY KEY,
  ID_Usuario NUMBER,
  Fecha_Compra DATE,
  Total NUMBER(10,2),
  Metodo_Pago VARCHAR2(50),
  Estado VARCHAR2(20),
  FOREIGN KEY (ID_Usuario) REFERENCES T_Usuarios(ID_Usuario) ON DELETE CASCADE
)
TABLESPACE TS_SOUNDHUB_DATOS
INITRANS 10;

-- Tabla de detalles de Factura
CREATE TABLE T_FacturaDetalles (
  ID_FacturaDetalle NUMBER PRIMARY KEY,
  ID_Factura NUMBER,
  ID_Cancion NUMBER,
  ID_Episodio NUMBER,
  ID_Podcast NUMBER,
  ID_Album NUMBER,
  Precio_Unitario NUMBER(10,2),
  Cantidad NUMBER,
  Subtotal NUMBER(10,2),
  FOREIGN KEY (ID_Factura) REFERENCES T_Factura(ID_Factura) ON DELETE CASCADE,
  FOREIGN KEY (ID_Cancion) REFERENCES T_Canciones(ID_Cancion) ON DELETE SET NULL,
  FOREIGN KEY (ID_Episodio) REFERENCES T_Episodios(ID_Episodio) ON DELETE SET NULL,
  FOREIGN KEY (ID_Podcast) REFERENCES T_Podcasts(ID_Podcast) ON DELETE SET NULL,
  FOREIGN KEY (ID_Album) REFERENCES T_Albumes(ID_Album) ON DELETE SET NULL
)
TABLESPACE TS_SOUNDHUB_DATOS
INITRANS 10;

-- Tabla de Comentarios
CREATE TABLE T_Comentarios (
  ID_Comentario NUMBER PRIMARY KEY,
  ID_Usuario NUMBER,
  ID_Cancion NUMBER,
  ID_Episodio NUMBER,
  Calificacion NUMBER(1), -- del 1 al 5
  Comentario VARCHAR2(500),
  Fecha_Comentario DATE,
  FOREIGN KEY (ID_Usuario) REFERENCES T_Usuarios(ID_Usuario) ON DELETE CASCADE,
  FOREIGN KEY (ID_Cancion) REFERENCES T_Canciones(ID_Cancion) ON DELETE SET NULL,
  FOREIGN KEY (ID_Episodio) REFERENCES T_Episodios(ID_Episodio) ON DELETE SET NULL
)
TABLESPACE TS_SOUNDHUB_DATOS
INITRANS 10;

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------CREACION DE PKs------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- Crear PK para T_Generos
ALTER TABLE T_Generos ADD (
CONSTRAINT T_GENEROS_PK PRIMARY KEY (ID_Genero)
ENABLE VALIDATE);

-- Crear PK para T_Artistas
ALTER TABLE T_Artistas ADD (
CONSTRAINT T_ARTISTAS_PK PRIMARY KEY (ID_Artista)
ENABLE VALIDATE);

-- Crear PK para T_Albumes
ALTER TABLE T_Albumes ADD (
CONSTRAINT T_ALBUMES_PK PRIMARY KEY (ID_Album)
ENABLE VALIDATE);

-- Crear PK para T_Canciones
ALTER TABLE T_Canciones ADD (
CONSTRAINT T_CANCIONES_PK PRIMARY KEY (ID_Cancion)
ENABLE VALIDATE);

-- Crear PK para T_Podcasts
ALTER TABLE T_Podcasts ADD (
CONSTRAINT T_PODCASTS_PK PRIMARY KEY (ID_Podcast)
ENABLE VALIDATE);

-- Crear PK para T_Episodios
ALTER TABLE T_Episodios ADD (
CONSTRAINT T_EPISODIOS_PK PRIMARY KEY (ID_Episodio)
ENABLE VALIDATE);

-- Crear PK para T_Albumes_Generos
ALTER TABLE T_Albumes_Generos ADD (
CONSTRAINT T_ALBUMES_GENEROS_PK PRIMARY KEY (ID_Album, ID_Genero)
ENABLE VALIDATE);

-- Crear PK para T_Canciones_Generos
ALTER TABLE T_Canciones_Generos ADD (
CONSTRAINT T_CANCIONES_GENEROS_PK PRIMARY KEY (ID_Cancion, ID_Genero)
ENABLE VALIDATE);

-- Crear PK para T_Episodios_Generos
ALTER TABLE T_Episodios_Generos ADD (
CONSTRAINT T_EPISODIOS_GENEROS_PK PRIMARY KEY (ID_Episodio, ID_Genero)
ENABLE VALIDATE);

-- Crear PK para T_Podcast_Generos
ALTER TABLE T_Podcast_Generos ADD (
CONSTRAINT T_PODCAST_GENEROS_PK PRIMARY KEY (ID_Podcast, ID_Genero)
ENABLE VALIDATE);

-- Crear PK para T_Usuarios
ALTER TABLE T_Usuarios ADD (
CONSTRAINT T_USUARIOS_PK PRIMARY KEY (ID_Usuario)
ENABLE VALIDATE);

-- Crear PK para T_Factura
ALTER TABLE T_Factura ADD (
CONSTRAINT T_FACTURA_PK PRIMARY KEY (ID_Factura)
ENABLE VALIDATE);

-- Crear PK para T_FacturaDetalles
ALTER TABLE T_FacturaDetalles ADD (
CONSTRAINT T_FACTURADETALLES_PK PRIMARY KEY (ID_FacturaDetalle)
ENABLE VALIDATE);

-- Crear PK para T_Comentarios
ALTER TABLE T_Comentarios ADD (
CONSTRAINT T_COMENTARIOS_PK PRIMARY KEY (ID_Comentario)
ENABLE VALIDATE);

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------CREACION DE INDICES DE PKs--------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- Crear Indice para PK de T_Generos
CREATE UNIQUE INDEX GENEROS_PK ON T_Generos (ID_Genero)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

-- Crear Indice para PK de T_Artistas
CREATE UNIQUE INDEX ARTISTAS_PK ON T_Artistas (ID_Artista)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

-- Crear Indice para PK de T_Albumes
CREATE UNIQUE INDEX ALBUMES_PK ON T_Albumes (ID_Album)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

-- Crear Indice para PK de T_Canciones
CREATE UNIQUE INDEX CANCIONES_PK ON T_Canciones (ID_Cancion)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

-- Crear Indice para PK de T_Podcasts
CREATE UNIQUE INDEX PODCASTS_PK ON T_Podcasts (ID_Podcast)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

-- Crear Indice para PK de T_Episodios
CREATE UNIQUE INDEX EPISODIOS_PK ON T_Episodios (ID_Episodio)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

-- Crear Indice para PK de T_Albumes_Generos
CREATE UNIQUE INDEX ALBUMES_GENEROS_PK ON T_Albumes_Generos (ID_Album, ID_Genero)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

-- Crear Indice para PK de T_Canciones_Generos
CREATE UNIQUE INDEX CANCIONES_GENEROS_PK ON T_Canciones_Generos (ID_Cancion, ID_Genero)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

-- Crear Indice para PK de T_Episodios_Generos
CREATE UNIQUE INDEX EPISODIOS_GENEROS_PK ON T_Episodios_Generos (ID_Episodio, ID_Genero)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

-- Crear Indice para PK de T_Podcast_Generos
CREATE UNIQUE INDEX PODCAST_GENEROS_PK ON T_Podcast_Generos (ID_Podcast, ID_Genero)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

-- Crear Indice para PK de T_Usuarios
CREATE UNIQUE INDEX USUARIOS_PK ON T_Usuarios (ID_Usuario)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

-- Crear Indice para PK de T_Factura
CREATE UNIQUE INDEX FACTURA_PK ON T_Factura (ID_Factura)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

-- Crear Indice para PK de T_FacturaDetalles
CREATE UNIQUE INDEX FACTURADETALLES_PK ON T_FacturaDetalles (ID_FacturaDetalle)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

-- Crear Indice para PK de T_Comentarios
CREATE UNIQUE INDEX COMENTARIOS_PK ON T_Comentarios (ID_Comentario)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------PROCEDIMIENTOS ALMACENADOS------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- CRUD T_Generos
-- INSERT_T_GENEROS_SP
CREATE OR REPLACE PROCEDURE INSERT_T_GENEROS_SP(
  p_Nombre_Genero VARCHAR2
) AS
BEGIN
  INSERT INTO T_Generos (ID_Genero, Nombre_Genero)
  VALUES (seq_genero.NEXTVAL, p_Nombre_Genero);
END;
/
-- SELECT_T_GENEROS_SP
CREATE OR REPLACE PROCEDURE SELECT_T_GENEROS_SP IS
BEGIN
  FOR r IN (SELECT * FROM T_Generos) LOOP
    DBMS_OUTPUT.PUT_LINE('ID: ' || r.ID_Genero || ', Nombre: ' || r.Nombre_Genero);
  END LOOP;
END;
/
-- UPDATE_T_GENEROS_SP
CREATE OR REPLACE PROCEDURE UPDATE_T_GENEROS_SP(
  p_ID_Genero NUMBER,
  p_Nombre_Genero VARCHAR2
) AS
BEGIN
  UPDATE T_Generos
  SET Nombre_Genero = p_Nombre_Genero
  WHERE ID_Genero = p_ID_Genero;
END;
/
-- DELETE_T_GENEROS_SP
CREATE OR REPLACE PROCEDURE DELETE_T_GENEROS_SP(
  p_ID_Genero NUMBER
) AS
BEGIN
  DELETE FROM T_Generos WHERE ID_Genero = p_ID_Genero;
END;
/
-- CRUD T_Artistas
-- INSERT_T_ARTISTAS_SP
CREATE OR REPLACE PROCEDURE INSERT_T_ARTISTAS_SP(
  p_ID_Artista NUMBER,
  p_Nombre VARCHAR2,
  p_Nombre_Artistico VARCHAR2,
  p_Biografica VARCHAR2
) AS
BEGIN
  INSERT INTO T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica)
  VALUES (p_ID_Artista, p_Nombre, p_Nombre_Artistico, p_Biografica);
END;
/
-- SELECT_T_ARTISTAS_SP
CREATE OR REPLACE PROCEDURE SELECT_T_ARTISTAS_SP IS
BEGIN
  FOR r IN (SELECT * FROM T_Artistas) LOOP
    DBMS_OUTPUT.PUT_LINE('ID: ' || r.ID_Artista || ', Nombre: ' || r.Nombre || ', Artístico: ' || r.Nombre_Artistico);
  END LOOP;
END;
/
-- UPDATE_T_ARTISTAS_SP
CREATE OR REPLACE PROCEDURE UPDATE_T_ARTISTAS_SP(
  p_ID_Artista NUMBER,
  p_Nombre VARCHAR2,
  p_Nombre_Artistico VARCHAR2,
  p_Biografica VARCHAR2
) AS
BEGIN
  UPDATE T_Artistas
  SET Nombre = p_Nombre,
      Nombre_Artistico = p_Nombre_Artistico,
      Biografica = p_Biografica
  WHERE ID_Artista = p_ID_Artista;
END;
/
-- DELETE_T_ARTISTAS_SP
CREATE OR REPLACE PROCEDURE DELETE_T_ARTISTAS_SP(
  p_ID_Artista NUMBER
) AS
BEGIN
  DELETE FROM T_Artistas WHERE ID_Artista = p_ID_Artista;
END;
/
-- CRUD T_Albumes
-- INSERT_T_ALBUMES_SP
CREATE OR REPLACE PROCEDURE INSERT_T_ALBUMES_SP(
  p_ID_Artista NUMBER,
  p_Titulo VARCHAR2,
  p_Fecha_Lanzamiento DATE,
  p_URL VARCHAR2,
  p_Precio NUMBER
) AS
BEGIN
  INSERT INTO T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio)
  VALUES (seq_album.NEXTVAL, p_ID_Artista, p_Titulo, p_Fecha_Lanzamiento, p_URL, p_Precio);
END;
/
-- SELECT_T_ALBUMES_SP
CREATE OR REPLACE PROCEDURE SELECT_T_ALBUMES_SP IS
BEGIN
  FOR r IN (SELECT * FROM T_Albumes) LOOP
    DBMS_OUTPUT.PUT_LINE('ID: ' || r.ID_Album || ', Título: ' || r.Titulo || ', Precio: ' || r.Precio);
  END LOOP;
END;
/
-- UPDATE_T_ALBUMES_SP
CREATE OR REPLACE PROCEDURE UPDATE_T_ALBUMES_SP(
  p_ID_Album NUMBER,
  p_ID_Artista NUMBER,
  p_Titulo VARCHAR2,
  p_Fecha_Lanzamiento DATE,
  p_URL VARCHAR2,
  p_Precio NUMBER
) AS
BEGIN
  UPDATE T_Albumes
  SET ID_Artista = p_ID_Artista,
      Titulo = p_Titulo,
      Fecha_Lanzamiento = p_Fecha_Lanzamiento,
      URL = p_URL,
      Precio = p_Precio
  WHERE ID_Album = p_ID_Album;
END;
/
-- DELETE_T_ALBUMES_SP
CREATE OR REPLACE PROCEDURE DELETE_T_ALBUMES_SP(
  p_ID_Album NUMBER
) AS
BEGIN
  DELETE FROM T_Albumes WHERE ID_Album = p_ID_Album;
END;
/
-- CRUD T_ALBUMES
-- INSERT_T_ALBUMES_SP
CREATE OR REPLACE PROCEDURE INSERT_T_ALBUMES_SP(
  p_ID_Artista NUMBER,
  p_Titulo VARCHAR2,
  p_Fecha_Lanzamiento DATE,
  p_URL VARCHAR2,
  p_Precio NUMBER
) AS
BEGIN
  INSERT INTO T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio)
  VALUES (seq_album.NEXTVAL, p_ID_Artista, p_Titulo, p_Fecha_Lanzamiento, p_URL, p_Precio);
END;
/
-- SELECT_T_ALBUMES_SP
CREATE OR REPLACE PROCEDURE SELECT_T_ALBUMES_SP IS
BEGIN
  FOR r IN (SELECT * FROM T_Albumes) LOOP
    DBMS_OUTPUT.PUT_LINE('ID: ' || r.ID_Album || ', Título: ' || r.Titulo || ', Precio: ' || r.Precio);
  END LOOP;
END;
/
-- UPDATE_T_ALBUMES_SP
CREATE OR REPLACE PROCEDURE UPDATE_T_ALBUMES_SP(
  p_ID_Album NUMBER,
  p_ID_Artista NUMBER,
  p_Titulo VARCHAR2,
  p_Fecha_Lanzamiento DATE,
  p_URL VARCHAR2,
  p_Precio NUMBER
) AS
BEGIN
  UPDATE T_Albumes
  SET ID_Artista = p_ID_Artista,
      Titulo = p_Titulo,
      Fecha_Lanzamiento = p_Fecha_Lanzamiento,
      URL = p_URL,
      Precio = p_Precio
  WHERE ID_Album = p_ID_Album;
END;
/
-- DELETE_T_ALBUMES_SP
CREATE OR REPLACE PROCEDURE DELETE_T_ALBUMES_SP(
  p_ID_Album NUMBER
) AS
BEGIN
  DELETE FROM T_Albumes WHERE ID_Album = p_ID_Album;
END;
/
-- CRUD T_USUARIOS
-- INSERT_T_USUARIOS_SP
CREATE OR REPLACE PROCEDURE INSERT_T_USUARIOS_SP(
  p_ID_Usuario NUMBER,
  p_Nombre VARCHAR2,
  p_Email VARCHAR2,
  p_Contrasena VARCHAR2,
  p_Telefono VARCHAR2,
  p_Fecha_Registro DATE
) AS
BEGIN
  INSERT INTO T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro)
  VALUES (p_ID_Usuario, p_Nombre, p_Email, p_Contrasena, p_Telefono, p_Fecha_Registro);
END;
/
-- SELECT_T_USUARIOS_SP
CREATE OR REPLACE PROCEDURE SELECT_T_USUARIOS_SP IS
BEGIN
  FOR r IN (SELECT * FROM T_Usuarios) LOOP
    DBMS_OUTPUT.PUT_LINE('ID: ' || r.ID_Usuario || ', Nombre: ' || r.Nombre || ', Email: ' || r.Email);
  END LOOP;
END;
/
-- UPDATE_T_USUARIOS_SP
CREATE OR REPLACE PROCEDURE UPDATE_T_USUARIOS_SP(
  p_ID_Usuario NUMBER,
  p_Nombre VARCHAR2,
  p_Email VARCHAR2,
  p_Contrasena VARCHAR2,
  p_Telefono VARCHAR2,
  p_Fecha_Registro DATE
) AS
BEGIN
  UPDATE T_Usuarios
  SET Nombre = p_Nombre,
      Email = p_Email,
      Contrasena = p_Contrasena,
      Telefono = p_Telefono,
      Fecha_Registro = p_Fecha_Registro
  WHERE ID_Usuario = p_ID_Usuario;
END;
/
-- DELETE_T_USUARIOS_SP
CREATE OR REPLACE PROCEDURE DELETE_T_USUARIOS_SP(
  p_ID_Usuario NUMBER
) AS
BEGIN
  DELETE FROM T_Usuarios WHERE ID_Usuario = p_ID_Usuario;
END;
/
-- CRUD T_CANCIONES
-- INSERT_T_CANCIONES_SP
CREATE OR REPLACE PROCEDURE INSERT_T_CANCIONES_SP(
  p_ID_Album NUMBER,
  p_Titulo VARCHAR2,
  p_Duracion NUMBER,
  p_Precio NUMBER,
  p_ID_Artista NUMBER
) AS
BEGIN
  INSERT INTO T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista)
  VALUES (seq_cancion.NEXTVAL, p_ID_Album, p_Titulo, p_Duracion, p_Precio, p_ID_Artista);
END;
/
-- SELECT_T_CANCIONES_SP
CREATE OR REPLACE PROCEDURE SELECT_T_CANCIONES_SP IS
BEGIN
  FOR r IN (SELECT * FROM T_Canciones) LOOP
    DBMS_OUTPUT.PUT_LINE('ID: ' || r.ID_Cancion || ', Título: ' || r.Titulo || ', Precio: ' || r.Precio);
  END LOOP;
END;
/
-- UPDATE_T_CANCIONES_SP
CREATE OR REPLACE PROCEDURE UPDATE_T_CANCIONES_SP(
  p_ID_Cancion NUMBER,
  p_ID_Album NUMBER,
  p_Titulo VARCHAR2,
  p_Duracion NUMBER,
  p_Precio NUMBER,
  p_ID_Artista NUMBER
) AS
BEGIN
  UPDATE T_Canciones
  SET ID_Album = p_ID_Album,
      Titulo = p_Titulo,
      Duracion = p_Duracion,
      Precio = p_Precio,
      ID_Artista = p_ID_Artista
  WHERE ID_Cancion = p_ID_Cancion;
END;
/
-- DELETE_T_CANCIONES_SP
CREATE OR REPLACE PROCEDURE DELETE_T_CANCIONES_SP(
  p_ID_Cancion NUMBER
) AS
BEGIN
  DELETE FROM T_Canciones WHERE ID_Cancion = p_ID_Cancion;
END;
/
-- CRUD T_PODCASTS
-- INSERT_T_PODCASTS_SP
CREATE OR REPLACE PROCEDURE INSERT_T_PODCASTS_SP(
  p_ID_Artista NUMBER,
  p_Titulo VARCHAR2,
  p_Descripcion VARCHAR2,
  p_URL VARCHAR2,
  p_Precio NUMBER
) AS
BEGIN
  INSERT INTO T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio)
  VALUES (seq_podcast.NEXTVAL, p_ID_Artista, p_Titulo, p_Descripcion, p_URL, p_Precio);
END;
/
-- SELECT_T_PODCASTS_SP
CREATE OR REPLACE PROCEDURE SELECT_T_PODCASTS_SP IS
BEGIN
  FOR r IN (SELECT * FROM T_Podcasts) LOOP
    DBMS_OUTPUT.PUT_LINE('ID: ' || r.ID_Podcast || ', Título: ' || r.Titulo || ', Precio: ' || r.Precio);
  END LOOP;
END;
/
-- UPDATE_T_PODCASTS_SP
CREATE OR REPLACE PROCEDURE UPDATE_T_PODCASTS_SP(
  p_ID_Podcast NUMBER,
  p_ID_Artista NUMBER,
  p_Titulo VARCHAR2,
  p_Descripcion VARCHAR2,
  p_URL VARCHAR2,
  p_Precio NUMBER
) AS
BEGIN
  UPDATE T_Podcasts
  SET ID_Artista = p_ID_Artista,
      Titulo = p_Titulo,
      Descripcion = p_Descripcion,
      URL = p_URL,
      Precio = p_Precio
  WHERE ID_Podcast = p_ID_Podcast;
END;
/
-- DELETE_T_PODCASTS_SP
CREATE OR REPLACE PROCEDURE DELETE_T_PODCASTS_SP(
  p_ID_Podcast NUMBER
) AS
BEGIN
  DELETE FROM T_Podcasts WHERE ID_Podcast = p_ID_Podcast;
END;
/
-- CRUD T_PODCASTS
-- INSERT_T_PODCASTS_SP
CREATE OR REPLACE PROCEDURE INSERT_T_PODCASTS_SP(
  p_ID_Artista NUMBER,
  p_Titulo VARCHAR2,
  p_Descripcion VARCHAR2,
  p_URL VARCHAR2,
  p_Precio NUMBER
) AS
BEGIN
  INSERT INTO T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio)
  VALUES (seq_podcast.NEXTVAL, p_ID_Artista, p_Titulo, p_Descripcion, p_URL, p_Precio);
END;
/

-- SELECT_T_PODCASTS_SP
CREATE OR REPLACE PROCEDURE SELECT_T_PODCASTS_SP IS
BEGIN
  FOR r IN (SELECT * FROM T_Podcasts) LOOP
    DBMS_OUTPUT.PUT_LINE('ID: ' || r.ID_Podcast || ', Título: ' || r.Titulo || ', Precio: ' || r.Precio);
  END LOOP;
END;
/

-- UPDATE_T_PODCASTS_SP
CREATE OR REPLACE PROCEDURE UPDATE_T_PODCASTS_SP(
  p_ID_Podcast NUMBER,
  p_ID_Artista NUMBER,
  p_Titulo VARCHAR2,
  p_Descripcion VARCHAR2,
  p_URL VARCHAR2,
  p_Precio NUMBER
) AS
BEGIN
  UPDATE T_Podcasts
  SET ID_Artista = p_ID_Artista,
      Titulo = p_Titulo,
      Descripcion = p_Descripcion,
      URL = p_URL,
      Precio = p_Precio
  WHERE ID_Podcast = p_ID_Podcast;
END;
/

-- DELETE_T_PODCASTS_SP
CREATE OR REPLACE PROCEDURE DELETE_T_PODCASTS_SP(
  p_ID_Podcast NUMBER
) AS
BEGIN
  DELETE FROM T_Podcasts WHERE ID_Podcast = p_ID_Podcast;
END;
/
-- CRUD T_EPISODIOS
-- INSERT_T_EPISODIOS_SP
CREATE OR REPLACE PROCEDURE INSERT_T_EPISODIOS_SP(
  p_ID_Podcast NUMBER,
  p_ID_Artista NUMBER,
  p_Duracion NUMBER,
  p_Precio NUMBER,
  p_URL VARCHAR2,
  p_Titulo VARCHAR2
) AS
BEGIN
  INSERT INTO T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo)
  VALUES (seq_episodio.NEXTVAL, p_ID_Podcast, p_ID_Artista, p_Duracion, p_Precio, p_URL, p_Titulo);
END;
/

-- SELECT_T_EPISODIOS_SP
CREATE OR REPLACE PROCEDURE SELECT_T_EPISODIOS_SP IS
BEGIN
  FOR r IN (SELECT * FROM T_Episodios) LOOP
    DBMS_OUTPUT.PUT_LINE('ID: ' || r.ID_Episodio || ', Título: ' || r.Titulo || ', Duración: ' || r.Duracion);
  END LOOP;
END;
/

-- UPDATE_T_EPISODIOS_SP
CREATE OR REPLACE PROCEDURE UPDATE_T_EPISODIOS_SP(
  p_ID_Episodio NUMBER,
  p_ID_Podcast NUMBER,
  p_ID_Artista NUMBER,
  p_Duracion NUMBER,
  p_Precio NUMBER,
  p_URL VARCHAR2,
  p_Titulo VARCHAR2
) AS
BEGIN
  UPDATE T_Episodios
  SET ID_Podcast = p_ID_Podcast,
      ID_Artista = p_ID_Artista,
      Duracion = p_Duracion,
      Precio = p_Precio,
      URL = p_URL,
      Titulo = p_Titulo
  WHERE ID_Episodio = p_ID_Episodio;
END;
/

-- DELETE_T_EPISODIOS_SP
CREATE OR REPLACE PROCEDURE DELETE_T_EPISODIOS_SP(
  p_ID_Episodio NUMBER
) AS
BEGIN
  DELETE FROM T_Episodios WHERE ID_Episodio = p_ID_Episodio;
END;
/
-- CRUD T_FACTURA
-- INSERT_T_FACTURA_SP
CREATE OR REPLACE PROCEDURE INSERT_T_FACTURA_SP(
  p_ID_Usuario NUMBER,
  p_Fecha_Compra DATE,
  p_Total NUMBER,
  p_Metodo_Pago VARCHAR2,
  p_Estado VARCHAR2
) AS
BEGIN
  INSERT INTO T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado)
  VALUES (seq_factura.NEXTVAL, p_ID_Usuario, p_Fecha_Compra, p_Total, p_Metodo_Pago, p_Estado);
END;
/

-- SELECT_T_FACTURA_SP
CREATE OR REPLACE PROCEDURE SELECT_T_FACTURA_SP IS
BEGIN
  FOR r IN (SELECT * FROM T_Factura) LOOP
    DBMS_OUTPUT.PUT_LINE('ID: ' || r.ID_Factura || ', Usuario: ' || r.ID_Usuario || ', Total: ' || r.Total);
  END LOOP;
END;
/

-- UPDATE_T_FACTURA_SP
CREATE OR REPLACE PROCEDURE UPDATE_T_FACTURA_SP(
  p_ID_Factura NUMBER,
  p_ID_Usuario NUMBER,
  p_Fecha_Compra DATE,
  p_Total NUMBER,
  p_Metodo_Pago VARCHAR2,
  p_Estado VARCHAR2
) AS
BEGIN
  UPDATE T_Factura
  SET ID_Usuario = p_ID_Usuario,
      Fecha_Compra = p_Fecha_Compra,
      Total = p_Total,
      Metodo_Pago = p_Metodo_Pago,
      Estado = p_Estado
  WHERE ID_Factura = p_ID_Factura;
END;
/

-- DELETE_T_FACTURA_SP
CREATE OR REPLACE PROCEDURE DELETE_T_FACTURA_SP(
  p_ID_Factura NUMBER
) AS
BEGIN
  DELETE FROM T_Factura WHERE ID_Factura = p_ID_Factura;
END;
/
-- CRUD T_FACTURA_DETALLES
-- INSERT_T_FACTURADETALLES_SP
CREATE OR REPLACE PROCEDURE INSERT_T_FACTURADETALLES_SP(
  p_ID_Factura NUMBER,
  p_ID_Cancion NUMBER,
  p_ID_Episodio NUMBER,
  p_ID_Podcast NUMBER,
  p_ID_Album NUMBER,
  p_Precio_Unitario NUMBER,
  p_Cantidad NUMBER,
  p_Subtotal NUMBER
) AS
BEGIN
  INSERT INTO T_FacturaDetalles (
    ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio,
    ID_Podcast, ID_Album, Precio_Unitario, Cantidad, Subtotal
  )
  VALUES (
    seq_facturadet.NEXTVAL, p_ID_Factura, p_ID_Cancion, p_ID_Episodio,
    p_ID_Podcast, p_ID_Album, p_Precio_Unitario, p_Cantidad, p_Subtotal
  );
END;
/

-- SELECT_T_FACTURADETALLES_SP
CREATE OR REPLACE PROCEDURE SELECT_T_FACTURADETALLES_SP IS
BEGIN
  FOR r IN (SELECT * FROM T_FacturaDetalles) LOOP
    DBMS_OUTPUT.PUT_LINE('Detalle ID: ' || r.ID_FacturaDetalle || ', Factura ID: ' || r.ID_Factura || ', Subtotal: ' || r.Subtotal);
  END LOOP;
END;
/

-- UPDATE_T_FACTURADETALLES_SP
CREATE OR REPLACE PROCEDURE UPDATE_T_FACTURADETALLES_SP(
  p_ID_FacturaDetalle NUMBER,
  p_ID_Factura NUMBER,
  p_ID_Cancion NUMBER,
  p_ID_Episodio NUMBER,
  p_ID_Podcast NUMBER,
  p_ID_Album NUMBER,
  p_Precio_Unitario NUMBER,
  p_Cantidad NUMBER,
  p_Subtotal NUMBER
) AS
BEGIN
  UPDATE T_FacturaDetalles
  SET ID_Factura = p_ID_Factura,
      ID_Cancion = p_ID_Cancion,
      ID_Episodio = p_ID_Episodio,
      ID_Podcast = p_ID_Podcast,
      ID_Album = p_ID_Album,
      Precio_Unitario = p_Precio_Unitario,
      Cantidad = p_Cantidad,
      Subtotal = p_Subtotal
  WHERE ID_FacturaDetalle = p_ID_FacturaDetalle;
END;
/

-- DELETE_T_FACTURADETALLES_SP
CREATE OR REPLACE PROCEDURE DELETE_T_FACTURADETALLES_SP(
  p_ID_FacturaDetalle NUMBER
) AS
BEGIN
  DELETE FROM T_FacturaDetalles WHERE ID_FacturaDetalle = p_ID_FacturaDetalle;
END;
/
-- CRUD T_COMENTARIOS
-- INSERT_T_COMENTARIOS_SP
CREATE OR REPLACE PROCEDURE INSERT_T_COMENTARIOS_SP(
  p_ID_Usuario NUMBER,
  p_ID_Cancion NUMBER,
  p_ID_Episodio NUMBER,
  p_Calificacion NUMBER,
  p_Comentario VARCHAR2,
  p_Fecha_Comentario DATE
) AS
BEGIN
  INSERT INTO T_Comentarios (
    ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio,
    Calificacion, Comentario, Fecha_Comentario
  )
  VALUES (
    seq_comentario.NEXTVAL, p_ID_Usuario, p_ID_Cancion, p_ID_Episodio,
    p_Calificacion, p_Comentario, p_Fecha_Comentario
  );
END;
/

-- SELECT_T_COMENTARIOS_SP
CREATE OR REPLACE PROCEDURE SELECT_T_COMENTARIOS_SP IS
BEGIN
  FOR r IN (SELECT * FROM T_Comentarios) LOOP
    DBMS_OUTPUT.PUT_LINE('Comentario ID: ' || r.ID_Comentario || ', Usuario: ' || r.ID_Usuario || ', Calificación: ' || r.Calificacion);
  END LOOP;
END;
/

-- UPDATE_T_COMENTARIOS_SP
CREATE OR REPLACE PROCEDURE UPDATE_T_COMENTARIOS_SP(
  p_ID_Comentario NUMBER,
  p_ID_Usuario NUMBER,
  p_ID_Cancion NUMBER,
  p_ID_Episodio NUMBER,
  p_Calificacion NUMBER,
  p_Comentario VARCHAR2,
  p_Fecha_Comentario DATE
) AS
BEGIN
  UPDATE T_Comentarios
  SET ID_Usuario = p_ID_Usuario,
      ID_Cancion = p_ID_Cancion,
      ID_Episodio = p_ID_Episodio,
      Calificacion = p_Calificacion,
      Comentario = p_Comentario,
      Fecha_Comentario = p_Fecha_Comentario
  WHERE ID_Comentario = p_ID_Comentario;
END;
/

-- DELETE_T_COMENTARIOS_SP
CREATE OR REPLACE PROCEDURE DELETE_T_COMENTARIOS_SP(
  p_ID_Comentario NUMBER
) AS
BEGIN
  DELETE FROM T_Comentarios WHERE ID_Comentario = p_ID_Comentario;
END;
/
-- CRUD T_ALBUMES_GENEROS
-- INSERT_T_ALBUMES_GENEROS_SP
CREATE OR REPLACE PROCEDURE INSERT_T_ALBUMES_GENEROS_SP(
  p_ID_Album NUMBER,
  p_ID_Genero NUMBER
) AS
BEGIN
  INSERT INTO T_Albumes_Generos (ID_Album, ID_Genero)
  VALUES (p_ID_Album, p_ID_Genero);
END;
/

-- SELECT_T_ALBUMES_GENEROS_SP
CREATE OR REPLACE PROCEDURE SELECT_T_ALBUMES_GENEROS_SP IS
BEGIN
  FOR r IN (SELECT * FROM T_Albumes_Generos) LOOP
    DBMS_OUTPUT.PUT_LINE('Álbum: ' || r.ID_Album || ', Género: ' || r.ID_Genero);
  END LOOP;
END;
/

-- UPDATE_T_ALBUMES_GENEROS_SP
CREATE OR REPLACE PROCEDURE UPDATE_T_ALBUMES_GENEROS_SP(
  p_ID_Album_OLD NUMBER,
  p_ID_Genero_OLD NUMBER,
  p_ID_Album_NEW NUMBER,
  p_ID_Genero_NEW NUMBER
) AS
BEGIN
  UPDATE T_Albumes_Generos
  SET ID_Album = p_ID_Album_NEW,
      ID_Genero = p_ID_Genero_NEW
  WHERE ID_Album = p_ID_Album_OLD AND ID_Genero = p_ID_Genero_OLD;
END;
/

-- DELETE_T_ALBUMES_GENEROS_SP
CREATE OR REPLACE PROCEDURE DELETE_T_ALBUMES_GENEROS_SP(
  p_ID_Album NUMBER,
  p_ID_Genero NUMBER
) AS
BEGIN
  DELETE FROM T_Albumes_Generos
  WHERE ID_Album = p_ID_Album AND ID_Genero = p_ID_Genero;
END;
/
-- CRUD T_CANCIONES_GENEROS
-- INSERT_T_CANCIONES_GENEROS_SP
CREATE OR REPLACE PROCEDURE INSERT_T_CANCIONES_GENEROS_SP(
  p_ID_Cancion NUMBER,
  p_ID_Genero NUMBER
) AS
BEGIN
  INSERT INTO T_Canciones_Generos (ID_Cancion, ID_Genero)
  VALUES (p_ID_Cancion, p_ID_Genero);
END;
/

-- SELECT_T_CANCIONES_GENEROS_SP
CREATE OR REPLACE PROCEDURE SELECT_T_CANCIONES_GENEROS_SP IS
BEGIN
  FOR r IN (SELECT * FROM T_Canciones_Generos) LOOP
    DBMS_OUTPUT.PUT_LINE('Canción: ' || r.ID_Cancion || ', Género: ' || r.ID_Genero);
  END LOOP;
END;
/

-- UPDATE_T_CANCIONES_GENEROS_SP
CREATE OR REPLACE PROCEDURE UPDATE_T_CANCIONES_GENEROS_SP(
  p_ID_Cancion_OLD NUMBER,
  p_ID_Genero_OLD NUMBER,
  p_ID_Cancion_NEW NUMBER,
  p_ID_Genero_NEW NUMBER
) AS
BEGIN
  UPDATE T_Canciones_Generos
  SET ID_Cancion = p_ID_Cancion_NEW,
      ID_Genero = p_ID_Genero_NEW
  WHERE ID_Cancion = p_ID_Cancion_OLD AND ID_Genero = p_ID_Genero_OLD;
END;
/

-- DELETE_T_CANCIONES_GENEROS_SP
CREATE OR REPLACE PROCEDURE DELETE_T_CANCIONES_GENEROS_SP(
  p_ID_Cancion NUMBER,
  p_ID_Genero NUMBER
) AS
BEGIN
  DELETE FROM T_Canciones_Generos
  WHERE ID_Cancion = p_ID_Cancion AND ID_Genero = p_ID_Genero;
END;
/
-- CRUD T_EPISODIOS_GENEROS
-- INSERT_T_EPISODIOS_GENEROS_SP
CREATE OR REPLACE PROCEDURE INSERT_T_EPISODIOS_GENEROS_SP(
  p_ID_Episodio NUMBER,
  p_ID_Genero NUMBER
) AS
BEGIN
  INSERT INTO T_Episodios_Generos (ID_Episodio, ID_Genero)
  VALUES (p_ID_Episodio, p_ID_Genero);
END;
/

-- SELECT_T_EPISODIOS_GENEROS_SP
CREATE OR REPLACE PROCEDURE SELECT_T_EPISODIOS_GENEROS_SP IS
BEGIN
  FOR r IN (SELECT * FROM T_Episodios_Generos) LOOP
    DBMS_OUTPUT.PUT_LINE('Episodio: ' || r.ID_Episodio || ', Género: ' || r.ID_Genero);
  END LOOP;
END;
/

-- UPDATE_T_EPISODIOS_GENEROS_SP
CREATE OR REPLACE PROCEDURE UPDATE_T_EPISODIOS_GENEROS_SP(
  p_ID_Episodio_OLD NUMBER,
  p_ID_Genero_OLD NUMBER,
  p_ID_Episodio_NEW NUMBER,
  p_ID_Genero_NEW NUMBER
) AS
BEGIN
  UPDATE T_Episodios_Generos
  SET ID_Episodio = p_ID_Episodio_NEW,
      ID_Genero = p_ID_Genero_NEW
  WHERE ID_Episodio = p_ID_Episodio_OLD AND ID_Genero = p_ID_Genero_OLD;
END;
/

-- DELETE_T_EPISODIOS_GENEROS_SP
CREATE OR REPLACE PROCEDURE DELETE_T_EPISODIOS_GENEROS_SP(
  p_ID_Episodio NUMBER,
  p_ID_Genero NUMBER
) AS
BEGIN
  DELETE FROM T_Episodios_Generos
  WHERE ID_Episodio = p_ID_Episodio AND ID_Genero = p_ID_Genero;
END;
/
--CRUD T_PODCAST_GENEROS
-- INSERT_T_PODCAST_GENEROS_SP
CREATE OR REPLACE PROCEDURE INSERT_T_PODCAST_GENEROS_SP(
  p_ID_Podcast NUMBER,
  p_ID_Genero NUMBER
) AS
BEGIN
  INSERT INTO T_Podcast_Generos (ID_Podcast, ID_Genero)
  VALUES (p_ID_Podcast, p_ID_Genero);
END;
/

-- SELECT_T_PODCAST_GENEROS_SP
CREATE OR REPLACE PROCEDURE SELECT_T_PODCAST_GENEROS_SP IS
BEGIN
  FOR r IN (SELECT * FROM T_Podcast_Generos) LOOP
    DBMS_OUTPUT.PUT_LINE('Podcast: ' || r.ID_Podcast || ', Género: ' || r.ID_Genero);
  END LOOP;
END;
/

-- UPDATE_T_PODCAST_GENEROS_SP
CREATE OR REPLACE PROCEDURE UPDATE_T_PODCAST_GENEROS_SP(
  p_ID_Podcast_OLD NUMBER,
  p_ID_Genero_OLD NUMBER,
  p_ID_Podcast_NEW NUMBER,
  p_ID_Genero_NEW NUMBER
) AS
BEGIN
  UPDATE T_Podcast_Generos
  SET ID_Podcast = p_ID_Podcast_NEW,
      ID_Genero = p_ID_Genero_NEW
  WHERE ID_Podcast = p_ID_Podcast_OLD AND ID_Genero = p_ID_Genero_OLD;
END;
/

-- DELETE_T_PODCAST_GENEROS_SP
CREATE OR REPLACE PROCEDURE DELETE_T_PODCAST_GENEROS_SP(
  p_ID_Podcast NUMBER,
  p_ID_Genero NUMBER
) AS
BEGIN
  DELETE FROM T_Podcast_Generos
  WHERE ID_Podcast = p_ID_Podcast AND ID_Genero = p_ID_Genero;
END;
/

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------OTROS INDICES------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- Índice para búsqueda de usuarios por email
CREATE UNIQUE INDEX USUARIOS_EMAIL_IDX ON T_Usuarios (Email)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

-- Índice para búsqueda de artistas por nombre
CREATE INDEX ARTISTAS_NOMBRE_IDX ON T_Artistas (Nombre)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

-- Índice para búsqueda de canciones por título
CREATE INDEX CANCIONES_TITULO_IDX ON T_Canciones (Titulo)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

-- Índice para facturas por usuario y fecha 
CREATE INDEX FACTURA_USUARIO_FECHA_IDX ON T_Factura (ID_Usuario, Fecha_Compra)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

-- Índice para comentarios por canción y calificación 
CREATE INDEX COMENTARIOS_CANCION_CALIF_IDX ON T_Comentarios (ID_Cancion, Calificacion)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

-- Índice para comentarios por episodio y calificación 
CREATE INDEX COMENTARIOS_EPISODIO_CALIF_IDX ON T_Comentarios (ID_Episodio, Calificacion)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

-- Índice para búsqueda de canciones por artista y duración 
CREATE INDEX CANCIONES_ARTISTA_DURACION_IDX ON T_Canciones (ID_Artista, Duracion)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

-- Índice para episodios por podcast y duración 
CREATE INDEX EPISODIOS_PODCAST_DURACION_IDX ON T_Episodios (ID_Podcast, Duracion)
TABLESPACE TS_SOUNDHUB_INDICES
INITRANS 10;

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------VISTAS----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

-- Vista artístas y álbumes
CREATE OR REPLACE VIEW V_Artistas_Albumes AS
SELECT 
    a.ID_Artista,
    a.Nombre_Artistico AS Artista,
    al.ID_Album,
    al.Titulo AS Album,
    al.Fecha_Lanzamiento,
    COUNT(c.ID_Cancion) AS Cantidad_Canciones
FROM T_Artistas a
LEFT JOIN T_Albumes al ON a.ID_Artista = al.ID_Artista
LEFT JOIN T_Canciones c ON al.ID_Album = c.ID_Album
GROUP BY a.ID_Artista, a.Nombre_Artistico, al.ID_Album, al.Titulo, al.Fecha_Lanzamiento;

-- Vista canciones populares (con más compras)
CREATE OR REPLACE VIEW V_Canciones_Populares AS
SELECT 
    c.ID_Cancion,
    c.Titulo AS Cancion,
    a.Nombre_Artistico AS Artista,
    COUNT(fd.ID_FacturaDetalle) AS Veces_Comprada
FROM T_Canciones c
JOIN T_Artistas a ON c.ID_Artista = a.ID_Artista
LEFT JOIN T_FacturaDetalles fd ON c.ID_Cancion = fd.ID_Cancion
GROUP BY c.ID_Cancion, c.Titulo, a.Nombre_Artistico
ORDER BY Veces_Comprada DESC;

-- Vista de comentarios recientes
CREATE OR REPLACE VIEW V_Comentarios_Recientes AS
SELECT 
    c.ID_Comentario,
    u.Nombre AS Usuario,
    COALESCE(cn.Titulo, ep.Titulo) AS Contenido,
    c.Calificacion,
    c.Comentario,
    c.Fecha_Comentario
FROM T_Comentarios c
JOIN T_Usuarios u ON c.ID_Usuario = u.ID_Usuario
LEFT JOIN T_Canciones cn ON c.ID_Cancion = cn.ID_Cancion
LEFT JOIN T_Episodios ep ON c.ID_Episodio = ep.ID_Episodio
ORDER BY c.Fecha_Comentario DESC;

-- Vista de compras por mes
CREATE OR REPLACE VIEW V_Compras_Por_Mes AS
SELECT 
    TO_CHAR(f.Fecha_Compra, 'YYYY-MM') AS Mes,
    COUNT(f.ID_Factura) AS Total_Compras,
    SUM(f.Total) AS Ingresos_Totales,
    COUNT(DISTINCT f.ID_Usuario) AS Usuarios_Unicos
FROM T_Factura f
GROUP BY TO_CHAR(f.Fecha_Compra, 'YYYY-MM')
ORDER BY Mes DESC;

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------CREACION DE ROLES------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- Rol para administradores con todos los privilegios
CREATE ROLE ROL_SOUNDHUB_ADMIN;

-- Permisos completos sobre todas las tablas
GRANT ALL PRIVILEGES ON T_Generos TO ROL_SOUNDHUB_ADMIN;
GRANT ALL PRIVILEGES ON T_Artistas TO ROL_SOUNDHUB_ADMIN;
GRANT ALL PRIVILEGES ON T_Albumes TO ROL_SOUNDHUB_ADMIN;
GRANT ALL PRIVILEGES ON T_Canciones TO ROL_SOUNDHUB_ADMIN;
GRANT ALL PRIVILEGES ON T_Podcasts TO ROL_SOUNDHUB_ADMIN;
GRANT ALL PRIVILEGES ON T_Episodios TO ROL_SOUNDHUB_ADMIN;
GRANT ALL PRIVILEGES ON T_Usuarios TO ROL_SOUNDHUB_ADMIN;
GRANT ALL PRIVILEGES ON T_Factura TO ROL_SOUNDHUB_ADMIN;
GRANT ALL PRIVILEGES ON T_FacturaDetalles TO ROL_SOUNDHUB_ADMIN;
GRANT ALL PRIVILEGES ON T_Comentarios TO ROL_SOUNDHUB_ADMIN;
GRANT ALL PRIVILEGES ON T_Albumes_Generos TO ROL_SOUNDHUB_ADMIN;
GRANT ALL PRIVILEGES ON T_Canciones_Generos TO ROL_SOUNDHUB_ADMIN;
GRANT ALL PRIVILEGES ON T_Episodios_Generos TO ROL_SOUNDHUB_ADMIN;
GRANT ALL PRIVILEGES ON T_Podcast_Generos TO ROL_SOUNDHUB_ADMIN;

-- Permisos adicionales para administradores
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, 
      CREATE SEQUENCE, CREATE TRIGGER TO ROL_SOUNDHUB_ADMIN;

-- Rol para usuarios normales con permisos limitados
CREATE ROLE ROL_SOUNDHUB_USER;

-- Permisos de solo lectura en tablas de catálogo
GRANT SELECT ON T_Generos TO ROL_SOUNDHUB_USER;
GRANT SELECT ON T_Artistas TO ROL_SOUNDHUB_USER;
GRANT SELECT ON T_Albumes TO ROL_SOUNDHUB_USER;
GRANT SELECT ON T_Canciones TO ROL_SOUNDHUB_USER;
GRANT SELECT ON T_Podcasts TO ROL_SOUNDHUB_USER;
GRANT SELECT ON T_Episodios TO ROL_SOUNDHUB_USER;

-- Permisos completos en su propia información de usuario
GRANT SELECT, INSERT, UPDATE ON T_Usuarios TO ROL_SOUNDHUB_USER;

-- Permisos limitados en facturación (solo sus propias facturas)
GRANT SELECT, INSERT ON T_Factura TO ROL_SOUNDHUB_USER;
GRANT SELECT, INSERT ON T_FacturaDetalles TO ROL_SOUNDHUB_USER;

-- Permisos para comentarios
GRANT SELECT, INSERT, UPDATE, DELETE ON T_Comentarios TO ROL_SOUNDHUB_USER;

-- Permiso para crear sesión
GRANT CREATE SESSION TO ROL_SOUNDHUB_USER;

-- Asignar rol de administrador al usuario admin
GRANT ROL_SOUNDHUB_ADMIN TO SOUNDHUB_ADMIN;

-- Asignar rol de usuario normal al usuario estándar
GRANT ROL_SOUNDHUB_USER TO SOUNDHUB_USER;

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------INSERCION DE DATOS--------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- Insercion de datos en T_Generos usando procedimiento almacenado
BEGIN
  INSERT_T_GENEROS_SP('Rock');
  INSERT_T_GENEROS_SP('Pop');
  INSERT_T_GENEROS_SP('Hip-Hop');
  INSERT_T_GENEROS_SP('Reggaeton');
  INSERT_T_GENEROS_SP('Electronica');
  INSERT_T_GENEROS_SP('Jazz');
  INSERT_T_GENEROS_SP('Clasica');
END;







