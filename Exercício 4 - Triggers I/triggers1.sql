-- Atividade de Banco de Dados referente à aula sobre Triggers


-------------------------------------------------------------------------------------------
--									    CRIAÇÃO DE TABELAS
-------------------------------------------------------------------------------------------

-- Criação da tabela aluno
CREATE TABLE aluno(
	matricula INTEGER NOT NULL PRIMARY KEY,
	nome VARCHAR(40) NOT NULL
);


-- Criação da tabela funcionario
CREATE TABLE funcionario(
	codigo INTEGER NOT NULL PRIMARY KEY,
	nome VARCHAR(30),
	salario FLOAT,
	data_ultima_atualizacao TIMESTAMP,
	usuario_que_atualizou VARCHAR(30)
);


-- Criação da tabela empregado
CREATE TABLE empregado(
	cod_empregado INTEGER NOT NULL,
	nome VARCHAR(30) NOT NULL,
	salario FLOAT NOT NULL
);


-- Criação da tabela empregado_auditoria
CREATE TABLE empregado_auditoria(
	operacao CHAR(1) NOT NULL,
	usuario VARCHAR(40) NOT NULL,
	data_auditoria TIMESTAMP NOT NULL,
	nome VARCHAR(30) NOT NULL,
	salario INTEGER NOT NULL
);


-- Criação da tabela empregado2
CREATE TABLE empregado2(
	codigo SERIAL PRIMARY KEY NOT NULL,
	nome VARCHAR(40) NOT NULL,
	salario INTEGER NOT NULL
);


-- Criação da tabela empregado2_audit
CREATE TABLE empregado2_audit(
	usuario VARCHAR(30) NOT NULL,
	data_audit2 TIMESTAMP NOT NULL,
	id_empregado2 INTEGER NOT NULL,
	coluna TEXT NOT NULL,
	valor_antigo TEXT,
	valor_novo TEXT
);


-------------------------------------------------------------------------------------------
--										INSERÇÃO DE DADOS
-------------------------------------------------------------------------------------------

-- Inserção de dados na tabela aluno (Ativa um trigger)
INSERT INTO aluno VALUES
	(1, 'Agenor Silvestre');


-- Inserção de dados na tabela aluno (Não ativa um trigger)
INSERT INTO aluno VALUES
	(2, 'Thiago Elias');


-- Inserção de dados na tabela funcionario (Ativa um trigger)
INSERT INTO funcionario VALUES
	(1, NULL, 1600),
	(2, 'Pope Frances', NULL),
	(3, 'Oswald Vilso', -1600);


-- Inserção de dados na tabela funcionario (Não ativa um trigger)
INSERT INTO funcionario VALUES
	(4, 'David Britterson', 3400);


-- Inserção de dados na tabela empregado (Ativa o trigger de empregado_auditoria)
INSERT INTO empregado VALUES
	(1, 'Sócrates Costa', 2000);
	

------------------------------------------------------------------------------------------
--											QUESTÃO 1
------------------------------------------------------------------------------------------

/*
Enunciado:
Crie uma tabela aluno com as colunas matrícula e nome. Depois crie um trigger que não 
permita o cadastro de alunos cujo nome começa com a letra “a”.
*/

/*
Cria uma função que impede o cadastro de um nome que comece com  letra A. Essa função
será posteriormente implementada no TRIGGER que irá ser acionado toda vez que um novo
nome for inserido no banco.
*/
CREATE OR REPLACE FUNCTION impedir_nome_com_letra_a()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.nome ILIKE 'a%' THEN
		RAISE EXCEPTION 'Não é permitido o cadastro de nomes que comecem com a letra A';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Trigger que faz a checagem dos nomes que são inseridos no banco
CREATE OR REPLACE TRIGGER checar_nome
BEFORE INSERT OR UPDATE
ON aluno
FOR EACH ROW
EXECUTE FUNCTION impedir_nome_com_letra_a();


------------------------------------------------------------------------------------------
--											QUESTÃO 2
------------------------------------------------------------------------------------------

/*
Enunciado:
Primeiro crie uma tabela chamada Funcionário com os seguintes campos: código (int), 
nome (varchar(30)), salário (int), data_última_atualização (timestamp), 
usuário_que_atualizou (varchar(30)). Na inserção desta tabela, você deve informar apenas 
o código, nome e salário do funcionário. Agora crie um Trigger que não permita o nome
nulo, o salário nulo e nem negativo. Faça testes que
comprovem o funcionamento do Trigger. 
*/

/*
Impede que os nomes e os salários digitados sejam nulos. Também impede que o salário
seja negativo.
*/
CREATE OR REPLACE FUNCTION impedir_valores_nulos_e_negativos()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.nome ISNULL THEN
		RAISE EXCEPTION 'Não é permitido a inserção de nomes nulos';
	ELSIF NEW.salario ISNULL OR NEW.salario < 0 THEN
		RAISE EXCEPTION 'Não é permitido salário nulo ou negativo';
	END IF;
	
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Trigger que ativa a função impedir_valores_nulos_e_negativos
CREATE OR REPLACE TRIGGER checar_nomes_e_salarios_de_funcionarios
BEFORE INSERT OR UPDATE
ON funcionario
FOR EACH ROW
EXECUTE FUNCTION impedir_valores_nulos_e_negativos();


------------------------------------------------------------------------------------------
--											QUESTÃO 3
------------------------------------------------------------------------------------------

