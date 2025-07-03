/*
	Fecha: 23/05/2025
	Grupo: 05
	Materia: Bases de Datos Aplicada
	Nicolas Perez 40015709
	Santiago Sanchez 42281463
	Jonathan Enrique 43301711
	Teo Turri 42819058

	Consigna:
		Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
		también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.
		Los nombres de los store procedures NO deben comenzar con “SP”. 

*/

USE Com5600G05;
GO

--Funcion para obtener el Socio Beneficiario (quien recibe el beneficio de la descripcion.)
CREATE OR ALTER FUNCTION Factura.ObtenerSocioBeneficiario
(
	@idFactura INT,
	@idSocioBeneficiario INT
)
RETURNS DECIMAL(10,2)
BEGIN

	DECLARE @idSocioDueñoFactura INT;
	SELECT @idSocioDueñoFactura = idSocio 
	FROM Factura.Factura 
	WHERE idFactura = @idFactura;

	RETURN COALESCE(@idSocioBeneficiario, @idSocioDueñoFactura);

END;
GO


--Funcion para obtener el IVA
CREATE OR ALTER FUNCTION Factura.ObtenerPorcentajeIVA
(
	@idFactura INT
)
RETURNS DECIMAL(10,2)
BEGIN
	DECLARE @PorcentajeIVA DECIMAL(10,2);

    SELECT
        @PorcentajeIVA =
            CASE
                WHEN tipoFactura IN ('C','E') THEN 0.00
                ELSE 21.00
            END
    FROM Factura.Factura
    WHERE idFactura = @idFactura;

    RETURN @PorcentajeIVA;
END;
GO

CREATE OR ALTER PROCEDURE Factura.ActualizarTotalFactura
	@idDetalle INT,
	@esSuma	BIT = 1   --1: Agregar a total, 0: Restar a total.
AS
BEGIN

	--Datos iniciales.
	DECLARE @montoFinal DECIMAL(10,2);
	DECLARE @idFactura INT;

	SELECT
		  @idFactura = idFactura,
		  @montoFinal = CASE WHEN @esSuma = 1 THEN montoFinalConIVA ELSE -montoFinalConIVA END
	FROM Factura.DetalleFactura 
	WHERE idDetalleFactura = @idDetalle;

	--Actualizar total
	UPDATE Factura.Factura
	SET totalFactura = totalFactura + @montoFinal
	WHERE idFactura = @idFactura;
END;
GO

--Procedure para obtener el precio para la Actividad o Cuota.
CREATE OR ALTER PROCEDURE Factura.ObtenerPrecioDetalle
	@idFactura			   INT,
    @descripcion		   VARCHAR(50),
	@idSocioBeneficiario   INT,
	@precio				   DECIMAL(10,2) OUTPUT
AS
BEGIN
    DECLARE @precioEncontrado DECIMAL(10,2) = NULL;

	DECLARE @fechaEmisionFactura DATE;
	
	SELECT @fechaEmisionFactura = fechaEmision
	FROM Factura.Factura
	WHERE idFactura = @idFactura


    -- Precio de actividad deportiva
    IF @descripcion IN ('Taekwondo','Vóley','Futsal','Natación','Baile artístico','Ajedrez')
    BEGIN
        SELECT TOP 1 @precio = ca.precio
        FROM Actividad.CostoActividadDeportiva ca
        JOIN Actividad.ActividadDeportiva a 
          ON a.idActividadDeportiva = ca.idActividadDeportiva 
         AND a.nombre  = @descripcion
        WHERE ca.fechaVigencia >= @fechaEmisionFactura
        ORDER BY ca.fechaVigencia ASC;
        SET @precio = @precioEncontrado;
    END

    -- Precio de cuota
    IF @descripcion = 'Cuota'
    BEGIN
        SELECT TOP 1 @precio = cc.precio
        FROM Socio.Socio s
        JOIN Socio.Categoria c       ON c.idCategoria    = s.idCategoria
        JOIN Socio.CostoCategoria cc ON cc.idCategoria   = c.idCategoria
        WHERE s.idSocio = @idSocioBeneficiario
          AND cc.fechaVigencia >= @fechaEmisionFactura
        ORDER BY cc.fechaVigencia ASC;
        SET @precio = @precioEncontrado;
    END

	-- Precio Uso Pileta
	-- Me falta implementar la logica aca, ya que necesito de la tabla InvitacionEvento.

	IF @precio IS NULL
	BEGIN
		DECLARE @mensajePrecioNoEncontrado VARCHAR(200) = CONCAT('No hay precio definido para', @descripcion, 'en la fecha', @fechaEmisionFactura);
		THROW 51107, @mensajePrecioNoEncontrado, 1;
	END;
