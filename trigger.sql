--Trigger:

--trigger: quando aggiungiamo un appuntamento accettato, la specializzazione richiesta dalla terapia deve essere tra le specializzazioni del medico che fa l'appuntamento

create trigger inserisci_accettato()
before insert on accettato
for each row
execute procedure controlla_specializzazione();

create or replace function controlla_specializzazione()
return trigger
language plpgsql as $$
begin
perform *
from accettato natural join appuntamento as a natural join terapiaProlungata as tp, 
where new.data = a.data and a.dataDiInizio = new.dataDiInizio and new.cf = a.cf and new.tipoDiSpecializzazione = a.tipoDiSpecializzazione
and new.tipoDiSpecializzazione in (select tipoDiSpecializzazione
				from medicoAppuntamento natural join medico natural join accettato natural join specializzare
				where new.data = data and dataDiInizio = new.dataDiInizio and new.cf = cf and new.tipoDiSpecializzazione = tipoDiSpecializzazione)
if found then
	return new;
else
	raise exception 'Il medico inserito non è specializzato per l'appuntamento';
	return null;
endif;
end;
$$;

--trigger: quando inseriamo una terapia prolungata, non ci devono essere, per quel paziente, terapie prolungate aperte con lo stesso tipo di specializzazione

create trigger inserisci_terapiaProlungata()
before insert on terapiaProlungata
for each row
execute procedure controlla_specializzazione_terapieProlungate();

create or replace function controlla_specializzazione_terapieProlungate()
return trigger
language plpgsql as $$
begin
perform *
from terapiaProlungata
where new.tipoDiTerapia in (select tipoDiSpecializzazione
			from terapiaProlungata natural join paziente
			where cf = new.cf and tipoDiTerapia='aperta';
if found then
	raise exception 'Non puoi inserite 2 terapie aperte con la stessa specializzazione';
	return null;
else
	return new;
endif;
end;
$$;


--Query

--(Fai l'unione di queste 2 query)
Dato un paziente, trova tutti i medici che lo hanno visitato
select codiceMedico, nome, cognome, 
from medico natural join medicoAppuntamento natural join accettato natural join appuntamento natural join terapiaProlungata
where cf='a123456789123456'

select codiceMedico, nome, cognome
from medicoSeduta natural join medico
where cf='a123456789123456'

--Tutti i medici specializzati in almeno 2 discipline

select codiceMedico
from specializzare as s1
where codiceMedico='jdfs7gfd9' and exists (select *
					from specializzare as s2
					where s2.codiceMedico=s1.codiceMedico and s2.tipoDiSpecializzazione <> s1.tipoDiSpecializzazione)

