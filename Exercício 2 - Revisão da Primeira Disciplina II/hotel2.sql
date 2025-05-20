-- Segundo exercício da disciplina de Banco de Dados II


-------------------------------------------------------------------------------------------
--									 CRIAÇÃO DAS TABELAS
-------------------------------------------------------------------------------------------

-- Criação da tabela HOSPEDE
CREATE TABLE HOSPEDE (
    COD_HOSP INTEGER NOT NULL PRIMARY KEY,
    NOME VARCHAR(40) NOT NULL,
    DT_NASC DATE NULL
);


-- Criação da tabela CATEGORIA
CREATE TABLE CATEGORIA (
    COD_CAT INT NOT NULL PRIMARY KEY,
    NOME VARCHAR(40) NOT NULL,
    VALOR_DIA FLOAT NOT NULL
);


-- Criação da tabela APTO
CREATE TABLE APTO (
    NUM INT NOT NULL PRIMARY KEY,
    COD_CAT INT NOT NULL REFERENCES CATEGORIA(COD_CAT)
);


-- Criação da tabela FUNCIONARIO
CREATE TABLE FUNCIONARIO (
    COD_FUNC INT NOT NULL PRIMARY KEY,
    NOME VARCHAR(50) NOT NULL,
    DT_NASC DATE
);


-- Criacao da tabela HOSPEDAGEM
CREATE TABLE HOSPEDAGEM (
    COD_HOSPEDA INT NOT NULL PRIMARY KEY,
    COD_HOSP INT NOT NULL REFERENCES HOSPEDE(COD_HOSP),
    NUM INT NOT NULL REFERENCES APTO(NUM),
    COD_FUNC INT NOT NULL REFERENCES FUNCIONARIO(COD_FUNC),
    DT_ENT DATE NOT NULL,
    DT_SAI DATE
);


-------------------------------------------------------------------------------------------
--										INSERÇÃO DE DADOS
-------------------------------------------------------------------------------------------

-- Inserindo dados na tabela HOSPEDE
INSERT INTO HOSPEDE VALUES
(1, 'João Silva', '1985-03-15'),
(2, 'Maria Souza', '1992-07-21'),
(3, 'Carlos Oliveira', '1969-12-05'),
(4, 'Ana Pereira', '2001-06-30'),
(5, 'Ayrton Pinheiro', '1992-07-21');


-- Inserindo dados na tabela CATEGORIA
INSERT INTO CATEGORIA VALUES
(1, 'Luxo Executivo', 180.00),
(2, 'Luxo Master', 250.00),
(3, 'Standard', 120.00),
(4, 'Econômico', 80.00),
(5, 'Super Luxo', 300);


-- Inserindo dados na tabela APTO
INSERT INTO APTO VALUES
(101, 1),
(102, 2),
(201, 3),
(202, 4),
(203, 1),
(301, 5),;


-- Inserindo dados na tabela FUNCIONARIO
INSERT INTO FUNCIONARIO VALUES
(1, 'Paulo Mendes', '1980-10-12'),
(2, 'Fernanda Lopes', '1995-04-25'),
(3, 'Ricardo Alves', '1972-08-17'),
(4, 'Joaquim Pereira', '1975-01-02');


-- Inserindo dados na tabela HOSPEDAGEM
INSERT INTO HOSPEDAGEM VALUES
(1, 1, 101, 1, '2018-03-01', '2025-03-05'),
(2, 2, 102, 2, '2016-03-02', NULL), -- Ocupado
(3, 3, 201, 3, '2017-02-28', '2025-03-03'),
(4, 4, 203, 1, '2016-03-04', NULL),
(5, 1, 101, 2, '2017-04-01', NULL),
(6, 2, 301, 1, '2017-06-01', '2017-06-03'),
(7, 1, 301, 3, '2017-12-09', '2017-12-13'),
(8, 1, 102, 4, '2016-08-08', NULL),
(9, 1, 202, 4, '2016-05-10', '2016-05-11'),
(10, 5, 101, 3, '2017-01-12', '2017-01-14'),
(11, 1, 201, 3, '2018-04-01', '2018-04-05'),
(12, 1, 203, 4, '2018-05-08', NULL); -- Ocupado


