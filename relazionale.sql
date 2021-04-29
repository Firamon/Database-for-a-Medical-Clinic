drop schema if exists studio cascade;

create schema studio;

set search_path to studio;

create type tipoMedico as enum ('interno','esterno');

create table medico(
    codiceMedico char(8) primary key,
    recapitoTelefonico decimal(15,0) not null,
    indirizzo varchar(50) not null,
    cognome varchar(40) not null,
    nome varchar(40) not null,
    tipo tipoMedico not null,
    percentualeIncassi smallint,
    tariffaOraria int
    constraint medico_interno check (((percentualeIncassi between 1 and 100) and tariffaOraria is null) or tipo <> 'interno')
    constraint medico_esterno check ((percentualeIncassi is null and tariffaOraria > 0) or tipo <> 'esterno'));

create type tipoPersonale as enum ('assistente medico','amministrativo','entrambi');

create table membroPersonaleAusiliario(
    codicePersonale char(8) primary key,
    recapitoTelefonico decimal(15,0) not null,
    indirizzo varchar(50) not null,
    cognome varchar(40) not null,
    nome varchar(40) not null,
    tipo tipoPersonale not null);

create table storico(
    mese date primary key,
    constraint mese_check check (extract(day from mese) = '1'));

create table medicoRegistra(
    mese date not null,
    codiceMedico char(8) not null,
    ordinario smallint,
    straordinario smallint,
    constraint medico_ore_check check (ordinario >= 0 and straordinario >=0 and (straordinario + ordinario) > 0),
    constraint fk_codice_medico_registra foreign key (codiceMedico) references medico (codiceMedico) on delete no action on update cascade,
    constraint fk_mese_medico_registra foreign key (mese) references storico (mese) on delete no action on update no action,
    constraint medico_registra_pk primary key (mese,codiceMedico));

create table ausiliarioRegistra(
    mese date not null,
    codicePersonale char(8) not null,
    ordinario smallint,
    straordinario smallint,
    constraint ausiliario_ore_check check (ordinario >= 0 and straordinario >=0 and (straordinario + ordinario) > 0),
    constraint fk_codice_ausiliario_registra foreign key (codicePersonale) references membroPersonaleAusiliario (codicePersonale) on delete no action on update cascade,
    constraint fk_mese_ausiliario_registra foreign key (mese) references storico (mese) on delete no action on update no action,
    constraint ausiliario_registra_pk primary key (mese,codicePersonale));

create table corsoDiAggiornamento(
    luogo varchar(50) not null,
    denominazione varchar(200) not null,
    data date not null,
    constraint corso_pk primary key (luogo, denominazione, data));

create table partecipa(
    codicePersonale varchar(20) not null,
    luogo varchar(50) not null,
    denominazione varchar(200) not null,
    data date not null,
    constraint fk_ausiliario_partecipa foreign key (codicePersonale) references membroPersonaleAusiliario (codicePersonale) on delete cascade on update cascade,
    constraint fk_corso_partecipa foreign key (luogo,denominazione,data) references corsoDiAggiornamento (luogo,denominazione,data) on delete cascade on update cascade,
    constraint partecipa_pk primary key (codicePersonale,luogo,denominazione,data));

create table qualifica(
    tipoDiQualifica varchar(50) primary key);

create table qualificare(
    codicePersonale varchar(20) not null,
    tipoDiQualifica varchar(50) not null,
    constraint fk_ausiliario_qualificare foreign key (codicePersonale) references membroPersonaleAusiliario (codicePersonale) on delete cascade on update cascade,
    constraint fk_qualifica_qualificare foreign key (tipoDiQualifica) references qualifica (tipoDiQualifica) on delete cascade on update cascade,
    constraint qualificare_pk primary key (codicePersonale,tipoDiQualifica));

create table specializzazione(
    tipoDiSpecializzazione varchar(50) primary key);

create table specializzare(
    codiceMedico varchar(20) not null,
    tipoDiSpecializzazione varchar(50) not null,
    constraint fk_medico_specializzare foreign key (codiceMedico) references medico (codiceMedico) on delete cascade on update cascade,
    constraint fk_specializzazione_specializzare foreign key (tipoDiSpecializzazione) references specializzazione (tipoDiSpecializzazione) on delete cascade on update cascade,
    constraint specializzare_pk primary key (codiceMedico,tipoDiSpecializzazione));