END;
GO

--Calcular descuento para el detalle ingresado/modificado.
CREATE OR ALTER PROCEDURE Factura.CalcularDescuento
    @idDetalleFactura INT,
	@descripcion VARCHAR(50)
AS
BEGIN


	DECLARE @idSocioBeneficiario INT;

	SELECT @idSocioBeneficiario = idSocioBeneficiario
	FROM Factura.DetalleFactura
	WHERE idDetalleFactura = @idDetalleFactura;

	DECLARE @idFactura INT;

	SELECT @idFactura = idFactura
	FROM Factura.DetalleFactura
	WHERE idDetalleFactura = @idDetalleFactura;

	-- Calcular Descuentos para Cuota

    IF @descripcion = 'Cuota' AND @idSocioBeneficiario IS NOT NULL
    BEGIN
        UPDATE Factura.DetalleFactura
        SET 
            porcentajeDescuento = 0.15,
            motivoDescuento     = 'Descuento en Cuota por Grupo Familiar'
        WHERE 
            idFactura         = @idFactura 
            AND motivoDescuento IS NULL 
            AND descripcion     = 'Cuota' 
            AND EXISTS (
                SELECT 1
                  FROM Socio.GrupoFamiliar
                 WHERE idSocioTutor = @idSocioBeneficiario 
                    OR idSocioMenor  = @idSocioBeneficiario
            );
    END;

    -- Calcular Descuentos para Actividades
    IF @descripcion IN (
            'Taekwondo', 'Vóley', 'Futsal',
            'Natación', 'Baile artístico', 'Ajedrez'
        )
    BEGIN
        UPDATE df
        SET
            porcentajeDescuento = 0.10,
            motivoDescuento     = 'Descuento por realizar más de una Actividad Deportiva por Socio.'
        FROM Factura.DetalleFactura AS df
        WHERE
            df.idFactura               = @idFactura
            AND df.idSocioBeneficiario = @idSocioBeneficiario
            AND df.descripcion IN (
                'Taekwondo','Vóley','Futsal',
                'Natación','Baile artístico','Ajedrez'
            )
            AND (
                SELECT COUNT(DISTINCT descripcion)
                  FROM Factura.DetalleFactura
                 WHERE
                     idFactura               = @idFactura
                     AND idSocioBeneficiario = @idSocioBeneficiario
                     AND descripcion IN (
                         'Taekwondo','Vóley','Futsal',
                         'Natación','Baile artístico','Ajedrez'
                     )
            ) > 1;
    END;
END;
GO

CREATE OR ALTER PROCEDURE Factura.ValidarDetalleFactura
    @idFactura             INT,
    @descripcion           VARCHAR(50),
    @idSocioBeneficiario   INT = NULL
