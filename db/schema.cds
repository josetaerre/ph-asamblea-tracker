namespace ph.asamblea;

using { cuid, managed } from '@sap/cds/common';

type TipoConvocatoria : String enum { ordinaria; extraordinaria; }
type FormatoReunion   : String enum { presencial; virtual; mixto; }
type TipoPresencia     : String enum { propietario; apoderado; }
type CanalAsistencia  : String enum { fisico; digital; }
type OpcionVoto       : String enum { favor; contra; abstencion; }
type CanalVoto        : String enum { digital_app; manual_operador; }
type TipoAccionLog    : String enum { entrada; salida; }

entity Propietarios : cuid, managed {
    nombre       : String(100);
    apellido     : String(100);
    cedula_o_ruc : String(50); 
    celular      : String(20);
    correo       : String(100);
    // Refactored backlink to the junction table
    unidades     : Association to many PropietarioUnidad on unidades.propietario = $self;
}

entity Unidades : cuid {
    numero_unidad : String(20);
    alicuota      : Decimal(7, 5); 
    fecha_entrega : Date;
    // Refactored backlink to the junction table
    propietarios  : Association to many PropietarioUnidad on propietarios.unidad = $self;
    cuentas       : Composition of many CuentaCorriente on cuentas.unidad = $self;
    multas        : Composition of many Multas on multas.unidad = $self;
}

// Fixed Junction Table modeling for native OData route generation
entity PropietarioUnidad : cuid {
    propietario : Association to Propietarios;
    unidad      : Association to Unidades;
}

entity CuentaCorriente : cuid {
    unidad       : Association to Unidades;
    ano          : Integer;
    mes          : Integer;
    monto_cuota  : Decimal(10, 2);
    esta_pagado  : Boolean default false;
}

entity Multas : cuid {
    unidad        : Association to Unidades;
    // Explicitly target the master entity with proper key matching parameters
    motivo        : Association to MultasMotivo; 
    monto         : Decimal(10, 2);
    fecha_emision : Date;
    esta_pagada   : Boolean default false;
}

entity MultasMotivo : cuid {
    descripcion    : String(255);
    monto_estandar : Decimal(10, 2);
    // Explicit backlink to fines using this category
    multas_emitidas: Association to many Multas on multas_emitidas.motivo = $self;
}

entity Asambleas : cuid, managed {
    fecha             : Date;
    hora_inicio       : Time;
    hora_fin          : Time;
    tiempo_espera     : Integer; 
    no_quorum         : Boolean default false;
    tipo_convocatoria : TipoConvocatoria;
    formato_reunion   : FormatoReunion;
    esta_activa       : Boolean default false;
    comentarios       : String(1000);
    agenda_items      : Composition of many AgendaItems on agenda_items.asamblea = $self;
}

entity AgendaItems : cuid {
    asamblea           : Association to Asambleas;
    orden              : Integer;
    titulo_descripcion : String(255);
    preguntas          : Composition of many Preguntas on preguntas.agenda_item = $self;
}

entity Preguntas : cuid {
    agenda_item            : Association to AgendaItems;
    enunciado_pregunta     : String(255);
    tipo_mayoria_requerida : Decimal(5, 2); 
}

entity RegistroAsistencia : cuid {
    asamblea         : Association to Asambleas;
    unidad           : Association to Unidades;
    es_paz_y_salvo   : Boolean; 
    tipo_presencia   : TipoPresencia;
    canal_asistencia : CanalAsistencia;
    nombre_asistente : String(200); 
    logs             : Composition of many RegistroAsistenciaLog on logs.registro_asistencia = $self;
}

entity RegistroAsistenciaLog : cuid {
    registro_asistencia : Association to RegistroAsistencia;
    tipo_accion         : TipoAccionLog;
    timestamp           : DateTime @cds.on.insert : $now; 
}

entity Votos : cuid {
    pregunta     : Association to Preguntas;
    unidad       : Association to Unidades;
    opcion_voto  : OpcionVoto;
    canal_voto   : CanalVoto;
    voto_valido  : Boolean;
}