-- Adiciona a coluna nacionalidade à tabela hospede
ALTER TABLE hospede
ADD COLUMN nacionalidade VARCHAR(30);

-- Atualiza os valores na coluna nacionalidade
UPDATE hospede
SET nacionalidade = 'Brasileiro'
WHERE nacionalidade is NULL;

-- Impede que futuros valores da coluna "nacionalidade" sejam NULL
ALTER TABLE hospede
ALTER COLUMN nacionalidade
set not NULL;

-- Adiciona a coluna salario à tabela funcionario
ALTER TABLE funcionario
ADD COLUMN salario FLOAT;

-- Atribui o salário dos funcionários, cada um com valores diferentes
UPDATE funcionario
SET salario = CASE cod_func
	WHEN 1 THEN 1800.00
    WHEN 2 THEN 600.00
    WHEN 3 THEN 1200.00
END
WHERE cod_func IN (1, 2, 3);


-------------------------------------------------------------------------------------------
--										QUESTÃO 1
-------------------------------------------------------------------------------------------

/*
Enunciado:
Listagem dos hóspedes contendo nome e data de nascimento, ordenada em ordem
crescente por nome e decrescente por data de nascimento.
*/

SELECT nome, dt_nasc as data_de_nascimento
from hospede
order by nome ASC, dt_nasc DESC;


-------------------------------------------------------------------------------------------
--										QUESTÃO 2
-------------------------------------------------------------------------------------------

/*
Enunciado:
Listagem contendo os nomes das categorias, ordenados alfabeticamente. A coluna de
nomes deve ter a palavra ‘Categoria’ como título.
*/

SELECT nome as Categoria
from categoria
order by nome;


-------------------------------------------------------------------------------------------
--										QUESTÃO 3
-------------------------------------------------------------------------------------------

/*
Enunciado:
Listagem contendo os valores de diárias e os números dos apartamentos, ordenada em
ordem decrescente de valor.
*/

SELECT categoria.valor_dia, apto.num
from categoria
JOIN apto on categoria.cod_cat = apto.cod_cat
order by valor_dia desc;


-------------------------------------------------------------------------------------------
--										QUESTÃO 4
-------------------------------------------------------------------------------------------

/*
Enunciado:
Categorias que possuem apenas um apartamento.
*/

SELECT nome
from categoria
join apto on categoria.cod_cat = apto.cod_cat
group by categoria.cod_cat
HAVING COUNT(apto.cod_cat) = 1;


-------------------------------------------------------------------------------------------
--										QUESTÃO 5
-------------------------------------------------------------------------------------------

/*
Enunciado:
Listagem dos nomes dos hóspedes brasileiros com mês e ano de nascimento, por ordem
decrescente de idade e por ordem crescente de nome do hóspede.
*/

UPDATE hospede
set nacionalidade = 'Português'
WHERE cod_hosp = 3;

SELECT *
from hospede;

SELECT nome, TO_CHAR(dt_nasc, 'YYYY-MM') as data_de_nascimento
from hospede
WHERE nacionalidade = 'Brasileiro'
ORDER by dt_nasc, nome;


-------------------------------------------------------------------------------------------
--										QUESTÃO 6
-------------------------------------------------------------------------------------------

/*
Enunciado:
Listagem com 3 colunas, nome do hóspede, número do apartamento e quantidade (número
de vezes que aquele hóspede se hospedou naquele apartamento), em ordem decrescente de
quantidade.
*/

SELECT nome, num, COUNT(hospedagem.num) as quantidade_de_hospedagens
from hospede
JOIN hospedagem on hospede.cod_hosp = hospedagem.cod_hosp
GROUP by hospede.cod_hosp, num
order by quantidade_de_hospedagens desc;


-------------------------------------------------------------------------------------------
--										QUESTÃO 7
-------------------------------------------------------------------------------------------

/*
Enunciado:
Categoria cujo nome tenha comprimento superior a 15 caracteres.
*/

SELECT nome
FROM categoria
WHERE LENGTH(nome) > 15;


-------------------------------------------------------------------------------------------
--										QUESTÃO 8
-------------------------------------------------------------------------------------------