AS
BEGIN
    
    -------------- Validaciones básicas --------------
    IF @idFactura IS NULL 
       AND @descripcion IS NULL
        THROW 51100, 'Los siguientes parámetros no pueden ser NULL: idFactura, descripción.', 1;

    IF NOT EXISTS (
        SELECT 1 
          FROM Factura.Factura 
         WHERE idFactura = @idFactura
    )
        THROW 51101, 'No existe el idFactura ingresado.', 1;

    IF @descripcion NOT IN (
        'Cuota', 'Taekwondo', 'Vóley', 'Futsal', 
        'Natación', 'Baile artístico', 'Ajedrez',
		'UsoPileta:Socio_Dia', 'UsoPileta:Socio_Mes', 
		'UsoPileta:Socio_Temporada', 'UsoPileta:Invitado',
		'Colonia', 'AlquilerSUM'
    )
        THROW 51102, 
              'La descripción debe ser: Cuota, Taekwondo, Vóley, Futsal, Natación, Baile artístico, Ajedrez, 
			  UsoPileta:Socio_Dia, UsoPileta:Socio_Mes, UsoPileta:Socio_Temporada, UsoPileta:Invitado,  Colonia, AlquilerSUM.', 
              1;
	

	--Obtengo el idSocio del dueño de la factura.
	DECLARE @idSocioDueñoFactura INT;
    SELECT @idSocioDueñoFactura = idSocio
    FROM Factura.Factura
    WHERE idFactura = @idFactura;

	
	-- Si no se especificó beneficiario, uso el dueño de la factura
    SET @idSocioBeneficiario = COALESCE(@idSocioBeneficiario, @idSocioDueñoFactura);

	-------------- Validación descripcion correcta para Socio e Invitado --------------
	IF NOT EXISTS (SELECT 1 FROM Socio.Socio WHERE idSocio = @idSocioBeneficiario) AND @descripcion <> 'UsoPileta:Invitado'
		THROW 51103, 'No se puede insertar una descripcion para una Factura destinada a un Invitado que no sea: UsoPileta:Invitado', 1;
	ELSE
		IF EXISTS (SELECT 1 FROM Socio.Socio WHERE idSocio = @idSocioBeneficiario) AND @descripcion = 'UsoPileta:Invitado'
			THROW 51104, 'No se puede insertar una descripcion para una Factura destinada a un Socio que sea: UsoPileta:Invitado', 1;

	-------------- Validación de grupo familiar --------------
    
    IF @idSocioBeneficiario <> @idSocioDueñoFactura
       AND @idSocioBeneficiario <> (
           SELECT idSocioMenor
             FROM Socio.GrupoFamiliar
            WHERE idSocioTutor = @idSocioDueñoFactura
       )
        THROW 51105, 
              'El idSocioBeneficiario no corresponde a un miembro del grupo familiar del dueño de la factura.', 1;
	

    -------------- Validación de duplicados por mes/año para Cuota y Actividad--------------
    
	IF EXISTS (SELECT 1 FROM Socio.Socio WHERE idSocio = @idSocioBeneficiario)
	BEGIN
		DECLARE 
			@fechaEmisionFactura DATE,
			@mes                  INT,
			@año                  INT;

		SELECT 
			@fechaEmisionFactura = fechaEmision,
			@mes                  = MONTH(fechaEmision),
			@año                  = YEAR(fechaEmision)
		  FROM Factura.Factura
		 WHERE idFactura = @idFactura;

		IF @descripcion IN (
			'Cuota', 'Taekwondo', 'Vóley', 'Futsal',
			'Natación', 'Baile artístico', 'Ajedrez'
		)
		BEGIN
			IF EXISTS (
				SELECT 1
				  FROM Factura.Factura f
				  JOIN Factura.DetalleFactura df 
					ON f.idFactura = df.idFactura
				 WHERE df.descripcion            = @descripcion
				   AND df.idSocioBeneficiario   = @idSocioBeneficiario
				   AND YEAR(f.fechaEmision)     = @año
				   AND MONTH(f.fechaEmision)    = @mes
			)
			BEGIN
				DECLARE @mensajeDetalleRepetido VARCHAR(200) = 
					CONCAT(
						'El socio ', @idSocioBeneficiario,
						' ya tiene "', @descripcion,
						'" facturado en ', @mes, '/', @año
					);
				THROW 51106, @mensajeDetalleRepetido, 1;
			END;
		END;
	END;
 
