-- criar um cursor que lê as consultas que já aconteceram das quais se produziram 
-- diagnosticos e guardar numa tabela o nome de cliente e animal , mês e ano
-- e numa string tem todas as prescrições que o animal teve nesse mes, nesse ano, 
-- separados por virgulas. Isto feito num procedimento, não função.

CREATE OR REPLACE PROCEDURE o_tal_cursor()
AS $$
DECLARE
    consulta RECORD; --linha a linha da tabela da consulta
    prescricoes_string TEXT;
BEGIN
    -- Cria uma tabela temporária para armazenar os resultados
    CREATE TEMP TABLE temp_diagnosticos (
        nome_cliente VARCHAR(255),
        nome_animal VARCHAR(255),
        mes INT,
        ano INT,
        prescricoes TEXT
    );

    for consulta in (
        SELECT a.nam_usr, an.nam_ani, a.sta_dat_app AS mes, a.sta_dat_app AS ano, dia_app AS diagnostico, com_app AS comentarios
        FROM appointment a
        JOIN client c ON a.id_cli = c.id_cli
        JOIN animal an ON a.id_animal = an.id_ani
        JOIN prescription p ON a.id_app = p.id_app
        WHERE a.sta_dat_app < CURRENT_DATE && a.end_dat_app IS NOT NULL -- Apenas consultas passadas e concluidas
    )LOOP
        -- Concatena as prescrições em uma string separada por vírgulas
        prescricoes_string := concat_ws(',', consulta.diagnostico, consulta.comentarios);
        --aqui eu só estou a concatenar o diagnostico e os comentários porque o nosso modelo já está montado para cada um deste atributos ser uma string

        -- Insere os dados na tabela temporária
        INSERT INTO temp_diagnosticos (nome_cliente, nome_animal, mes, ano, prescricoes)
        VALUES (consulta.nam_usr, consulta.nam_ani, consulta.mes, consulta.ano, prescricoes_string);
    END LOOP;
END;
$$ LANGUAGE plpgsql;




-- Criar uma função ou procedimento para escrever numa tabela um texto que é no fundo um aviso para uma consulta que existe no dia seguinte” 
-- ou seja, um aviso para todos os “clientes” que no dia seguinte tem consulta, a dizer “Bom dia (nome do cliente) amnaha tem consulta com o veterinario (nome do veterinario) com o seu animal(nome animal)

CreATE OR REPLACE PROCEDURE aviso_consulta()
AS $$
DECLARE
    consulta RECORD; --linha a linha da tabela da consulta
BEGIN
    -- Cria uma tabela temporária para armazenar os avisos
    CREATE TEMP TABLE temp_avisos (
        aviso TEXT
    );  
    for consulta in (
        SELECT c.nam_usr AS nome_cliente, e.nam_emp AS nome_veterinario, an.nam_ani AS nome_animal
        FROM appointment a
        JOIN client c ON a.id_cli = c.id_cli
        JOIN animal an ON a.id_animal = an.id_ani
        JOIN employee e ON a.id_emp = e.id_emp
        WHERE a.sta_dat_app > current_date + INTERVAL '1 day' 
    )LOOP
        -- Cria o aviso personalizado
        INSERT INTO temp_avisos (aviso)
        VALUES (concat('Bom dia ', consulta.nome_cliente, ' amanhã tem consulta com o veterinário ', consulta.nome_veterinario, ' com o seu animal ', consulta.nome_animal));   
    END LOOP;
END;
$$ LANGUAGE plpgsql;

