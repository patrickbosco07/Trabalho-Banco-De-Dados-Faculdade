CREATE TABLE ALUNOS
	(
		MATRICULA INT NOT NULL IDENTITY
			CONSTRAINT PK_ALUNO PRIMARY KEY,
		NOME VARCHAR(50) NOT NULL
	);
	GO
	CREATE TABLE CURSOS
	(
		CURSO CHAR(3) NOT NULL
			CONSTRAINT PK_CURSO PRIMARY KEY,
		NOME VARCHAR(50) NOT NULL
	);
	GO
	CREATE TABLE PROFESSOR
	(
		PROFESSOR INT IDENTITY NOT NULL
			CONSTRAINT PK_PROFESSOR PRIMARY KEY,
		NOME VARCHAR(50) NOT NULL
	);
	GO
	CREATE TABLE MATERIAS
	(
		SIGLA CHAR(3) NOT NULL,
		NOME VARCHAR(50) NOT NULL,
		CARGAHORARIA INT NOT NULL,
		CURSO CHAR(3) NOT NULL,
		PROFESSOR INT
			CONSTRAINT PK_MATERIA
			PRIMARY KEY (
							SIGLA,
							CURSO,
							PROFESSOR
						)
			CONSTRAINT FK_CURSO
			FOREIGN KEY (CURSO) REFERENCES CURSOS (CURSO),
		CONSTRAINT FK_PROFESSOR
			FOREIGN KEY (PROFESSOR)
			REFERENCES PROFESSOR (PROFESSOR)
	);
	GO
	INSERT ALUNOS
	(
		NOME
	)
	VALUES
	('Pedro'),('Joao'),('Robersvalto'),('Tito');
	GO
	INSERT CURSOS
	(
		CURSO,
		NOME
	)
	VALUES
	('ENG', 'ENGENHARIA'),
	('SIS', 'SISTEMAS'),
	('DIR', 'DIREITO'),
	('FAR', 'FARMACIA'),
	('FIS', 'FISICA');
	GO
	INSERT PROFESSOR
	(
		NOME
	)
	VALUES
	('Francisco'),
	('Cleyson'),
	('Elielton'),
	('Neilton'),
	('Guilherme'),
	('Marcos');
	GO
	
	INSERT MATERIAS
	(
		SIGLA,
		NOME,
		CARGAHORARIA,
		CURSO,
		PROFESSOR
	)
	VALUES
	('BDA','BANCO DE DADOS',144,'ENG',1),
	('PRO','PROGRAMACAO',144,'ENG',2),
	('BDA','BANCO DE DADOS',144,'SIS',1),
	('PRO','PROGRAMACAO',144,'SIS',2),		
	('CIV', 'PROCESSO CIVIL', 144, 'DIR', 2),
	('COD', 'CÓDIGO PENAL', 144, 'DIR', 2),
	('QUI','QUIMICA',144,'FAR',1),
	('ANA','ANATOMIA HUMANA',144,'FAR',2),
	('CAL','CALCULO',144,'FIS',3),
	('ALG','ALGEBRA LINEAR',144,'FIS',2);
	GO
	CREATE TABLE MATRICULA
	(
		MATRICULA INT,
		CURSO CHAR(3),
		MATERIA CHAR(3),
		PROFESSOR INT,
		PERLETIVO INT,
		N1 FLOAT,
		N2 FLOAT,
		N3 FLOAT,
		N4 FLOAT,
		TOTALPONTOS FLOAT,
		MEDIA FLOAT,
		F1 INT,
		F2 INT,
		F3 INT,
		F4 INT,
		TOTALFALTAS INT,
		PERCFREQ FLOAT,
		RESULTADO VARCHAR(20)
			CONSTRAINT PK_MATRICULA
			PRIMARY KEY (
							MATRICULA,
							CURSO,
							MATERIA,
							PROFESSOR,
							PERLETIVO
						),
		CONSTRAINT FK_ALUNOS_MATRICULA
			FOREIGN KEY (MATRICULA)
			REFERENCES ALUNOS (MATRICULA),
		CONSTRAINT FK_CURSOS_MATRICULA
			FOREIGN KEY (CURSO)
			REFERENCES CURSOS (CURSO),
		--CONSTRAINT FK_MATERIAS FOREIGN KEY (MATERIA) REFERENCES MATERIAS (SIGLA),
		CONSTRAINT FK_PROFESSOR_MATRICULA
			FOREIGN KEY (PROFESSOR)
			REFERENCES PROFESSOR (PROFESSOR)
	);
	GO
	ALTER TABLE MATRICULA ADD MEDIAFINAL FLOAT;
	GO
	ALTER TABLE MATRICULA ADD NOTAEXAME FLOAT;
	GO

CREATE PROCEDURE MATRICULANDOALUNOSS_2
    (
        @NOME VARCHAR(50),
        @CURSO CHAR(3)
    )
