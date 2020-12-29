DROP SCHEMA IF EXISTS studio CASCADE;

CREATE SCHEMA studio;

set search_path to studio;

create type tipoMedico as enum ('interno','esterno');

create table medico(
    codiceMedico char(8) primary key,
    recapitoTelefonico decimal(15,0) not null,
    indirizzo varchar(50) not null,
    cognome varchar(20) not null,
    nome varchar(20) not null,
    tipo tipoMedico not null,
    percentualeIncassi smallint,
    tariffaOraria int);

create type tipoPersonale as enum ('assistente medico','amministrativo','entrambi');

create table membroPersonaleAusiliario(
    codicePersonale char(8) primary key,
    recapitoTelefonico decimal(15,0) not null,
    indirizzo varchar(50) not null,
    cognome varchar(20) not null,
    nome varchar(20) not null,
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
    constraint fk_codice_medico_registra foreign key (codiceMedico) references medico (codiceMedico),
    constraint fk_mese_medico_registra foreign key (mese) references storico (mese),
    constraint medico_registra_pk primary key (mese,codiceMedico));

create table ausiliarioRegistra(
    mese date not null,
    codicePersonale char(8) not null,
    ordinario smallint,
    straordinario smallint,
    constraint ausiliario_ore_check check (ordinario >= 0 and straordinario >=0 and (straordinario + ordinario) > 0),
    constraint fk_codice_ausiliario_registra foreign key (codicePersonale) references membroPersonaleAusiliario (codicePersonale),
    constraint fk_mese_ausiliario_registra foreign key (mese) references storico (mese),
    constraint ausiliario_registra_pk primary key (mese,codicePersonale));

create table corsoDiAggiornamento(
    luogo varchar(20) not null,
    denominazione varchar(20) not null,
    data date not null,
    constraint corso_pk primary key (luogo, denominazione, data));

create table partecipa(
    codicePersonale varchar(20) not null,
    luogo varchar(20) not null,
    denominazione varchar(20) not null,
    data date not null,
    constraint fk_ausiliario_partecipa foreign key (codicePersonale) references membroPersonaleAusiliario (codicePersonale),
    constraint fk_corso_partecipa foreign key (luogo,denominazione,data) references corsoDiAggiornamento (luogo,denominazione,data),
    constraint partecipa_pk primary key (codicePersonale,luogo,denominazione,data));

create table qualifica(
    tipoDiQualifica varchar(20) primary key);

create table qualificare(
    codicePersonale varchar(20) not null,
    tipoDiQualifica varchar(20) not null,
    constraint fk_ausiliario_qualificare foreign key (codicePersonale) references membroPersonaleAusiliario (codicePersonale),
    constraint fk_qualifica_qualificare foreign key (tipoDiQualifica) references qualifica (tipoDiQualifica),
    constraint qualificare_pk primary key (codicePersonale,tipoDiQualifica));

create table specializzazione(
    tipoDiSpecializzazione varchar(20) primary key);

create table specializzare(
    codiceMedico varchar(20) not null,
    tipoDiSpecializzazione varchar(20) not null,
    constraint fk_medico_specializzare foreign key (codiceMedico) references medico (codiceMedico),
    constraint fk_specializzazione_specializzare foreign key (tipoDiSpecializzazione) references specializzazione (tipoDiSpecializzazione),
    constraint specializzare_pk primary key (codiceMedico,tipoDiSpecializzazione));

CREATE TYPE tipoPaziente AS ENUM ('occasionale', 'regolare', 'entrambi');

create table Paziente(
    cf char(16) primary key,
    nome varchar(20) not null,
    cognome varchar(10) not null,
    indirizzo varchar(20) not null,
    recapito_telefonico decimal(15,0) not null,
    dataDiNascita date not null,
    tipo tipoMedico not null,
    eta int not null);

CREATE TYPE tipoTerapia AS ENUM ('aperta', 'chiusa');

create table TerapiaProlungata(
    DataDiInizio date,
    cf char(16),
    dataDiFine date,
    tipoDiTerapia tipoTerapia not null,
    tipoDiSpecializzazione varchar(20) not null,
    numeroAppuntamenti int,
    constraint ValidDate check (dataDiFine >= DataDiInizio),
    constraint TerapiaProlungata_pk primary key(DataDiInizio, cf),
    constraint fk_specializzazione_terapia foreign key (tipoDiSpecializzazione) references specializzazione (tipoDiSpecializzazione) on update cascade on delete no action);

create table Appuntamento(
    data date,
    DataDiInizio date,
    cf char(16),
    ora int not null constraint validTime check (ora between 1 and 24),
    constraint Appuntamento_pk primary key(data, DataDiInizio, cf) ,
    constraint Appuntamento_fk foreign key(DataDiInizio, cf) references TerapiaProlungata(DataDiInizio, cf) on delete cascade on update cascade);

create table Programmato(
    data date,
    DataDiInizio date,
    cf char(16),
    ora int not null constraint validTime check (ora between 1 and 24),
    constraint Programmato_pk primary key(data, DataDiInizio, cf),
    constraint Programmato_fk foreign key(data,DataDiInizio, cf) references Appuntamento(data, DataDiInizio, cf) on delete cascade on update cascade);

create table Accettato(
    data date,
    DataDiInizio date,
    cf char(16),
    ambulatorio int not null,
    constraint Accettato_pk primary key(data, DataDiInizio, cf),
    constraint Accettato_fk foreign key(data,DataDiInizio, cf) references Appuntamento(data, DataDiInizio, cf) on delete cascade on update cascade);

create table MedicoAppuntamento(
    codiceMedico int,
    data date not null,
    DataDiInizio date,
    cf char(16),
    constraint MedicoAppuntamento_pk primary key(codiceMedico, data, DataDiInizio, cf),
    constraint medicoAppuntamento_fk foreign key(data, DataDiInizio, cf) references Appuntamento(data,DataDiInizio,cf) on delete cascade on update cascade);

create table AusiliarioAppuntamento(
    codicePersonale int,
    data date not null,
    DataDiInizio date,
    cf char(16),
    constraint AusiliarioAppuntamento_pk primary key(codicePersonale, data, DataDiInizio, cf),
    constraint AusiliarioAppuntamento_fk foreign key(data, DataDiInizio, cf) references Appuntamento(data,DataDiInizio,cf) on delete cascade on update cascade);
