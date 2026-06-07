const cds = require('@sap/cds');

class AsambleaService extends cds.ApplicationService {
    
    /**
     * Event & Hook Registration
     */
    async init() {
        // Register the action hook and bind it to our clean implementation method below
        this.on('obtenerQuorumActual', this.onObtenerQuorumActual);

        // Always invoke super.init() to ensure generic CRUD handlers are registered
        await super.init();
    }

    /**
     * Business Logic Implementation Methods
     */
    async onObtenerQuorumActual(req) {
        const { RegistroAsistencia, RegistroAsistenciaLog, Unidades } = this.entities;
        const { asambleaId } = req.data;

        if (!asambleaId) {
            return req.error(400, 'El parámetro asambleaId es obligatorio.');
        }

        // 1. Fetch all registration records for tonight's assembly
        const registrations = await SELECT.from(RegistroAsistencia)
            .where({ asamblea_ID: asambleaId });

        if (registrations.length === 0) {
            return 0.00000; // Early night, no one checked in yet
        }

        let totalQuorumActivo = 0;

        // 2. Iterate through each registration to check their latest timeline movement
        for (const reg of registrations) {
            const latestLog = await SELECT.one.from(RegistroAsistenciaLog)
                .where({ registro_asistencia_ID: reg.id })
                .orderBy('timestamp desc'); // Focus exclusively on their latest action

            // 3. If their last move was 'entrada', they are still actively in the room
            if (latestLog && latestLog.tipo_accion === 'entrada') {
                const unit = await SELECT.one.from(Unidades)
                    .where({ id: reg.unidad_ID })
                    .columns('alicuota');

                if (unit?.alicuota) {
                    totalQuorumActivo += Number(unit.alicuota);
                }
            }
        }

        // 4. Return the aggregated dynamic alícuota total back to the user interface
        return totalQuorumActivo;
    }
}

module.exports = AsambleaService;