AS
    BEGIN 
    DECLARE @MATRICULA INT 
    SELECT @MATRICULA = MATRICULA FROM ALUNOS WHERE NOME = @NOME

    INSERT MATRICULA (MATRICULA,CURSO,MATERIA,PROFESSOR,PERLETIVO)
    SELECT @MATRICULA,@CURSO,SIGLA,PROFESSOR,2023 FROM MATERIAS WHERE CURSO = @CURSO 
      
    END;
GO

EXEC MATRICULANDOALUNOSS_2 'Pedro','SIS';
EXEC MATRICULANDOALUNOSS_2 'Joao','DIR';

CREATE PROCEDURE sp_CadastraNotas
	(
		@MATRICULA INT,
		@CURSO CHAR(3),
		@MATERIA CHAR(3),
		@PERLETIVO CHAR(4),
		@NOTA FLOAT,
		@FALTA INT,
		@BIMESTRE INT
	)
	AS
BEGIN

		IF @BIMESTRE = 1
		    BEGIN

                UPDATE MATRICULA
                SET N1 = @NOTA,
                    F1 = @FALTA,
                    TOTALPONTOS = @NOTA,
                    TOTALFALTAS = @FALTA,
                    MEDIA = @NOTA
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
		    END

        ELSE 
        
        IF @BIMESTRE = 2
            BEGIN

                UPDATE MATRICULA
                SET N2 = @NOTA,
                    F2 = @FALTA,
                    TOTALPONTOS = @NOTA + N1,
                    TOTALFALTAS = @FALTA + F1,
                    MEDIA = (@NOTA + N1) / 2
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
            END

        ELSE 
        
        IF @BIMESTRE = 3
            BEGIN

                UPDATE MATRICULA
                SET N3 = @NOTA,
                    F3 = @FALTA,
                    TOTALPONTOS = @NOTA + N1 + N2,
                    TOTALFALTAS = @FALTA + F1 + F2,
                    MEDIA = (@NOTA + N1 + N2) / 3
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
            END

        ELSE 
        
        IF @BIMESTRE = 4
            BEGIN

                DECLARE @RESULTADO VARCHAR(50),
                        @FREQUENCIA FLOAT,
                        @MEDIAFINAL FLOAT,
                        @CARGAHORA INT
                
                SET @CARGAHORA = (
                    SELECT CARGAHORARIA FROM MATERIAS 
                    WHERE       SIGLA = @MATERIA
                            AND CURSO = @CURSO)

                UPDATE MATRICULA
                SET N4 = @NOTA,
                    F4 = @FALTA,
                    TOTALPONTOS = @NOTA + N1 + N2 + N3,
                    TOTALFALTAS = @FALTA + F1 + F2 + F3,
                    MEDIA = (@NOTA + N1 + N2 + N3) / 4,
                    MEDIAFINAL = (@NOTA + N1 + N2 + N3) / 4,
                    PERCFREQ = 100 -( ((@FALTA + F1 + F2 + F3)*@CARGAHORA )/100)
                        WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;  
                IF @MEDIAFINAL = 7
                        BEGIN

                            UPDATE MATRICULA
                            SET RESULTADO = 'APROVADO'
                                    WHERE MATRICULA = @MATRICULA
                                AND CURSO = @CURSO
                                AND MATERIA = @MATERIA
                                AND PERLETIVO = @PERLETIVO;  
                        END
                ELSE

                IF @MEDIAFINAL < 7
                        BEGIN

                            UPDATE MATRICULA
                            SET RESULTADO = 'EXAME'
                                    WHERE MATRICULA = @MATRICULA
                                AND CURSO = @CURSO
                                AND MATERIA = @MATERIA
                                AND PERLETIVO = @PERLETIVO;

                        END
            END
            

		SELECT * FROM MATRICULA	WHERE MATRICULA = @MATRICULA
END

EXEC sp_CadastraNotas @MATRICULA = 1,      -- int
                      @CURSO = 'SIS',      -- char(3)
                      @MATERIA = 'BDA',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 4,
                      @BIMESTRE = 1      -- int

EXEC sp_CadastraNotas @MATRICULA = 1,      -- int
                      @CURSO = 'SIS',      -- char(3)
                      @MATERIA = 'PRO',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 2,
                      @BIMESTRE = 1      -- int

EXEC sp_CadastraNotas @MATRICULA = 2,      -- int
                      @CURSO = 'DIR',      -- char(3)
                      @MATERIA = 'COD',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 2,
                      @BIMESTRE = 1      -- int                                            

EXEC sp_CadastraNotas @MATRICULA = 2,      -- int
                      @CURSO = 'DIR',      -- char(3)
                      @MATERIA = 'CIV',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 6,
                      @BIMESTRE = 1      -- int

EXEC sp_CadastraNotas @MATRICULA = 1,      -- int
                      @CURSO = 'SIS',      -- char(3)
                      @MATERIA = 'BDA',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 0,
                      @BIMESTRE = 2      -- int