END;
GO


--Crear CrearDetalleFacturaCuotaActividad: Solo para Cuotas y Actividades Deportivas.

CREATE OR ALTER PROCEDURE Factura.CrearDetalleFactura
	@idFactura INT,
    @descripcion VARCHAR(50),
	@idSocioBeneficiario INT = NULL
AS
BEGIN
	

	---------------- Validar Detalle -----------------------------
	EXEC Factura.ValidarDetalleFactura @idFactura = @idFactura, @descripcion = @descripcion, 
		@idSocioBeneficiario = @idSocioBeneficiario;


	---------------- Obtener socio quien recibe se le aplica el detalle. -----------------------------
	SET @idSocioBeneficiario = Factura.ObtenerSocioBeneficiario(@idFactura, @idSocioBeneficiario);


	---------------- Calcular Precio para Descripcion -----------------------------
	
	DECLARE @precio DECIMAL(10,2)

	EXEC Factura.ObtenerPrecioDetalle @idFactura = @idFactura,
		@descripcion = @descripcion, @idSocioBeneficiario = @idSocioBeneficiario, @precio = @precio;

	---------------- Calcular IVA -----------------------------
	DECLARE @PorcentajeIVA DECIMAL(5,2) = Factura.ObtenerPorcentajeIVA(@idFactura);


	--------------- Insertar Detalle -----------------------------

	SET XACT_ABORT ON;

	BEGIN TRY

		BEGIN TRAN;
		INSERT INTO Factura.DetalleFactura (idFactura, descripcion, montoBase, porcentajeIVA, idSocioBeneficiario)
		VALUES (@idFactura, @descripcion, @precio, @porcentajeIVA, @idSocioBeneficiario);

		DECLARE @idDetalleInsertado INT = SCOPE_IDENTITY();

		--------------- Calcular Descuento -----------------------------

		EXEC Factura.CalcularDescuento @idDetalleFactura = @idDetalleInsertado, @descripcion = @descripcion;

		--------------- Actualizar total factura -----------------------------

		EXEC Factura.ActualizarTotalFactura @idDetalle = @idDetalleInsertado;

		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW 51110, 'Error al realizar la transaccion en Factura.CrearDetalleFactura', 1;
	END CATCH;

END;
GO



CREATE OR ALTER PROCEDURE Factura.ActualizarDetalleFactura
	@idDetalle INT,
	@descripcion VARCHAR(50),
	@idSocioBeneficiario INT = NULL
