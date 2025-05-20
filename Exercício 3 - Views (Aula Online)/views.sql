-- Exercício de Banco de Dados sobre Views, da aula do sábado letivo de 12/04/2025


-------------------------------------------------------------------------------------------
--									CRIAÇÃO DA TABELA
-------------------------------------------------------------------------------------------


-- Solução da questão 0
CREATE TABLE VENDA(
	COD_VENDA SERIAL, 
	NOME_VEND VARCHAR(40),
	DT_VENDA DATE,
	VALOR_VENDIDO FLOAT
);


-------------------------------------------------------------------------------------------
--									INSERÇÃO DE DADOS
-------------------------------------------------------------------------------------------

-- Solução da questão 1
INSERT INTO VENDA VALUES
	(DEFAULT, 'JOAO', '2024-03-10', 1000),
	(DEFAULT, 'JOAO', '2024-03-11', 50),
	(DEFAULT, 'JOAO', '2024-04-10', 100),
	(DEFAULT, 'JOSE', '2024-03-10', 500),
	(DEFAULT, 'JOSE', '2024-03-10', 500),
	(DEFAULT, 'JOSE', '2024-05-10', 1000),
	(DEFAULT, 'ANTONIO', '2024-03-10', 100),
	(DEFAULT, 'ANTONIO', '2024-03-10', 100),
	(DEFAULT, 'ANTONIO', '2024-03-10', 100),
	(DEFAULT, 'ANTONIO', '2024-03-10', 100),
	(DEFAULT, 'MARIA', '2024-03-10', 100);
	

------------------------------------------------------------------------------------------
--										Questão 0
------------------------------------------------------------------------------------------

/*
Questão 0
Crie a tabela venda com os seguintes atributos:
- Cod_venda
- Nome_vendedor
- data_venda
- Valor_vendido
*/

-- SOLUÇÃO NA SEÇÃO DE CRIAÇÃO DA TABELA


------------------------------------------------------------------------------------------
--										Questão 1
------------------------------------------------------------------------------------------

/*
Enunciado:
Povoe a tabela com 10 vendas, considerando que existam apenas 4
vendedores na loja.
*/

-- SOLUÇÃO NA SEÇÃO DE INSERÇÃO DE DADOS


------------------------------------------------------------------------------------------
--										Questão 2.1
------------------------------------------------------------------------------------------

/*
Enunciado:
Mostre o nome dos vendedores que venderam mais de X reais no
mês de março de 2024.
*/

/*
Cria uma view que contém apenas os nomes e o total vendido por cada funcionário
em Março de 2024, agrupando por nome do vendedor e ordenando as informações
pelo total vendido em ordem decrescente.
*/
CREATE VIEW TOTAL_DE_VENDAS AS
SELECT NOME_VEND, SUM(VALOR_VENDIDO) AS TOTAL_VENDIDO 
FROM VENDA
WHERE DT_VENDA BETWEEN '2024-03-01' AND '2024-03-31'
GROUP BY NOME_VEND
ORDER BY TOTAL_VENDIDO DESC;

-- Realiza a consulta proposta pela questão a partir da view criada anteriormente
SELECT NOME_VEND, TOTAL_VENDIDO
FROM TOTAL_DE_VENDAS
WHERE TOTAL_VENDIDO > 900;


------------------------------------------------------------------------------------------
--										Questão 2.2
------------------------------------------------------------------------------------------

/*
Enunciado:
Mostre o nome de um dos vendedores que mais vendeu no mês
de março de 2024
*/

/*
Seleciona o nome de um dos vendedores que mais vendeu no mês de Março, tomando
como ponto de partida a view total_vendido (Tomei a liberdade de escolher quem
mais vendeu).
*/
SELECT NOME_VEND, TOTAL_VENDIDO
FROM TOTAL_DE_VENDAS
ORDER BY TOTAL_VENDIDO DESC
LIMIT 1;


------------------------------------------------------------------------------------------
--										Questão 3
------------------------------------------------------------------------------------------

/*
Enunciado:
Sem usar “select na cláusula from,”qual o nome do(s)
vendedor(es) que mais vendeu no mês de março de 2024?
*/

-- Solução 1 - Usando WITH (Solução ideal)
WITH MAIOR_VALOR AS(
	SELECT MAX(TOTAL_VENDIDO) AS MAXIMO
	FROM TOTAL_DE_VENDAS
)
SELECT NOME_VEND, TOTAL_VENDIDO
FROM TOTAL_DE_VENDAS
JOIN MAIOR_VALOR ON TOTAL_VENDIDO = MAXIMO;


-- Solução 2 - Usando uma VIEW (Solução exibida)
CREATE OR REPLACE VIEW VENDEDORES_PREMIUM AS
SELECT NOME_VEND, TOTAL_VENDIDO
FROM TOTAL_DE_VENDAS
WHERE TOTAL_VENDIDO = (
	SELECT MAX(TOTAL_VENDIDO)
	FROM TOTAL_DE_VENDAS
);

SELECT *
FROM VENDEDORES_PREMIUM;
