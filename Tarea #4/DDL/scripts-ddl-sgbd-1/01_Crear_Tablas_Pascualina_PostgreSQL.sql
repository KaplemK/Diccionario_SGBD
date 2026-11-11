-- =====================================================================
-- Red Social Estudiantil Pascualina - Modelo físico (DDL)
-- SGBD: PostgreSQL
-- Integrantes: Emanuel Ortiz y Saray Muñoz
-- Nomenclatura: minúsculas, snake_case, tablas en singular,
--   pk_  = clave primaria, fk_ = clave foránea,
--   uq_  = restricción única, ck_ = restricción de chequeo.
-- Orden de creación: primero las tablas padre, luego las hijas.
-- =====================================================================

-- =====================================================================
-- PARTE 1 - EMANUEL ORTIZ
-- Módulo: usuarios, perfiles, habilidades, intereses y seguimientos
-- =====================================================================

CREATE TABLE usuario (
    id_usuario        INTEGER GENERATED ALWAYS AS IDENTITY,
    nombre_usuario    VARCHAR(30)  NOT NULL,
    correo            VARCHAR(100) NOT NULL,
    contrasena_hash   VARCHAR(255) NOT NULL,
    nombres           VARCHAR(60)  NOT NULL,
    apellidos         VARCHAR(60)  NOT NULL,
    area_estudio      VARCHAR(80),
    semestre          SMALLINT,
    biografia         TEXT,
    fecha_registro    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_usuario         PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_nombre  UNIQUE (nombre_usuario),
    CONSTRAINT uq_usuario_correo  UNIQUE (correo),
    CONSTRAINT ck_usuario_semestre CHECK (semestre IS NULL OR semestre BETWEEN 1 AND 12)
);

CREATE TABLE habilidad (
    id_habilidad      INTEGER GENERATED ALWAYS AS IDENTITY,
    nombre_habilidad  VARCHAR(60)  NOT NULL,
    descripcion       VARCHAR(200),
    CONSTRAINT pk_habilidad        PRIMARY KEY (id_habilidad),
    CONSTRAINT uq_habilidad_nombre UNIQUE (nombre_habilidad)
);

CREATE TABLE interes (
    id_interes        INTEGER GENERATED ALWAYS AS IDENTITY,
    nombre_interes    VARCHAR(60)  NOT NULL,
    CONSTRAINT pk_interes        PRIMARY KEY (id_interes),
    CONSTRAINT uq_interes_nombre UNIQUE (nombre_interes)
);

CREATE TABLE usuario_habilidad (
    id_usuario        INTEGER      NOT NULL,
    id_habilidad      INTEGER      NOT NULL,
    nivel             VARCHAR(15)  NOT NULL DEFAULT 'basico',
    CONSTRAINT pk_usuario_habilidad PRIMARY KEY (id_usuario, id_habilidad),
    CONSTRAINT fk_usuhab_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_usuhab_habilidad FOREIGN KEY (id_habilidad)
        REFERENCES habilidad (id_habilidad) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_usuhab_nivel CHECK (nivel IN ('basico', 'intermedio', 'avanzado'))
);