create type tipoPaziente as enum ('occasionale', 'regolare', 'entrambi');

create table paziente(
    cf char(16) primary key,
    nome varchar(40) not null,
    cognome varchar(40) not null,
    indirizzo varchar(50) not null,
    recapitoTelefonico decimal(15,0) not null,
    dataDiNascita date not null,
    tipo tipoPaziente not null);

create type tipoTerapia as enum ('aperta', 'chiusa');

create table terapiaProlungata(
    dataDiInizio date,
    cf char(16),
    dataDiFine date,
    tipoDiTerapia tipoTerapia not null,
    tipoDiSpecializzazione varchar(50),
    constraint data_check check ((dataDiFine is null and tipoDiTerapia = 'aperta') or (dataDiFine >= dataDiInizio and tipoDiTerapia = 'chiusa')),
    constraint terapiaProlungata_pk primary key (dataDiInizio,cf,tipoDiSpecializzazione),
    constraint fk_paziente_terapia foreign key (cf) references paziente (cf) on delete no action on update no action,
    constraint fk_specializzazione_terapia foreign key (tipoDiSpecializzazione) references specializzazione (tipoDiSpecializzazione) on delete cascade on update cascade);

create table seduta(
    data date not null,
    ora int not null constraint validTime check (ora between 1 and 24),
    ambulatorio char(1),
    cf char(16) not null,
    constraint seduta_pk primary key (data,ora,cf),
    constraint fk_paziente_seduta foreign key (cf) references paziente (cf) on delete cascade on update no action);

create table medicoSeduta(
    codiceMedico varchar(20),
    data date not null,
    ora int not null constraint validTime check (ora between 1 and 24),
    cf char(16),
    constraint medicoSeduta_pk primary key (codiceMedico,data,ora,cf),
    constraint fk_seduta_medico_seduta foreign key (data,ora,cf) references seduta (data,ora,cf) on delete cascade on update cascade,
    constraint fk_medico_medico_seduta foreign key (codiceMedico) references medico (codiceMedico) on delete no action on update cascade);

create table ausiliarioSeduta(
    codicePersonale varchar(20),
    data date not null,
    ora int not null constraint validTime check (ora between 1 and 24),
    cf char(16),
    constraint ausiliarioSeduta_pk primary key (codicePersonale,data,ora,cf),
    constraint fk_seduta_ausiliario_seduta foreign key (data,ora,cf) references seduta (data,ora,cf) on delete cascade on update cascade,
    constraint fk_ausiliario_ausiliario_Seduta foreign key (codicePersonale) references membroPersonaleAusiliario (codicePersonale) on delete cascade on update cascade);

create table appuntamento(
    data date,
    dataDiInizio date,
    cf char(16),
    tipoDiSpecializzazione varchar(20),
    ora int not null constraint validTime check (ora between 1 and 24),
    constraint appuntamento_pk primary key (data,dataDiInizio,cf,tipoDiSpecializzazione) ,
    constraint fk_terapia_appuntamento foreign key (dataDiInizio,cf,tipoDiSpecializzazione) references terapiaProlungata (dataDiInizio,cf,tipoDiSpecializzazione) on delete cascade on update cascade,
    constraint pazienteUbiquitario unique (data, ora, cf));

create table programmato(
    data date,
    dataDiInizio date,
    cf char(16),
    tipoDiSpecializzazione varchar(20),
    ora int not null constraint validTime check (ora between 1 and 24),
    constraint data_check check ((data > CURRENT_DATE) or (data = CURRENT_DATE and ora > extract(hour from CURRENT_TIME))),
    constraint programmato_pk primary key (data,dataDiInizio,cf,tipoDiSpecializzazione),
    constraint fk_appuntamento_programmato foreign key (data,dataDiInizio,cf,tipoDiSpecializzazione) references appuntamento (data,dataDiInizio,cf,tipoDiSpecializzazione) on delete cascade on update cascade);

create table accettato(
    data date,
    dataDiInizio date,
    cf char(16),
    tipoDiSpecializzazione varchar(20),
    ambulatorio char(1) not null,
    constraint accettato_pk primary key (data,dataDiInizio,cf,tipoDiSpecializzazione),
    constraint fk_appuntamento_accettato foreign key (data,dataDiInizio,cf,tipoDiSpecializzazione) references appuntamento (data,dataDiInizio,cf,tipoDiSpecializzazione) on delete cascade on update cascade);

