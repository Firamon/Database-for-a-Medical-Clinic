--Trigger:

--trigger: quando aggiungiamo un appuntamento accettato, la specializzazione richiesta dalla terapia deve essere tra le specializzazioni del medico che fa l'appuntamento

create or replace function controlla_specializzazione()
return trigger
language plpgsql as $$
begin
perform *
from specializzare
where codiceMedico = new.codiceMedico and new.tipoDiSpecializzazione = tipoDiSpecializzazione;
if found then
	return new;
else
	raise exception 'Il medico inserito non ? specializzato per l appuntamento';
	return null;
endif;
end;
$$;

create trigger inserisci_accettato()
before insert on medicoAppuntamento
for each row
execute procedure controlla_specializzazione();

--trigger: quando inseriamo una terapia prolungata, non ci devono essere, per quel paziente, terapie prolungate aperte con lo stesso tipo di specializzazione

create or replace function controlla_specializzazione_terapieProlungate()
return trigger
language plpgsql as $$
begin
perform *
from terapiaProlungata
where new.tipoDiSpecializzazione = tipoDiSpecializzazione and tipoDiTerapia = 'aperta' and new.cf = cf and new.tipoDiTerapia = 'aperto';
if found then
	raise exception 'Non puoi inserite 2 terapie aperte con la stessa specializzazione';
	return null;
else
	return new;
endif;
end;
$$;

create trigger inserisci_terapiaProlungata()
before insert on terapiaProlungata
for each row
execute procedure controlla_specializzazione_terapieProlungate();

--Query

--(Fai l'unione di queste 2 query)
--Dato un paziente, trova tutti i medici che lo hanno visitato

select codiceMedico, nome, cognome, 
from medico natural join medicoAppuntamento
where cf='a123456789123456'

select codiceMedico, nome, cognome
from medicoSeduta natural join medico
where cf='a123456789123456'

--Tutti i medici specializzati in almeno 2 discipline

select codiceMedico, nome, cognome
from specializzare as s1 natural join medico
where codiceMedico='jdfs7gfd9' and exists (select *
					from specializzare as s2
					where s2.codiceMedico=s1.codiceMedico and s2.tipoDiSpecializzazione <> s1.tipoDiSpecializzazione)

