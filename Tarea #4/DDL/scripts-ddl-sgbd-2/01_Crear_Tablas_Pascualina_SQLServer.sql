CREATE TABLE usuario (
    id_usuario INT IDENTITY(1,1) NOT NULL,
    nombre_usuario VARCHAR(30) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    contrasena_hash VARCHAR(255) NOT NULL,
    nombres VARCHAR(60) NOT NULL,
    apellidos VARCHAR(60) NOT NULL,
    area_estudio VARCHAR(80) NULL,
    semestre SMALLINT NULL,
    biografia VARCHAR(MAX) NULL,
    fecha_registro DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT UQ_usuario_nombre UNIQUE (nombre_usuario),
    CONSTRAINT UQ_usuario_correo UNIQUE (correo),
    CONSTRAINT CK_usuario_semestre
        CHECK (semestre IS NULL OR semestre BETWEEN 1 AND 12)
);

CREATE TABLE habilidad (
    id_habilidad INT IDENTITY(1,1) NOT NULL,
    nombre_habilidad VARCHAR(60) NOT NULL,
    descripcion VARCHAR(200) NULL,

    CONSTRAINT PK_habilidad PRIMARY KEY (id_habilidad),
    CONSTRAINT UQ_habilidad_nombre UNIQUE (nombre_habilidad)
);

CREATE TABLE interes (
    id_interes INT IDENTITY(1,1) NOT NULL,
    nombre_interes VARCHAR(60) NOT NULL,

    CONSTRAINT PK_interes PRIMARY KEY (id_interes),
    CONSTRAINT UQ_interes_nombre UNIQUE (nombre_interes)
);


CREATE TABLE usuario_habilidad (
    id_usuario INT NOT NULL,
    id_habilidad INT NOT NULL,
    nivel VARCHAR(15) NOT NULL DEFAULT 'basico',

    CONSTRAINT PK_usuario_habilidad
        PRIMARY KEY (id_usuario, id_habilidad),

    CONSTRAINT FK_usuario_habilidad_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),

    CONSTRAINT FK_usuario_habilidad_habilidad
        FOREIGN KEY (id_habilidad) REFERENCES habilidad(id_habilidad),

    CONSTRAINT CK_usuario_habilidad_nivel
        CHECK (nivel IN ('basico', 'intermedio', 'avanzado'))
);


CREATE TABLE usuario_interes (
    id_usuario INT NOT NULL,
    id_interes INT NOT NULL,

    CONSTRAINT PK_usuario_interes
        PRIMARY KEY (id_usuario, id_interes),

    CONSTRAINT FK_usuario_interes_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),

    CONSTRAINT FK_usuario_interes_interes
        FOREIGN KEY (id_interes) REFERENCES interes(id_interes)
);


CREATE TABLE seguimiento (
    id_seguidor INT NOT NULL,
    id_seguido INT NOT NULL,
    fecha_seguimiento DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_seguimiento
        PRIMARY KEY (id_seguidor, id_seguido),

    CONSTRAINT FK_seguimiento_seguidor
        FOREIGN KEY (id_seguidor) REFERENCES usuario(id_usuario),

    CONSTRAINT FK_seguimiento_seguido
        FOREIGN KEY (id_seguido) REFERENCES usuario(id_usuario),

    CONSTRAINT CK_seguimiento_no_autoseguimiento
        CHECK (id_seguidor <> id_seguido)
);

CREATE TABLE grupo (
    id_grupo INT IDENTITY(1,1) NOT NULL,
    id_creador INT NOT NULL,
    nombre_grupo VARCHAR(80) NOT NULL,
    descripcion VARCHAR(MAX) NULL,
    tipo_grupo VARCHAR(20) NOT NULL,
    fecha_creacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_grupo PRIMARY KEY (id_grupo),
    CONSTRAINT UQ_grupo_nombre UNIQUE (nombre_grupo),

    CONSTRAINT FK_grupo_usuario
        FOREIGN KEY (id_creador) REFERENCES usuario(id_usuario),

    CONSTRAINT CK_grupo_tipo
        CHECK (tipo_grupo IN ('estudio', 'hackaton', 'club'))
);


CREATE TABLE miembro_grupo (
    id_grupo INT NOT NULL,
    id_usuario INT NOT NULL,
    rol VARCHAR(15) NOT NULL DEFAULT 'miembro',
    fecha_ingreso DATETIME2 NOT NULL DEFAULT SYSDATETIME(),

    CONSTRAINT PK_miembro_grupo
        PRIMARY KEY (id_grupo, id_usuario),

    CONSTRAINT FK_miembro_grupo_grupo
        FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo),

    CONSTRAINT FK_miembro_grupo_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),

    CONSTRAINT CK_miembro_grupo_rol
        CHECK (rol IN ('admin', 'miembro'))
);

CREATE TABLE publicacion (
    id_publicacion INT IDENTITY(1,1) NOT NULL,
    id_usuario INT NOT NULL,
    id_grupo INT NULL,
    contenido VARCHAR(MAX) NOT NULL,
    tipo_publicacion VARCHAR(20) NOT NULL DEFAULT 'general',
    fecha_publicacion DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    metadatos NVARCHAR(MAX) NULL,

    CONSTRAINT PK_publicacion PRIMARY KEY (id_publicacion),

    CONSTRAINT FK_publicacion_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
        ON DELETE CASCADE,

    CONSTRAINT FK_publicacion_grupo
        FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo)
        ON DELETE CASCADE,

    CONSTRAINT CK_publicacion_tipo
        CHECK (tipo_publicacion IN ('general', 'pregunta', 'recurso', 'noticia')),

    CONSTRAINT CK_publicacion_metadatos_JSON
        CHECK (metadatos IS NULL OR ISJSON(metadatos) = 1)
);

CREATE TABLE evento (
    id_evento INT IDENTITY(1,1) NOT NULL,
    id_organizador INT NOT NULL,
    id_grupo INT NULL,
    titulo VARCHAR(100) NOT NULL,
    descripcion VARCHAR(MAX) NULL,
    lugar VARCHAR(100) NULL,
    fecha_inicio DATETIME2 NOT NULL,
    fecha_fin DATETIME2 NULL,
    tipo_evento VARCHAR(20) NOT NULL,

    CONSTRAINT PK_evento PRIMARY KEY (id_evento),

    CONSTRAINT FK_evento_usuario
        FOREIGN KEY (id_organizador) REFERENCES usuario(id_usuario),

    CONSTRAINT FK_evento_grupo
        FOREIGN KEY (id_grupo) REFERENCES grupo(id_grupo)
        ON DELETE SET NULL,

    CONSTRAINT CK_evento_tipo
        CHECK (tipo_evento IN ('estudio', 'taller', 'social')),

    CONSTRAINT CK_evento_fechas
        CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);


CREATE TABLE asistencia_evento (
    id_evento INT NOT NULL,
    id_usuario INT NOT NULL,
    estado VARCHAR(15) NOT NULL DEFAULT 'confirmado',

    CONSTRAINT PK_asistencia_evento
        PRIMARY KEY (id_evento, id_usuario),

    CONSTRAINT FK_asistencia_evento_evento
        FOREIGN KEY (id_evento) REFERENCES evento(id_evento),

    CONSTRAINT FK_asistencia_evento_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),

    CONSTRAINT CK_asistencia_evento_estado
        CHECK (estado IN ('confirmado', 'tal_vez', 'cancelado'))
);