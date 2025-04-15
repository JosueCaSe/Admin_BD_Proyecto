
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
GRANT CONNECT, RESOURCE TO SOUNDHUB_ADMIN;

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
   PASSWORD_GRACE_TIME       7;         -- 7 días de gracia para cambiar contraseña

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
   PASSWORD_GRACE_TIME       5;         -- 5 días de gracia para cambiar contraseña

-- Asignar perfil de administrador
ALTER USER SOUNDHUB_ADMIN PROFILE PROFILE_SOUNDHUB_ADMIN;

-- Asignar perfil de usuario normal
ALTER USER SOUNDHUB_USER PROFILE PROFILE_SOUNDHUB_USER;

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------CREACION DE TABLESPACES----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
-- Creacion de usuarios del sistema 
//Tablespace TS_SOUNDHUB_DATOS
CREATE TABLESPACE TS_SOUNDHUB_DATOS DATAFILE 'TS_SOUNDHUB_DATOS001.DBF'
SIZE 16M AUTOEXTEND ON NEXT 16M MAXSIZE UNLIMITED
BLOCKSIZE 8K;

//Tablespace TS_SOUNDHUB_INDICES
CREATE TABLESPACE TS_SOUNDHUB_INDICES DATAFILE 'TS_SOUNDHUB_INDICES001.DBF'
SIZE 16M AUTOEXTEND ON NEXT 16M MAXSIZE UNLIMITED
BLOCKSIZE 8K;

//Tablespace TS_SOUNDHUB_TEMPORAL
CREATE TEMPORARY TABLESPACE TS_SOUNDHUB_TEMPORAL 
TEMPFILE 'TS_SOUNDHUB_TEMPORAL001.TMP' SIZE 16M AUTOEXTEND ON NEXT 16M MAXSIZE UNLIMITED
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
  ID_Genero NUMBER ,
  Nombre_Genero VARCHAR2(100)
)
TABLESPACE TS_SOUNDHUB_DATOS
INITRANS 10;

select * from T_Artistas;

-- Tabla de Artistas
CREATE TABLE T_Artistas (
  ID_Artista NUMBER ,
  Nombre VARCHAR2(100),
  Nombre_Artistico VARCHAR2(100),
  Biografica VARCHAR2(1000)
)
TABLESPACE TS_SOUNDHUB_DATOS
INITRANS 10;



-- Tabla de Álbumes
CREATE TABLE T_Albumes (
  ID_Album NUMBER,
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
  ID_Cancion NUMBER ,
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
  ID_Podcast NUMBER ,
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
  ID_Episodio NUMBER ,
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
  FOREIGN KEY (ID_Album) REFERENCES T_Albumes(ID_Album) ON DELETE CASCADE,
  FOREIGN KEY (ID_Genero) REFERENCES T_Generos(ID_Genero) ON DELETE CASCADE
)
TABLESPACE TS_SOUNDHUB_DATOS
INITRANS 10;

CREATE TABLE T_Canciones_Generos (
  ID_Cancion NUMBER,
  ID_Genero NUMBER,
  FOREIGN KEY (ID_Cancion) REFERENCES T_Canciones(ID_Cancion) ON DELETE CASCADE,
  FOREIGN KEY (ID_Genero) REFERENCES T_Generos(ID_Genero) ON DELETE CASCADE
)
TABLESPACE TS_SOUNDHUB_DATOS
INITRANS 10;

CREATE TABLE T_Episodios_Generos (
  ID_Episodio NUMBER,
  ID_Genero NUMBER,
  FOREIGN KEY (ID_Episodio) REFERENCES T_Episodios(ID_Episodio) ON DELETE CASCADE,
  FOREIGN KEY (ID_Genero) REFERENCES T_Generos(ID_Genero) ON DELETE CASCADE
)
TABLESPACE TS_SOUNDHUB_DATOS
INITRANS 10;

CREATE TABLE T_Podcast_Generos (
  ID_Podcast NUMBER,
  ID_Genero NUMBER,
  FOREIGN KEY (ID_Podcast) REFERENCES T_Podcasts(ID_Podcast) ON DELETE CASCADE,
  FOREIGN KEY (ID_Genero) REFERENCES T_Generos(ID_Genero) ON DELETE CASCADE
)
TABLESPACE TS_SOUNDHUB_DATOS
INITRANS 10;

-- Tabla de Usuarios
CREATE TABLE T_Usuarios (
  ID_Usuario NUMBER,
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
  ID_Factura NUMBER,
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
  ID_FacturaDetalle NUMBER,
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
  ID_Comentario NUMBER,
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

-- Inserccion de datos en T_Artistas

insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (1, 'Erwin', 'etrorey0', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (2, 'Nanete', 'nloisi1', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (3, 'Luise', 'lkeasy2', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (4, 'Livvy', 'lwindram3', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (5, 'Alfonso', 'aagglio4', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (6, 'Aveline', 'aranscombe5', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (7, 'Seumas', 'sworsnip6', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (8, 'Bonni', 'bscarlan7', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (9, 'Virginia', 'vskiggs8', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (10, 'Alfi', 'aechlin9', 'In congue. Etiam justo. Etiam pretium iaculis justo.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (11, 'Angeline', 'ajeeksa', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (12, 'Doy', 'dyearnb', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (13, 'Ailis', 'adangelic', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (14, 'Margaretta', 'mshallcroffd', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (15, 'Davidde', 'dbainbridgee', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (16, 'Raviv', 'rhorsfieldf', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (17, 'Jamaal', 'jwormleightong', 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (18, 'Nonah', 'nbehningh', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (19, 'Nancy', 'njanowskii', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (20, 'Arthur', 'awhitefordj', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (21, 'Westley', 'wchinnockk', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (22, 'Larine', 'litzcakl', 'Phasellus in felis. Donec semper sapien a libero. Nam dui.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (23, 'Casandra', 'cjemmettm', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (24, 'Adina', 'adurniann', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (25, 'Kaja', 'kavraamo', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (26, 'Loree', 'lwinneyp', 'Fusce consequat. Nulla nisl. Nunc nisl.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (27, 'Mirella', 'mguthrieq', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (28, 'Lincoln', 'lkarpr', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (29, 'Desiree', 'dilchuks', 'In congue. Etiam justo. Etiam pretium iaculis justo.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (30, 'Nils', 'njakucewiczt', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (31, 'Baryram', 'bheretyu', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (32, 'Birk', 'bahlinv', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (33, 'Cathie', 'ctidmarshw', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (34, 'Vinita', 'vharriotx', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (35, 'Meredithe', 'mspiresy', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (36, 'Benedetto', 'bhargeyz', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (37, 'Kimbell', 'kalliband10', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (38, 'Ivett', 'iilles11', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (39, 'Nicky', 'nrathmell12', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (40, 'Dacey', 'dburge13', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (41, 'Rickard', 'rwilding14', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (42, 'Lonnie', 'ldunstone15', 'Fusce consequat. Nulla nisl. Nunc nisl.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (43, 'Alford', 'asaye16', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (44, 'Newton', 'ndufray17', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (45, 'Frankie', 'fjoyner18', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (46, 'Hildegarde', 'hloadsman19', 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (47, 'Wat', 'wyesipov1a', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (48, 'Freemon', 'fseggie1b', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (49, 'Cacilia', 'cspraggs1c', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (50, 'Bartholomeo', 'bdunkerly1d', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (51, 'Benetta', 'bbrilleman1e', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (52, 'Kalindi', 'kdanahar1f', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (53, 'Esther', 'emcilvoray1g', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (54, 'Adah', 'apanniers1h', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (55, 'Seumas', 'scaulkett1i', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (56, 'Garv', 'gkinsett1j', 'In congue. Etiam justo. Etiam pretium iaculis justo.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (57, 'Daria', 'drolley1k', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (58, 'Reggie', 'rpasse1l', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (59, 'Alta', 'abeddows1m', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (60, 'Joey', 'jwillcot1n', 'In congue. Etiam justo. Etiam pretium iaculis justo.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (61, 'Valentina', 'vjosling1o', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (62, 'Roby', 'rhonacker1p', 'Fusce consequat. Nulla nisl. Nunc nisl.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (63, 'Perry', 'piacivelli1q', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (64, 'Dolly', 'dmewitt1r', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (65, 'Annie', 'araubenheimers1s', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (66, 'Aarika', 'aosban1t', 'In congue. Etiam justo. Etiam pretium iaculis justo.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (67, 'Rasla', 'rwindows1u', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (68, 'Margaret', 'meastes1v', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (69, 'Berny', 'bpaolillo1w', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (70, 'Aurelia', 'acornes1x', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (71, 'Meridith', 'mgierck1y', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (72, 'Jamie', 'jjarrett1z', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (73, 'Quintus', 'qcomberbeach20', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (74, 'Sayre', 'sblundan21', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (75, 'Christoper', 'cwilbor22', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (76, 'Meggy', 'mwashington23', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (77, 'Bartholemy', 'bdermott24', 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (78, 'Micky', 'mdils25', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (79, 'Norma', 'nlawrenceson26', 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (80, 'Lancelot', 'lscraggs27', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (81, 'Michaella', 'mpook28', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (82, 'Joana', 'jrainey29', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (83, 'Angelico', 'adelooze2a', 'In congue. Etiam justo. Etiam pretium iaculis justo.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (84, 'Kati', 'kabbe2b', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (85, 'Giselbert', 'gstower2c', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (86, 'Clyve', 'cslidders2d', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (87, 'Pauli', 'pllorens2e', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (88, 'Gaven', 'ggunstone2f', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (89, 'Philippe', 'pkaasman2g', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (90, 'Melosa', 'mbernadot2h', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (91, 'Cherrita', 'croberson2i', 'Fusce consequat. Nulla nisl. Nunc nisl.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (92, 'Inesita', 'icauderlie2j', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (93, 'Tiebold', 'tbrennand2k', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (94, 'Jobina', 'jnealand2l', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (95, 'Flori', 'fsparwell2m', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (96, 'Beniamino', 'bsaint2n', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (97, 'Myrle', 'mgaggen2o', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (98, 'Wayne', 'wminney2p', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (99, 'Meggi', 'moxford2q', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (100, 'Venita', 'vagates2r', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (101, 'Lionel', 'lscottini2s', 'Phasellus in felis. Donec semper sapien a libero. Nam dui.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (102, 'Cassi', 'crycroft2t', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (103, 'Padriac', 'paugustin2u', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (104, 'Trenton', 'tmatovic2v', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (105, 'Rachael', 'rsantora2w', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (106, 'Cristen', 'cstrattan2x', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (107, 'Erasmus', 'ebarz2y', 'Fusce consequat. Nulla nisl. Nunc nisl.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (108, 'Eliza', 'eshortt2z', 'In congue. Etiam justo. Etiam pretium iaculis justo.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (109, 'Doti', 'dgianulli30', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (110, 'Sonia', 'sdaguanno31', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (111, 'Beatriz', 'bbence32', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (112, 'Briney', 'bphelipeau33', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (113, 'Celeste', 'cjerzak34', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (114, 'Porty', 'pbuggs35', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (115, 'Caril', 'ckann36', 'In congue. Etiam justo. Etiam pretium iaculis justo.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (116, 'Drusilla', 'dmacneilley37', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (117, 'Meredeth', 'mpressland38', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (118, 'Winifield', 'wdirkin39', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (119, 'Sloan', 'salejandri3a', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (120, 'Brandy', 'bbeale3b', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (121, 'Nertie', 'nfatharly3c', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (122, 'Niles', 'npaolini3d', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (123, 'Agnes', 'aloxly3e', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (124, 'Gwynne', 'gmccomish3f', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (125, 'Janis', 'jsangwin3g', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (126, 'Stavros', 'scastells3h', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (127, 'Natalie', 'nroblin3i', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (128, 'Lizbeth', 'lblakeslee3j', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (129, 'Nev', 'nmcguggy3k', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (130, 'Dukie', 'dtrodd3l', 'In congue. Etiam justo. Etiam pretium iaculis justo.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (131, 'Nell', 'ngartland3m', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (132, 'Mike', 'msheryn3n', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (133, 'Lynette', 'lcrannell3o', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (134, 'Ulrike', 'utranter3p', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (135, 'Candra', 'cmeriott3q', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (136, 'Dennie', 'dharhoff3r', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (137, 'Arleta', 'aodde3s', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (138, 'Andrej', 'amattevi3t', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (139, 'Sven', 'sstockbridge3u', 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (140, 'Gilberto', 'glarkworthy3v', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (141, 'Ramsey', 'rrider3w', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (142, 'Goddart', 'ggreader3x', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (143, 'Verena', 'vrigard3y', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (144, 'Fernanda', 'fbaggot3z', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (145, 'Jermaine', 'jissacof40', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (146, 'Gauthier', 'gmorland41', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (147, 'Joshua', 'jmarusik42', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (148, 'Gearard', 'gshilstone43', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (149, 'Nevins', 'nveitch44', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (150, 'Vicki', 'vramas45', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (151, 'Cass', 'copdenort46', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (152, 'Judith', 'jpollastro47', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (153, 'Jo-ann', 'jghelerdini48', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (154, 'Giorgio', 'gsuscens49', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (155, 'Adolphus', 'akleinplatz4a', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (156, 'Archibaldo', 'aenevoldsen4b', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (157, 'Nanon', 'nmowbury4c', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (158, 'Mollie', 'mwedge4d', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (159, 'Louisa', 'lrunham4e', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (160, 'Sharla', 'sarnot4f', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (161, 'Gareth', 'gpiccard4g', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (162, 'Artair', 'awallage4h', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (163, 'Raleigh', 'rdaish4i', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (164, 'Roana', 'rolivelli4j', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (165, 'Bruis', 'breadhead4k', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (166, 'Georgena', 'gtixier4l', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (167, 'Theda', 'twarbey4m', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (168, 'Anatola', 'abreeds4n', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (169, 'Dwain', 'dstrass4o', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (170, 'Vito', 'vwoolbrook4p', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (171, 'Horatio', 'hokielt4q', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (172, 'Arielle', 'aohogertie4r', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (173, 'Lilli', 'ldewer4s', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (174, 'Adriane', 'alesieur4t', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (175, 'Kelila', 'kposse4u', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (176, 'Daven', 'dmcgahern4v', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (177, 'Brit', 'bblackmore4w', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (178, 'Aubrie', 'alepiscopio4x', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (179, 'Ruprecht', 'rdeknevet4y', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (180, 'Lynsey', 'lgoulborn4z', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (181, 'Damien', 'dhazelden50', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (182, 'Kalvin', 'klabbey51', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (183, 'Willi', 'wwornum52', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (184, 'Carry', 'cverne53', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (185, 'Husain', 'hperry54', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (186, 'Lesly', 'lcornford55', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (187, 'Daria', 'dwarboy56', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (188, 'Janeen', 'jwoolstenholmes57', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (189, 'Marni', 'mirvin58', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (190, 'Korrie', 'kscottrell59', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (191, 'Teriann', 'tlindenman5a', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (192, 'Zorina', 'zgothard5b', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (193, 'Tamqrah', 'tpottage5c', 'Fusce consequat. Nulla nisl. Nunc nisl.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (194, 'Josey', 'jscorton5d', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (195, 'Fernando', 'fcashen5e', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (196, 'Thorn', 'tscutter5f', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (197, 'Caro', 'cdonovan5g', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (198, 'Darcy', 'dhurry5h', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (199, 'Michell', 'mborless5i', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.');
insert into T_Artistas (ID_Artista, Nombre, Nombre_Artistico, Biografica) values (200, 'Devina', 'dwheadon5j', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.');

select * from T_Canciones; 

-- Inserccion de datos en  T_Albumes

insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 113, 'Home Ing', '01/03/2025', 'https://music.io/song/73', 8.37);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 113, 'Sonsing', '01/09/2025', 'https://music.io/song/80', 12.33);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 33, 'Bamity', '09/01/2024', 'https://music.io/song/62', 5.87);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 149, 'Sonsing', '11/02/2024', 'https://music.io/song/94', 5.42);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 30, 'Zoolab', '03/13/2025', 'https://music.io/song/97', 7.08);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 30, 'Kanlam', '10/12/2024', 'https://music.io/song/91', 19.24);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 138, 'Prodder', '03/12/2025', 'https://music.io/song/7', 9.26);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 81, 'Vagram', '09/15/2024', 'https://music.io/song/27', 18.17);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 1, 'Bamity', '09/15/2024', 'https://music.io/song/22', 5.94);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 8, 'Wrapsafe', '09/24/2024', 'https://music.io/song/68', 18.81);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 47, 'Rank', '11/03/2024', 'https://music.io/song/42', 12.22);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 50, 'Flowdesk', '05/18/2024', 'https://music.io/song/68', 15.17);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 2, 'Stronghold', '07/23/2024', 'https://music.io/song/31', 6.85);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 97, 'Sonsing', '03/04/2025', 'https://music.io/song/94', 9.57);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 63, 'Flexidy', '01/13/2025', 'https://music.io/song/14', 6.55);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 60, 'Sonair', '05/03/2024', 'https://music.io/song/85', 5.66);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 24, 'Zamit', '07/14/2024', 'https://music.io/song/73', 12.64);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 102, 'Solarbreeze', '05/01/2024', 'https://music.io/song/1', 12.37);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 55, 'Cardguard', '10/02/2024', 'https://music.io/song/65', 11.3);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 115, 'Prodder', '05/06/2024', 'https://music.io/song/16', 12.77);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 40, 'Zontrax', '07/21/2024', 'https://music.io/song/1', 16.1);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 91, 'Prodder', '08/16/2024', 'https://music.io/song/92', 19.98);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 139, 'Ventosanzap', '07/23/2024', 'https://music.io/song/10', 12.78);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 36, 'Asoka', '11/20/2024', 'https://music.io/song/43', 12.01);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 9, 'Alphazap', '05/23/2024', 'https://music.io/song/65', 14.55);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 134, 'Voltsillam', '03/23/2025', 'https://music.io/song/54', 9.3);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 6, 'Y-Solowarm', '01/06/2025', 'https://music.io/song/36', 13.29);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 48, 'Stim', '10/19/2024', 'https://music.io/song/50', 8.24);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 74, 'Bigtax', '08/04/2024', 'https://music.io/song/25', 17.24);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 139, 'Trippledex', '02/16/2025', 'https://music.io/song/36', 14.58);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 75, 'Mat Lam Tam', '07/15/2024', 'https://music.io/song/88', 18.44);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 135, 'Ronstring', '12/04/2024', 'https://music.io/song/53', 19.74);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 74, 'Gembucket', '10/01/2024', 'https://music.io/song/64', 19.26);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 2, 'Bitwolf', '06/22/2024', 'https://music.io/song/1', 17.4);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 12, 'Y-find', '10/31/2024', 'https://music.io/song/89', 10.67);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 25, 'Mat Lam Tam', '10/09/2024', 'https://music.io/song/91', 8.29);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 65, 'Redhold', '12/19/2024', 'https://music.io/song/76', 18.08);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 9, 'Y-Solowarm', '09/16/2024', 'https://music.io/song/19', 7.53);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 108, 'Overhold', '07/18/2024', 'https://music.io/song/69', 19.36);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 130, 'Redhold', '06/30/2024', 'https://music.io/song/51', 8.93);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 149, 'Alphazap', '02/01/2025', 'https://music.io/song/81', 14.15);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 126, 'Treeflex', '01/23/2025', 'https://music.io/song/54', 16.36);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 31, 'Duobam', '12/01/2024', 'https://music.io/song/72', 19.73);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 38, 'Pannier', '11/18/2024', 'https://music.io/song/36', 9.07);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 102, 'Veribet', '01/06/2025', 'https://music.io/song/33', 15.48);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 5, 'Flowdesk', '12/09/2024', 'https://music.io/song/46', 8.06);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 7, 'Redhold', '11/13/2024', 'https://music.io/song/41', 9.45);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 58, 'Greenlam', '07/06/2024', 'https://music.io/song/84', 11.53);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 145, 'Otcom', '09/09/2024', 'https://music.io/song/32', 15.72);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 25, 'Matsoft', '11/18/2024', 'https://music.io/song/24', 11.69);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 62, 'Span', '08/06/2024', 'https://music.io/song/76', 7.22);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 90, 'Job', '02/10/2025', 'https://music.io/song/15', 19.65);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 143, 'Regrant', '05/27/2024', 'https://music.io/song/39', 6.43);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 128, 'Stronghold', '01/28/2025', 'https://music.io/song/61', 17.03);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 20, 'Wrapsafe', '05/25/2024', 'https://music.io/song/88', 17.93);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 66, 'Zontrax', '06/16/2024', 'https://music.io/song/95', 13.61);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 49, 'Tin', '09/13/2024', 'https://music.io/song/38', 17.15);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 25, 'Ventosanzap', '02/13/2025', 'https://music.io/song/64', 15.08);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 92, 'Ventosanzap', '06/12/2024', 'https://music.io/song/51', 17.43);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 31, 'Rank', '03/25/2025', 'https://music.io/song/76', 15.77);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 110, 'Namfix', '10/23/2024', 'https://music.io/song/96', 14.25);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 24, 'Alphazap', '07/19/2024', 'https://music.io/song/78', 12.4);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 96, 'Pannier', '11/15/2024', 'https://music.io/song/28', 16.93);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 130, 'Veribet', '09/01/2024', 'https://music.io/song/12', 17.25);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 79, 'Vagram', '09/14/2024', 'https://music.io/song/43', 19.39);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 27, 'Namfix', '05/04/2024', 'https://music.io/song/10', 5.77);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 72, 'Matsoft', '09/03/2024', 'https://music.io/song/69', 11.83);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 75, 'Stringtough', '01/01/2025', 'https://music.io/song/71', 11.78);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 87, 'Bitwolf', '09/17/2024', 'https://music.io/song/8', 18.93);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 42, 'Cookley', '03/09/2025', 'https://music.io/song/69', 8.71);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 16, 'Bitwolf', '03/10/2025', 'https://music.io/song/56', 6.03);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 9, 'Bitwolf', '02/22/2025', 'https://music.io/song/81', 11.3);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 116, 'Stronghold', '05/08/2024', 'https://music.io/song/21', 12.51);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 120, 'Y-Solowarm', '06/26/2024', 'https://music.io/song/93', 8.67);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 134, 'Konklux', '02/25/2025', 'https://music.io/song/100', 7.63);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 50, 'Subin', '06/22/2024', 'https://music.io/song/33', 7.57);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 119, 'Andalax', '11/11/2024', 'https://music.io/song/33', 18.11);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 20, 'Alpha', '11/20/2024', 'https://music.io/song/4', 19.65);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 105, 'Pannier', '09/12/2024', 'https://music.io/song/60', 19.77);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 101, 'Job', '02/01/2025', 'https://music.io/song/78', 14.23);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 137, 'Solarbreeze', '10/13/2024', 'https://music.io/song/45', 6.74);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 125, 'Cookley', '03/05/2025', 'https://music.io/song/72', 13.79);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 123, 'Tresom', '12/25/2024', 'https://music.io/song/87', 6.61);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 125, 'Opela', '06/01/2024', 'https://music.io/song/23', 13.58);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 136, 'Andalax', '09/13/2024', 'https://music.io/song/41', 5.45);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 92, 'Stim', '11/14/2024', 'https://music.io/song/64', 5.39);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 72, 'Bitchip', '07/26/2024', 'https://music.io/song/85', 17.21);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 33, 'Wrapsafe', '12/24/2024', 'https://music.io/song/65', 12.79);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 135, 'Redhold', '07/03/2024', 'https://music.io/song/94', 18.23);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 148, 'Lotstring', '07/11/2024', 'https://music.io/song/86', 15.72);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 77, 'Y-find', '08/24/2024', 'https://music.io/song/99', 6.86);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 127, 'Trippledex', '04/13/2024', 'https://music.io/song/98', 19.95);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 60, 'Prodder', '10/05/2024', 'https://music.io/song/80', 18.04);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 27, 'Andalax', '02/14/2025', 'https://music.io/song/16', 6.6);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 126, 'Voyatouch', '08/20/2024', 'https://music.io/song/37', 17.32);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 43, 'Otcom', '06/23/2024', 'https://music.io/song/18', 19.84);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 16, 'Voyatouch', '08/20/2024', 'https://music.io/song/9', 15.96);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 67, 'Opela', '07/24/2024', 'https://music.io/song/48', 12.31);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 39, 'Solarbreeze', '11/22/2024', 'https://music.io/song/41', 16.69);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 8, 'Greenlam', '06/07/2024', 'https://music.io/song/7', 10.38);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 87, 'Tin', '01/25/2025', 'https://music.io/song/58', 8.91);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 14, 'Kanlam', '10/05/2024', 'https://music.io/song/46', 18.76);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 136, 'Flexidy', '01/20/2025', 'https://music.io/song/44', 12.98);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 101, 'Voyatouch', '01/02/2025', 'https://music.io/song/45', 7.43);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 76, 'Zaam-Dox', '04/18/2024', 'https://music.io/song/53', 17.38);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 81, 'Hatity', '03/23/2025', 'https://music.io/song/85', 14.91);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 65, 'Overhold', '12/29/2024', 'https://music.io/song/8', 19.53);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 20, 'Stronghold', '11/10/2024', 'https://music.io/song/60', 5.38);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 67, 'Tresom', '04/09/2025', 'https://music.io/song/84', 14.65);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 96, 'Domainer', '04/10/2025', 'https://music.io/song/28', 15.34);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 149, 'Bytecard', '03/28/2025', 'https://music.io/song/71', 15.04);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 101, 'Quo Lux', '10/18/2024', 'https://music.io/song/21', 15.85);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 57, 'Transcof', '11/12/2024', 'https://music.io/song/17', 8.16);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 80, 'Bitwolf', '04/29/2024', 'https://music.io/song/37', 13.24);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 85, 'Andalax', '04/04/2025', 'https://music.io/song/16', 13.19);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 38, 'Matsoft', '11/12/2024', 'https://music.io/song/17', 12.34);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 122, 'Tempsoft', '01/31/2025', 'https://music.io/song/55', 15.77);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 21, 'Span', '07/25/2024', 'https://music.io/song/8', 17.78);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 73, 'It', '10/12/2024', 'https://music.io/song/57', 17.95);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 50, 'Zontrax', '04/15/2024', 'https://music.io/song/89', 6.98);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 42, 'Namfix', '03/03/2025', 'https://music.io/song/4', 13.92);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 33, 'Prodder', '12/28/2024', 'https://music.io/song/46', 5.41);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 24, 'Subin', '06/07/2024', 'https://music.io/song/82', 15.13);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 94, 'Quo Lux', '01/14/2025', 'https://music.io/song/26', 15.01);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 146, 'Domainer', '06/04/2024', 'https://music.io/song/64', 6.05);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 90, 'Cardguard', '06/05/2024', 'https://music.io/song/100', 5.59);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 133, 'Tempsoft', '12/30/2024', 'https://music.io/song/70', 14.32);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 140, 'Wrapsafe', '01/03/2025', 'https://music.io/song/32', 17.12);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 92, 'Home Ing', '01/25/2025', 'https://music.io/song/13', 14.55);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 57, 'Veribet', '11/06/2024', 'https://music.io/song/81', 11.06);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 97, 'Tin', '12/16/2024', 'https://music.io/song/86', 8.59);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 149, 'Cardify', '09/24/2024', 'https://music.io/song/77', 15.32);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 54, 'Alpha', '10/08/2024', 'https://music.io/song/16', 18.61);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 47, 'Voyatouch', '02/20/2025', 'https://music.io/song/58', 17.67);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 143, 'Lotstring', '10/31/2024', 'https://music.io/song/82', 10.04);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 14, 'Y-find', '12/20/2024', 'https://music.io/song/43', 5.85);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 5, 'Fintone', '12/23/2024', 'https://music.io/song/98', 15.4);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 2, 'Lotlux', '05/13/2024', 'https://music.io/song/38', 17.36);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 12, 'Y-find', '03/12/2025', 'https://music.io/song/5', 14.69);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 96, 'Biodex', '03/26/2025', 'https://music.io/song/59', 9.43);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 39, 'Otcom', '09/14/2024', 'https://music.io/song/87', 18.37);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 123, 'Sub-Ex', '10/05/2024', 'https://music.io/song/48', 15.41);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 94, 'Fix San', '08/21/2024', 'https://music.io/song/75', 10.98);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 104, 'Bitwolf', '07/26/2024', 'https://music.io/song/13', 7.78);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 118, 'Zathin', '12/28/2024', 'https://music.io/song/40', 14.63);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 123, 'Ronstring', '10/25/2024', 'https://music.io/song/23', 19.83);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 117, 'Voyatouch', '08/21/2024', 'https://music.io/song/88', 12.13);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 135, 'Tresom', '12/23/2024', 'https://music.io/song/10', 8.05);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 77, 'Pannier', '02/05/2025', 'https://music.io/song/74', 8.52);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 92, 'Hatity', '07/06/2024', 'https://music.io/song/78', 12.46);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 18, 'Vagram', '09/12/2024', 'https://music.io/song/87', 16.91);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 109, 'Cookley', '11/15/2024', 'https://music.io/song/18', 13.25);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 15, 'Greenlam', '01/12/2025', 'https://music.io/song/54', 17.58);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 86, 'Sonair', '12/13/2024', 'https://music.io/song/58', 9.06);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 142, 'Sonair', '02/03/2025', 'https://music.io/song/20', 7.18);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 21, 'Cardify', '11/02/2024', 'https://music.io/song/1', 9.3);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 146, 'Regrant', '11/10/2024', 'https://music.io/song/91', 11.17);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 143, 'Cookley', '12/27/2024', 'https://music.io/song/90', 19.39);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 42, 'Pannier', '02/16/2025', 'https://music.io/song/21', 16.65);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 28, 'Tres-Zap', '11/08/2024', 'https://music.io/song/6', 11.6);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 98, 'Ventosanzap', '05/10/2024', 'https://music.io/song/51', 8.8);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 135, 'Keylex', '11/29/2024', 'https://music.io/song/66', 8.35);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 129, 'Flexidy', '12/30/2024', 'https://music.io/song/51', 5.71);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 67, 'Cookley', '06/26/2024', 'https://music.io/song/16', 12.21);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 137, 'Home Ing', '11/29/2024', 'https://music.io/song/55', 11.43);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 64, 'Voyatouch', '03/25/2025', 'https://music.io/song/21', 8.17);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 75, 'Kanlam', '01/13/2025', 'https://music.io/song/25', 10.61);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 34, 'Stronghold', '02/01/2025', 'https://music.io/song/42', 19.19);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 2, 'Zontrax', '04/26/2024', 'https://music.io/song/32', 13.82);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 130, 'Tres-Zap', '04/25/2024', 'https://music.io/song/58', 6.55);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 20, 'Bigtax', '10/05/2024', 'https://music.io/song/2', 7.85);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 138, 'Opela', '11/05/2024', 'https://music.io/song/44', 17.01);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 13, 'Voltsillam', '01/13/2025', 'https://music.io/song/62', 12.21);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 20, 'Keylex', '01/17/2025', 'https://music.io/song/68', 12.99);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 146, 'Hatity', '10/22/2024', 'https://music.io/song/29', 17.42);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 144, 'Tres-Zap', '07/25/2024', 'https://music.io/song/44', 9.11);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 107, 'Bitwolf', '06/16/2024', 'https://music.io/song/26', 13.74);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 139, 'Lotlux', '08/24/2024', 'https://music.io/song/50', 12.6);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 116, 'Tempsoft', '11/08/2024', 'https://music.io/song/16', 10.48);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 56, 'Transcof', '07/02/2024', 'https://music.io/song/49', 19.84);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 113, 'Zontrax', '10/21/2024', 'https://music.io/song/85', 8.51);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 87, 'Span', '05/03/2024', 'https://music.io/song/50', 19.28);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 35, 'Rank', '11/21/2024', 'https://music.io/song/29', 12.08);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 51, 'Sonsing', '09/05/2024', 'https://music.io/song/55', 15.26);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 58, 'Home Ing', '01/14/2025', 'https://music.io/song/29', 11.13);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 65, 'Fixflex', '04/07/2025', 'https://music.io/song/5', 14.59);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 13, 'Cookley', '02/05/2025', 'https://music.io/song/88', 6.94);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 70, 'Kanlam', '03/18/2025', 'https://music.io/song/52', 6.34);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 86, 'Fintone', '11/04/2024', 'https://music.io/song/65', 14.09);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 88, 'Bytecard', '04/21/2024', 'https://music.io/song/42', 7.97);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 69, 'Alphazap', '02/01/2025', 'https://music.io/song/94', 12.65);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 125, 'Prodder', '06/30/2024', 'https://music.io/song/66', 16.01);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 22, 'Sub-Ex', '06/18/2024', 'https://music.io/song/68', 7.46);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 96, 'Quo Lux', '05/14/2024', 'https://music.io/song/100', 11.22);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 109, 'Bytecard', '03/18/2025', 'https://music.io/song/2', 17.06);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 40, 'Span', '02/22/2025', 'https://music.io/song/56', 10.35);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 62, 'Tin', '10/25/2024', 'https://music.io/song/88', 16.29);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 105, 'Temp', '06/19/2024', 'https://music.io/song/90', 16.48);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 101, 'Cardify', '12/28/2024', 'https://music.io/song/66', 8.17);
insert into T_Albumes (ID_Album, ID_Artista, Titulo, Fecha_Lanzamiento, URL, Precio) values (seq_album.NEXTVAL, 57, 'Voltsillam', '11/21/2024', 'https://music.io/song/27', 10.59);