/*
Enunciado:
Agora crie uma tabela chamada Empregado com os atributos nome e salário. Crie também 
outra tabela chamada Empregado_auditoria com os atributos: operação (char(1)),
usuário (varchar), data (timestamp), nome (varchar), salário (integer) . Agora crie um 
trigger que registre na tabela Empregado_auditoria a modificação que foi feita na tabela
empregado (E,A,I), quem fez a modificação, a data da modificação, o nome do empregado que 
foi alterado e o salário atual dele.
*/

/*
Registra na tabela empregado_auditoria as mudanças que foram feitas na tabela
empregado
*/
CREATE OR REPLACE FUNCTION registrar_alteracoes_do_empregado()
RETURNS TRIGGER AS $$
BEGIN
	/*
	TG_OP: Uma variável especial do postgres que armazena o tipo da operação realizada,
	se é um INSERT, UPDATE ou DELETE.
	*/
	IF TG_OP = 'INSERT' THEN -- Caso a operação seja de INSERIR
		INSERT INTO empregado_auditoria VALUES
			(
				'I', 
				CURRENT_USER, -- Variável que retorna o usuário do momento da operação
				CURRENT_TIMESTAMP, -- Variável que retorna data/hora do momento da operação
				NEW.nome, 
				NEW.salario
			);
	ELSIF TG_OP = 'UPDATE' THEN -- Caso a operação escolhida seja de ATUALIZAR
		INSERT INTO empregado_auditoria VALUES
			(
				'A', 
				CURRENT_USER, 
				CURRENT_TIMESTAMP, 
				NEW.nome,
				NEW.salario
			);
	ELSIF TG_OP = 'DELETE' THEN -- Caso a operação escolhida seja de DELETAR
		INSERT INTO empregado_auditoria VALUES
			(
				'E',
				CURRENT_USER,
				CURRENT_TIMESTAMP,
				OLD.nome,
				OLD.salario
			);
	END IF;

	RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- Trigger que ativa a função registrar_alteracoes_do_empregado()
CREATE OR REPLACE TRIGGER log_de_alteracoes_do_empregado
AFTER INSERT OR UPDATE OR DELETE
ON empregado
FOR EACH ROW
EXECUTE FUNCTION registrar_alteracoes_do_empregado();


------------------------------------------------------------------------------------------
--											QUESTÃO 4
------------------------------------------------------------------------------------------

/*
Enunciado:
Crie a tabela Empregado2 com os atributos código (serial e
chave primária), nome (varchar) e salário (integer). Crie
também a tabela Empregado2_audit com os seguintes
atributos: usuário (varchar), data (timestamp), id (integer),
coluna (text), valor_antigo (text), valor_novo(text). Agora crie
um trigger que não permita a alteração da chave primária e
insira registros na tabela Empregado2_audit para refletir as
alterações realizadas na tabela Empregado2.
*/

/*
Gera, na tabela empregado2_audit, registros das alterações realizadas na tabela empregado2.
Também impede que a chave primária seja alterada.
*/
CREATE OR REPLACE FUNCTION registrar_alteracoes_de_empregado2()
RETURNS TRIGGER AS $$
BEGIN
	-- Retorna uma exceção caso o usuário tente mudar a chave primária de empregado2
	IF NEW.codigo <> OLD.codigo THEN
		RAISE EXCEPTION 'O código do empregado não pode ser alterado!';
	END IF;

	IF TG_OP = 'INSERT' THEN
		INSERT INTO empregado2_audit
		VALUES
		(
			SESSION_USER,
			CURRENT_TIMESTAMP,
			NEW.codigo,
			'nome',
			NULL,
			NEW.nome
		),
		(
			SESSION_USER,
			CURRENT_TIMESTAMP,
			NEW.codigo,
			'salario',
			NULL,
			NEW.salario
		);
	ELSIF TG_OP = 'UPDATE' THEN
		IF NEW.nome IS DISTINCT FROM OLD.nome THEN
			INSERT INTO empregado2_audit
			VALUES
			(
				SESSION_USER,
				CURRENT_TIMESTAMP,
				OLD.codigo,
				'nome',
				OLD.nome,
				NEW.nome
			);
		END IF;

		IF NEW.salario <> OLD.salario THEN
			INSERT INTO empregado2_audit
			VALUES
			(
				SESSION_USER,
				CURRENT_TIMESTAMP,
				OLD.codigo,
				'salario',
				OLD.salario::TEXT, -- ::TEXT serve para converter dados para texto
				NEW.salario::TEXT
			);
		END IF;
	ELSIF TG_OP = 'DELETE' THEN
		INSERT INTO empregado2_audit
		VALUES
		(
			SESSION_USER,
			CURRENT_TIMESTAMP,
			OLD.codigo,
			'nome',
			OLD.nome,
			NULL
		),
		(
			SESSION_USER,
			CURRENT_TIMESTAMP,
			OLD.codigo,
			'salario',
			OLD.salario,
			NULL
		);
	END IF;

	RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- Trigger que ativa a função registrar_alteracoes_de_empregado2()
CREATE OR REPLACE TRIGGER log_de_alteracoes_do_empregado2
AFTER INSERT OR UPDATE OR DELETE
ON empregado2
FOR EACH ROW
EXECUTE FUNCTION registrar_alteracoes_de_empregado2();
