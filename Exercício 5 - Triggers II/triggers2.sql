-- Atividade referente à segunda atividade sobre triggers da disciplina de Banco de Dados II


--------------------------------------------------------------------------------------------
--									 CRIAÇÃO DAS TABELAS
--------------------------------------------------------------------------------------------

-- Criação da tabela fornecedor
CREATE TABLE fornecedor(
	cod_fornecedor INTEGER PRIMARY KEY NOT NULL,
	nome_fornecedor VARCHAR(40) NOT NULL,
	endereco_fornecedor VARCHAR(80) NOT NULL
);


-- Criação da tabela livro
CREATE TABLE livro(
	cod_livro INTEGER PRIMARY KEY NOT NULL,
	cod_titulo VARCHAR(80) NOT NULL,
	quant_estoque INTEGER NOT NULL,
	valor_unitario FLOAT NOT NULL
);


-- Criação da tabela titulo
CREATE TABLE titulo(
	cod_titulo INTEGER PRIMARY KEY NOT NULL,
	descr_titulo TEXT NOT NULL
);


-- Criação da tabela pedido
CREATE TABLE pedido(
	cod_pedido INTEGER,
	cod_fornecedor INTEGER,
	data_pedido DATE,
	hora_pedido TIMESTAMP,
	valor_total_pedido FLOAT,
	quant_itens_pedidos INTEGER
);


-- Criação da tabela item_pedido
CREATE TABLE item_pedido(
	cod_livro INTEGER,
	cod_pedido INTEGER,
	quantidade_item INTEGER,
	valor_total_item FLOAT
);


DROP TABLE item_pedido;
DROP TABLE pedido;


--------------------------------------------------------------------------------------------
--									MANIPULAÇÃO DE DADOS
--------------------------------------------------------------------------------------------

INSERT INTO fornecedor VALUES 
	(1, 'Editora Atlas', 'Rua Helvetia, 574'),
	(2, 'Editora Rocco', 'Rua Evaristo da Veiga, 65'),
	(3, 'Editora Globo', 'Rua Marquês de Pombal, 25');


INSERT INTO titulo VALUES 
	(101, 'Sapiens: Uma Breve História da Humanidade'),
	(102, 'Drácula'),
	(103, 'Banco de Dados: Fundamentos e Prática'),
	(104, 'Dom Casmurro');


INSERT INTO livro VALUES 
	(1001, 101, 50, 89.90),
	(1002, 102, 35, 59.50),
	(1003, 103, 20, 120.00),
	(1004, 104, 10, 150.00);


INSERT INTO pedido VALUES
	(5001, 1, '2024-02-15', '2024-02-15 10:30:00', 538.00, 3),
	(5002, 2, '2024-02-16', '2024-02-16 14:00:00', 240.00, 2),
	(5003, 3, '2024-02-17', '2024-02-17 09:45:00', 300.00, 1);


INSERT INTO item_pedido VALUES
	(1001, 5001, 2, 179.80),
	(1002, 5001, 3, 178.50),
	(1003, 5001, 1, 120.00),
	(1002, 5002, 2, 119.00),
	(1004, 5002, 1, 121.00),
	(1004, 5003, 2, 300.00);


--------------------------------------------------------------------------------------------
--									     QUESTÃO 1
--------------------------------------------------------------------------------------------

/*
Enunciado:
Implemente o banco de dados que controla as compras de livros de uma livraria em seus
respectivos fornecedores, de acordo com o esquema abaixo. Os domínios dos atributos 
ficarão a seu critério. Não se esqueça de povoar as tabelas.

Tabelas a serem criadas:
Fornecedor (cod_fornecedor, nome_fornenecdor, endereco_fornecedor)
Livro (cod_livro, cod_titulo, quant_estoque, valor_unitario)
Titulo (cod_titulo, descr_titulo)
Pedido (cod_pedido, cod_fornecedor, data_pedido, hora_pedido, valor_total_pedido,
quant_itens_pedidos)
Item_pedido (cod_livro, cod_pedido, quantidade_item, valor_total_item)

Obs: Durante a criação das tabelas, não implemente restrições de chaves primárias e
estrangeiras e nem restrições de valores não nulos nas tabelas Pedido e Item_pedido.
*/

/*
A criação das tabelas se encontra na seção de 'CRIAÇÃO DE TABELAS' (não me diga).
Já a povoamento das tabelas se encontra na seção de 'MANIPULAÇÃO DE DADOS'.
*/


--------------------------------------------------------------------------------------------
--									     QUESTÃO 2
--------------------------------------------------------------------------------------------

/*
Enunciado geral:
Responda as questões a seguir:
*/