AS
BEGIN
	
	IF @idDetalle IS NULL
		THROW 51111, 'El idDetalle ingresado es NULL.', 1;
	

	IF NOT EXISTS (SELECT 1 FROM Factura.DetalleFactura WHERE idDetalleFactura = @idDetalle)
	BEGIN
		DECLARE @mensajeDetalle VARCHAR(100);
		SET @mensajeDetalle = 'No existe un detalle de ID ' + CAST(@idDetalle AS VARCHAR);
		THROW 51112, @mensajeDetalle, 1;
	END

	DECLARE @idFactura INT = (SELECT idFactura FROM Factura.DetalleFactura WHERE idDetalleFactura = @idDetalle);

	IF 'Borrador' <> (SELECT estado FROM Factura.Factura WHERE idFactura = @idFactura)
		THROW 51113, 'La factura ya fue emitida, no se puede modificar.', 1;

	IF @descripcion		IS NULL AND @idSocioBeneficiario IS NULL
		THROW 51114, 'Debe proveer al menos un campo a modificar.', 1;

	--Reemplazo si @descripcion IS NULL para que funcione Factura.ValidarDetalleFactura
	SELECT 
		@descripcion = COALESCE(@descripcion, descripcion)
	FROM Factura.DetalleFactura
	WHERE idFactura = @idFactura;


	---------------- Validar Detalle -----------------------------
	EXEC Factura.ValidarDetalleFactura @idFactura = @idFactura, @descripcion = @descripcion, 
		@idSocioBeneficiario = @idSocioBeneficiario;


	---------------- Obtener socio quien recibe se le aplica el detalle. -----------------------------
	SET @idSocioBeneficiario = Factura.ObtenerSocioBeneficiario(@idFactura, @idSocioBeneficiario);


	---------------- Calcular Precio para Descripcion -----------------------------
	
	DECLARE @precio DECIMAL(10,2)

	EXEC Factura.ObtenerPrecioDetalle @idFactura = @idFactura,
		@descripcion = @descripcion, @idSocioBeneficiario = @idSocioBeneficiario, @precio = @precio;

	---------------- Calcular IVA -----------------------------
	DECLARE @PorcentajeIVA DECIMAL(5,2) = Factura.ObtenerPorcentajeIVA(@idFactura);

	--------------- Actualizar Detalle -----------------------------

	SET XACT_ABORT ON;

	BEGIN TRY

		BEGIN TRAN;
		UPDATE Factura.DetalleFactura
		SET
			idFactura = @idFactura,
			descripcion = @descripcion,
			montoBase = @precio,
			porcentajeIVA = @porcentajeIVA,
			idSocioBeneficiario = @idSocioBeneficiario
		WHERE idDetalleFactura = @idDetalle;


		--------------- Calcular Descuento -----------------------------

		EXEC Factura.CalcularDescuento @idDetalleFactura = @idDetalle, @descripcion = @descripcion;

		--------------- Actualizar total factura -----------------------------

		EXEC Factura.ActualizarTotalFactura @idDetalle = @idDetalle;

		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW 51110, 'Error al realizar la transaccion en Factura.ActualizarDetalleFactura', 1;
	END CATCH;
END;
GO


CREATE OR ALTER PROCEDURE Factura.EliminarDetalleFactura
	@idDetalle INT
AS
BEGIN
	
	IF @idDetalle IS NULL
		THROW 51111, 'El idDetalle ingresado es NULL.', 1;
	

	IF NOT EXISTS (SELECT 1 FROM Factura.DetalleFactura WHERE idDetalleFactura = @idDetalle)
	BEGIN
		DECLARE @mensajeDetalle VARCHAR(100);
		SET @mensajeDetalle = 'No existe un detalle de ID ' + CAST(@idDetalle AS VARCHAR);
		THROW 51112, @mensajeDetalle, 1;
	END

	DECLARE @idFactura INT = (SELECT idFactura FROM Factura.DetalleFactura WHERE idDetalleFactura = @idDetalle);

	IF 'Borrador' <> (SELECT estado FROM Factura.Factura WHERE idFactura = @idFactura)
		THROW 51113, 'La factura ya fue emitida, no se puede modificar.', 1;



	--------------- Obtener precio que sera eliminado -----------------------------
	DECLARE @precioEliminado DECIMAL(10,2);

	SELECT @precioEliminado = montoFinalConIVA
	FROM Factura.DetalleFactura
	WHERE idDetalleFactura = @idDetalle


	SET XACT_ABORT ON;

	BEGIN TRY
		BEGIN TRAN;

		--------------- Actualizar total factura -----------------------------
		EXEC Factura.ActualizarTotalFactura @idDetalle = @idDetalle, @esSuma = 0;
		
		--------------- Eliminar Detalle -----------------------------
		DELETE FROM Factura.DetalleFactura
		WHERE idDetalleFactura = @idDetalle;

		COMMIT;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW 51110, 'Error al realizar la transaccion en Factura.EliminarDetalleFactura', 1;
	END CATCH;


END;
GO