/*
Enunciado:
Número dos apartamentos ocupados no ano de 2017 com o respectivo nome da sua
categoria.
*/

SELECT apto.num, categoria.nome
FROM categoria
JOIN apto on categoria.cod_cat = apto.cod_cat
JOIN hospedagem on apto.num = hospedagem.num
WHERE dt_ent BETWEEN '2017-01-01' and '2017-12-31';


-------------------------------------------------------------------------------------------
--										QUESTÃO 9
-------------------------------------------------------------------------------------------

/*
Enunciado:
Título do livro, nome da editora que o publicou e a descrição do assunto
*/

-- LIVRO??????


-------------------------------------------------------------------------------------------
--										QUESTÃO 10
-------------------------------------------------------------------------------------------

/*
Enunciado:
Crie a tabela funcionário com as atributos: cod_func, nome, dt_nascimento e salário.
Depois disso, acrescente o cod_func como chave estrangeira nas tabelas hospedagem e
reserva.
*/

-- Resolução na seção de "INSERÇÃO DE DADOS"


-------------------------------------------------------------------------------------------
--										QUESTÃO 11
-------------------------------------------------------------------------------------------

/*
Enunciado:
Mostre o nome e o salário de cada funcionário. Extraordinariamente, cada funcionário
receberá um acréscimo neste salário de 10 reais para cada hospedagem realizada.
*/

SELECT 
	funcionario.nome, 
    funcionario.salario + (COUNT(hospedagem) * 10) as salario_com_acrescimos, 
    COUNT(hospedagem)
from funcionario
LEFT JOIN hospedagem ON funcionario.cod_func = hospedagem.cod_func
GROUP by funcionario.nome, funcionario.salario;


-------------------------------------------------------------------------------------------
--										QUESTÃO 12
-------------------------------------------------------------------------------------------

/*
Enunciado:
Listagem das categorias cadastradas e para aquelas que possuem apartamentos, relacionar
também o número do apartamento, ordenada pelo nome da categoria e pelo número do
apartamento.
*/

SELECT categoria.nome, apto.num
FROM categoria
LEFT JOIN apto on categoria.cod_cat = apto.cod_cat
GROUP by categoria.nome, apto.num
order by categoria.nome, apto.num;


-------------------------------------------------------------------------------------------
--										QUESTÃO 13
-------------------------------------------------------------------------------------------

/*
Enunciado:
Listagem das categorias cadastradas e para aquelas que possuem apartamentos, relacionar
também o número do apartamento, ordenada pelo nome da categoria e pelo número do
apartamento. Para aquelas que não possuem apartamentos associados, escrever "não possui
apartamento".
*/

SELECT 
	categoria.nome, 
  COALESCE(apto.num, 'não possui apartamento') as num_apto
from categoria
LEFT JOIN apto on categoria.cod_cat = apto.cod_cat
GROUP by categoria.nome, apto.num;


-------------------------------------------------------------------------------------------
--										QUESTÃO 14
-------------------------------------------------------------------------------------------

/*
Enunciado:
O nome dos funcionários que atenderam o João (hospedando ou reservando) ou que
hospedaram ou reservaram apartamentos da categoria luxo.
*/

/*
Para facilitar a visualização do resultado, inclui também o nome do hóspede e o
nome da categoria.
*/
SELECT funcionario.nome, hospede.nome, categoria.nome
FROM hospede
JOIN hospedagem on hospede.cod_hosp = hospedagem.cod_hosp
JOIN funcionario on hospedagem.cod_func = funcionario.cod_func
JOIN apto on hospedagem.num = apto.num
JOIN categoria on apto.cod_cat = categoria.cod_cat
WHERE hospede.nome IN(
  SELECT hospede.nome
  FROM hospede
  -- Tomei a liberdade de usar o nome específico de um João que já existia na base de dados
  WHERE hospede.nome = 'João Silva'
)
OR apto.cod_cat IN(
  SELECT apto.cod_cat
  FROM apto
  /*
  Também tomei a liberdade de usar a categoria 'Luxo Executivo', tendo em vista que não há
  uma categoria chamada apenas de 'Luxo' na base de dados.
  */
  WHERE apto.cod_cat = 1
);