-- Inserccion de datos en T_Canciones

insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 5, 'Bigtax', 4.55, 11.66, 52);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 47, 'Flexidy', 3.8, 12.0, 62);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 58, 'Voyatouch', 4.86, 7.13, 27);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 20, 'Tres-Zap', 4.86, 14.92, 93);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 22, 'Zaam-Dox', 5.47, 10.14, 61);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 58, 'Tampflex', 4.07, 9.09, 71);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 83, 'Greenlam', 2.83, 7.07, 116);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 39, 'Tempsoft', 5.57, 2.97, 7);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 11, 'Konklab', 5.47, 3.12, 102);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 23, 'Zontrax', 5.12, 11.58, 97);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 60, 'Toughjoyfax', 3.01, 3.06, 34);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 93, 'Viva', 4.21, 6.52, 74);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 97, 'Gembucket', 5.15, 2.59, 59);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 112, 'Ronstring', 4.13, 6.54, 127);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 86, 'Bamity', 1.24, 4.1, 124);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 29, 'Job', 2.54, 14.16, 8);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 32, 'Tresom', 3.7, 2.6, 77);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 42, 'Lotlux', 1.1, 4.11, 27);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 12, 'Solarbreeze', 2.83, 8.72, 42);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 66, 'Lotstring', 4.02, 6.81, 104);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 70, 'Job', 1.52, 14.1, 17);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 94, 'Latlux', 1.32, 4.49, 51);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 101, 'Tres-Zap', 4.73, 3.61, 16);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 115, 'Namfix', 3.38, 6.32, 79);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 50, 'Cardguard', 2.51, 7.94, 93);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 4, 'Toughjoyfax', 4.55, 6.61, 51);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 109, 'Zaam-Dox', 1.15, 1.03, 55);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 92, 'Cardify', 5.12, 5.22, 108);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 109, 'Latlux', 1.43, 11.86, 37);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 100, 'Bitwolf', 2.02, 10.73, 77);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 71, 'Y-Solowarm', 4.99, 1.76, 9);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 118, 'Veribet', 1.19, 12.52, 22);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 78, 'Otcom', 4.91, 11.24, 71);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 39, 'Greenlam', 4.01, 1.5, 51);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 40, 'Sonsing', 1.64, 6.58, 123);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 38, 'Cardguard', 2.66, 7.71, 29);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 102, 'Lotstring', 4.39, 10.27, 126);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 84, 'Subin', 4.09, 9.28, 54);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 78, 'Lotstring', 2.76, 13.78, 45);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 60, 'Transcof', 4.61, 7.22, 79);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 91, 'Span', 1.98, 9.78, 91);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 17, 'Zamit', 2.19, 12.04, 100);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 27, 'Prodder', 3.95, 6.55, 122);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 35, 'Konklab', 1.01, 12.43, 90);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 49, 'Holdlamis', 4.61, 3.18, 65);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 105, 'Duobam', 1.65, 3.06, 45);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 47, 'Ventosanzap', 2.15, 11.48, 102);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 93, 'Zamit', 1.38, 5.38, 83);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 38, 'Bamity', 1.27, 3.94, 59);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 66, 'Keylex', 3.83, 13.75, 125);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 4, 'Bigtax', 5.18, 3.08, 5);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 70, 'Cardguard', 3.35, 8.69, 22);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 77, 'Treeflex', 2.1, 6.51, 39);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 8, 'Tempsoft', 3.39, 3.49, 127);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 7, 'Wrapsafe', 3.73, 9.23, 93);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 92, 'Domainer', 4.64, 8.53, 119);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 117, 'Domainer', 2.44, 12.39, 96);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 105, 'Bigtax', 2.29, 14.47, 26);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 63, 'Regrant', 3.28, 3.77, 85);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 16, 'Redhold', 2.65, 6.06, 122);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 97, 'Y-Solowarm', 3.45, 1.93, 97);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 105, 'Prodder', 5.29, 12.8, 100);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 33, 'Zathin', 1.6, 6.58, 38);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 61, 'Solarbreeze', 2.07, 2.88, 62);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 80, 'Stringtough', 2.92, 11.0, 124);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 70, 'Tin', 4.61, 1.06, 67);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 109, 'Opela', 2.2, 9.07, 102);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 63, 'Tresom', 4.93, 7.68, 27);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 55, 'Domainer', 2.17, 3.22, 54);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 117, 'Vagram', 2.0, 2.03, 14);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 102, 'Flexidy', 1.02, 7.1, 3);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 1, 'Span', 1.34, 9.15, 12);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 87, 'Holdlamis', 1.27, 1.88, 120);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 109, 'Konklab', 1.99, 1.49, 19);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 49, 'Duobam', 4.37, 14.5, 90);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 8, 'Fintone', 1.49, 12.26, 42);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 31, 'Rank', 3.87, 11.43, 121);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 96, 'Cardguard', 1.18, 2.64, 94);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 89, 'Job', 4.0, 4.54, 74);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 119, 'Lotstring', 2.79, 8.49, 24);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 112, 'Kanlam', 5.0, 7.52, 78);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 119, 'Hatity', 3.67, 6.51, 117);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 22, 'Lotlux', 4.24, 8.86, 54);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 71, 'Pannier', 2.15, 10.38, 35);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 86, 'Transcof', 2.42, 6.43, 40);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 117, 'Matsoft', 1.55, 7.63, 49);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 71, 'Mat Lam Tam', 4.15, 13.43, 13);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 47, 'Solarbreeze', 1.34, 13.02, 117);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 90, 'Fix San', 1.22, 5.62, 28);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 27, 'Ronstring', 4.53, 10.77, 105);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 76, 'Gembucket', 5.69, 10.11, 84);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 103, 'Fix San', 5.09, 1.19, 77);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 1, 'Prodder', 5.22, 8.11, 75);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 27, 'Flexidy', 4.08, 4.76, 34);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 99, 'Quo Lux', 3.6, 12.76, 10);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 83, 'Y-find', 3.83, 4.78, 101);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 84, 'Y-find', 5.14, 10.62, 52);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 44, 'Veribet', 4.36, 11.78, 84);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 103, 'Opela', 3.33, 6.98, 29);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 120, 'Lotstring', 1.28, 3.27, 59);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 10, 'Tres-Zap', 3.7, 3.96, 76);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 62, 'Konklux', 5.51, 6.75, 42);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 119, 'Sub-Ex', 3.99, 11.97, 36);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 110, 'Lotstring', 5.14, 14.2, 66);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 71, 'Toughjoyfax', 3.8, 4.38, 119);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 111, 'It', 3.28, 10.9, 122);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 97, 'Toughjoyfax', 5.83, 14.45, 78);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 72, 'Tin', 5.71, 7.27, 30);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 23, 'Tres-Zap', 5.41, 9.04, 29);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 105, 'Alpha', 5.14, 2.15, 76);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 87, 'Duobam', 3.3, 3.18, 93);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 61, 'Alpha', 3.2, 7.43, 104);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 70, 'Sonair', 4.13, 2.55, 18);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 59, 'Domainer', 5.78, 1.47, 120);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 88, 'Flowdesk', 1.38, 11.29, 29);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 13, 'Ventosanzap', 2.03, 3.52, 23);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 2, 'Duobam', 4.22, 14.23, 35);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 16, 'Alpha', 1.95, 12.26, 52);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 55, 'Transcof', 5.89, 14.72, 125);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 40, 'Hatity', 2.58, 10.13, 99);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 17, 'Tempsoft', 1.37, 8.67, 122);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 13, 'Ronstring', 4.83, 10.8, 68);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 60, 'Subin', 3.47, 8.4, 59);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 79, 'Fix San', 5.84, 14.09, 94);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 82, 'Duobam', 5.78, 2.08, 66);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 88, 'Solarbreeze', 5.98, 13.18, 113);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 44, 'Solarbreeze', 1.35, 14.86, 90);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 37, 'Sonsing', 2.51, 10.52, 89);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 11, 'Voltsillam', 3.9, 5.42, 92);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 52, 'Bytecard', 3.62, 12.53, 108);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 108, 'Trippledex', 2.41, 13.59, 4);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 14, 'Sonsing', 3.83, 2.68, 90);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 76, 'Regrant', 4.15, 5.34, 112);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 4, 'Stronghold', 3.54, 11.0, 68);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 51, 'Sub-Ex', 1.42, 15.0, 47);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 108, 'Zoolab', 1.52, 13.68, 115);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 64, 'Holdlamis', 3.4, 6.96, 75);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 84, 'Alpha', 3.28, 8.38, 62);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 79, 'Veribet', 1.0, 5.14, 30);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 66, 'Opela', 3.95, 8.86, 64);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 35, 'Tres-Zap', 1.51, 3.38, 103);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 93, 'Quo Lux', 3.17, 3.65, 81);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 1, 'Cardguard', 3.69, 5.54, 41);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 112, 'Treeflex', 5.92, 3.25, 89);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 113, 'Bytecard', 4.47, 4.56, 110);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 64, 'Flowdesk', 3.34, 6.06, 78);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 79, 'Y-Solowarm', 1.14, 12.65, 2);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 78, 'Cookley', 1.6, 9.26, 46);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 113, 'Ronstring', 4.96, 5.48, 121);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 87, 'Bytecard', 5.25, 11.25, 6);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 68, 'Zathin', 1.47, 13.07, 129);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 106, 'Fix San', 3.74, 9.66, 80);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 19, 'Lotstring', 5.88, 5.58, 6);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 95, 'Fixflex', 3.25, 8.3, 9);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 69, 'Hatity', 4.06, 2.04, 34);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 92, 'Bytecard', 5.7, 6.69, 116);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 28, 'Cookley', 3.12, 1.79, 101);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 80, 'Subin', 1.82, 3.17, 77);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 13, 'Alpha', 4.63, 4.56, 26);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 104, 'Overhold', 4.11, 6.17, 45);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 92, 'Bamity', 4.96, 7.43, 4);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 27, 'Alphazap', 5.23, 12.57, 38);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 27, 'Alphazap', 3.46, 13.7, 116);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 14, 'Matsoft', 2.94, 10.1, 88);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 42, 'Domainer', 3.58, 9.6, 16);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 116, 'Vagram', 4.28, 10.72, 55);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 34, 'Flowdesk', 4.35, 6.73, 20);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 66, 'Aerified', 1.41, 1.57, 107);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 90, 'Job', 1.11, 13.33, 18);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 76, 'Bitwolf', 3.03, 4.42, 86);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 56, 'Lotlux', 5.67, 12.57, 106);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 116, 'Cardify', 3.33, 6.91, 73);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 103, 'Sonsing', 3.6, 8.44, 8.);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 106, 'Veribet', 4.9, 11.96, 121);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 113, 'Stronghold', 3.28, 4.08, 109);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 31, 'Quo Lux', 2.08, 1.28, 41);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 120, 'Bitchip', 2.37, 3.7, 51);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 87, 'Transcof', 1.97, 13.7, 84);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 95, 'Bitwolf', 1.86, 13.77, 35);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 54, 'Holdlamis', 1.65, 7.12, 95);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 85, 'Keylex', 1.79, 1.86, 99);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 56, 'Kanlam', 4.75, 7.77, 57);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 9, 'Duobam', 2.52, 3.81, 93);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 66, 'Zaam-Dox', 1.51, 5.01, 5);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 60, 'Overhold', 3.28, 2.05, 23);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 50, 'Mat Lam Tam', 4.47, 10.13, 104);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 59, 'Flowdesk', 5.58, 1.95, 70);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 73, 'Y-Solowarm', 1.83, 9.14, 25);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 67, 'Otcom', 4.02, 12.93, 80);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 82, 'It', 5.3, 14.09, 73);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 98, 'Transcof', 2.42, 7.72, 49);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 14, 'Vagram', 4.69, 2.41, 84);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 117, 'Domainer', 1.67, 4.15, 125);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 28, 'Job', 5.88, 5.42, 78);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 4, 'Stringtough', 1.72, 8.37, 69);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 109, 'Cardguard', 4.66, 3.09, 23);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 55, 'Konklux', 1.73, 10.75, 123);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 51, 'Home Ing', 3.46, 4.23, 125);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 40, 'Ventosanzap', 2.95, 7.38, 14);
insert into T_Canciones (ID_Cancion, ID_Album, Titulo, Duracion, Precio, ID_Artista) values (seq_cancion.NEXTVAL, 75, 'Tres-Zap', 5.09, 11.4, 36);



