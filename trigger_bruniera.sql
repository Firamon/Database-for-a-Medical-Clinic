create or replace function check_non_partecipa_amministrativo()
returns trigger
language plpgsql as $$
begin
    perform * from membroPersonaleAusiliario
        where codicePersonale = new.codicePersonale and tipo = 'amministrativo';
    if found then
        raise exception 'Solo gli assistenti medici possono essere iscritti ai corsi di aggiornamento';
        return null;
    else
        return new;
    end if;
end;
$$;

create trigger non_partecipa_amministrativo before insert or update
on partecipa for each row
execute procedure check_non_partecipa_amministrativo();

create or replace function check_amministrativo_non_partecipa()
returns trigger
language plpgsql as $$
begin
    perform * from partecipa
        where codicePersonale = new.codicePersonale;
    if found and then
        raise exception 'Solo gli assistenti medici possono essere iscritti ai corsi di aggiornamento';
        return null;
    else
        return new;
    end if;
end;
$$;

create trigger amministrativo_non_partecipa before insert or update
on membroPersonaleAusiliario for each row
        when (new.tipo = 'amministrativo')
execute procedure check_amministrativo_non_partecipa();

create or replace function check_appuntamenti_terapia_chiusa()
returns trigger
language plpgsql as $$
begin
    perform * from programmato
        where dataDiInizio = new.dataDiInizio and cf = new.cf and tipoDiSpecializzazione = new.tipoDiSpecializzazione;
    if found and new.tipoDiTerapia = 'chiusa' then
        raise exception 'Le terapie chiuse non possono avere appuntamenti programmati';
        return null;
    else
        return new;
    end if;
end;
$$;

create trigger appuntamenti_terapia_chiusa before update
on terapiaProlungata for each row
        when (new.tipoDiTerapia = 'chiusa')
execute procedure check_appuntamenti_terapia_chiusa();

create or replace function check_terapia_chiusa_appuntamenti()
returns trigger
language plpgsql as $$
begin
    perform * from terapiaProlungata
        where dataDiInizio = new.dataDiInizio and cf = new.cf and tipoDiSpecializzazione = new.tipoDiSpecializzazione and tipoDiTerapia = 'chiusa';
    if found then
        raise exception 'Le terapie chiuse non possono avere appuntamenti programmati';
        return null;
    else
        return new;
    end if;
end;
$$;

create trigger terapia_chiusa_appuntamenti before insert
on programmato for each row
execute procedure check_terapia_chiusa_appuntamenti();

create or replace function check_programma_appuntamento_futuro()
returns trigger
language plpgsql as $$
begin
    if ((new.data > CURRENT_DATE) or (new.data = CURRENT_DATE and new.ora > extract(hour from CURRENT_TIME))) then
        insert into programmato (data, cf, dataDiInizio, tipoDiSpecializzazione, ora)
        values (new.data, new.cf, new.dataDiInizio, new.tipoDiSpecializzazione, new.ora);
    end if;
end;
$$;

create trigger programma_appuntamento_futuro after insert or update
on appuntamento for each row
execute procedure check_programma_appuntamento_futuro();
