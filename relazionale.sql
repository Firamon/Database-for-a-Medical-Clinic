drop schema if exists studio cascade;

create schema studio;

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
    tariffaOraria int
    constraint medico_interno check (((percentualeIncassi between 1 and 100) and tariffaOraria is null) or tipo <> 'interno')
    constraint medico_esterno check ((percentualeIncassi is null and tariffaOraria > 0) or tipo <> 'esterno'));

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
    luogo varchar(20) not null,
    denominazione varchar(20) not null,
    data date not null,
    constraint corso_pk primary key (luogo, denominazione, data));

create table partecipa(
    codicePersonale varchar(20) not null,
    luogo varchar(20) not null,
    denominazione varchar(20) not null,
    data date not null,
    constraint fk_ausiliario_partecipa foreign key (codicePersonale) references membroPersonaleAusiliario (codicePersonale) on delete cascade on update cascade,
    constraint fk_corso_partecipa foreign key (luogo,denominazione,data) references corsoDiAggiornamento (luogo,denominazione,data) on delete cascade on update cascade,
    constraint partecipa_pk primary key (codicePersonale,luogo,denominazione,data));

create table qualifica(
    tipoDiQualifica varchar(20) primary key);

create table qualificare(
    codicePersonale varchar(20) not null,
    tipoDiQualifica varchar(20) not null,
    constraint fk_ausiliario_qualificare foreign key (codicePersonale) references membroPersonaleAusiliario (codicePersonale) on delete cascade on update cascade,
    constraint fk_qualifica_qualificare foreign key (tipoDiQualifica) references qualifica (tipoDiQualifica) on delete cascade on update cascade,
    constraint qualificare_pk primary key (codicePersonale,tipoDiQualifica));

create table specializzazione(
    tipoDiSpecializzazione varchar(20) primary key);

create table specializzare(
    codiceMedico varchar(20) not null,
    tipoDiSpecializzazione varchar(20) not null,
    constraint fk_medico_specializzare foreign key (codiceMedico) references medico (codiceMedico) on delete cascade on update cascade,
    constraint fk_specializzazione_specializzare foreign key (tipoDiSpecializzazione) references specializzazione (tipoDiSpecializzazione) on delete cascade on update cascade,
    constraint specializzare_pk primary key (codiceMedico,tipoDiSpecializzazione));

create type tipoPaziente as enum ('occasionale', 'regolare', 'entrambi');

create table paziente(
    cf char(16) primary key,
    nome varchar(20) not null,
    cognome varchar(10) not null,
    indirizzo varchar(20) not null,
    recapitoTelefonico decimal(15,0) not null,
    dataDiNascita date not null,
    tipo tipoPaziente not null,
    eta int not null);

create type tipoTerapia as enum ('aperta', 'chiusa');

create table terapiaProlungata(
    dataDiInizio date,
    cf char(16),
    dataDiFine date,
    tipoDiTerapia tipoTerapia not null,
    tipoDiSpecializzazione varchar(20) not null,
    numeroAppuntamenti int,
    constraint data_check check (dataDiFine >= dataDiInizio),
    constraint terapiaProlungata_pk primary key (dataDiInizio,cf),
    constraint fk_paziente_terapia foreign key (cf) references paziente (cf) on delete no action on update no action,
    constraint fk_specializzazione_terapia foreign key (tipoDiSpecializzazione) references specializzazione (tipoDiSpecializzazione) on delete cascade on update cascade);

create table seduta(
    data date not null,
    ora int not null constraint validTime check (ora between 1 and 24),
    ambulatorio char(1),
    cf char(16) not null,
    constraint seduta_pk primary key (data,ora,cf),
    constraint fk_paziente_seduta foreign key (cf) references paziente (cf) on delete cascade on update no action),

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
    constraint fk_Seduta_ausiliario_appuntamento foreign key (data,ora,cf) references accettato (data,ora,cf) on delete cascade on update cascade,
    constraint fk_ausiliario_ausiliario_Seduta foreign key (codicePersonale) references membroPersonaleAusiliario (codicePersonale) on delete cascade on update cascade);

create table appuntamento(
    data date,
    dataDiInizio date,
    cf char(16),
    ora int not null constraint validTime check (ora between 1 and 24),
    constraint appuntamento_pk primary key (data,dataDiInizio,cf) ,
    constraint fk_terapia_appuntamento foreign key (dataDiInizio,cf) references terapiaProlungata (dataDiInizio,cf) on delete cascade on update cascade,
    constraint pazienteUbiquitario unique (data, ora, cf));

create table programmato(
    data date,
    dataDiInizio date,
    cf char(16),
    ora int not null constraint validTime check (ora between 1 and 24),
    constraint programmato_pk primary key (data,dataDiInizio,cf),
    constraint fk_appuntamento_programmato foreign key (data,dataDiInizio,cf) references appuntamento (data,dataDiInizio,cf) on delete cascade on update cascade);

create table accettato(
    data date,
    dataDiInizio date,
    cf char(16),
    ambulatorio int not null,
    constraint accettato_pk primary key (data,dataDiInizio,cf),
    constraint fk_appuntamento_accettato foreign key (data,dataDiInizio,cf) references appuntamento (data,dataDiInizio,cf) on delete cascade on update cascade);

create table medicoAppuntamento(
    codiceMedico varchar(20),
    data date not null,
    dataDiInizio date,
    cf char(16),
    constraint medicoAppuntamento_pk primary key (codiceMedico,data,dataDiInizio,cf),
    constraint fk_appuntamento_medico_appuntamento foreign key (data,dataDiInizio,cf) references accettato (data,dataDiInizio,cf) on delete cascade on update cascade,
    constraint fk_medico_medico_appuntamento foreign key (codiceMedico) references medico (codiceMedico) on delete no action on update cascade);

create table ausiliarioAppuntamento(
    codicePersonale varchar(20),
    data date not null,
    dataDiInizio date,
    cf char(16),
    constraint ausiliarioAppuntamento_pk primary key (codicePersonale,data,DataDiInizio,cf),
    constraint fk_appuntamento_ausiliario_appuntamento foreign key (data,dataDiInizio,cf) references accettato (data,dataDiInizio,cf) on delete cascade on update cascade,
    constraint fk_ausiliario_ausiliario_appuntamento foreign key (codicePersonale) references membroPersonaleAusiliario (codicePersonale) on delete cascade on update cascade);
