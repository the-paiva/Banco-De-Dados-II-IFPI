-- Exercício de Banco de Dados - Revisão de assuntos da primeira disciplina


--------------------------------------- CRIAÇÃO DAS TABELAS----------------------------------------------


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


--------------------------------------- INSERÇÃO DE DADOS -----------------------------------------------


-- Inserindo dados na tabela HOSPEDE
INSERT INTO HOSPEDE (COD_HOSP, NOME, DT_NASC) VALUES
(1, 'João Silva', '1985-03-15'),
(2, 'Maria Souza', '1992-07-21'),
(3, 'Carlos Oliveira', '1969-12-05'),
(4, 'Ana Pereira', '2001-06-30');


-- Inserindo dados na tabela CATEGORIA
INSERT INTO CATEGORIA (COD_CAT, NOME, VALOR_DIA) VALUES
(1, 'Luxo Executivo', 180.00),
(2, 'Luxo Master', 250.00),
(3, 'Standard', 120.00),
(4, 'Econômico', 80.00);


-- Inserindo dados na tabela APTO
INSERT INTO APTO (NUM, COD_CAT) VALUES
(101, 1),
(102, 2),
(201, 3),
(202, 4),
(203, 1);


-- Inserindo dados na tabela FUNCIONARIO
INSERT INTO FUNCIONARIO (COD_FUNC, NOME, DT_NASC) VALUES
(1, 'Paulo Mendes', '1980-10-12'),
(2, 'Fernanda Lopes', '1995-04-25'),
(3, 'Ricardo Alves', '1972-08-17');


-- Inserindo dados na tabela HOSPEDAGEM
INSERT INTO HOSPEDAGEM (COD_HOSPEDA, COD_HOSP, NUM, COD_FUNC, DT_ENT, DT_SAI) VALUES
(1, 1, 101, 1, '2025-03-01', '2025-03-05'),
(2, 2, 102, 2, '2025-03-02', NULL), -- Ocupado
(3, 3, 201, 3, '2025-02-28', '2025-03-03'),
(4, 4, 203, 1, '2025-03-04', NULL); -- Ocupado


--------------------------------------- RESOLUÇÃO DAS QUESTÕES ------------------------------------------


/*
1ª Questão
Nomes das categorias que possuam preços entre R$ 100,00 e R$ 200,00
*/
SELECT nome
FROM categoria
where valor_dia BETWEEN 100 and 200;


/*
2ª Questão
Nomes das categorias cujos nomes possuam a palavra ‘Luxo’
*/
SELECT nome
from categoria
where nome ILIKE '%Luxo%';


/*
3ª Questão
Número dos apartamentos que estão ocupados, ou seja, a data de saída está vazia
*/
SELECT num as numero_dos_apartamentos_ocupados
from hospedagem
WHERE dt_sai is NULL;


/*
4ª Questão
Número dos apartamentos cuja categoria tenha código 1, 2, 3, 11, 34, 54, 24, 12
*/
SELECT num
FROM apto
WHERE cod_cat in (1, 2, 3, 11, 34, 54, 24, 12);


/*
5ª Questão
Todas as informações dos apartamentos cujas categorias iniciam com a palavra ‘Luxo’.
*/
SELECT *
from apto
WHERE cod_cat in(
  SELECT cod_cat
  FROM categoria
  WHERE categoria.nome ILIKE 'Luxo%'
);


/*
6ª Questão
Quantidade de apartamentos cadastrados no sistema.
*/
SELECT COUNT(*) as quant_apartamentos
FROM apto;


/*
7ª Questão
Somatório dos preços das categorias.
*/
SELECT sum(valor_dia) as somatorio_dos_precos
from categoria;


/*
8ª Questão
Média de preços das categorias.
*/
SELECT ROUND(AVG(valor_dia)::NUMERIC, 2) as media_dos_precos
FROM categoria;


/*
9ª Questão
Maior preço de categoria.
*/
SELECT max(valor_dia) as maior_preco
from categoria;


/*
10ª Questão
Menor preço de categoria.
*/
SELECT min(valor_dia) as menor_preco
from categoria;


/*
11ª Questão
Nome dos hóspedes que nasceram após 1° de janeiro de 1970.
*/
SELECT nome
from hospede
where dt_nasc > '1970-01-01';


