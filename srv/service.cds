using { ph.asamblea as my } from '../db/schema';

@path: '/admin'
service AsambleaService {
    entity Propietarios         as projection on my.Propietarios;
    entity Unidades             as projection on my.Unidades;
    entity PropietarioUnidad    as projection on my.PropietarioUnidad;
    entity CuentaCorriente      as projection on my.CuentaCorriente;
    entity Multas               as projection on my.Multas;
    entity MultasMotivo         as projection on my.MultasMotivo;
    entity Asambleas            as projection on my.Asambleas;
    entity AgendaItems          as projection on my.AgendaItems;
    entity Preguntas            as projection on my.Preguntas;
    entity RegistroAsistencia   as projection on my.RegistroAsistencia;
    entity RegistroAsistenciaLog as projection on my.RegistroAsistenciaLog;
    entity Votos                as projection on my.Votos;

    function obtenerQuorumActual(asambleaId: UUID) returns Decimal(7,5);
}