EXEC sp_CadastraNotas @MATRICULA = 1,      -- int
                      @CURSO = 'SIS',      -- char(3)
                      @MATERIA = 'PRO',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 0,
                      @BIMESTRE = 2      -- int

EXEC sp_CadastraNotas @MATRICULA = 2,      -- int
                      @CURSO = 'DIR',      -- char(3)
                      @MATERIA = 'CIV',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 0,
                      @BIMESTRE = 2      -- int 

EXEC sp_CadastraNotas @MATRICULA = 2,      -- int
                      @CURSO = 'DIR',      -- char(3)
                      @MATERIA = 'COD',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 0,
                      @BIMESTRE = 2      -- int

EXEC sp_CadastraNotas @MATRICULA = 1,      -- int
                      @CURSO = 'SIS',      -- char(3)
                      @MATERIA = 'BDA',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 2,
                      @BIMESTRE = 3      -- int

EXEC sp_CadastraNotas @MATRICULA = 1,      -- int
                      @CURSO = 'SIS',      -- char(3)
                      @MATERIA = 'PRO',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 2,
                      @BIMESTRE = 3      -- int

EXEC sp_CadastraNotas @MATRICULA = 2,      -- int
                      @CURSO = 'DIR',      -- char(3)
                      @MATERIA = 'CIV',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 2,
                      @BIMESTRE = 3      -- int

EXEC sp_CadastraNotas @MATRICULA = 2,      -- int
                      @CURSO = 'DIR',      -- char(3)
                      @MATERIA = 'COD',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 2,
                      @BIMESTRE = 3      -- int

EXEC sp_CadastraNotas @MATRICULA = 1,      -- int
                      @CURSO = 'SIS',      -- char(3)
                      @MATERIA = 'BDA',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 5.0,         -- float
                      @FALTA = 2,
                      @BIMESTRE = 4      -- int  

EXEC sp_CadastraNotas @MATRICULA = 1,      -- int
                      @CURSO = 'SIS',      -- char(3)
                      @MATERIA = 'PRO',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 5.0,         -- float
                      @FALTA = 2,
                      @BIMESTRE = 4      -- int

EXEC sp_CadastraNotas @MATRICULA = 2,      -- int
                      @CURSO = 'DIR',      -- char(3)
                      @MATERIA = 'COD',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 2,
                      @BIMESTRE = 4      -- int

EXEC sp_CadastraNotas @MATRICULA = 2,      -- int
                      @CURSO = 'DIR',      -- char(3)
                      @MATERIA = 'CIV',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 7.0,         -- float
                      @FALTA = 0,
                      @BIMESTRE = 4      -- int

  CREATE PROCEDURE CALCULO_RESULTADO_FINAL_2
    (
        @ID VARCHAR(3),
        @NOTA FLOAT,
        @MAT VARCHAR(3)
    )
    AS
    BEGIN
        IF @NOTA = 7
                        BEGIN

                            UPDATE MATRICULA
                            SET RESULTADO = 'APROVADO'
                                    WHERE MATRICULA = @ID
                                AND MATERIA = @MAT     
                        END
                ELSE

                IF @NOTA < 7
                        BEGIN

                            UPDATE MATRICULA
                            SET RESULTADO = 'EXAME'
                                    WHERE MATRICULA = @ID
                                AND MATERIA = @MAT      

                        END
    END

EXEC CALCULO_RESULTADO_FINAL_2  @ID = 1,
                                @NOTA = 6.5,
                                @MAT = 'BDA'

EXEC CALCULO_RESULTADO_FINAL_2  @ID = 1,
                                @NOTA = 6.5,
                                @MAT = 'PRO'

EXEC CALCULO_RESULTADO_FINAL_2  @ID = 2,
                                @NOTA = 7,
                                @MAT = 'CIV'

EXEC CALCULO_RESULTADO_FINAL_2  @ID = 2,
                                @NOTA = 7,
                                @MAT = 'COD'

CREATE PROCEDURE CALCULO_EXAME
    (
        @NOTA INT,
        @ID INT,
        @MAT VARCHAR(3)

    )
    AS
    BEGIN
        IF @NOTA = 7
            BEGIN
                DECLARE @RESULTADO VARCHAR(50)

                UPDATE MATRICULA
                SET NOTAEXAME = @NOTA,
                    RESULTADO = 'APROVADO'
                        WHERE MATRICULA = @ID
                    AND MATERIA = @MAT    
            END
        
        ELSE
        IF @NOTA < 7 
            BEGIN
                UPDATE MATRICULA
                SET NOTAEXAME = @NOTA,
                    RESULTADO = 'REPROVADO'
                        WHERE MATRICULA = @ID
                    AND MATERIA = @MAT       
            END
    END

EXEC CALCULO_EXAME @NOTA = 7,
@ID = 1,
@MAT = 'BDA'

EXEC CALCULO_EXAME @NOTA = 6.2,
@ID = 1,
@MAT = 'PRO'                                                                                                                                                                                                                                                             
                                                                                                                                                                                                                