CREATE TABLE usuario_interes (
    id_usuario        INTEGER      NOT NULL,
    id_interes        INTEGER      NOT NULL,
    CONSTRAINT pk_usuario_interes PRIMARY KEY (id_usuario, id_interes),
    CONSTRAINT fk_usuint_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_usuint_interes FOREIGN KEY (id_interes)
        REFERENCES interes (id_interes) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE seguimiento (
    id_seguidor        INTEGER   NOT NULL,
    id_seguido         INTEGER   NOT NULL,
    fecha_seguimiento  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_seguimiento PRIMARY KEY (id_seguidor, id_seguido),
    CONSTRAINT fk_seguimiento_seguidor FOREIGN KEY (id_seguidor)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_seguimiento_seguido FOREIGN KEY (id_seguido)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_seguimiento_no_propio CHECK (id_seguidor <> id_seguido)
);

-- =====================================================================
-- PARTE 2 - SARAY MUÑOZ
-- Módulo: grupos, membresías, publicaciones y eventos
-- (depende de la tabla usuario de la Parte 1)
-- =====================================================================

CREATE TABLE grupo (
    id_grupo          INTEGER GENERATED ALWAYS AS IDENTITY,
    id_creador        INTEGER      NOT NULL,
    nombre_grupo      VARCHAR(80)  NOT NULL,
    descripcion       TEXT,
    tipo_grupo        VARCHAR(20)  NOT NULL,
    fecha_creacion    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_grupo        PRIMARY KEY (id_grupo),
    CONSTRAINT uq_grupo_nombre UNIQUE (nombre_grupo),
    CONSTRAINT fk_grupo_creador FOREIGN KEY (id_creador)
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_grupo_tipo CHECK (tipo_grupo IN ('estudio', 'hackaton', 'club'))
);

CREATE TABLE miembro_grupo (
    id_grupo          INTEGER      NOT NULL,
    id_usuario        INTEGER      NOT NULL,
    rol               VARCHAR(15)  NOT NULL DEFAULT 'miembro',
    fecha_ingreso     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_miembro_grupo PRIMARY KEY (id_grupo, id_usuario),
    CONSTRAINT fk_miembro_grupo FOREIGN KEY (id_grupo)
        REFERENCES grupo (id_grupo) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_miembro_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_miembro_rol CHECK (rol IN ('admin', 'miembro'))
);

CREATE TABLE publicacion (
    id_publicacion INTEGER GENERATED ALWAYS AS IDENTITY,
    id_usuario INTEGER NOT NULL,
    id_grupo INTEGER,
    contenido TEXT NOT NULL,
    tipo_publicacion VARCHAR(20) NOT NULL DEFAULT 'general',
    fecha_publicacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metadatos JSONB,

    CONSTRAINT pk_publicacion
        PRIMARY KEY (id_publicacion),

    CONSTRAINT fk_publicacion_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
        ON DELETE CASCADE,

    CONSTRAINT fk_publicacion_grupo
        FOREIGN KEY (id_grupo)
        REFERENCES grupo (id_grupo)
        ON DELETE CASCADE,

    CONSTRAINT ck_publicacion_tipo
        CHECK (tipo_publicacion IN ('general', 'pregunta', 'recurso', 'noticia'))
);
CREATE TABLE evento (
    id_evento         INTEGER GENERATED ALWAYS AS IDENTITY,
    id_organizador    INTEGER      NOT NULL,
    id_grupo          INTEGER,
    titulo            VARCHAR(100) NOT NULL,
    descripcion       TEXT,
    lugar             VARCHAR(100),
    fecha_inicio      TIMESTAMP    NOT NULL,
    fecha_fin         TIMESTAMP,
    tipo_evento       VARCHAR(20)  NOT NULL,
    CONSTRAINT pk_evento PRIMARY KEY (id_evento),
    CONSTRAINT fk_evento_organizador FOREIGN KEY (id_organizador)
        REFERENCES usuario (id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_evento_grupo FOREIGN KEY (id_grupo)
        REFERENCES grupo (id_grupo) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT ck_evento_tipo CHECK (tipo_evento IN ('estudio', 'taller', 'social')),
    CONSTRAINT ck_evento_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);

CREATE TABLE asistencia_evento (
    id_evento         INTEGER      NOT NULL,
    id_usuario        INTEGER      NOT NULL,
    estado            VARCHAR(15)  NOT NULL DEFAULT 'confirmado',
    CONSTRAINT pk_asistencia_evento PRIMARY KEY (id_evento, id_usuario),
    CONSTRAINT fk_asistencia_evento FOREIGN KEY (id_evento)
        REFERENCES evento (id_evento) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_asistencia_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_asistencia_estado CHECK (estado IN ('confirmado', 'tal_vez', 'cancelado'))
);