-------------------------------------------------------------------------------------------
--										QUESTÃO 15
-------------------------------------------------------------------------------------------

/*
Enunciado:
O código das hospedagens realizadas pelo hóspede mais velho que se hospedou no
apartamento mais caro.
*/

-- 1ª Resolução
SELECT cod_hospeda
from hospedagem
WHERE cod_hosp IN 
(
  SELECT cod_hosp
  from hospede
  WHERE dt_nasc IN 
  (
    SELECT MIN(dt_nasc)
    from hospede
    WHERE cod_hosp IN
    (
      SELECT cod_hosp
      from hospedagem
      WHERE num IN
      (
        SELECT num
        from apto
        where cod_cat IN
        (
          SELECT cod_cat
          from categoria
          WHERE valor_dia IN
          (
            SELECT MAX(valor_dia)
            from categoria
          )
        )
      )
    )
  )
);

    
-- 2ª Resolução

-- Achamos primeiro a categoria mais cara
WITH categoria_mais_cara AS
(
  SELECT cod_cat
  FROM categoria
  WHERE valor_dia =
  (
    SELECT MAX(valor_dia)
    FROM categoria
  )
),

-- Depois achamos os apartamentos dessa categoria
apartamentos_da_categoria_mais_cara AS
(
  SELECT num
  FROM apto
  JOIN categoria_mais_cara ON apto.cod_cat = categoria_mais_cara.cod_cat
),

/*
Depois achamos também todos os hospedes que se hospedaram nos apartamentos da categoria 
mais cara
*/
hospedes_dos_apartamentos_mais_caros AS
(
  SELECT hospede.cod_hosp, hospede.dt_nasc
  from hospede
  JOIN hospedagem on hospede.cod_hosp = hospedagem.cod_hosp
  WHERE hospedagem.num IN
  (
    SELECT apartamentos_da_categoria_mais_cara.num
    FROM apartamentos_da_categoria_mais_cara
  )
),

-- Dentre esses hóspedes, procuramos agora o hóspede mais velho
hospede_mais_velho AS
(
  SELECT hospedes_dos_apartamentos_mais_caros.cod_hosp
  from hospedes_dos_apartamentos_mais_caros
  WHERE dt_nasc IN
  (
    SELECT MIN(hospedes_dos_apartamentos_mais_caros.dt_nasc)
    FROM hospedes_dos_apartamentos_mais_caros
  )
)

-- Com a cláusula With finalizada, agora partimos para o comando em si
SELECT hospedagem.cod_hospeda
FROM hospedagem
WHERE hospedagem.cod_hosp IN
(
  SELECT hospede_mais_velho.cod_hosp
  FROM hospede_mais_velho
);


-------------------------------------------------------------------------------------------
--										QUESTÃO 16
-------------------------------------------------------------------------------------------

/*
Enunciado:
Sem usar subquery, o nome dos hóspedes que nasceram na mesma data do hóspede de
código 2.
*/

SELECT H2.NOME 
FROM HOSPEDE AS H1, HOSPEDE AS H2 
WHERE H1.COD_HOSP <> H2.COD_HOSP AND H1.COD_HOSP = 2 AND H1.DT_NASC = H2.DT_NASC; 


-------------------------------------------------------------------------------------------
--										QUESTÃO 17
-------------------------------------------------------------------------------------------

/*
Enunciado:
O nome do hóspede mais velho que se hospedou na categoria mais cara no ano de 2017.
*/

SELECT hospede.nome
FROM hospede
JOIN hospedagem ON hospede.cod_hosp = hospedagem.cod_hosp
JOIN apto on hospedagem.num = apto.num
JOIN categoria on apto.cod_cat = categoria.cod_cat
WHERE hospedagem.dt_ent BETWEEN '2017-01-01' AND '2017-12-31'
AND categoria.valor_dia IN(
  SELECT MAX(valor_dia)
  FROM categoria
)
AND hospede.dt_nasc IN(
  SELECT MIN(hospede.dt_nasc)
  FROM hospede
  JOIN hospedagem ON hospede.cod_hosp = hospedagem.cod_hosp
  JOIN apto on hospedagem.num = apto.num
  JOIN categoria on apto.cod_cat = categoria.cod_cat
  WHERE hospedagem.dt_ent BETWEEN '2017-01-01' AND '2017-12-31'
  AND categoria.valor_dia IN(
    SELECT MAX(valor_dia)
    FROM categoria
  )
);