/*
Enunciado 2.A)
Mostre o nome dos fornecedores que venderam mais de X reais no mês de fevereiro de
2024.
*/

-- X nesse caso será 200
SELECT nome_fornecedor
FROM fornecedor
JOIN pedido ON fornecedor.cod_fornecedor = pedido.cod_fornecedor
WHERE valor_total_pedido > 250 AND data_pedido BETWEEN '2024-02-01' AND '2024-02-29';

/*
Enunciado 2.B)
Mostre o nome de um dos fornecedores que mais vendeu no mês de fevereiro de 2024.
*/

SELECT nome_fornecedor
FROM fornecedor
JOIN pedido ON fornecedor.cod_fornecedor = pedido.cod_fornecedor
WHERE data_pedido BETWEEN '2024-02-01' AND '2024-02-29'
GROUP BY nome_fornecedor
ORDER BY SUM(valor_total_pedido)
LIMIT 1;


/*
Enunciado 2.C)
Qual o nome do(s) fornecedor(es) que mais vendeu(eram) no mês de fevereiro de 2024?
*/

/*
O agrupamento por nome e a soma dos valores vendidos por cada um dos fornecedores é
realizado previamente com a cláusula WITH
*/
WITH total_vendido AS (
	SELECT nome_fornecedor, SUM(valor_total_pedido) AS total
	FROM fornecedor
	JOIN pedido ON fornecedor.cod_fornecedor = pedido.cod_fornecedor
	WHERE data_pedido BETWEEN '2024-02-01' AND '2024-02-29'
	GROUP BY nome_fornecedor
)

-- Consulta principal feita através da "tabela" criada com o WITH
SELECT nome_fornecedor
FROM total_vendido
WHERE total = 
(
	SELECT MAX(total)
	FROM total_vendido
);


--------------------------------------------------------------------------------------------
--									     QUESTÃO 3
--------------------------------------------------------------------------------------------

/*
Enunciado geral:
Usando trigger, responda as questões a seguir
*/

--------------------------------------------------------------------------------------------

/*
Enunciado 3.A)
Crie triggers que implementem todas essas restrições de chave primária, chave estrangeira
e valores não nulos nas tabelas Pedido e Item_pedido.
*/

-- Implementa as restrições necessárias na tabela pedido
CREATE OR REPLACE FUNCTION verificacao_de_restricoes_de_pedido()
RETURNS TRIGGER AS $$
BEGIN
	-- Impede que os valores obrigatórios da tabela sejam nulos
	IF NEW.cod_pedido ISNULL OR NEW.cod_fornecedor ISNULL OR
	NEW.data_pedido ISNULL OR NEW.hora_pedido ISNULL THEN
		RAISE EXCEPTION 'Campos obrigatórios não devem ser nulos';
	END IF;

	-- Impede que o código do pedido seja repetido
	IF EXISTS 
	(
		SELECT 1
		FROM pedido
		WHERE cod_pedido = NEW.cod_pedido
	) 
	THEN
		RAISE EXCEPTION 'Código do pedido deve ser único';
	END IF;

	-- Impede que o código do fornecedor seja inválido (caso de fornecedor inexistente)
	IF NOT EXISTS
	(
		SELECT 1
		FROM fornecedor
		WHERE cod_fornecedor = NEW.cod_fornecedor
	)
	THEN
		RAISE EXCEPTION 'Vendedor não existe';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que ativa a função verificacao_de_restricoes_de_pedido()
CREATE OR REPLACE TRIGGER ativar_verificacao_de_restricoes_de_pedido
BEFORE INSERT OR UPDATE ON pedido
FOR EACH ROW
EXECUTE FUNCTION verificacao_de_restricoes_de_pedido();

-- Implementa as restrições necessárias na tabela item_pedido
CREATE OR REPLACE FUNCTION verificacao_de_restricoes_de_item_pedido()
RETURNS TRIGGER AS $$
BEGIN
	-- Impede que valores nulos sejam digitados na tabela item_pedido
	IF NEW.cod_livro ISNULL OR NEW.cod_pedido ISNULL OR NEW.quantidade_item ISNULL
	OR NEW.valor_total_item ISNULL THEN
		RAISE EXCEPTION 'Campos obrigatórios não devem ter valor nulo';
	END IF;

	-- Impede que as chaves primária e estrangeira contenham valor repetido
	IF EXISTS
	(
		SELECT 1
		FROM item_pedido
		WHERE cod_livro = NEW.cod_livro AND cod_pedido = NEW.cod_pedido
	)
	THEN
		RAISE EXCEPTION 'Item já registrado';
	END IF;

	-- Impede que o código do livro seja inválido (Caso de livro inexistente)
	IF NOT EXISTS
	(
		SELECT 1
		FROM livro
		WHERE cod_livro = NEW.cod_livro
	)
	THEN
		RAISE EXCEPTION 'Código de livro inexistente';
	END IF;

	-- Impede que o código do pedido seja inválido (Caso de pedido inexistente)
	IF NOT EXISTS
	(
		SELECT 1
		FROM pedido
		WHERE cod_pedido = NEW.cod_pedido
	)
	THEN
		RAISE EXCEPTION 'Código de pedido inexistente';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que ativa a função verificacao_de_restricoes_de_item_pedido