create table medicoAppuntamento(
    codiceMedico varchar(20),
    data date not null,
    dataDiInizio date,
    cf char(16),
    tipoDiSpecializzazione varchar(20),
    constraint medicoAppuntamento_pk primary key (codiceMedico,data,dataDiInizio,cf,tipoDiSpecializzazione),
    constraint fk_appuntamento_medico_appuntamento foreign key (data,dataDiInizio,cf,tipoDiSpecializzazione) references accettato (data,dataDiInizio,cf,tipoDiSpecializzazione) on delete cascade on update cascade,
    constraint fk_medico_medico_appuntamento foreign key (codiceMedico) references medico (codiceMedico) on delete no action on update cascade);

create table ausiliarioAppuntamento(
    codicePersonale varchar(20),
    data date not null,
    dataDiInizio date,
    cf char(16),
    tipoDiSpecializzazione varchar(20),
    constraint ausiliarioAppuntamento_pk primary key (codicePersonale,data,DataDiInizio,cf,tipoDiSpecializzazione),
    constraint fk_appuntamento_ausiliario_appuntamento foreign key (data,dataDiInizio,cf,tipoDiSpecializzazione) references accettato (data,dataDiInizio,cf,tipoDiSpecializzazione) on delete cascade on update cascade,
    constraint fk_ausiliario_ausiliario_appuntamento foreign key (codicePersonale) references membroPersonaleAusiliario (codicePersonale) on delete cascade on update cascade);

--trigger: quando aggiungiamo un appuntamento accettato, la specializzazione richiesta dalla terapia deve essere tra le specializzazioni del medico che fa l'appuntamento

create or replace function controlla_specializzazione()
returns trigger
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
end if;
end;
$$;

create trigger inserisci_accettato
before insert on medicoAppuntamento
for each row
execute procedure controlla_specializzazione();

--trigger: quando inseriamo una terapia prolungata, non ci devono essere, per quel paziente, terapie prolungate aperte con lo stesso tipo di specializzazione

create or replace function controlla_specializzazione_terapieProlungate()
returns trigger
language plpgsql as $$
begin
perform *
from terapiaProlungata
where new.tipoDiSpecializzazione = tipoDiSpecializzazione and tipoDiTerapia = 'aperta' and new.cf = cf and new.tipoDiTerapia = 'aperta' and dataDiInizio <> new.dataDiInizio;
if found then
	raise exception 'Non puoi inserite 2 terapie aperte con la stessa specializzazione';
	return null;
else
	return new;
end if;
end;
$$;

create trigger inserisci_terapiaProlungata
before insert on terapiaProlungata
for each row
execute procedure controlla_specializzazione_terapieProlungate();

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

create trigger non_partecipa_amministrativo
before insert or update on partecipa
for each row
execute procedure check_non_partecipa_amministrativo();

create or replace function check_amministrativo_non_partecipa()
returns trigger
language plpgsql as $$
begin
    perform * from partecipa
        where codicePersonale = new.codicePersonale;
    if found then
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
    return new;
end;
$$;

create trigger programma_appuntamento_futuro after insert or update
on appuntamento for each row
execute procedure check_programma_appuntamento_futuro();

create index cf_terapiaProlungata on terapiaProlungata (cf);
create index cf_appuntamento on appuntamento (cf);
create index cf_programmato on programmato (cf);
create index cf_accettato on accettato (cf);
create index cf_seduta on seduta (cf);
create index terapia_appuntamento on appuntamento (dataDiInizio,cf,tipoDiSpecializzazione);
create index codiceMedico_medicoAppuntamento on medicoAppuntamento (codiceMedico);
create index codiceMedico_medicoSeduta on medicoSeduta (codiceMedico);
create index nome_paziente on paziente (nome);
create index nome_medico on medico (nome);
create index cognome_paziente on paziente (cognome);
create index cognome_medico on medico (cognome);

create view paziente_eta as
select *, age(datadinascita) eta from paziente;

create view terapia_naccettati as
select dataDiInizio, cf, dataDiFine, tipoDiTerapia, tipoDiSpecializzazione, count(*) nAppuntamentiAccettati
from terapiaprolungata natural join accettato
group by dataDiInizio, cf, dataDiFine, tipoDiTerapia, tipoDiSpecializzazione;