/*
12ª Questão
Quantidade de hóspedes
*/
SELECT COUNT(*) as quant_hospedes
from hospede;


/*
13ª Questão
Altere a tabela Hóspede, acrescentando o campo "Nacionalidade".
*/

-- Acrescenta a coluna "nacionalidade"
ALTER TABLE hospede
ADD COLUMN nacionalidade VARCHAR(30);

-- Atualiza os valores 
UPDATE hospede
SET nacionalidade = 'Brasileiro'
WHERE nacionalidade is NULL;

-- Impede que futuros valores da coluna "nacionalidade" sejam NULL
ALTER TABLE hospede
ALTER COLUMN nacionalidade
set not NULL;

/*
14ª Questão
A data de nascimento do hóspede mais velho.
*/
SELECT MIN(dt_nasc)
from hospede;


/*
15ª Questão
A data de nascimento do hóspede mais novo.
*/
SELECT MAX(dt_nasc)
from hospede;


/*
16ª Questão
O nome do hóspede mais velho
*/

-- 1ª Alternativa
SELECT nome
FROM hospede
WHERE dt_nasc = (
  SELECT MIN(dt_nasc)
  from hospede
);

-- 2ª Alternativa
SELECT nome
from hospede
order by dt_nasc asc
LIMIT 1;


/*
17ª Questão
Reajuste em 10% o valor das diárias das categorias.
*/

-- SELECT dos valores, para fins de comparação (antes e depois do reajuste)
SELECT *
from categoria
in (
  SELECT ROUND(valor_dia::NUMERIC, 2)
  from categoria
);

-- Atualização dos valores através de UPDATE
UPDATE categoria
SET valor_dia = valor_dia * 1.10;


/*
18ª Questão
O número do apartamento mais caro ocupado pelo João Silva.
*/
SELECT apto.num
from apto
join categoria on apto.cod_cat = categoria.cod_cat
join hospedagem on apto.num = hospedagem.num
join hospede on hospedagem.cod_hosp = hospede.cod_hosp
group by apto.num, valor_dia, hospede.nome
HAVING hospede.nome = 'João Silva'
order by valor_dia ASC
LIMIT 1;


/*
19ª Questão
O nome dos hóspedes que nunca se hospedaram no apartamento 201.
*/
SELECT hospede.nome
from hospede
JOIN hospedagem on hospede.cod_hosp = hospedagem.cod_hosp
GROUP BY hospede.nome, hospedagem.num
HAVING hospedagem.num not IN (201);


/*
20ª Questão
O nome dos hóspedes que nunca se hospedaram em apartamentos da categoria LUXO.
*/
select hospede.nome
from hospede


/*
21ª Questão
O nome do hóspede mais velho que foi atendido pelo atendente mais novo.
*/
SELECT hospede.nome
from hospede
JOIN hospedagem on hospede.cod_hosp = hospedagem.cod_hosp
JOIN funcionario on hospedagem.cod_func = funcionario.cod_func

WHERE funcionario.dt_nasc = (
  SELECT MAX(dt_nasc)
  FROM funcionario
)

order by hospede.dt_nasc asc
LIMIT 1;


/*
22ª Questão
O nome da categoria mais cara que foi ocupado pelo hóspede mais velho.
*/

-- 1ª Alternativa - Usando JOIN para unir tabelas
SELECT categoria.nome
FROM categoria
JOIN apto on categoria.cod_cat = apto.cod_cat
JOIN hospedagem on apto.num = hospedagem.num
JOIN hospede on hospedagem.cod_hosp = hospede.cod_hosp

WHERE hospede.dt_nasc = 
(
  SELECT MIN(dt_nasc)
  FROM hospede
)

ORDER by valor_dia ASC
LIMIT 1;

-- 2ª Alternativa - Usando SELECT para unir tabelas
SELECT categoria.nome
FROM categoria
WHERE categoria.cod_cat IN 
(  
  SELECT apto.cod_cat
  FROM apto
  where apto.num IN
  ( 
    SELECT hospedagem.num
    from hospedagem
    WHERE hospedagem.cod_hosp IN 
    (  
      SELECT hospede.cod_hosp
      FROM hospede
      WHERE hospede.dt_nasc =
      (
        SELECT min(hospede.dt_nasc)
        from hospede
      )
      ORDER by valor_dia ASC
      LIMIT 1
    )
  )
);
    
    