CREATE OR REPLACE TRIGGER ativar_verificacao_de_restricoes_de_item_pedido
BEFORE INSERT OR UPDATE ON item_pedido
FOR EACH ROW
EXECUTE FUNCTION verificacao_de_restricoes_de_item_pedido();

--------------------------------------------------------------------------------------------

/*
Enunciado 3.B)
Crie um trigger na tabela Livro que não permita quantidade em estoque negativa e sempre
que a quantidade em estoque atingir 10 ou menos unidades, um aviso de quantidade mínima
deve ser emitido ao usuário (para emitir alertas sem interromper a execução da transação,
você pode usar "raise notice" ou "raise info").
*/

/*
O.B.S: Não consegui encontrar uma maneira adequada de resolver a questão usando apenas
uma função e um trigger. Sendo assim, optei por resolver usando duas funções e dois
triggers separados, o que possibilitou fazer o que foi proposto pelo enunciado da questão.
*/

-- Impede que a quantidade de livros em estoque seja negativa
CREATE OR REPLACE FUNCTION restricao_de_valores_negativos()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.quant_estoque < 0 THEN
		RAISE EXCEPTION 'Quantidade de livros em estoque não pode ser negativa';
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Ativa a função restricao_de_valores_negativos()
CREATE OR REPLACE TRIGGER ativar_restricao_de_valores_negativos
BEFORE INSERT OR UPDATE ON livro
FOR EACH ROW 
EXECUTE FUNCTION restricao_de_valores_negativos();

/*
Lança um alerta informando o usuário que a quantidade de livros em estoque está baixa (
com 10 ou menos livros).
*/
CREATE OR REPLACE FUNCTION aviso_de_baixa_quantidade_de_livros()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.quant_estoque <= 10 AND NEW.quant_estoque > 0 THEN
		RAISE NOTICE 'Baixa quantidade de livros em estoque';
	END IF;

	IF NEW.quant_estoque = 0 THEN
		RAISE NOTICE 'Sem livros no estoque';
	END IF;

	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Ativa a função aviso_de_baixa_quantidade_de_livros
CREATE OR REPLACE TRIGGER ativar_aviso_de_baixa_quantidade_de_livros
AFTER INSERT OR UPDATE ON livro
FOR EACH ROW
EXECUTE FUNCTION aviso_de_baixa_quantidade_de_livros();

--------------------------------------------------------------------------------------------

/*
Enunciado 3.C)
Crie um trigger que sempre que houver inserções, remoções ou alterações na tabela
"Item_pedido", haja a atualização da "quant_itens_pedidos" e do "valor_total_pedido" da
tabela "pedido", bem como a atualização da quantidade em estoque da tabela Livro.
*/

CREATE OR REPLACE FUNCTION atualizar_dados_do_pedido()
RETURNS TRIGGER AS $$
BEGIN
	UPDATE pedido
	SET
		quant_itens_pedidos =
		(
			SELECT SUM(quantidade_item)
			FROM item_pedido
			WHERE cod_pedido = NEW.cod_pedido
		),
		valor_total_pedido =
		(
			SELECT SUM(valor_total_pedido)
			FROM item_pedido
			WHERE cod_pedido = NEW.cod_pedido
		)
	WHERE cod_pedido = NEW.cod_pedido;

	UPDATE livro
	SET quant_estoque = quant_estoque - NEW.quantidade_item
	WHERE cod_livro = NEW.cod_livro;

	RETURN NULL;
END;
$$ LANGUAGE plpgsql;


--------------------------------------------------------------------------------------------

/*
Enunciado 3.D)
Crie uma tabela chamada "controla_alteracao". Nesta tabela, deverão ser armazenadas as
alterações (update, delete) feitas na tabela "livro". Deverão ser registradas as seguintes
informações: operação que foi realizada, a data e hora, além do usuário que realizou a
modificação. No caso de acontecer uma atualização, deverão ser registrados os valores novos
e os valores antigos da coluna "cod_titulo" do livro e quantidade em estoque. No caso de
acontecer uma deleção, basta armazenar o "cod_titulo" do livro e a respectiva quantidade em
estoque que foi deletada.
*/