--Inserccion de datos en T_Podcasts

insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 120, 'Solarbreeze', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.', 'https://podcast.io/show/84', 19.79);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 81, 'Lotlux', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', 'https://podcast.io/show/161', 12.94);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 51, 'Voyatouch', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', 'https://podcast.io/show/33', 18.61);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 128, 'Rank', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', 'https://podcast.io/show/79', 5.62);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 14, 'Rank', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', 'https://podcast.io/show/119', 8.74);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 133, 'Otcom', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', 'https://podcast.io/show/73', 15.25);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 6, 'Tempsoft', 'Phasellus in felis. Donec semper sapien a libero. Nam dui.', 'https://podcast.io/show/88', 12.4);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 138, 'Trippledex', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.', 'https://podcast.io/show/109', 17.19);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 146, 'Gembucket', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', 'https://podcast.io/show/71', 14.07);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 108, 'Namfix', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', 'https://podcast.io/show/70', 13.09);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 59, 'Bitwolf', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.', 'https://podcast.io/show/123', 17.55);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 120, 'Andalax', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', 'https://podcast.io/show/66', 7.28);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 120, 'Job', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', 'https://podcast.io/show/71', 13.25);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 39, 'Bitwolf', 'Fusce consequat. Nulla nisl. Nunc nisl.', 'https://podcast.io/show/120', 12.57);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 53, 'Opela', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', 'https://podcast.io/show/101', 10.68);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 98, 'Holdlamis', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', 'https://podcast.io/show/152', 10.57);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 105, 'Konklux', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.', 'https://podcast.io/show/126', 5.02);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 147, 'Sonair', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', 'https://podcast.io/show/148', 18.94);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 80, 'Namfix', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', 'https://podcast.io/show/130', 8.58);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 43, 'Andalax', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', 'https://podcast.io/show/164', 11.79);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 106, 'Alpha', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', 'https://podcast.io/show/66', 17.35);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 82, 'Redhold', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', 'https://podcast.io/show/110', 16.15);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 145, 'Opela', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', 'https://podcast.io/show/151', 19.5);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 23, 'Viva', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', 'https://podcast.io/show/138', 8.99);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 93, 'Vagram', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 'https://podcast.io/show/45', 15.52);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 13, 'Sonair', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', 'https://podcast.io/show/29', 7.41);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 30, 'Alpha', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', 'https://podcast.io/show/101', 18.45);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 107, 'Stim', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', 'https://podcast.io/show/168', 14.53);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 72, 'Bamity', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', 'https://podcast.io/show/54', 5.76);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 83, 'Subin', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', 'https://podcast.io/show/6', 17.4);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 129, 'Daltfresh', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', 'https://podcast.io/show/89', 12.42);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 41, 'Pannier', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', 'https://podcast.io/show/78', 15.44);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 118, 'Aerified', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', 'https://podcast.io/show/105', 11.29);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 44, 'Namfix', 'Phasellus in felis. Donec semper sapien a libero. Nam dui.', 'https://podcast.io/show/1', 19.77);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 57, 'Y-Solowarm', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', 'https://podcast.io/show/144', 11.98);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 129, 'Matsoft', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', 'https://podcast.io/show/25', 11.09);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 146, 'Treeflex', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', 'https://podcast.io/show/92', 9.88);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 22, 'Pannier', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', 'https://podcast.io/show/31', 18.87);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 118, 'Fintone', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', 'https://podcast.io/show/45', 17.47);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 130, 'Tresom', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', 'https://podcast.io/show/162', 11.58);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 33, 'Andalax', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', 'https://podcast.io/show/199', 15.97);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 112, 'Mat Lam Tam', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', 'https://podcast.io/show/109', 8.76);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 133, 'Konklab', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', 'https://podcast.io/show/158', 16.9);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 123, 'Opela', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', 'https://podcast.io/show/106', 17.32);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 123, 'Sonsing', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', 'https://podcast.io/show/1', 9.24);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 26, 'Tempsoft', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.', 'https://podcast.io/show/177', 9.65);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 33, 'Keylex', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.', 'https://podcast.io/show/169', 5.14);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 109, 'Trippledex', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', 'https://podcast.io/show/80', 9.33);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 13, 'It', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', 'https://podcast.io/show/121', 7.61);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 108, 'Overhold', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', 'https://podcast.io/show/180', 10.78);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 21, 'Tempsoft', 'Phasellus in felis. Donec semper sapien a libero. Nam dui.', 'https://podcast.io/show/87', 16.02);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 46, 'Greenlam', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', 'https://podcast.io/show/107', 5.15);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 95, 'Rank', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', 'https://podcast.io/show/9', 19.18);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 13, 'Flowdesk', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', 'https://podcast.io/show/42', 8.19);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 32, 'Cardguard', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', 'https://podcast.io/show/67', 16.52);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 115, 'Ronstring', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', 'https://podcast.io/show/157', 6.13);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 54, 'Y-Solowarm', 'Fusce consequat. Nulla nisl. Nunc nisl.', 'https://podcast.io/show/30', 19.13);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 71, 'Bitchip', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', 'https://podcast.io/show/148', 15.23);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 16, 'Hatity', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', 'https://podcast.io/show/86', 17.91);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 126, 'Ronstring', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', 'https://podcast.io/show/63', 5.96);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 67, 'Andalax', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.', 'https://podcast.io/show/158', 14.67);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 37, 'Tin', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', 'https://podcast.io/show/19', 16.16);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 145, 'Sonair', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', 'https://podcast.io/show/189', 13.84);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 100, 'Flexidy', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', 'https://podcast.io/show/174', 18.18);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 70, 'Lotlux', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', 'https://podcast.io/show/178', 6.19);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 51, 'Zoolab', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', 'https://podcast.io/show/182', 10.06);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 149, 'Bigtax', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', 'https://podcast.io/show/141', 11.03);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 48, 'Hatity', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', 'https://podcast.io/show/39', 8.77);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 11, 'Zamit', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', 'https://podcast.io/show/43', 17.99);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 22, 'Greenlam', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', 'https://podcast.io/show/90', 19.63);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 128, 'Sonsing', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', 'https://podcast.io/show/22', 7.94);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 123, 'Redhold', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', 'https://podcast.io/show/68', 11.19);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 133, 'Ventosanzap', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', 'https://podcast.io/show/37', 15.12);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 83, 'Sonsing', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.', 'https://podcast.io/show/88', 14.95);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 91, 'Gembucket', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', 'https://podcast.io/show/12', 9.22);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 145, 'Flowdesk', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', 'https://podcast.io/show/149', 18.24);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 82, 'Keylex', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.', 'https://podcast.io/show/57', 8.53);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 147, 'Sonair', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', 'https://podcast.io/show/8', 11.04);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 90, 'Redhold', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', 'https://podcast.io/show/144', 5.63);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 146, 'Treeflex', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', 'https://podcast.io/show/97', 11.46);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 59, 'Fix San', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.', 'https://podcast.io/show/4', 5.63);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 13, 'Home Ing', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', 'https://podcast.io/show/22', 17.53);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 33, 'Bitwolf', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', 'https://podcast.io/show/17', 10.62);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 145, 'It', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 'https://podcast.io/show/50', 13.02);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 59, 'Tresom', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', 'https://podcast.io/show/168', 16.67);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 65, 'Viva', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', 'https://podcast.io/show/150', 17.55);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 106, 'Bitwolf', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', 'https://podcast.io/show/159', 8.4);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 64, 'Konklux', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', 'https://podcast.io/show/144', 16.31);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 133, 'Wrapsafe', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', 'https://podcast.io/show/153', 19.36);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 131, 'Voyatouch', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', 'https://podcast.io/show/2', 5.13);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 65, 'Sub-Ex', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.', 'https://podcast.io/show/80', 17.36);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 142, 'Cardify', 'In congue. Etiam justo. Etiam pretium iaculis justo.', 'https://podcast.io/show/7', 5.03);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 78, 'Job', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', 'https://podcast.io/show/143', 7.53);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 116, 'Fixflex', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', 'https://podcast.io/show/27', 12.87);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 12, 'Voltsillam', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', 'https://podcast.io/show/35', 7.56);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 131, 'Zaam-Dox', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', 'https://podcast.io/show/155', 9.38);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 125, 'Fintone', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', 'https://podcast.io/show/161', 8.0);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 98, 'Flexidy', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', 'https://podcast.io/show/17', 16.14);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 7, 'Opela', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', 'https://podcast.io/show/92', 8.75);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 135, 'Otcom', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', 'https://podcast.io/show/66', 15.43);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 88, 'Subin', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', 'https://podcast.io/show/196', 5.39);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 145, 'Kanlam', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 'https://podcast.io/show/141', 17.39);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 15, 'Y-find', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', 'https://podcast.io/show/104', 17.22);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 107, 'Tampflex', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', 'https://podcast.io/show/92', 12.88);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 40, 'Voyatouch', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', 'https://podcast.io/show/53', 17.34);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 72, 'Veribet', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', 'https://podcast.io/show/62', 17.65);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 32, 'Keylex', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', 'https://podcast.io/show/115', 15.49);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 113, 'Matsoft', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.', 'https://podcast.io/show/156', 6.5);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 82, 'Daltfresh', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', 'https://podcast.io/show/180', 17.72);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 10, 'Bitchip', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', 'https://podcast.io/show/5', 15.31);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 114, 'Tres-Zap', 'Phasellus in felis. Donec semper sapien a libero. Nam dui.', 'https://podcast.io/show/152', 17.26);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 61, 'Cookley', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', 'https://podcast.io/show/82', 6.43);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 126, 'Rank', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', 'https://podcast.io/show/151', 12.92);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 12, 'Trippledex', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', 'https://podcast.io/show/76', 16.0);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 145, 'Tres-Zap', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', 'https://podcast.io/show/38', 13.52);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 126, 'Latlux', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.', 'https://podcast.io/show/191', 6.31);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 1, 'Flexidy', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', 'https://podcast.io/show/35', 19.19);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 71, 'Wrapsafe', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', 'https://podcast.io/show/86', 11.48);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 14, 'Wrapsafe', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', 'https://podcast.io/show/77', 10.81);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 13, 'Rank', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', 'https://podcast.io/show/109', 17.59);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 124, 'Stringtough', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', 'https://podcast.io/show/13', 5.35);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 114, 'Stim', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 'https://podcast.io/show/140', 19.08);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 96, 'Andalax', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', 'https://podcast.io/show/24', 11.67);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 123, 'Fix San', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', 'https://podcast.io/show/124', 8.25);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 67, 'Y-find', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', 'https://podcast.io/show/73', 10.85);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 48, 'Domainer', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', 'https://podcast.io/show/191', 8.53);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 133, 'Sub-Ex', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', 'https://podcast.io/show/97', 17.66);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 62, 'Voyatouch', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.', 'https://podcast.io/show/184', 12.74);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 124, 'Daltfresh', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', 'https://podcast.io/show/91', 17.9);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 145, 'Tres-Zap', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.', 'https://podcast.io/show/25', 19.26);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 150, 'Tres-Zap', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.', 'https://podcast.io/show/127', 10.79);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 134, 'Andalax', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 'https://podcast.io/show/176', 8.0);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 5, 'Otcom', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', 'https://podcast.io/show/192', 19.32);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 52, 'Tresom', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', 'https://podcast.io/show/24', 18.19);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 13, 'Ronstring', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', 'https://podcast.io/show/20', 9.45);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 6, 'Asoka', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', 'https://podcast.io/show/64', 18.31);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 85, 'Home Ing', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', 'https://podcast.io/show/49', 12.86);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 132, 'Temp', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', 'https://podcast.io/show/179', 19.38);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 6, 'Tres-Zap', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', 'https://podcast.io/show/60', 8.66);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 138, 'Asoka', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', 'https://podcast.io/show/44', 19.27);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 45, 'Voyatouch', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', 'https://podcast.io/show/27', 5.34);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 68, 'Zamit', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', 'https://podcast.io/show/24', 17.3);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 113, 'Stringtough', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', 'https://podcast.io/show/158', 16.2);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 150, 'Zamit', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', 'https://podcast.io/show/78', 8.75);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 82, 'Regrant', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.', 'https://podcast.io/show/3', 12.1);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 126, 'Cookley', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.', 'https://podcast.io/show/143', 16.23);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 38, 'Bytecard', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.', 'https://podcast.io/show/102', 11.35);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 85, 'Flexidy', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', 'https://podcast.io/show/122', 10.0);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 21, 'Greenlam', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', 'https://podcast.io/show/151', 8.51);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 79, 'Namfix', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', 'https://podcast.io/show/167', 19.44);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 133, 'Konklab', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', 'https://podcast.io/show/71', 9.1);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 84, 'Toughjoyfax', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', 'https://podcast.io/show/114', 11.18);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 87, 'Opela', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', 'https://podcast.io/show/170', 5.12);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 100, 'Bitwolf', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', 'https://podcast.io/show/176', 17.22);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 115, 'Bitchip', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', 'https://podcast.io/show/189', 12.65);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 33, 'Matsoft', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', 'https://podcast.io/show/4', 12.99);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 80, 'Tres-Zap', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', 'https://podcast.io/show/19', 18.49);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 7, 'Bitchip', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', 'https://podcast.io/show/86', 18.46);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 71, 'Konklux', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.', 'https://podcast.io/show/152', 7.85);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 75, 'Transcof', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', 'https://podcast.io/show/199', 17.83);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 103, 'Trippledex', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', 'https://podcast.io/show/92', 17.63);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 42, 'Cardify', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', 'https://podcast.io/show/72', 18.72);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 115, 'Viva', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', 'https://podcast.io/show/7', 18.99);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 128, 'Namfix', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', 'https://podcast.io/show/7', 18.22);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 38, 'Sonair', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', 'https://podcast.io/show/170', 19.58);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 125, 'Greenlam', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', 'https://podcast.io/show/119', 11.87);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 78, 'Cardguard', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.', 'https://podcast.io/show/129', 18.67);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 50, 'Alpha', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.', 'https://podcast.io/show/106', 8.38);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 60, 'Vagram', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', 'https://podcast.io/show/43', 16.24);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 136, 'Pannier', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.', 'https://podcast.io/show/25', 9.41);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 102, 'Domainer', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', 'https://podcast.io/show/196', 13.15);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 83, 'Zaam-Dox', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', 'https://podcast.io/show/63', 8.62);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 95, 'Treeflex', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', 'https://podcast.io/show/28', 17.22);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 30, 'Treeflex', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.', 'https://podcast.io/show/93', 14.19);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 82, 'Ventosanzap', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', 'https://podcast.io/show/35', 5.4);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 34, 'Tresom', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', 'https://podcast.io/show/159', 10.76);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 85, 'Redhold', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', 'https://podcast.io/show/36', 5.59);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 43, 'Stringtough', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', 'https://podcast.io/show/77', 5.34);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 91, 'Bamity', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', 'https://podcast.io/show/100', 6.15);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 150, 'Veribet', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', 'https://podcast.io/show/51', 19.92);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 123, 'Hatity', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', 'https://podcast.io/show/33', 15.69);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 83, 'Zamit', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', 'https://podcast.io/show/190', 12.35);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 26, 'Holdlamis', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', 'https://podcast.io/show/70', 13.59);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 110, 'Matsoft', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', 'https://podcast.io/show/112', 14.87);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 7, 'Asoka', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.', 'https://podcast.io/show/30', 7.08);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 5, 'Temp', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', 'https://podcast.io/show/11', 18.78);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 133, 'Prodder', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', 'https://podcast.io/show/22', 7.14);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 108, 'Span', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', 'https://podcast.io/show/27', 14.28);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 140, 'Fix San', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', 'https://podcast.io/show/116', 15.36);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 44, 'Treeflex', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', 'https://podcast.io/show/144', 6.97);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 56, 'Quo Lux', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.', 'https://podcast.io/show/8', 7.55);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 72, 'Fixflex', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', 'https://podcast.io/show/92', 12.85);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 103, 'Aerified', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', 'https://podcast.io/show/175', 12.43);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 111, 'It', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', 'https://podcast.io/show/193', 12.45);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 24, 'Lotlux', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', 'https://podcast.io/show/75', 15.66);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 97, 'Zoolab', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', 'https://podcast.io/show/132', 14.62);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 139, 'Holdlamis', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', 'https://podcast.io/show/157', 16.37);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 98, 'Aerified', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', 'https://podcast.io/show/58', 11.05);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 97, 'Zontrax', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', 'https://podcast.io/show/83', 17.39);
insert into T_Podcasts (ID_Podcast, ID_Artista, Titulo, Descripcion, URL, Precio) values (seq_podcast.NEXTVAL, 13, 'Matsoft', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', 'https://podcast.io/show/188', 17.85);


--Inserccion de datos en T_Episodios

insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 87, 155, 3.35, 15.17, 'https://podcast.io/episode/36', 'Pocahontas');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 129, 25, 3.71, 5.31, 'https://podcast.io/episode/81', 'Ulysses (Ulisse)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 149, 54, 3.99, 11.65, 'https://podcast.io/episode/135', 'Planes');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 118, 145, 1.94, 17.41, 'https://podcast.io/episode/171', 'Stevie Nicks: Live at Red Rocks');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 22, 130, 2.77, 14.01, 'https://podcast.io/episode/11', 'Two Lovers');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 112, 103, 3.36, 14.05, 'https://podcast.io/episode/38', 'Colony, The');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 19, 53, 6.0, 10.43, 'https://podcast.io/episode/82', 'Just Sex and Nothing Else (Csak szex és más semmi)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 37, 115, 1.4, 16.79, 'https://podcast.io/episode/100', 'Road to Utopia');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 113, 18, 4.47, 7.13, 'https://podcast.io/episode/196', 'December Boys');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 31, 67, 5.75, 14.71, 'https://podcast.io/episode/112', 'Clone (Womb)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 110, 170, 1.37, 18.19, 'https://podcast.io/episode/94', 'Elysium');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 126, 35, 4.52, 7.86, 'https://podcast.io/episode/51', 'Anastasia');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 47, 59, 3.68, 6.01, 'https://podcast.io/episode/139', 'Jam');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 141, 71, 3.34, 16.47, 'https://podcast.io/episode/37', 'God’s Wedding (As Bodas de Deus)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 27, 106, 5.47, 11.74, 'https://podcast.io/episode/112', 'Fist of Fury (Chinese Connection, The) (Jing wu men)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 157, 14, 2.25, 19.88, 'https://podcast.io/episode/83', 'Dragon Ball Z: Super Android 13! (Doragon bôru Z 7: Kyokugen batoru!! San dai sûpâ saiyajin)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 26, 156, 1.99, 18.17, 'https://podcast.io/episode/55', 'So Proudly We Hail!');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 41, 98, 2.55, 13.68, 'https://podcast.io/episode/57', 'Dancing Outlaw II: Jesco Goes to Hollywood');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 131, 150, 2.32, 19.74, 'https://podcast.io/episode/103', 'Dream of Light (a.k.a. Quince Tree Sun, The) (Sol del membrillo, El)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 148, 81, 4.89, 15.34, 'https://podcast.io/episode/56', 'Fast and the Furious, The');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 15, 53, 4.72, 8.93, 'https://podcast.io/episode/78', 'Ordeal, The (Calvaire)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 61, 148, 3.8, 19.51, 'https://podcast.io/episode/103', 'Sin Retorno');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 71, 162, 4.47, 18.63, 'https://podcast.io/episode/73', 'Gorgeous (Boh lee chun)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 155, 166, 5.73, 10.94, 'https://podcast.io/episode/2', 'Play');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 166, 28, 3.39, 17.07, 'https://podcast.io/episode/56', 'Tempest');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 60, 45, 4.69, 14.74, 'https://podcast.io/episode/126', 'Sheep Has Five Legs, The (Le mouton à cinq pattes)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 152, 56, 2.64, 6.2, 'https://podcast.io/episode/43', 'Dirties, The');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 115, 4, 4.88, 14.1, 'https://podcast.io/episode/100', 'Illtown');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 33, 140, 4.33, 13.28, 'https://podcast.io/episode/26', 'Martian Child');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 150, 29, 2.57, 15.62, 'https://podcast.io/episode/151', 'Operator 13');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 161, 162, 4.55, 17.53, 'https://podcast.io/episode/192', 'Billy Blazes, Esq.');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 155, 83, 5.89, 5.84, 'https://podcast.io/episode/146', 'Son of a Gun');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 165, 163, 5.81, 15.91, 'https://podcast.io/episode/158', 'Hallelujah!');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 162, 146, 4.31, 12.31, 'https://podcast.io/episode/179', 'Mein Kampf');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 61, 24, 1.92, 16.82, 'https://podcast.io/episode/67', 'Arsène Lupin');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 30, 134, 5.92, 19.77, 'https://podcast.io/episode/77', 'Sister (L''enfant d''en haut)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 167, 67, 3.14, 5.93, 'https://podcast.io/episode/187', 'Mishima: A Life in Four Chapters');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 169, 68, 1.15, 17.73, 'https://podcast.io/episode/181', 'Liquid Sky');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 12, 139, 4.65, 7.2, 'https://podcast.io/episode/54', 'Genghis Khan');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 94, 31, 2.65, 14.45, 'https://podcast.io/episode/46', 'Dirty Dozen: The Deadly Mission');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 43, 25, 4.88, 17.7, 'https://podcast.io/episode/148', 'Icon');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 11, 87, 3.92, 14.57, 'https://podcast.io/episode/31', 'Wuthering Heights');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 132, 110, 3.63, 6.51, 'https://podcast.io/episode/42', 'Punk Syndrome, The (Kovasikajuttu)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 42, 146, 3.21, 7.12, 'https://podcast.io/episode/8', 'Journey of Natty Gann, The');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 89, 59, 5.89, 9.71, 'https://podcast.io/episode/108', 'Christmas Evil (a.k.a. You Better Watch Out)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 90, 56, 2.18, 10.6, 'https://podcast.io/episode/89', 'Cold in July');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 21, 9, 2.86, 18.14, 'https://podcast.io/episode/9', 'Right Kind of Wrong, The');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 151, 74, 1.38, 5.44, 'https://podcast.io/episode/199', 'Gregory Go Boom');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 13, 97, 1.68, 11.4, 'https://podcast.io/episode/126', 'Cure');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 156, 47, 4.89, 18.18, 'https://podcast.io/episode/104', 'Himizu');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 45, 14, 3.85, 15.28, 'https://podcast.io/episode/68', 'Two Jakes, The');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 114, 90, 4.04, 7.06, 'https://podcast.io/episode/37', 'Looking for Eric');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 160, 30, 5.22, 11.31, 'https://podcast.io/episode/146', 'Piggy');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 66, 88, 1.8, 16.3, 'https://podcast.io/episode/122', 'Sybil');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 107, 9, 5.81, 14.03, 'https://podcast.io/episode/96', 'WarGames');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 16, 5, 3.34, 19.76, 'https://podcast.io/episode/85', 'Raining Stones');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 80, 99, 2.12, 18.67, 'https://podcast.io/episode/48', 'In China They Eat Dogs (I Kina spiser de hunde)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 86, 169, 3.65, 14.87, 'https://podcast.io/episode/171', 'Meet Dave');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 153, 160, 1.32, 8.97, 'https://podcast.io/episode/142', 'Your Friends and Neighbors');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 65, 79, 4.28, 9.03, 'https://podcast.io/episode/138', 'Suddenly, Last Winter (Improvvisamente l''inverno scorso)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 118, 150, 4.02, 15.73, 'https://podcast.io/episode/125', 'Lili');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 3, 41, 5.15, 11.63, 'https://podcast.io/episode/144', 'In Praise of Older Women');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 48, 158, 3.21, 8.84, 'https://podcast.io/episode/89', 'On a Clear Day You Can See Forever');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 130, 98, 3.56, 10.85, 'https://podcast.io/episode/104', 'Lusty Men, The');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 121, 90, 1.32, 7.83, 'https://podcast.io/episode/108', 'Cranes Are Flying, The (Letyat zhuravli)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 45, 95, 3.34, 18.95, 'https://podcast.io/episode/142', 'Melody Time');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 58, 131, 5.03, 5.41, 'https://podcast.io/episode/64', 'Deja Vu');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 53, 133, 2.64, 7.98, 'https://podcast.io/episode/137', 'Red Obession');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 57, 35, 5.98, 14.77, 'https://podcast.io/episode/123', 'Bye-Bye');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 74, 37, 5.17, 14.68, 'https://podcast.io/episode/111', 'Bishop Murder Case, The');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 101, 158, 5.05, 6.93, 'https://podcast.io/episode/65', 'Rogue');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 37, 159, 1.71, 9.81, 'https://podcast.io/episode/181', 'Dracula''s Daughter');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 29, 59, 5.79, 6.73, 'https://podcast.io/episode/105', 'Heckler');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 169, 142, 1.84, 12.6, 'https://podcast.io/episode/58', 'I Have Found It (Kandukondain Kandukondain)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 159, 160, 4.16, 7.91, 'https://podcast.io/episode/3', 'Fearful Symmetry: The Making of ''To Kill a Mockingbird''');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 109, 149, 3.23, 6.57, 'https://podcast.io/episode/63', 'Pelle Svanslös');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 29, 42, 3.06, 13.69, 'https://podcast.io/episode/66', 'Black Rain');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 91, 69, 1.62, 15.27, 'https://podcast.io/episode/192', 'Strong Man, The');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 95, 160, 3.28, 18.45, 'https://podcast.io/episode/86', 'Baby Face');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 133, 142, 3.41, 10.31, 'https://podcast.io/episode/68', 'Fork in the Road, A');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 79, 101, 5.44, 17.34, 'https://podcast.io/episode/24', 'Zulu');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 56, 9, 4.37, 13.49, 'https://podcast.io/episode/155', 'Titan A.E.');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 48, 86, 3.5, 14.19, 'https://podcast.io/episode/51', 'Samoure');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 63, 48, 1.97, 7.14, 'https://podcast.io/episode/5', 'Cut and Run (Inferno in diretta)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 76, 71, 3.49, 11.84, 'https://podcast.io/episode/49', 'Enemy Within, The (O ehthros mou)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 161, 59, 4.32, 11.3, 'https://podcast.io/episode/50', 'Prisoners of the Lost Universe');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 119, 86, 3.32, 7.15, 'https://podcast.io/episode/9', 'What Goes Up');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 78, 1, 2.07, 9.17, 'https://podcast.io/episode/133', 'Cocoanuts, The');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 43, 128, 3.46, 17.6, 'https://podcast.io/episode/92', 'Nude for Satan (Nuda per Satana)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 74, 112, 3.7, 12.25, 'https://podcast.io/episode/106', 'Spider');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 144, 11, 3.25, 11.04, 'https://podcast.io/episode/113', 'Victory Through Air Power');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 80, 137, 2.6, 16.43, 'https://podcast.io/episode/138', 'Burton and Taylor');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 3, 160, 5.85, 12.32, 'https://podcast.io/episode/160', 'Woman in The Septic Tank, The (Ang Babae sa septic tank)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 29, 144, 4.64, 18.67, 'https://podcast.io/episode/182', 'Don''t Look Now: We''re Being Shot At (La grande vadrouille)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 157, 123, 2.31, 5.64, 'https://podcast.io/episode/200', 'Attenberg');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 93, 93, 5.48, 15.32, 'https://podcast.io/episode/171', 'Tracker, The');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 158, 4, 2.46, 5.59, 'https://podcast.io/episode/78', 'Tomorrow, the World!');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 138, 88, 2.46, 11.04, 'https://podcast.io/episode/24', 'Head Above Water');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 87, 140, 5.0, 11.03, 'https://podcast.io/episode/44', 'Suspect, The (Yong-eui-ja)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 119, 34, 3.34, 16.03, 'https://podcast.io/episode/88', 'Listen Up Philip');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 35, 29, 3.2, 11.19, 'https://podcast.io/episode/199', 'Hello, Dolly!');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 12, 90, 2.18, 9.13, 'https://podcast.io/episode/125', 'Singham');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 125, 113, 4.17, 18.03, 'https://podcast.io/episode/140', 'Mother''s Day');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 57, 156, 3.7, 13.7, 'https://podcast.io/episode/23', 'Change of Plans (Le code a changé)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 86, 167, 1.27, 14.29, 'https://podcast.io/episode/188', 'Life After Tomorrow');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 47, 74, 1.39, 12.76, 'https://podcast.io/episode/154', 'Inside Llewyn Davis');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 71, 39, 1.21, 6.21, 'https://podcast.io/episode/113', 'Heaven Knows, Mr. Allison');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 64, 164, 5.65, 8.86, 'https://podcast.io/episode/88', 'The Circle');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 19, 125, 5.02, 5.91, 'https://podcast.io/episode/14', 'List of Adrian Messenger, The');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 16, 94, 2.05, 19.53, 'https://podcast.io/episode/40', 'Gervaise');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 88, 117, 2.89, 19.19, 'https://podcast.io/episode/2', 'Heavenly Body, The');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 96, 41, 5.45, 13.86, 'https://podcast.io/episode/167', 'Cube 2: Hypercube');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 59, 67, 5.43, 15.8, 'https://podcast.io/episode/197', 'Universal Soldier: Regeneration');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 109, 1, 2.64, 12.14, 'https://podcast.io/episode/112', 'Gitarrmongot');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 37, 57, 3.22, 14.52, 'https://podcast.io/episode/2', 'Highball');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 86, 56, 4.17, 6.05, 'https://podcast.io/episode/119', 'Hudsucker Proxy, The');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 121, 91, 3.93, 12.21, 'https://podcast.io/episode/157', '36 Hours');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 110, 138, 3.37, 18.6, 'https://podcast.io/episode/5', 'Jesse Stone: Thin Ice');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 42, 37, 3.04, 17.97, 'https://podcast.io/episode/152', 'White Diamond, The');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 155, 137, 3.72, 11.57, 'https://podcast.io/episode/59', 'From Morn to Midnight (Von morgens bis Mitternacht)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 158, 52, 2.39, 11.01, 'https://podcast.io/episode/175', 'Romance in Manhattan');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 62, 23, 5.18, 14.54, 'https://podcast.io/episode/146', 'Off and Running ');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 134, 62, 2.18, 13.22, 'https://podcast.io/episode/44', 'The Child and the Policeman');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 33, 109, 4.56, 12.05, 'https://podcast.io/episode/115', 'Lapland Odyssey (Napapiirin sankarit)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 122, 156, 3.36, 12.56, 'https://podcast.io/episode/71', 'Tokyo Zombie (Tôkyô zonbi)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 113, 159, 1.44, 6.96, 'https://podcast.io/episode/129', 'Bloody Territories (Kôiki bôryoku: ryuuketsu no shima)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 149, 68, 2.2, 14.29, 'https://podcast.io/episode/160', 'Kid for Two Farthings, A');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 139, 100, 5.11, 19.37, 'https://podcast.io/episode/128', 'I, the Jury');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 64, 109, 2.38, 15.64, 'https://podcast.io/episode/37', 'Ride Along');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 80, 140, 2.6, 10.49, 'https://podcast.io/episode/185', 'Girl on a Bicycle');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 157, 28, 2.32, 14.44, 'https://podcast.io/episode/37', 'Cutter''s Way');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 19, 142, 5.85, 7.4, 'https://podcast.io/episode/78', 'The Love Machine');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 103, 39, 1.72, 17.13, 'https://podcast.io/episode/35', 'What Ever Happened to Baby Jane?');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 110, 148, 4.07, 17.04, 'https://podcast.io/episode/200', 'Dope');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 116, 22, 5.18, 6.75, 'https://podcast.io/episode/125', 'Loser Takes All, The (O hamenos ta pairnei ola)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 15, 23, 5.14, 17.12, 'https://podcast.io/episode/141', 'I''m a Cyborg, But That''s OK (Saibogujiman kwenchana)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 102, 112, 4.11, 6.01, 'https://podcast.io/episode/100', 'Babylon 5: A Call to Arms');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 37, 8, 1.03, 17.75, 'https://podcast.io/episode/143', 'Tarnished Angels, The');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 170, 5, 3.96, 5.63, 'https://podcast.io/episode/105', 'Girl He Left Behind, The');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 34, 93, 4.19, 19.84, 'https://podcast.io/episode/159', 'ZMD: Zombies of Mass Destruction');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 106, 85, 4.42, 8.3, 'https://podcast.io/episode/107', 'The Castle of Fu Manchu');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 131, 17, 4.68, 9.17, 'https://podcast.io/episode/106', 'Secretariat');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 64, 30, 2.73, 10.57, 'https://podcast.io/episode/5', 'Allotment Wives');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 1, 25, 1.78, 9.72, 'https://podcast.io/episode/119', 'Barton Fink');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 152, 56, 4.67, 6.3, 'https://podcast.io/episode/176', 'Nueba Yol');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 165, 77, 1.05, 9.69, 'https://podcast.io/episode/2', 'Snow and Ashes');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 39, 52, 2.31, 17.56, 'https://podcast.io/episode/95', 'Generation Um...');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 78, 55, 3.91, 12.32, 'https://podcast.io/episode/100', 'Titanic');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 161, 19, 2.54, 14.98, 'https://podcast.io/episode/27', 'Apollo 18');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 70, 85, 3.0, 7.59, 'https://podcast.io/episode/64', 'Civil Brand');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 30, 62, 4.64, 18.45, 'https://podcast.io/episode/49', 'Atalante, L''');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 110, 44, 2.27, 8.82, 'https://podcast.io/episode/50', 'Adjustment Bureau, The');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 62, 42, 4.04, 15.17, 'https://podcast.io/episode/58', 'Eyes of Tammy Faye, The');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 33, 137, 5.6, 12.18, 'https://podcast.io/episode/23', 'Commune');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 116, 28, 5.17, 13.38, 'https://podcast.io/episode/3', 'Conrack');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 170, 15, 5.13, 19.35, 'https://podcast.io/episode/34', 'Gamera vs. Viras ');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 96, 45, 5.09, 16.37, 'https://podcast.io/episode/41', 'Henry IV, Part I (First Part of King Henry the Fourth, with the Life and Death of Henry Surnamed Hotspur, The)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 51, 43, 2.03, 15.79, 'https://podcast.io/episode/138', 'Liberty Heights');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 148, 78, 2.73, 8.91, 'https://podcast.io/episode/28', 'Winter Nomads');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 30, 56, 4.19, 12.66, 'https://podcast.io/episode/132', 'Cimarron');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 97, 34, 3.71, 9.29, 'https://podcast.io/episode/69', 'Chasers, The (Jakten)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 123, 9, 5.8, 5.36, 'https://podcast.io/episode/82', 'Happiness of the Katakuris, The (Katakuri-ke no kôfuku)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 87, 25, 3.69, 8.44, 'https://podcast.io/episode/22', 'Woman of the Year');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 120, 142, 3.37, 7.56, 'https://podcast.io/episode/161', 'Warning from Space (Uchûjin Tôkyô ni arawaru)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 65, 101, 1.1, 10.16, 'https://podcast.io/episode/171', 'Jackass Presents: Bad Grandpa');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 21, 65, 3.84, 17.63, 'https://podcast.io/episode/42', 'Murderous Maids (Blessures assassines, Les)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 153, 90, 2.31, 15.55, 'https://podcast.io/episode/167', 'Quatermass and the Pit');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 126, 141, 5.33, 13.28, 'https://podcast.io/episode/62', 'Ce que mes yeux ont vu');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 20, 65, 2.83, 7.28, 'https://podcast.io/episode/77', 'Planet of the Apes');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 7, 35, 2.86, 9.34, 'https://podcast.io/episode/168', 'Garage Olimpo');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 154, 86, 3.02, 16.81, 'https://podcast.io/episode/44', 'Lassie');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 38, 55, 5.69, 6.21, 'https://podcast.io/episode/140', 'All About Steve');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 50, 79, 4.23, 10.38, 'https://podcast.io/episode/129', 'Bambi Meets Godzilla');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 31, 124, 4.11, 14.87, 'https://podcast.io/episode/13', 'Premium Rush');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 111, 95, 2.47, 9.5, 'https://podcast.io/episode/11', 'Lee Daniels'' The Butler');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 68, 28, 2.58, 14.8, 'https://podcast.io/episode/180', 'Jane Austen''s Mafia!');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 162, 9, 4.95, 15.0, 'https://podcast.io/episode/184', 'Hollywood or Bust');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 30, 8, 2.86, 5.29, 'https://podcast.io/episode/52', 'Lotta på Bråkmakargatan');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 24, 95, 1.01, 9.53, 'https://podcast.io/episode/94', 'Desperate Hours');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 7, 5, 3.66, 5.11, 'https://podcast.io/episode/175', '1, 2, 3, Sun (Un, deuz, trois, soleil)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 13, 91, 1.86, 8.4, 'https://podcast.io/episode/46', 'Halls of Montezuma');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 59, 81, 1.17, 8.41, 'https://podcast.io/episode/100', 'Nazareno Cruz and the Wolf');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 138, 54, 5.91, 7.1, 'https://podcast.io/episode/148', 'London After Midnight');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 77, 73, 2.04, 10.03, 'https://podcast.io/episode/126', 'Wizard of Baghdad, The');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 28, 106, 2.32, 6.55, 'https://podcast.io/episode/62', 'Terri');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 102, 3, 5.46, 15.11, 'https://podcast.io/episode/135', 'Angel in Cracow (Aniol w Krakowie)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 65, 4, 5.16, 19.54, 'https://podcast.io/episode/170', 'Japanese Girls at the Harbor (Minato no nihon musume)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 90, 15, 2.67, 7.14, 'https://podcast.io/episode/65', 'My Friend Irma Goes West');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 108, 40, 5.01, 14.68, 'https://podcast.io/episode/189', 'Elmer Gantry');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 116, 40, 2.87, 19.22, 'https://podcast.io/episode/73', 'Little World of Don Camillo, The (Petit monde de Don Camillo, Le)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 14, 150, 3.89, 17.3, 'https://podcast.io/episode/16', 'Charlie Chan''s Murder Cruise');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 39, 10, 3.77, 8.36, 'https://podcast.io/episode/109', 'Shakespeare in Love');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 157, 140, 3.98, 18.66, 'https://podcast.io/episode/36', 'Forbidden');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 50, 17, 4.63, 18.75, 'https://podcast.io/episode/138', 'Batman Beyond: Return of the Joker');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 96, 61, 2.12, 17.45, 'https://podcast.io/episode/69', 'Kiss Me, Guido');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 1, 141, 1.04, 17.25, 'https://podcast.io/episode/189', 'Mía');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 4, 142, 4.19, 5.68, 'https://podcast.io/episode/123', 'Still Walking (Aruitemo aruitemo)');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 135, 145, 4.6, 7.39, 'https://podcast.io/episode/93', 'Doggiewoggiez! Poochiewoochiez!');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 44, 66, 3.41, 5.31, 'https://podcast.io/episode/70', 'Class of 1984');
insert into T_Episodios (ID_Episodio, ID_Podcast, ID_Artista, Duracion, Precio, URL, Titulo) values (seq_episodio.NEXTVAL, 16, 135, 1.66, 18.28, 'https://podcast.io/episode/191', 'King of Thorn (King of Thorns) (Ibara no O)');