-------------------------------------------------------------------------------------------
--										QUESTÃO 18
-------------------------------------------------------------------------------------------

/*
Enunciado:
O nome das categorias que foram reservadas pela Maria ou que foram ocupadas pelo João
quando ele foi atendido pelo Joaquim.
*/

SELECT CATEGORIA.NOME, HOSPEDE.NOME, FUNCIONARIO.NOME
FROM HOSPEDE
JOIN HOSPEDAGEM ON HOSPEDE.COD_HOSP = HOSPEDAGEM.COD_HOSP
JOIN FUNCIONARIO ON HOSPEDAGEM.COD_FUNC = FUNCIONARIO.cod_func
JOIN APTO ON HOSPEDAGEM.num = APTO.num
JOIN CATEGORIA ON APTO.cod_cat = CATEGORIA.cod_cat
WHERE HOSPEDE.NOME = 'Maria Souza'
OR (HOSPEDE.NOME = 'João Silva' AND FUNCIONARIO.NOME = 'Joaquim Pereira');


-------------------------------------------------------------------------------------------
--										QUESTÃO 19
-------------------------------------------------------------------------------------------

/*
Enunciado:
O nome e a data de nascimento dos funcionários, além do valor de diária mais cara
reservado por cada um deles.
*/

SELECT FUNCIONARIO.nome, FUNCIONARIO.dt_nasc, MAX(valor_dia) AS maior_valor
FROM FUNCIONARIO
JOIN HOSPEDAGEM ON FUNCIONARIO.cod_func = HOSPEDAGEM.cod_func
JOIN APTO ON HOSPEDAGEM.num = APTO.num
JOIN CATEGORIA ON APTO.cod_cat = CATEGORIA.cod_cat
GROUP BY FUNCIONARIO.nome, FUNCIONARIO.dt_nasc;


-------------------------------------------------------------------------------------------
--										QUESTÃO 20
-------------------------------------------------------------------------------------------

/*
Enunciado:
A quantidade de apartamentos ocupados por cada um dos hóspedes (mostrar o nome).
*/

SELECT HOSPEDE.nome, COUNT(APTO) AS cont_apto
FROM HOSPEDE
JOIN HOSPEDAGEM ON HOSPEDE.cod_hosp = HOSPEDAGEM.cod_hosp
JOIN APTO ON HOSPEDAGEM.num = APTO.num
GROUP BY HOSPEDE.nome;


-------------------------------------------------------------------------------------------
--										QUESTÃO 21
-------------------------------------------------------------------------------------------

/*
Enunciado:
A relação com o nome dos hóspedes, a data de entrada, a data de saída e o valor total
pago em diárias (não é necessário considerar a hora de entrada e saída, apenas as datas).
*/

SELECT HOSPEDE.NOME, DT_ENT, DT_SAI, (DT_SAI - DT_ENT) * VALOR_DIA AS VALOR_TOTAL_PAGO
FROM HOSPEDE JOIN HOSPEDAGEM ON HOSPEDE.COD_HOSP = HOSPEDAGEM.COD_HOSP 
JOIN APTO ON HOSPEDAGEM.NUM = APTO.NUM 
JOIN CATEGORIA ON APTO.COD_CAT = CATEGORIA.COD_CAT;


-------------------------------------------------------------------------------------------
--										QUESTÃO 22
-------------------------------------------------------------------------------------------

/*
Enunciado:
O nome dos hóspedes que já se hospedaram em todos os apartamentos do hotel.
*/

SELECT hospede.nome
FROM hospede
JOIN hospedagem ON hospede.cod_hosp = hospedagem.cod_hosp
GROUP BY hospede.cod_hosp, hospede.nome
HAVING COUNT(DISTINCT hospedagem.num) = (SELECT COUNT(*) FROM apto);

