
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
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------CREACION DE TABLAS -------------------------------------------------------------------------------------------
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
/
-- Tabla de Géneros
CREATE TABLE T_Generos (
  ID_Genero NUMBER PRIMARY KEY,
  Nombre_Genero VARCHAR2(100)
);
/
-- Tabla de Artistas
CREATE TABLE T_Artistas (
  ID_Artista NUMBER PRIMARY KEY,
  Nombre VARCHAR2(100),
  Nombre_Artistico VARCHAR2(100),
  Biografica VARCHAR2(1000)
);
/
-- Tabla de Álbumes
CREATE TABLE T_Albumes (
  ID_Album NUMBER PRIMARY KEY,
  ID_Artista NUMBER,
  Titulo VARCHAR2(150),
  Fecha_Lanzamiento DATE,
  URL VARCHAR2(255),
  Precio NUMBER(10,2),
  FOREIGN KEY (ID_Artista) REFERENCES T_Artistas(ID_Artista)
);
/
-- Tabla de Canciones
CREATE TABLE T_Canciones (
  ID_Cancion NUMBER PRIMARY KEY,
  ID_Album NUMBER,
  Titulo VARCHAR2(150),
  Duracion NUMBER(5,2),
  Precio NUMBER(10,2),
  ID_Artista NUMBER,
  FOREIGN KEY (ID_Album) REFERENCES T_Albumes(ID_Album),
  FOREIGN KEY (ID_Artista) REFERENCES T_Artistas(ID_Artista)
);
/
-- Tabla de Podcasts
CREATE TABLE T_Podcasts (
  ID_Podcast NUMBER PRIMARY KEY,
  ID_Artista NUMBER,
  Titulo VARCHAR2(150),
  Descripcion CLOB,
  URL VARCHAR2(255),
  Precio NUMBER(10,2),
  FOREIGN KEY (ID_Artista) REFERENCES T_Artistas(ID_Artista)
);
/
-- Tabla de Episodios
CREATE TABLE T_Episodios (
  ID_Episodio NUMBER PRIMARY KEY,
  ID_Podcast NUMBER,
  ID_Artista NUMBER,
  Duracion NUMBER(5,2),
  Precio NUMBER(10,2),
  URL VARCHAR2(255),
  Titulo VARCHAR2(150),
  FOREIGN KEY (ID_Podcast) REFERENCES T_Podcasts(ID_Podcast),
  FOREIGN KEY (ID_Artista) REFERENCES T_Artistas(ID_Artista)
);
/
-- Tablas intermedias con generos
CREATE TABLE T_Albumes_Generos (
  ID_Album NUMBER,
  ID_Genero NUMBER,
  PRIMARY KEY (ID_Album, ID_Genero),
  FOREIGN KEY (ID_Album) REFERENCES T_Albumes(ID_Album),
  FOREIGN KEY (ID_Genero) REFERENCES T_Generos(ID_Genero)
);
/
CREATE TABLE T_Canciones_Generos (
  ID_Cancion NUMBER,
  ID_Genero NUMBER,
  PRIMARY KEY (ID_Cancion, ID_Genero),
  FOREIGN KEY (ID_Cancion) REFERENCES T_Canciones(ID_Cancion),
  FOREIGN KEY (ID_Genero) REFERENCES T_Generos(ID_Genero)
);
/
CREATE TABLE T_Episodios_Generos (
  ID_Episodio NUMBER,
  ID_Genero NUMBER,
  PRIMARY KEY (ID_Episodio, ID_Genero),
  FOREIGN KEY (ID_Episodio) REFERENCES T_Episodios(ID_Episodio),
  FOREIGN KEY (ID_Genero) REFERENCES T_Generos(ID_Genero)
);
/
CREATE TABLE T_Podcast_Generos (
  ID_Podcast NUMBER,
  ID_Genero NUMBER,
  PRIMARY KEY (ID_Podcast, ID_Genero),
  FOREIGN KEY (ID_Podcast) REFERENCES T_Podcasts(ID_Podcast),
  FOREIGN KEY (ID_Genero) REFERENCES T_Generos(ID_Genero)
);
/
-- Tabla de Usuarios
CREATE TABLE T_Usuarios (
  ID_Usuario NUMBER PRIMARY KEY,
  Nombre VARCHAR2(100),
  Email VARCHAR2(100) UNIQUE,
  Contrasena VARCHAR2(100),
  Telefono VARCHAR2(20),
  Fecha_Registro DATE
);
/
-- Tabla de Facturas
CREATE TABLE T_Factura (
  ID_Factura NUMBER PRIMARY KEY,
  ID_Usuario NUMBER,
  Fecha_Compra DATE,
  Total NUMBER(10,2),
  Metodo_Pago VARCHAR2(50),
  Estado VARCHAR2(20),
  FOREIGN KEY (ID_Usuario) REFERENCES T_Usuarios(ID_Usuario)
);
/
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
  FOREIGN KEY (ID_Factura) REFERENCES T_Factura(ID_Factura),
  FOREIGN KEY (ID_Cancion) REFERENCES T_Canciones(ID_Cancion),
  FOREIGN KEY (ID_Episodio) REFERENCES T_Episodios(ID_Episodio),
  FOREIGN KEY (ID_Podcast) REFERENCES T_Podcasts(ID_Podcast),
  FOREIGN KEY (ID_Album) REFERENCES T_Albumes(ID_Album)
);
/
-- Tabla de Comentarios
CREATE TABLE T_Comentarios (
  ID_Comentario NUMBER PRIMARY KEY,
  ID_Usuario NUMBER,
  ID_Cancion NUMBER,
  ID_Episodio NUMBER,
  Calificacion NUMBER(1), -- del 1 al 5
  Comentario VARCHAR2(500),
  Fecha_Comentario DATE,
  FOREIGN KEY (ID_Usuario) REFERENCES T_Usuarios(ID_Usuario),
  FOREIGN KEY (ID_Cancion) REFERENCES T_Canciones(ID_Cancion),
  FOREIGN KEY (ID_Episodio) REFERENCES T_Episodios(ID_Episodio)
);
/
/*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------Procedimientos Almacenados------------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------Insercion de datos--------------------------------------------------------------------------------------------
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