-- Inserccion de datos en T_Albumes_Generos

insert into T_Albumes_Generos (ID_Album, ID_Genero) values (115, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (51, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (106, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (178, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (122, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (41, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (88, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (70, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (154, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (133, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (29, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (72, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (189, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (2, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (91, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (76, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (200, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (27, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (176, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (175, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (189, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (179, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (145, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (151, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (87, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (134, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (169, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (102, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (64, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (54, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (149, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (14, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (166, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (68, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (187, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (170, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (139, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (130, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (155, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (36, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (123, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (141, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (1, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (115, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (190, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (13, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (129, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (76, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (122, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (92, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (83, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (87, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (24, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (11, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (89, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (165, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (84, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (141, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (87, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (125, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (50, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (168, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (92, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (166, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (29, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (27, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (94, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (120, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (71, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (174, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (179, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (148, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (112, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (145, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (33, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (8, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (151, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (173, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (104, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (128, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (85, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (47, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (104, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (38, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (111, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (93, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (73, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (116, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (33, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (52, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (42, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (69, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (189, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (66, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (87, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (120, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (129, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (32, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (155, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (57, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (155, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (39, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (148, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (17, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (176, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (76, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (31, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (78, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (100, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (117, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (78, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (60, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (35, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (130, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (156, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (34, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (88, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (165, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (146, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (161, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (165, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (7, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (74, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (114, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (43, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (32, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (122, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (48, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (84, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (165, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (165, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (42, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (28, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (177, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (147, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (177, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (167, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (122, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (119, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (73, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (135, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (192, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (129, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (27, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (5, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (172, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (49, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (182, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (13, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (109, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (103, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (103, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (155, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (73, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (147, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (48, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (193, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (35, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (110, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (35, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (157, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (33, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (67, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (97, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (28, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (39, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (143, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (143, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (147, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (49, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (59, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (116, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (164, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (117, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (55, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (14, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (5, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (169, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (17, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (86, 5);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (76, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (150, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (91, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (140, 2);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (147, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (82, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (37, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (133, 6);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (55, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (117, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (8, 7);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (158, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (96, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (15, 4);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (56, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (30, 3);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (36, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (200, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (110, 1);
insert into T_Albumes_Generos (ID_Album, ID_Genero) values (106, 4);

-- Inserccion de datos en T_Canciones_Generos

insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (159, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (182, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (130, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (117, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (150, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (187, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (48, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (184, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (64, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (38, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (158, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (71, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (145, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (132, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (187, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (19, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (71, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (81, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (79, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (98, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (43, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (8, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (1, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (79, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (98, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (54, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (37, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (86, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (61, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (94, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (5, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (60, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (12, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (70, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (51, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (126, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (44, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (26, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (89, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (114, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (199, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (122, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (180, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (168, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (2, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (92, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (173, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (172, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (176, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (117, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (118, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (89, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (37, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (189, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (72, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (103, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (60, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (95, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (75, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (23, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (98, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (115, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (48, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (104, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (39, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (141, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (19, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (87, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (5, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (190, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (93, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (45, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (167, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (163, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (12, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (64, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (72, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (185, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (45, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (183, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (12, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (100, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (44, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (83, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (185, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (160, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (80, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (6, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (1, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (88, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (107, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (165, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (115, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (27, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (98, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (97, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (181, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (93, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (68, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (159, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (103, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (124, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (65, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (87, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (113, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (126, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (87, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (59, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (140, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (73, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (53, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (81, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (144, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (34, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (76, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (35, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (193, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (35, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (39, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (184, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (126, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (77, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (28, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (55, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (57, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (66, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (158, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (149, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (46, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (40, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (12, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (195, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (143, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (69, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (128, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (161, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (105, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (62, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (188, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (77, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (133, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (120, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (173, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (180, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (181, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (16, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (46, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (15, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (81, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (189, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (99, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (30, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (93, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (87, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (133, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (116, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (2, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (38, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (16, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (61, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (151, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (198, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (149, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (179, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (102, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (12, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (59, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (11, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (47, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (82, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (27, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (25, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (134, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (141, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (159, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (131, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (181, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (96, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (31, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (106, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (47, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (182, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (168, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (131, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (156, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (196, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (196, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (68, 4);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (200, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (173, 1);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (111, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (174, 5);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (148, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (15, 6);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (160, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (43, 3);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (28, 2);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (67, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (77, 7);
insert into T_Canciones_Generos (ID_Cancion, ID_Genero) values (127, 4);

-- Inserccion de datos en T_Episodios_Generos

insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (96, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (152, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (117, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (158, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (181, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (71, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (103, 4);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (87, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (60, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (173, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (26, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (161, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (101, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (93, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (60, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (96, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (51, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (73, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (32, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (160, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (178, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (44, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (180, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (163, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (106, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (68, 4);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (59, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (107, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (135, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (18, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (19, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (51, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (194, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (1, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (57, 4);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (177, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (117, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (130, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (19, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (99, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (170, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (83, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (186, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (4, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (158, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (85, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (198, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (143, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (141, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (176, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (175, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (83, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (150, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (76, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (51, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (91, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (159, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (184, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (197, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (188, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (118, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (131, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (83, 4);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (26, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (172, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (13, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (158, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (167, 4);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (172, 4);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (46, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (87, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (106, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (131, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (54, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (26, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (136, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (96, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (89, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (156, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (179, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (39, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (192, 4);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (23, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (117, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (156, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (145, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (161, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (162, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (128, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (42, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (101, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (188, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (119, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (143, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (8, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (172, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (62, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (96, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (5, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (163, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (48, 4);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (111, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (163, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (134, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (158, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (168, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (117, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (21, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (1, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (144, 4);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (164, 4);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (183, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (48, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (149, 4);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (23, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (81, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (36, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (69, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (129, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (192, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (197, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (52, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (6, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (108, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (107, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (182, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (32, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (46, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (6, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (37, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (117, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (83, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (104, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (191, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (123, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (97, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (120, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (184, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (42, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (176, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (106, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (182, 4);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (64, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (114, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (71, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (105, 4);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (85, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (174, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (72, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (105, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (88, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (170, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (8, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (49, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (93, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (109, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (78, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (44, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (96, 4);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (144, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (127, 4);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (145, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (25, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (89, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (15, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (99, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (71, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (150, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (145, 4);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (36, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (16, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (28, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (120, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (134, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (120, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (171, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (78, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (128, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (123, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (12, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (146, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (87, 7);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (34, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (126, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (150, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (138, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (193, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (75, 6);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (185, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (51, 4);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (17, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (81, 3);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (29, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (93, 5);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (129, 2);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (140, 4);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (113, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (112, 4);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (153, 1);
insert into T_Episodios_Generos (ID_Episodio, ID_Genero) values (84, 3);


-- Inserccion de datos en T_Podcast_Generos

insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (166, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (17, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (174, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (12, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (166, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (141, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (120, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (15, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (135, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (3, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (56, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (179, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (11, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (86, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (186, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (93, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (152, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (177, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (79, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (184, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (91, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (28, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (9, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (157, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (115, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (47, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (94, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (29, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (175, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (118, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (102, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (183, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (28, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (114, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (20, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (45, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (157, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (187, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (73, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (80, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (122, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (79, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (69, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (170, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (159, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (32, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (146, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (5, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (6, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (118, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (61, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (88, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (49, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (142, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (140, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (119, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (164, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (48, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (138, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (143, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (105, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (21, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (79, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (24, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (87, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (106, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (155, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (31, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (188, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (58, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (100, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (193, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (195, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (47, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (110, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (133, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (108, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (146, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (130, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (99, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (63, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (161, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (177, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (28, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (141, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (53, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (153, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (150, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (157, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (18, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (35, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (31, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (84, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (74, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (179, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (111, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (86, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (83, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (163, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (46, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (169, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (194, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (54, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (161, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (65, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (179, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (31, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (76, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (35, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (2, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (81, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (74, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (102, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (157, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (2, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (153, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (169, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (96, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (50, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (142, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (89, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (159, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (118, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (157, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (190, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (74, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (129, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (172, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (36, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (59, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (78, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (14, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (104, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (176, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (135, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (192, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (101, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (90, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (198, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (199, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (134, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (59, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (9, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (2, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (162, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (180, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (191, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (47, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (147, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (194, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (19, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (192, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (63, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (115, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (32, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (121, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (133, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (32, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (15, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (145, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (34, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (95, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (121, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (177, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (167, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (76, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (54, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (168, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (172, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (147, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (62, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (21, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (128, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (23, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (128, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (17, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (63, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (67, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (161, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (139, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (69, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (169, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (35, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (99, 3);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (160, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (166, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (56, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (24, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (84, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (172, 7);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (28, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (163, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (178, 1);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (181, 4);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (117, 2);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (172, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (42, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (45, 6);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (89, 5);
insert into T_Podcast_Generos (ID_Podcast, ID_Genero) values (163, 4);


select * from T_Usuarios;

-- Inserccion de datos en T_Usuarios

insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (1, 'Eldin', 'epriest0@squidoo.com', '9079693691', '569-146-1288', '06/05/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (2, 'Armand', 'amapples1@elegantthemes.com', '8888953953', '943-607-4992', '01/05/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (3, 'Kristina', 'kfonte2@yandex.ru', '2997051769', '524-841-8476', '01/21/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (4, 'Joly', 'jschimann3@canalblog.com', '1714673653', '518-786-9002', '10/30/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (5, 'Aviva', 'adoby4@dell.com', '6723832786', '306-907-5230', '12/06/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (6, 'Vanni', 'vpotzold5@opera.com', '9018331128', '585-974-7334', '05/22/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (7, 'Callean', 'ctaylour6@ox.ac.uk', '3268137644', '779-381-9000', '08/20/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (8, 'Viole', 'vlinbohm7@example.com', '5003076292', '383-943-5234', '05/25/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (9, 'Reggy', 'rpulfer8@wunderground.com', '5885350382', '722-289-3366', '04/10/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (10, 'Oneida', 'oposselwhite9@spotify.com', '1957935261', '174-675-3441', '01/18/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (11, 'Fleur', 'fdobkina@ft.com', '1291951562', '867-540-6392', '05/01/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (12, 'Emmett', 'eaguirrezabalab@cbc.ca', '3562728776', '905-199-0244', '01/30/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (13, 'Zea', 'zcarlec@domainmarket.com', '9762888406', '602-115-9469', '10/27/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (14, 'Al', 'acrinidged@about.me', '8511017175', '684-357-7546', '04/16/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (15, 'Philippine', 'pgwilliamse@altervista.org', '1502805581', '928-599-3892', '08/11/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (16, 'Rodrick', 'rkiltyf@cdbaby.com', '7445954461', '505-543-3996', '08/03/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (17, 'Joella', 'jreddyg@go.com', '7643713780', '110-383-8171', '01/16/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (18, 'Lu', 'lbowichh@twitter.com', '3722758654', '698-691-2541', '07/14/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (19, 'Corey', 'cbordessai@4shared.com', '7872322864', '985-999-4703', '01/02/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (20, 'Preston', 'pgallagherj@ustream.tv', '6537171894', '733-922-9006', '09/10/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (21, 'Dorey', 'daberdalgyk@amazon.de', '1338555101', '828-940-9179', '11/06/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (22, 'Susanetta', 'srawesl@soup.io', '9814132273', '188-438-1911', '10/29/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (23, 'Barrie', 'bbiggerdikem@squidoo.com', '9021139029', '280-291-6093', '05/22/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (24, 'Robbert', 'rshildraken@soup.io', '8433764310', '658-938-5537', '01/10/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (25, 'Austin', 'ashowteo@cnet.com', '4502746323', '991-856-1287', '11/03/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (26, 'Vaughan', 'vlarticep@hostgator.com', '8663210185', '224-802-9724', '09/15/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (27, 'Meier', 'medisonq@ca.gov', '8285965252', '295-734-8902', '10/02/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (28, 'Gustie', 'griltonr@1und1.de', '1224888777', '702-471-1002', '01/08/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (29, 'Min', 'mpiechas@usa.gov', '8088699859', '302-621-8909', '03/25/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (30, 'Clarence', 'candertont@elegantthemes.com', '5432628947', '908-539-4990', '04/06/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (31, 'Glad', 'gscoatesu@scribd.com', '3791241261', '754-523-5386', '09/11/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (32, 'Domeniga', 'dpiwellv@bluehost.com', '4566957479', '560-371-4604', '06/13/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (33, 'Carla', 'ckasperskiw@irs.gov', '5738607450', '966-650-8694', '03/24/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (34, 'Heda', 'hbrianx@wunderground.com', '3366711857', '183-474-4723', '03/30/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (35, 'Shawn', 'smehewy@webs.com', '7907980889', '475-996-5142', '11/29/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (36, 'Astrid', 'atuckwoodz@cpanel.net', '9495013522', '602-880-2444', '01/12/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (37, 'Napoleon', 'ncastaner10@fotki.com', '1711865029', '905-570-9705', '04/28/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (38, 'Mona', 'mpunt11@toplist.cz', '2642750570', '570-238-5634', '12/07/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (39, 'Byrom', 'bprue12@myspace.com', '5212592140', '888-155-5654', '06/05/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (40, 'Krysta', 'kbreslauer13@apache.org', '4363194407', '471-382-4227', '01/01/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (41, 'Ferdinande', 'fklambt14@naver.com', '2678775592', '986-143-1024', '05/22/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (42, 'Rochester', 'rpotteridge15@reddit.com', '8021343977', '347-781-1508', '08/27/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (43, 'Frederich', 'fhowden16@google.pl', '8075483363', '263-480-6376', '12/09/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (44, 'Feodor', 'fsurmon17@last.fm', '6816821686', '529-252-2466', '06/14/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (45, 'Doretta', 'dcoverley18@mit.edu', '2495549154', '450-242-7247', '02/29/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (46, 'Sydel', 'syeardley19@fastcompany.com', '6571578759', '319-951-8412', '03/21/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (47, 'Emmit', 'ehewlings1a@naver.com', '3754914336', '955-578-0110', '10/04/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (48, 'Kingsley', 'kbellew1b@seesaa.net', '7469073129', '801-412-1889', '10/22/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (49, 'Aidan', 'agraeber1c@ycombinator.com', '7593219631', '514-350-4707', '10/01/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (50, 'Helga', 'hcoumbe1d@tinyurl.com', '1956961966', '747-823-9199', '02/08/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (51, 'Hilly', 'hvidineev1e@twitter.com', '9716794105', '245-469-8362', '12/25/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (52, 'Hasheem', 'hbaldery1f@typepad.com', '3227911952', '572-287-7586', '01/18/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (53, 'Laureen', 'lclewarth1g@ucoz.ru', '7129466527', '650-238-1274', '10/27/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (54, 'Ervin', 'ebinstead1h@google.pl', '3514158799', '285-736-5080', '03/05/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (55, 'Correy', 'clegerton1i@pinterest.com', '2745602052', '376-488-2097', '03/11/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (56, 'Claire', 'cticehurst1j@netvibes.com', '6236447790', '399-375-5296', '10/08/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (57, 'Erina', 'ealpin1k@aboutads.info', '7513158596', '449-387-1786', '05/17/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (58, 'Patricio', 'ppoore1l@diigo.com', '6895609108', '974-130-1133', '11/17/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (59, 'Rosemaria', 'rkemsley1m@prnewswire.com', '7875489824', '754-223-0726', '08/04/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (60, 'Therine', 'tokenden1n@devhub.com', '9616395268', '378-979-0626', '03/23/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (61, 'Katy', 'kpleaden1o@cocolog-nifty.com', '3214489235', '745-744-6564', '03/24/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (62, 'Haley', 'hburstowe1p@nasa.gov', '8493035047', '639-598-6117', '01/21/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (63, 'Harli', 'hworton1q@naver.com', '8835464077', '895-844-1285', '08/13/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (64, 'Raquel', 'rdudney1r@geocities.com', '7724995235', '218-160-9032', '06/09/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (65, 'Jillian', 'jgorden1s@ted.com', '9738174787', '265-667-0997', '04/17/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (66, 'Corabella', 'cdrews1t@github.com', '3987942131', '834-959-4696', '08/02/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (67, 'Udall', 'uborrill1u@hugedomains.com', '3194908782', '990-431-1517', '11/20/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (68, 'Granny', 'grichardson1v@t.co', '7918848166', '766-466-9760', '10/05/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (69, 'Brendon', 'bluberti1w@microsoft.com', '7447382881', '780-554-4311', '12/19/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (70, 'Alistair', 'aharp1x@prlog.org', '8786644041', '988-956-2902', '07/31/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (71, 'Zenia', 'zbeteriss1y@marketwatch.com', '8117603906', '908-896-9236', '11/06/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (72, 'Vanessa', 'vmaryet1z@taobao.com', '5928058798', '439-148-4609', '08/26/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (73, 'Lori', 'lgeer20@salon.com', '4694373374', '732-550-7890', '11/27/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (74, 'Dominick', 'dscarisbrick21@psu.edu', '5677708231', '568-812-6113', '04/08/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (75, 'Inna', 'ibaxstair22@sourceforge.net', '1059067638', '544-858-8188', '12/15/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (76, 'Walker', 'wpolle23@adobe.com', '6462148579', '522-121-8335', '04/28/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (77, 'Minette', 'mwaszkiewicz24@mediafire.com', '6888180472', '697-368-5746', '03/18/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (78, 'Trev', 'tmaccarter25@wordpress.com', '9408297152', '678-629-4850', '11/13/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (79, 'Walt', 'wmaton26@google.pl', '9348006012', '644-834-5948', '05/12/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (80, 'Vasili', 'vblunn27@sciencedirect.com', '9994741410', '897-712-5744', '08/18/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (81, 'Karena', 'katyeo28@tmall.com', '3429476732', '820-427-4925', '01/24/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (82, 'North', 'nguitel29@squidoo.com', '8917378000', '585-798-0750', '12/23/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (83, 'Tedra', 'tkrolak2a@nasa.gov', '7061856423', '331-314-8514', '08/18/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (84, 'Leonie', 'lwenban2b@ted.com', '6973124249', '748-459-9112', '04/06/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (85, 'Rickie', 'rodgers2c@paginegialle.it', '7168017715', '770-940-5700', '05/22/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (86, 'Khalil', 'khackett2d@miibeian.gov.cn', '9454231266', '957-691-3198', '05/31/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (87, 'Eliot', 'eholdforth2e@mail.ru', '4476874383', '215-136-2485', '07/22/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (88, 'Gizela', 'gburbridge2f@epa.gov', '1221820000', '208-774-8883', '10/23/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (89, 'Sayres', 'slarham2g@tmall.com', '6984074618', '643-807-1418', '05/11/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (90, 'Garner', 'goates2h@ox.ac.uk', '6398292357', '765-713-7683', '11/28/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (91, 'Feodor', 'fdoyle2i@bing.com', '8089223838', '840-743-9819', '10/05/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (92, 'Gracie', 'gpavluk2j@csmonitor.com', '6338972635', '860-953-5831', '01/04/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (93, 'Moselle', 'mzettoi2k@narod.ru', '6572525201', '496-612-5721', '02/12/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (94, 'Quinton', 'qthompson2l@google.de', '2166842872', '863-233-9246', '08/11/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (95, 'Helli', 'hveltman2m@forbes.com', '7074879006', '579-223-7081', '04/01/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (96, 'Natassia', 'nrojel2n@jugem.jp', '8793674209', '670-140-1857', '07/20/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (97, 'Brett', 'bstrattan2o@furl.net', '1166809121', '351-518-9216', '09/30/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (98, 'Dwight', 'dsenter2p@ucoz.com', '9641618862', '372-502-3345', '01/01/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (99, 'Lucretia', 'lgerlack2q@multiply.com', '1147424997', '684-995-7614', '02/05/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (100, 'Filide', 'ffrankish2r@archive.org', '9015132240', '565-117-6423', '11/05/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (101, 'Dorris', 'dbraunfeld2s@dion.ne.jp', '7919462438', '303-161-9806', '03/09/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (102, 'Flossi', 'fjudkins2t@liveinternet.ru', '6679303643', '754-602-6649', '03/01/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (103, 'Verena', 'vtrelevan2u@ustream.tv', '3742724107', '585-773-7091', '01/06/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (104, 'Zahara', 'zgerber2v@fema.gov', '8604028473', '538-388-3438', '01/13/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (105, 'Merla', 'mbodley2w@4shared.com', '6811923226', '659-415-2436', '04/03/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (106, 'Zack', 'zgodson2x@hud.gov', '4092346006', '177-781-0692', '09/27/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (107, 'Hewie', 'hsamwayes2y@usatoday.com', '9628284085', '684-346-9852', '01/14/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (108, 'Starr', 'sgillibrand2z@livejournal.com', '6302705215', '132-460-8265', '12/04/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (109, 'Rutter', 'rivic30@imdb.com', '1486131562', '122-588-4684', '01/01/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (110, 'Lynett', 'lcolbeck31@purevolume.com', '1317260223', '429-416-7448', '04/09/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (111, 'Farrand', 'fforsyde32@goodreads.com', '3641951940', '536-891-0774', '08/16/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (112, 'Libby', 'lpedro33@mlb.com', '3932303271', '854-900-7628', '02/21/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (113, 'Winona', 'wnudde34@blinklist.com', '1529953484', '389-766-3117', '11/18/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (114, 'Luke', 'lkuhwald35@youtu.be', '5487276667', '855-584-4205', '08/27/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (115, 'Elisabeth', 'emckinlay36@free.fr', '2366359903', '805-460-8710', '09/08/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (116, 'Peggie', 'psteart37@scribd.com', '4337599215', '753-450-2488', '04/25/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (117, 'Sheppard', 'skenton38@biglobe.ne.jp', '6881798446', '943-920-6237', '04/02/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (118, 'Nancie', 'nwolfit39@sun.com', '4391860023', '427-618-5400', '04/17/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (119, 'Maude', 'mmalyj3a@paginegialle.it', '8635378718', '867-379-5687', '04/04/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (120, 'Lena', 'londrusek3b@uiuc.edu', '2003532392', '852-403-8172', '08/24/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (121, 'Pepi', 'poswick3c@amazon.co.jp', '3945530933', '390-712-4659', '10/29/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (122, 'Gabriello', 'gelecum3d@hc360.com', '6906693881', '914-510-7987', '04/17/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (123, 'Kakalina', 'kgarmon3e@google.com', '5861490367', '806-149-8030', '12/23/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (124, 'Nat', 'nbartod3f@blogs.com', '7801513409', '123-573-7410', '09/18/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (125, 'Angie', 'askelcher3g@usnews.com', '6705679244', '165-184-4151', '11/17/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (126, 'Marcela', 'mmcdade3h@feedburner.com', '6419164805', '676-384-4102', '04/10/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (127, 'Orlando', 'oswaden3i@geocities.com', '6358340132', '842-466-0908', '03/18/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (128, 'Jobina', 'jcossey3j@yellowbook.com', '9268430303', '448-193-9062', '03/08/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (129, 'Odella', 'oosichev3k@globo.com', '6757030934', '730-822-7708', '07/27/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (130, 'Myrta', 'mburkwood3l@ed.gov', '9467856758', '656-853-0261', '08/26/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (131, 'Corrina', 'cwenderott3m@merriam-webster.com', '9598557143', '497-725-4135', '03/16/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (132, 'Brade', 'baverill3n@illinois.edu', '9887225350', '362-118-6093', '07/18/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (133, 'Grantham', 'gschroter3o@flickr.com', '8311078859', '540-545-2692', '08/05/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (134, 'Morgen', 'mmckeighen3p@yale.edu', '4933722460', '415-762-9152', '11/11/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (135, 'Shirlee', 'sperott3q@guardian.co.uk', '6853078467', '143-172-3463', '02/22/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (136, 'Blisse', 'bruffey3r@nyu.edu', '4157317642', '306-763-8878', '10/11/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (137, 'Caleb', 'cmcalarney3s@stumbleupon.com', '7604123500', '789-311-3058', '07/23/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (138, 'Hendrika', 'htincombe3t@nps.gov', '1295644392', '278-862-3079', '09/01/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (139, 'Giffer', 'gscohier3u@pagesperso-orange.fr', '5266123297', '576-733-6427', '12/19/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (140, 'Amandie', 'abrightey3v@weebly.com', '1211905185', '278-610-5139', '02/23/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (141, 'Cecilio', 'cdegliabbati3w@youtube.com', '7886685203', '798-310-6301', '01/28/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (142, 'Crystal', 'cbassindale3x@usda.gov', '8391479115', '629-416-6505', '11/29/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (143, 'Eolanda', 'enanuccioi3y@privacy.gov.au', '1496338048', '864-449-9338', '02/27/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (144, 'Dale', 'dbullman3z@marriott.com', '1445389158', '580-925-4405', '12/19/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (145, 'Rutherford', 'rkimmince40@senate.gov', '6079157762', '872-158-9350', '11/08/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (146, 'Ham', 'hkynder41@elegantthemes.com', '1384131185', '510-996-8696', '05/05/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (147, 'Maegan', 'mdevon42@dmoz.org', '6248127289', '807-427-1865', '07/16/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (148, 'Ilsa', 'iferrero43@amazonaws.com', '5338733431', '942-871-0424', '03/02/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (149, 'Amitie', 'atimeby44@phpbb.com', '1599593508', '457-959-4231', '03/11/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (150, 'Camey', 'cbedham45@csmonitor.com', '6537651397', '719-896-3877', '07/26/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (151, 'Milicent', 'manten46@dyndns.org', '6411552538', '445-362-3784', '11/24/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (152, 'Laetitia', 'lvincent47@cisco.com', '5632842070', '925-532-0583', '07/24/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (153, 'Pat', 'prickaert48@hp.com', '9683212154', '245-858-5548', '09/01/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (154, 'Engelbert', 'eashby49@barnesandnoble.com', '3143168225', '844-790-0291', '12/10/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (155, 'Ellswerth', 'ekirman4a@live.com', '8542420457', '919-899-9638', '01/13/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (156, 'Carolynn', 'clowdiane4b@cnn.com', '1257227450', '973-854-8612', '01/11/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (157, 'Dana', 'dsummerrell4c@boston.com', '7214105732', '750-137-0292', '01/21/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (158, 'Massimiliano', 'myaldren4d@tiny.cc', '2408578623', '893-794-7883', '01/25/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (159, 'Mellisa', 'mdufaire4e@xrea.com', '4681626635', '703-826-4852', '04/10/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (160, 'Yorgos', 'ymckibbin4f@vk.com', '8653458574', '331-808-8752', '10/19/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (161, 'Artie', 'agrishakin4g@cpanel.net', '7461777408', '212-706-4372', '09/13/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (162, 'Selia', 'smorsom4h@networkadvertising.org', '2834987118', '499-748-1455', '09/16/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (163, 'Marie-jeanne', 'mstiggers4i@cmu.edu', '4324806286', '784-352-3716', '05/14/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (164, 'Else', 'ecostigan4j@altervista.org', '5788991181', '695-518-8348', '06/30/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (165, 'Clio', 'cgambrell4k@scribd.com', '3407711858', '832-123-1487', '07/22/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (166, 'Denis', 'dlaurenz4l@istockphoto.com', '2489661393', '828-362-0365', '08/30/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (167, 'Kleon', 'kcollyer4m@seesaa.net', '6938334597', '764-677-7415', '03/22/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (168, 'Glen', 'ggwilym4n@dailymail.co.uk', '2611653543', '614-350-8939', '12/29/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (169, 'Dory', 'delsley4o@goodreads.com', '4021620086', '208-519-9776', '08/22/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (170, 'Norean', 'nchristofor4p@msu.edu', '2962904452', '158-204-0488', '10/30/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (171, 'Salomo', 'sclow4q@jugem.jp', '5638333868', '235-418-3855', '12/10/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (172, 'Karilynn', 'kthurlow4r@bloglines.com', '8783756181', '534-629-3581', '09/19/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (173, 'Ferguson', 'fhandrik4s@tiny.cc', '7483029287', '178-366-3690', '03/12/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (174, 'Petronia', 'pmacskeaghan4t@dmoz.org', '7888142117', '124-624-7747', '04/19/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (175, 'Colver', 'csharram4u@arstechnica.com', '2167177774', '478-208-1661', '11/07/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (176, 'Arlee', 'atripp4v@abc.net.au', '9598499680', '457-332-8314', '03/04/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (177, 'Mathias', 'mtunnah4w@elpais.com', '5345665270', '215-894-4046', '04/12/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (178, 'Sharia', 'sjachimiak4x@diigo.com', '3642075841', '269-985-9266', '09/05/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (179, 'Irving', 'iandree4y@home.pl', '5515050532', '437-214-8968', '02/07/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (180, 'Malina', 'mferrier4z@washington.edu', '7653045200', '909-805-4558', '10/01/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (181, 'Thurstan', 'tkinnane50@apple.com', '3591906643', '502-677-8713', '11/15/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (182, 'Bogey', 'bdain51@marketwatch.com', '9936776058', '725-190-8038', '10/21/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (183, 'Lenee', 'llent52@timesonline.co.uk', '9003801964', '476-263-8809', '11/30/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (184, 'Harry', 'hfutcher53@msn.com', '3863063329', '220-983-1827', '12/22/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (185, 'Alexandra', 'aivanshintsev54@google.pl', '5793208835', '483-163-0013', '01/08/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (186, 'Adham', 'aickovitz55@ebay.co.uk', '7786462859', '323-900-9622', '01/26/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (187, 'Douglas', 'dneles56@smh.com.au', '2374616094', '674-699-5420', '02/09/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (188, 'Ignacius', 'imarciek57@joomla.org', '6329552039', '327-855-6844', '11/04/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (189, 'Amye', 'apechan58@mashable.com', '9567107338', '493-239-2741', '08/29/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (190, 'Ellette', 'epegram59@de.vu', '6202037762', '251-704-3679', '11/07/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (191, 'Scot', 'scolley5a@wikia.com', '9194833409', '256-239-4341', '09/29/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (192, 'Dougy', 'ddmitrovic5b@umn.edu', '3426847584', '173-531-9876', '02/27/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (193, 'Hartley', 'hkirkebye5c@cbc.ca', '4433970427', '264-895-3619', '09/29/2023');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (194, 'Abba', 'akirstein5d@virginia.edu', '1551471797', '359-910-2013', '01/16/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (195, 'Morganne', 'mablewhite5e@europa.eu', '4497916780', '945-549-4866', '03/23/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (196, 'Iver', 'ijoslyn5f@networkadvertising.org', '8903201921', '481-763-7801', '01/04/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (197, 'Patric', 'psevier5g@clickbank.net', '8834745198', '858-499-2320', '02/17/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (198, 'Wendel', 'wpescud5h@odnoklassniki.ru', '8005369523', '334-762-8947', '02/27/2024');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (199, 'Buddie', 'bfinlaison5i@list-manage.com', '1929010507', '700-156-5659', '03/31/2025');
insert into T_Usuarios (ID_Usuario, Nombre, Email, Contrasena, Telefono, Fecha_Registro) values (200, 'Willem', 'wodriscole5j@purevolume.com', '5645574616', '888-996-5459', '02/08/2024');



--Inserccion de datos en T_Factura

insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 117, '12/14/2024', 37.37, 'Visa', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 38, '1/16/2024', 62.63, 'Efectivo', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 40, '5/3/2024', 66.73, 'Efectivo', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 12, '7/11/2024', 97.15, 'Visa', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 107, '1/19/2025', 28.73, 'SinpeMovil', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 24, '10/16/2024', 84.86, 'Visa', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 58, '1/17/2024', 14.28, 'SinpeMovil', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 73, '7/24/2023', 99.38, 'Visa', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 122, '7/14/2023', 9.21, 'SinpeMovil', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 70, '11/6/2023', 19.63, 'Mastercard', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 36, '5/10/2024', 83.43, 'Mastercard', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 45, '7/16/2024', 61.72, 'PayPal', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 72, '7/24/2023', 87.15, 'SinpeMovil', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 126, '5/24/2024', 92.71, 'Efectivo', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 104, '2/17/2024', 30.18, 'Mastercard', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 91, '10/8/2023', 69.78, 'Visa', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 8, '1/13/2025', 22.47, 'SinpeMovil', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 85, '5/20/2024', 17.99, 'Visa', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 72, '1/21/2024', 92.16, 'Efectivo', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 130, '5/17/2023', 70.25, 'Efectivo', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 108, '10/12/2023', 89.26, 'Mastercard', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 31, '9/21/2023', 97.12, 'PayPal', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 45, '4/28/2024', 21.71, 'Mastercard', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 79, '12/21/2023', 61.2, 'Visa', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 119, '2/13/2025', 27.81, 'Mastercard', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 105, '7/18/2024', 70.21, 'PayPal', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 16, '5/5/2024', 79.66, 'Efectivo', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 115, '5/7/2023', 83.77, 'Efectivo', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 22, '4/8/2025', 75.3, 'PayPal', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 40, '10/15/2024', 41.1, 'PayPal', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 69, '5/5/2024', 23.05, 'Efectivo', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 90, '8/24/2023', 66.15, 'Mastercard', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 40, '10/11/2024', 68.92, 'SinpeMovil', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 48, '4/5/2024', 29.79, 'Visa', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 24, '6/10/2023', 92.49, 'Efectivo', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 91, '5/31/2023', 80.1, 'Efectivo', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 102, '12/9/2023', 22.77, 'Efectivo', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 127, '9/28/2024', 55.07, 'Visa', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 54, '10/21/2023', 18.76, 'Mastercard', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 117, '2/3/2025', 52.44, 'Mastercard', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 105, '2/9/2024', 98.7, 'SinpeMovil', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 17, '3/10/2024', 86.39, 'SinpeMovil', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 116, '4/7/2025', 43.37, 'PayPal', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 94, '7/13/2024', 84.07, 'PayPal', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 48, '3/11/2025', 60.94, 'Visa', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 27, '9/28/2024', 93.72, 'SinpeMovil', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 9, '7/7/2024', 43.01, 'Visa', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 33, '2/11/2025', 80.37, 'PayPal', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 21, '10/9/2023', 26.33, 'Mastercard', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 41, '11/20/2023', 37.09, 'SinpeMovil', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 21, '2/22/2024', 74.75, 'SinpeMovil', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 36, '10/15/2024', 85.78, 'Visa', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 76, '2/16/2025', 36.08, 'Efectivo', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 114, '2/17/2024', 34.72, 'Mastercard', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 35, '4/3/2025', 19.0, 'Mastercard', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 110, '7/15/2024', 78.69, 'PayPal', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 87, '11/5/2023', 19.0, 'PayPal', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 39, '2/16/2024', 60.3, 'PayPal', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 21, '4/26/2024', 66.08, 'Visa', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 104, '7/10/2023', 84.47, 'SinpeMovil', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 101, '9/23/2024', 95.04, 'Visa', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 128, '1/27/2025', 58.15, 'SinpeMovil', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 75, '6/27/2024', 85.32, 'Efectivo', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 93, '12/25/2023', 93.13, 'Mastercard', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 112, '11/27/2023', 20.99, 'Efectivo', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 83, '10/22/2024', 62.71, 'PayPal', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 100, '12/11/2023', 18.59, 'Efectivo', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 42, '10/25/2024', 46.79, 'Efectivo', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 124, '7/17/2023', 88.47, 'Efectivo', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 63, '6/6/2024', 76.01, 'Efectivo', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 44, '8/2/2024', 61.12, 'Efectivo', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 97, '10/9/2023', 98.15, 'Efectivo', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 12, '7/20/2024', 78.84, 'SinpeMovil', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 62, '2/17/2025', 50.96, 'Visa', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 48, '10/5/2024', 64.09, 'Visa', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 85, '10/19/2023', 23.86, 'Efectivo', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 43, '7/27/2024', 92.08, 'Visa', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 94, '11/10/2024', 64.46, 'SinpeMovil', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 11, '9/3/2023', 31.59, 'PayPal', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 24, '5/30/2024', 48.08, 'SinpeMovil', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 27, '5/16/2024', 54.0, 'Visa', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 68, '1/16/2024', 60.4, 'Mastercard', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 85, '12/7/2024', 82.08, 'SinpeMovil', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 104, '10/9/2024', 32.37, 'Mastercard', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 91, '4/24/2024', 37.31, 'PayPal', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 114, '10/9/2024', 72.13, 'Efectivo', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 99, '2/19/2025', 73.04, 'Efectivo', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 5, '2/3/2025', 50.65, 'Efectivo', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 26, '11/24/2023', 48.16, 'Visa', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 39, '5/8/2023', 94.39, 'PayPal', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 31, '8/16/2024', 52.75, 'Visa', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 103, '2/3/2025', 45.59, 'PayPal', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 73, '6/10/2023', 99.74, 'PayPal', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 101, '7/7/2023', 45.76, 'PayPal', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 49, '11/12/2023', 82.94, 'PayPal', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 106, '10/7/2024', 74.0, 'PayPal', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 111, '8/19/2023', 62.33, 'Visa', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 26, '6/1/2023', 23.54, 'PayPal', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 54, '9/15/2023', 20.9, 'PayPal', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 78, '1/9/2024', 28.8, 'SinpeMovil', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 68, '4/7/2025', 71.46, 'Mastercard', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 50, '7/25/2023', 78.46, 'SinpeMovil', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 77, '5/28/2024', 89.84, 'Efectivo', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 62, '2/23/2025', 94.92, 'SinpeMovil', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 73, '7/29/2023', 26.17, 'Visa', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 28, '7/10/2023', 69.96, 'Visa', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 54, '1/18/2025', 81.34, 'Efectivo', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 94, '7/25/2024', 43.39, 'Efectivo', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 7, '6/2/2024', 37.53, 'Efectivo', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 59, '12/2/2023', 85.98, 'Efectivo', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 98, '6/23/2023', 56.76, 'SinpeMovil', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 99, '7/30/2023', 86.16, 'Efectivo', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 81, '3/6/2025', 29.42, 'Visa', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 29, '7/4/2024', 23.63, 'Efectivo', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 11, '11/29/2024', 15.5, 'SinpeMovil', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 96, '9/13/2023', 23.74, 'SinpeMovil', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 88, '1/9/2025', 49.31, 'Visa', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 89, '2/12/2024', 48.14, 'Visa', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 54, '3/28/2024', 64.08, 'Mastercard', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 106, '10/12/2024', 71.18, 'Mastercard', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 107, '10/11/2023', 56.43, 'Visa', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 45, '6/17/2024', 20.85, 'PayPal', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 125, '6/22/2023', 10.61, 'PayPal', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 15, '2/25/2024', 84.0, 'Visa', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 15, '8/2/2024', 84.98, 'Mastercard', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 75, '11/25/2023', 10.6, 'Mastercard', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 94, '5/11/2024', 46.49, 'Visa', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 103, '3/17/2025', 31.08, 'Efectivo', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 127, '10/8/2024', 17.43, 'PayPal', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 9, '6/16/2024', 14.15, 'Visa', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 12, '6/1/2023', 20.25, 'PayPal', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 79, '2/4/2025', 35.61, 'Visa', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 79, '2/9/2025', 13.06, 'SinpeMovil', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 72, '9/20/2023', 41.0, 'Visa', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 89, '7/19/2023', 38.32, 'Visa', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 7, '4/12/2024', 16.88, 'SinpeMovil', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 72, '7/12/2023', 62.81, 'PayPal', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 24, '4/9/2024', 97.75, 'Mastercard', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 14, '6/15/2024', 81.19, 'Mastercard', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 33, '4/14/2024', 27.48, 'Efectivo', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 122, '7/20/2024', 76.37, 'PayPal', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 123, '5/31/2023', 55.05, 'Mastercard', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 81, '2/4/2024', 25.27, 'Efectivo', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 10, '9/23/2023', 70.81, 'PayPal', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 41, '12/4/2024', 15.98, 'SinpeMovil', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 92, '8/18/2023', 29.26, 'PayPal', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 73, '3/7/2025', 27.8, 'SinpeMovil', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 123, '1/21/2025', 86.31, 'Efectivo', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 38, '6/27/2024', 24.94, 'Mastercard', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 117, '5/15/2024', 81.98, 'Mastercard', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 23, '5/23/2023', 6.88, 'Mastercard', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 25, '6/24/2024', 71.33, 'PayPal', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 95, '8/28/2023', 78.25, 'SinpeMovil', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 13, '4/27/2024', 17.35, 'Efectivo', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 33, '6/4/2024', 42.42, 'SinpeMovil', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 52, '3/5/2025', 91.82, 'Visa', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 116, '4/10/2025', 78.24, 'Efectivo', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 54, '1/20/2025', 24.18, 'Visa', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 18, '8/23/2024', 48.86, 'Visa', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 18, '5/23/2024', 70.84, 'Mastercard', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 43, '7/27/2024', 61.83, 'SinpeMovil', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 7, '6/21/2024', 87.22, 'PayPal', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 101, '5/15/2024', 67.43, 'Visa', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 92, '12/23/2024', 5.23, 'Visa', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 53, '3/22/2025', 39.1, 'Visa', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 48, '7/27/2023', 13.86, 'Efectivo', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 68, '11/5/2024', 68.51, 'Mastercard', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 38, '6/20/2023', 82.78, 'PayPal', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 126, '5/11/2023', 12.22, 'Visa', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 124, '1/6/2024', 6.25, 'SinpeMovil', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 78, '3/8/2025', 39.39, 'Efectivo', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 111, '7/19/2023', 75.46, 'Mastercard', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 63, '3/6/2024', 72.15, 'PayPal', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 107, '11/7/2024', 29.51, 'Visa', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 95, '12/13/2023', 14.93, 'Efectivo', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 130, '4/6/2025', 90.47, 'Visa', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 94, '8/20/2024', 59.44, 'Mastercard', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 89, '12/24/2023', 64.29, 'SinpeMovil', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 68, '10/27/2024', 27.25, 'SinpeMovil', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 18, '4/6/2025', 22.41, 'Visa', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 13, '5/4/2023', 58.06, 'Mastercard', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 112, '7/3/2023', 9.55, 'Mastercard', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 83, '1/8/2025', 96.21, 'Efectivo', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 86, '3/10/2024', 80.59, 'SinpeMovil', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 42, '2/13/2025', 98.9, 'Efectivo', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 86, '8/24/2023', 54.24, 'SinpeMovil', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 24, '9/8/2023', 32.07, 'SinpeMovil', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 43, '1/25/2025', 30.44, 'SinpeMovil', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 60, '9/4/2023', 49.47, 'PayPal', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 55, '6/16/2023', 52.08, 'SinpeMovil', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 81, '12/3/2024', 72.48, 'SinpeMovil', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 92, '3/14/2025', 37.32, 'PayPal', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 29, '11/14/2023', 26.91, 'Efectivo', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 121, '9/30/2023', 56.35, 'SinpeMovil', 'Pendiente');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 103, '2/16/2025', 46.47, 'Efectivo', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 124, '6/9/2023', 90.96, 'Visa', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 44, '5/16/2023', 79.66, 'Efectivo', 'Cancelado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 1, '10/6/2024', 59.95, 'Efectivo', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 81, '7/21/2024', 94.95, 'Efectivo', 'Pagado');
insert into T_Factura (ID_Factura, ID_Usuario, Fecha_Compra, Total, Metodo_Pago, Estado) values (seq_factura.NEXTVAL, 107, '7/23/2024', 93.4, 'SinpeMovil', 'Pendiente');


--Inserccion de datos en T_FacturaDetalles

insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 126, 15, 40, 39, 4.88, 8, 39.04);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 47, 44, 20, 28, 24.52, 13, 318.76);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 74, 159, 29, 4, 8.99, 11, 98.89);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 50, 43, 146, 18, 10.43, 2, 20.86);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 97, 150, 93, 16, 16.27, 2, 32.54);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 96, 101, 66, 22, 18.63, 5, 93.15);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 182, 106, 66, 2, 14.87, 12, 178.44);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 76, 135, 43, 30, 3.97, 9, 35.73);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 33, 7, 98, 14, 16.35, 5, 81.75);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 3, 91, 27, 42, 8.98, 11, 98.78);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 102, 58, 65, 15, 12.53, 6, 75.18);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 137, 106, 28, 45, 20.37, 13, 264.81);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 63, 142, 66, 23, 5.16, 15, 77.4);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 165, 81, 124, 14, 10.16, 11, 111.76);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 119, 21, 127, 2, 5.38, 4, 21.52);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 56, 87, 106, 11, 11.11, 8, 88.88);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 169, 76, 11, 4, 6.84, 13, 88.92);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 65, 125, 34, 3, 20.48, 10, 204.8);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 186, 22, 18, 14, 5.87, 14, 82.18);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 169, 64, 129, 8, 21.55, 3, 64.65);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 73, 106, 104, 10, 4.59, 6, 27.54);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 110, 3, 105, 45, 9.7, 8, 77.6);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 67, 121, 111, 37, 4.18, 10, 41.8);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 46, 25, 155, 24, 17.94, 11, 197.34);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 87, 164, 138, 19, 19.76, 8, 158.08);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 181, 8, 76, 3, 23.41, 10, 234.1);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 172, 34, 30, 11, 9.1, 11, 100.1);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 108, 68, 19, 20, 6.25, 14, 87.5);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 165, 24, 94, 28, 12.83, 8, 102.64);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 31, 127, 80, 28, 11.17, 10, 111.7);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 78, 55, 83, 26, 24.92, 12, 299.04);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 95, 18, 127, 25, 7.33, 2, 14.66);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 182, 125, 57, 44, 16.35, 11, 179.85);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 186, 38, 24, 44, 13.7, 9, 123.3);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 183, 91, 53, 6, 4.39, 3, 13.17);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 157, 36, 17, 38, 18.77, 2, 37.54);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 138, 121, 145, 20, 21.0, 15, 315.0);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 178, 30, 15, 4, 2.74, 5, 13.7);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 142, 160, 97, 13, 6.42, 3, 19.26);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 89, 31, 1, 34, 8.46, 3, 25.38);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 199, 97, 72, 35, 24.51, 7, 171.57);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 28, 29, 93, 30, 10.76, 9, 96.84);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 187, 18, 2, 44, 14.52, 3, 43.56);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 147, 110, 111, 8, 17.6, 14, 246.4);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 28, 78, 147, 11, 8.83, 3, 26.49);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 2, 130, 65, 38, 10.38, 15, 155.7);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 46, 85, 16, 40, 7.46, 14, 104.44);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 166, 30, 76, 50, 19.1, 1, 19.1);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 27, 108, 132, 37, 21.11, 15, 316.65);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 199, 133, 151, 37, 6.4, 5, 32.0);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 187, 64, 112, 31, 4.24, 11, 46.64);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 39, 43, 19, 26, 8.26, 6, 49.56);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 151, 11, 148, 48, 13.54, 8, 108.32);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 137, 13, 20, 11, 8.86, 1, 8.86);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 83, 151, 130, 25, 17.57, 7, 122.99);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 133, 52, 84, 23, 13.05, 9, 117.45);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 181, 125, 11, 5, 6.76, 4, 27.04);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 121, 5, 138, 5, 3.54, 14, 49.56);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 106, 117, 135, 11, 10.04, 8, 80.32);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 10, 170, 47, 2, 10.08, 6, 60.48);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 142, 70, 30, 18, 8.45, 14, 118.3);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 65, 138, 53, 50, 19.41, 13, 252.33);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 21, 105, 92, 8, 13.86, 10, 138.6);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 8, 132, 94, 7, 21.38, 9, 192.42);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 185, 90, 145, 49, 15.42, 4, 61.68);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 195, 69, 149, 44, 14.02, 6, 84.12);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 18, 15, 101, 40, 20.82, 2, 41.64);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 103, 114, 11, 49, 6.12, 4, 24.48);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 91, 109, 20, 25, 9.57, 1, 9.57);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 173, 32, 85, 4, 3.9, 4, 15.6);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 187, 168, 41, 5, 9.19, 14, 128.66);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 94, 41, 51, 48, 15.34, 9, 138.06);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 44, 11, 91, 31, 15.54, 3, 46.62);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 137, 102, 92, 37, 11.36, 13, 147.68);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 84, 148, 135, 4, 7.46, 14, 104.44);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 108, 66, 71, 46, 24.48, 2, 48.96);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 178, 112, 67, 24, 16.37, 1, 16.37);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 129, 165, 120, 5, 10.66, 9, 95.94);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 56, 127, 50, 2, 23.33, 5, 116.65);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 19, 56, 72, 31, 7.19, 14, 100.66);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 140, 55, 99, 34, 8.83, 7, 61.81);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 141, 40, 135, 46, 9.42, 13, 122.46);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 20, 38, 107, 20, 18.27, 14, 255.78);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 158, 51, 94, 9, 6.43, 10, 64.3);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 91, 156, 60, 18, 23.48, 7, 164.36);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 186, 75, 86, 13, 21.05, 10, 210.5);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 187, 123, 109, 20, 12.79, 7, 89.53);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 24, 69, 104, 12, 23.23, 12, 278.76);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 19, 110, 36, 15, 16.81, 12, 201.72);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 105, 47, 11, 16, 18.03, 3, 54.09);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 129, 87, 41, 47, 7.09, 8, 56.72);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 185, 51, 7, 1, 23.17, 9, 208.53);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 65, 18, 69, 3, 12.69, 6, 76.14);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 11, 90, 104, 7, 5.32, 4, 21.28);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 193, 96, 109, 46, 5.04, 4, 20.16);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 83, 117, 76, 29, 5.91, 10, 59.1);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 73, 62, 125, 49, 20.31, 14, 284.34);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 131, 32, 90, 44, 3.44, 4, 13.76);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 134, 128, 88, 25, 21.78, 7, 152.46);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 143, 166, 126, 42, 2.47, 3, 7.41);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 199, 12, 56, 9, 3.8, 5, 19.0);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 15, 62, 134, 33, 15.19, 6, 91.14);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 70, 63, 8, 24, 14.95, 3, 44.85);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 4, 29, 80, 41, 18.21, 5, 91.05);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 181, 76, 141, 10, 16.03, 12, 192.36);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 75, 154, 147, 10, 12.66, 7, 88.62);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 125, 61, 91, 9, 6.46, 14, 90.44);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 108, 7, 6, 25, 8.68, 6, 52.08);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 23, 147, 84, 29, 23.27, 5, 116.35);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 79, 160, 72, 50, 6.05, 9, 54.45);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 101, 35, 70, 49, 23.45, 6, 140.7);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 193, 164, 7, 35, 10.12, 11, 111.32);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 88, 157, 68, 4, 3.31, 8, 26.48);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 1, 74, 77, 45, 5.25, 8, 42.0);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 174, 96, 117, 29, 2.14, 9, 19.26);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 154, 55, 21, 45, 2.08, 15, 31.2);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 102, 128, 112, 42, 6.43, 1, 6.43);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 171, 132, 79, 20, 23.88, 7, 167.16);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 160, 52, 129, 9, 17.53, 5, 87.65);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 102, 47, 96, 47, 2.05, 5, 10.25);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 156, 146, 94, 13, 11.61, 7, 81.27);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 9, 51, 30, 19, 13.59, 8, 108.72);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 71, 37, 87, 17, 17.62, 8, 140.96);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 36, 105, 71, 49, 7.95, 5, 39.75);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 132, 152, 93, 36, 5.52, 11, 60.72);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 154, 53, 32, 9, 12.48, 14, 174.72);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 151, 134, 157, 48, 14.33, 6, 85.98);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 28, 40, 120, 34, 3.56, 10, 35.6);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 65, 134, 66, 24, 20.81, 6, 124.86);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 26, 96, 118, 30, 3.17, 5, 15.85);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 178, 11, 32, 46, 23.22, 13, 301.86);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 116, 158, 80, 11, 13.63, 8, 109.04);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 184, 18, 36, 16, 15.97, 2, 31.94);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 177, 75, 138, 14, 16.8, 9, 151.2);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 19, 114, 23, 24, 17.79, 8, 142.32);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 28, 64, 139, 33, 5.53, 13, 71.89);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 5, 82, 49, 38, 15.68, 2, 31.36);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 149, 143, 119, 29, 23.2, 4, 92.8);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 71, 82, 7, 35, 21.93, 5, 109.65);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 167, 132, 30, 22, 23.53, 10, 235.3);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 51, 35, 113, 45, 8.0, 3, 24.0);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 86, 15, 54, 43, 19.13, 8, 153.04);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 22, 38, 73, 8, 2.78, 4, 11.12);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 119, 89, 23, 38, 2.41, 1, 2.41);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 134, 122, 129, 43, 7.28, 14, 101.92);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 107, 18, 5, 20, 3.31, 5, 16.55);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 37, 10, 81, 43, 13.65, 14, 191.1);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 174, 12, 23, 26, 23.11, 3, 69.33);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 132, 150, 132, 13, 14.03, 15, 210.45);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 55, 74, 23, 28, 11.44, 8, 91.52);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 138, 170, 118, 25, 15.81, 15, 237.15);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 159, 89, 92, 46, 23.52, 4, 94.08);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 27, 98, 159, 33, 20.28, 1, 20.28);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 30, 41, 61, 5, 16.96, 14, 237.44);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 118, 90, 159, 50, 9.92, 10, 99.2);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 131, 25, 40, 39, 5.53, 2, 11.06);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 170, 138, 132, 3, 21.82, 3, 65.46);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 174, 123, 143, 35, 5.15, 13, 66.95);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 61, 34, 47, 17, 15.31, 4, 61.24);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 139, 44, 67, 40, 7.83, 6, 46.98);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 153, 29, 115, 27, 4.81, 13, 62.53);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 23, 166, 6, 37, 8.17, 4, 32.68);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 2, 139, 147, 29, 14.91, 6, 89.46);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 120, 6, 40, 4, 5.23, 8, 41.84);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 47, 30, 146, 20, 16.89, 12, 202.68);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 160, 112, 126, 13, 9.85, 1, 9.85);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 147, 60, 28, 6, 17.24, 9, 155.16);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 47, 142, 104, 41, 13.96, 1, 13.96);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 116, 18, 126, 28, 14.54, 9, 130.86);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 140, 110, 155, 47, 8.38, 2, 16.76);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 53, 5, 27, 47, 8.89, 8, 71.12);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 70, 6, 63, 46, 24.32, 13, 316.16);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 7, 135, 59, 10, 20.75, 10, 207.5);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 117, 7, 95, 34, 15.91, 13, 206.83);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 138, 78, 6, 43, 7.47, 4, 29.88);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 146, 12, 20, 45, 9.08, 6, 54.48);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 170, 28, 75, 49, 14.03, 1, 14.03);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 116, 9, 20, 24, 21.93, 11, 241.23);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 181, 157, 66, 20, 9.81, 14, 137.34);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 123, 168, 35, 24, 20.51, 2, 41.02);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 139, 17, 44, 2, 21.58, 2, 43.16);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 50, 49, 22, 31, 22.42, 8, 179.36);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 192, 79, 139, 19, 8.46, 1, 8.46);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 174, 31, 94, 27, 21.74, 12, 260.88);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 152, 93, 15, 25, 4.85, 7, 33.95);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 176, 134, 11, 47, 6.34, 12, 76.08);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 68, 159, 25, 16, 23.38, 10, 233.8);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 14, 106, 52, 49, 17.11, 15, 256.65);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 172, 77, 53, 25, 13.57, 10, 135.7);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 9, 91, 59, 30, 8.25, 15, 123.75);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 19, 125, 87, 48, 17.26, 10, 172.6);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 139, 120, 2, 28, 24.17, 14, 338.38);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 174, 56, 99, 23, 4.1, 15, 61.5);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 149, 168, 63, 38, 13.31, 5, 66.55);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 142, 154, 39, 17, 8.33, 9, 74.97);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 123, 153, 66, 48, 3.61, 9, 32.49);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 198, 30, 31, 12, 3.1, 3, 9.3);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 32, 87, 95, 1, 3.95, 15, 59.25);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 198, 14, 102, 17, 3.28, 2, 6.56);
insert into T_FacturaDetalles (ID_FacturaDetalle, ID_Factura, ID_Cancion, ID_Episodio, ID_Podcast, Precio_Unitario, Cantidad, Subtotal) values (seq_facturadet.NEXTVAL, 30, 65, 57, 21, 15.68, 3, 47.04);


--Inserccion de datos en T_Comentarios

insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 98, 143, 151, 2, 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', '3/1/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 92, 94, 47, 5, 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', '12/12/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 16, 138, 158, 5, 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', '11/11/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 35, 119, 8, 4, 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', '12/27/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 3, 5, 111, 3, 'Phasellus in felis. Donec semper sapien a libero. Nam dui.', '6/13/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 66, 148, 5, 4, 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', '2/27/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 21, 160, 128, 1, 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.', '4/19/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 92, 140, 83, 1, 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', '10/9/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 8, 16, 21, 2, 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', '2/21/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 78, 148, 87, 2, 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '11/4/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 30, 96, 152, 4, 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', '9/2/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 37, 133, 28, 4, 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', '7/26/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 81, 86, 17, 1, 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', '7/30/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 77, 3, 9, 2, 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', '9/16/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 25, 43, 5, 5, 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', '3/26/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 50, 99, 52, 1, 'In congue. Etiam justo. Etiam pretium iaculis justo.', '8/10/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 97, 166, 146, 4, 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', '10/14/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 82, 44, 122, 1, 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', '10/18/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 75, 165, 16, 2, 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', '8/21/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 32, 168, 55, 2, 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', '1/3/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 54, 156, 84, 3, 'Sed ante. Vivamus tortor. Duis mattis egestas metus.', '9/28/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 25, 46, 77, 3, 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', '12/23/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 84, 71, 109, 5, 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', '5/19/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 20, 153, 139, 1, 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', '10/2/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 43, 153, 120, 5, 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', '5/28/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 22, 46, 159, 5, 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', '1/14/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 70, 92, 82, 4, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', '4/17/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 71, 123, 20, 3, 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', '3/19/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 19, 1, 64, 4, 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', '8/25/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 90, 100, 86, 5, 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', '4/2/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 11, 100, 74, 2, 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', '6/15/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 91, 163, 154, 2, 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', '4/28/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 51, 105, 160, 4, 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', '7/6/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 96, 143, 52, 4, 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', '9/12/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 25, 33, 133, 2, 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', '12/29/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 79, 106, 49, 4, 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', '12/7/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 27, 23, 109, 2, 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', '7/30/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 48, 133, 38, 2, 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', '11/23/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 29, 150, 16, 5, 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', '6/8/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 32, 156, 53, 2, 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', '9/5/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 62, 152, 43, 1, 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', '2/7/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 73, 143, 155, 2, 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', '5/24/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 27, 163, 86, 3, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', '10/3/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 49, 169, 64, 3, 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', '6/11/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 29, 12, 99, 5, 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', '3/4/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 64, 108, 102, 3, 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', '8/13/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 64, 144, 75, 1, 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.', '12/1/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 82, 115, 125, 5, 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', '4/17/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 32, 94, 137, 4, 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', '2/4/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 73, 67, 62, 5, 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', '9/8/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 56, 98, 54, 2, 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', '7/3/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 51, 76, 28, 1, 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', '2/25/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 56, 88, 138, 2, 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.', '2/6/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 95, 95, 78, 2, 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', '1/26/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 40, 105, 104, 2, 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.', '11/16/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 51, 153, 12, 2, 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', '10/20/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 69, 39, 110, 1, 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', '5/20/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 74, 35, 45, 4, 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', '6/1/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 96, 6, 86, 3, 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', '6/28/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 83, 63, 50, 4, 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', '9/9/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 36, 112, 134, 4, 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.', '8/27/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 2, 41, 107, 3, 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '7/25/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 29, 96, 2, 3, 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', '5/27/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 84, 23, 27, 4, 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', '9/23/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 37, 105, 36, 1, 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.', '6/3/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 18, 63, 139, 4, 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', '12/6/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 84, 152, 81, 4, 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', '6/3/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 25, 141, 99, 4, 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', '4/2/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 75, 7, 149, 2, 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', '7/11/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 82, 109, 103, 2, 'In congue. Etiam justo. Etiam pretium iaculis justo.', '6/8/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 64, 17, 44, 3, 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.', '3/19/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 55, 57, 126, 1, 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', '12/9/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 65, 80, 30, 3, 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', '5/5/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 53, 32, 95, 4, 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', '6/19/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 8, 92, 73, 4, 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', '9/29/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 71, 116, 99, 4, 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', '10/19/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 4, 12, 144, 3, 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', '8/11/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 28, 88, 118, 2, 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', '4/20/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 52, 17, 107, 4, 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', '11/14/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 58, 159, 122, 3, 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', '3/25/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 50, 125, 75, 3, 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', '3/10/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 67, 109, 117, 2, 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', '8/21/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 75, 125, 137, 2, 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', '8/22/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 25, 37, 56, 5, 'Fusce consequat. Nulla nisl. Nunc nisl.', '5/19/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 98, 89, 153, 5, 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', '10/18/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 43, 144, 80, 4, 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', '4/29/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 25, 10, 3, 5, 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', '1/11/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 51, 39, 38, 5, 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.', '7/20/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 79, 42, 134, 3, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', '2/20/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 48, 141, 25, 2, 'Phasellus in felis. Donec semper sapien a libero. Nam dui.', '7/26/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 25, 74, 158, 3, 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', '2/1/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 58, 121, 138, 2, 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', '5/21/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 29, 42, 46, 3, 'Fusce consequat. Nulla nisl. Nunc nisl.', '6/13/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 19, 16, 22, 1, 'Sed ante. Vivamus tortor. Duis mattis egestas metus.', '10/2/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 27, 105, 131, 2, 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', '5/4/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 34, 158, 6, 5, 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', '12/3/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 62, 158, 90, 2, 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', '11/12/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 9, 159, 46, 4, 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', '7/27/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 46, 25, 91, 5, 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', '8/29/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 11, 163, 143, 2, 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', '12/2/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 7, 161, 17, 1, 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', '1/24/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 77, 166, 15, 2, 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', '8/26/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 72, 87, 52, 2, 'Phasellus in felis. Donec semper sapien a libero. Nam dui.', '8/10/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 56, 142, 159, 4, 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', '3/19/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 17, 29, 92, 3, 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', '7/14/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 3, 137, 57, 4, 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.', '3/3/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 55, 61, 103, 1, 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', '1/18/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 31, 127, 153, 3, 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', '11/24/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 5, 99, 57, 5, 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', '2/5/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 17, 107, 153, 5, 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '5/11/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 42, 160, 92, 5, 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', '8/31/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 31, 87, 158, 4, 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', '6/17/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 25, 146, 53, 2, 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', '7/11/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 45, 159, 124, 5, 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.', '8/8/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 49, 123, 74, 4, 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', '12/15/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 98, 119, 108, 5, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', '7/29/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 24, 132, 42, 4, 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', '12/31/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 11, 47, 32, 1, 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', '5/24/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 82, 75, 47, 5, 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', '6/25/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 87, 156, 120, 4, 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', '2/25/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 49, 121, 32, 4, 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', '1/7/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 86, 22, 103, 1, 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', '4/28/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 55, 35, 140, 3, 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', '9/10/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 65, 18, 149, 1, 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', '5/18/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 57, 145, 128, 1, 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', '11/27/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 69, 67, 80, 2, 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', '10/27/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 13, 123, 56, 2, 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.', '10/19/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 94, 75, 135, 4, 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', '7/12/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 71, 126, 14, 1, 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', '4/12/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 38, 84, 144, 1, 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', '9/13/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 12, 58, 123, 2, 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', '9/28/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 92, 137, 131, 5, 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', '11/7/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 9, 26, 53, 2, 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', '2/20/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 70, 66, 77, 4, 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', '5/4/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 82, 80, 144, 4, 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', '10/26/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 56, 86, 51, 3, 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.', '2/19/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 95, 72, 150, 3, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', '4/29/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 19, 75, 63, 5, 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', '9/3/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 81, 3, 136, 5, 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '3/28/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 19, 136, 80, 2, 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', '7/15/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 91, 107, 94, 3, 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', '4/14/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 48, 105, 29, 4, 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', '7/27/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 83, 148, 78, 2, 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', '3/14/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 79, 43, 35, 5, 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', '10/26/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 57, 126, 79, 3, 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', '2/7/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 75, 163, 137, 5, 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', '6/11/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 86, 137, 10, 4, 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', '6/19/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 3, 94, 124, 3, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', '3/11/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 98, 145, 5, 3, 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.', '9/11/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 37, 147, 16, 1, 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', '6/6/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 77, 65, 62, 5, 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', '12/27/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 94, 84, 129, 4, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', '1/5/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 49, 87, 33, 2, 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', '6/24/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 70, 14, 63, 1, 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', '10/1/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 50, 78, 50, 3, 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', '5/5/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 68, 97, 146, 1, 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', '11/8/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 33, 119, 86, 3, 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', '5/29/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 18, 38, 125, 5, 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.', '1/13/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 60, 141, 61, 5, 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '12/19/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 81, 108, 52, 1, 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', '4/21/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 73, 147, 69, 1, 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', '4/24/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 33, 70, 133, 2, 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', '11/15/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 71, 143, 49, 2, 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', '4/28/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 78, 87, 87, 5, 'In congue. Etiam justo. Etiam pretium iaculis justo.', '12/17/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 50, 120, 125, 3, 'Phasellus in felis. Donec semper sapien a libero. Nam dui.', '11/19/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 11, 32, 121, 1, 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', '1/15/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 14, 49, 44, 5, 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', '11/2/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 43, 56, 125, 4, 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', '9/9/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 22, 137, 117, 3, 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.', '7/10/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 7, 113, 105, 4, 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', '6/9/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 25, 56, 130, 1, 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', '2/26/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 47, 143, 71, 5, 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', '3/26/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 14, 69, 144, 1, 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', '4/26/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 77, 77, 81, 3, 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', '4/28/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 50, 137, 7, 3, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', '6/12/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 77, 105, 111, 4, 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.', '10/1/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 6, 106, 82, 1, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', '2/1/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 61, 33, 83, 5, 'Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', '12/25/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 3, 27, 124, 3, 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.', '6/17/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 49, 61, 26, 4, 'Sed ante. Vivamus tortor. Duis mattis egestas metus.', '3/1/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 46, 3, 141, 3, 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', '10/11/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 95, 75, 36, 3, 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', '1/28/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 26, 142, 121, 5, 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', '10/9/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 40, 143, 105, 4, 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', '7/7/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 51, 108, 150, 1, 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', '8/13/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 78, 158, 45, 5, 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', '3/2/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 55, 80, 97, 1, 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '5/25/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 67, 146, 93, 4, 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', '2/11/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 55, 58, 51, 3, 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', '4/26/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 48, 102, 138, 2, 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', '9/16/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 74, 33, 63, 1, 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', '3/1/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 20, 70, 70, 3, 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', '8/27/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 66, 77, 136, 4, 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', '5/15/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 100, 88, 109, 1, 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', '2/16/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 29, 8, 115, 5, 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', '10/31/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 12, 107, 141, 4, 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', '8/1/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 88, 38, 8, 2, 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.', '8/30/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 43, 10, 90, 4, 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', '7/15/2024');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 6, 86, 158, 2, 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', '2/16/2025');
insert into T_Comentarios (ID_Comentario, ID_Usuario, ID_Cancion, ID_Episodio, Calificacion, Comentario, Fecha_Comentario) values (seq_comentario.NEXTVAL, 38, 36, 79, 1, 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', '4/14/2024');

