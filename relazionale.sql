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
    tipoDiSpecializzazione varchar(20),
    numeroAppuntamenti int,
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
    constraint fk_Seduta_ausiliario_appuntamento foreign key (data,ora,cf) references seduta (data,ora,cf) on delete cascade on update cascade,
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


insert into medico values ('a1234567', 3459386039, 'via 20 settembre 1', 'rossi','gianni', 'interno', 2, null);
insert into medico values ('b1234567', 5495849598, 'via del popolo 10', 'verdi', 'mauro', 'interno', 6, null);
insert into medico values ('c1234567', 9032498764, 'viale Garibaldi 20', 'bianchi', 'anna', 'esterno', null, 55);
insert into medico values ('d1234567', 9875324766, 'via flaminia 1', 'montecristo', 'michelle', 'esterno', null, 46);

insert into membroPersonaleAusiliario values ('a0112358', 3459386036, 'via flaminia 10', 'bianchi', 'luca', 'assistente medico');
insert into membroPersonaleAusiliario values ('b0112358', 3459386036, 'via del popolo 5', 'neri', 'giacomo', 'amministrativo');
insert into membroPersonaleAusiliario values ('c0112358', 3459386036, 'viale Garibaldi 6', 'rossi', 'raimondo', 'assistente medico');
insert into membroPersonaleAusiliario values ('d0112358', 3459386036, 'via del popolo 5', 'marroni', 'luca', 'entrambi');
insert into membroPersonaleAusiliario values ('e0112358', 3459386036, 'viale Garibaldi 78', 'montecristo', 'giocanni', 'entrambi');

insert into corsoDiAggiornamento values ('associazione medici', 'corso sulle iniezioni', '2021-03-20');
insert into corsoDiAggiornamento values ('associazione ortopedici', '1000 modi per martellare le ossa', '2021-01-22');
insert into corsoDiAggiornamento values ('associazione ortopedici', 'le protesi moderne', '2021-01-22');

inserto into partecipa values ('a0112358', 'associazione medici', 'corso sulle iniezioni', '2021-03-20');
inserto into partecipa values ('a0112358', 'associazione ortopedici', '1000 modi per martellare le ossa', '2021-01-22');
inserto into partecipa values ('a0112358', 'associazione ortopedici', 'le protesi moderne', '2021-01-22');

insert into qualifica values ('diploma di ragioneria');
insert into qualifica values ('tecnico radiologo');
insert into qualifica values ('laurea in infermieristica');

insert into qualificare values ('a0112358', 'tecnico radiologo');
insert into qualificare values ('b0112358', 'laurea in infermieristica');
insert into qualificare values ('c0112358', 'laurea in infermieristica');
insert into qualificare values ('d0112358', 'diploma di ragioneria');
insert into qualificare values ('e0112358', 'diploma di ragioneria');

insert into specializzazione values ('ortopedia');
insert into specializzazione values ('oculistica');
insert into specializzazione values ('radiologia');
insert into specializzazione values ('urologia');

insert into specializzare values ('a1234567', 'ortopedia');
insert into specializzare values ('b1234567', 'radiologia');
insert into specializzare values ('c1234567', 'ortopedia');
insert into specializzare values ('d1234567', 'oculistica');
insert into specializzare values ('a1234567', 'oculistica');
insert into specializzare values ('b1234567', 'urologia');

insert into paziente values ('a011235812213455', 'gianni', 'rossi', 'via del proletario 1', 8475948033, '1976-01-12', 'regolare', 45);
insert into paziente values ('b011235812213455', 'carla', 'neri', 'via del proletario 2', 8475948033, '1960-01-12', 'regolare', 61);
insert into paziente values ('c011235812213455', 'girolamo', 'rossi', 'via del proletario 3', 8475948033, '1999-01-12', 'occasionale', 22);
insert into paziente values ('d011235812213455', 'anna', 'neri', 'via del proletario 4', 8475948033, '1980-01-12', 'occasionale', 41);
insert into paziente values ('e011235812213455', 'luca', 'verdi', 'via del proletario 5', 8475948033, '2002-01-12', 'entrambi', 19);
insert into paziente values ('f011235812213455', 'luisa', 'montecristo', 'via del proletario 6', 8475948033, '1928-01-12', 'entrambi', 93);

insert into terapiaProlungata values ('2020-01-01','a011235812213455', '2020-06-30', 'chiusa', 'radiologia' ,5);
insert into terapiaProlungata values ('2021-02-22','a011235812213455', null, 'aperta', 'urologia' , 2);
insert into terapiaProlungata values ('2021-01-01','a011235812213455', null, 'aperta', 'oculistica' ,9);
insert into terapiaProlungata values ('2021-01-01','b011235812213455', null, 'aperta', 'ortopedia' ,1);
insert into terapiaProlungata values ('2019-01-01','e011235812213455', '2019-06-30', 'chiusa', 'urologia' ,14);
insert into terapiaProlungata values ('2020-01-01','e011235812213455', '2020-06-30', 'chiusa', 'ortopedia' ,3);
insert into terapiaProlungata values ('2021-01-02','f011235812213455', null, 'aperta', 'oculistica' ,1);
insert into terapiaProlungata values ('2019-02-13','e011235812213455', '2019-07-30', 'chiusa', 'radiologia' ,6);

insert into seduta values ('2021-01-02', 12, 'A', 'c011235812213455');
insert into seduta values ('2020-03-12', 13, 'A', 'c011235812213455');
insert into seduta values ('2020-05-06', 8, 'B', 'd011235812213455');
insert into seduta values ('2019-09-15', 17, 'B', 'e011235812213455');
insert into seduta values ('2018-12-02', 12, 'C', 'f011235812213455');

insert into medicoSeduta values ('2021-01-02', 12, 'A', 'c011235812213455', 'a1234567');
insert into medicoSeduta values ('2021-01-02', 12, 'A', 'c011235812213455', 'b1234567');
insert into medicoSeduta values ('2021-01-02', 12, 'A', 'c011235812213455', 'c1234567');
insert into medicoSeduta values ('2020-03-12', 13, 'A', 'c011235812213455', 'b1234567');
insert into medicoSeduta values ('2020-05-06', 8, 'B', 'd011235812213455', 'b1234567');
insert into medicoSeduta values ('2019-09-15', 17, 'B', 'e011235812213455', 'c1234567');
insert into medicoSeduta values ('2018-12-02', 12, 'C', 'f011235812213455', 'd1234567');
insert into medicoSeduta values ('2018-12-02', 12, 'C', 'f011235812213455', 'a1234567');

insert into ausiliarioAppuntamento values ('2021-01-02', 12, 'A', 'c011235812213455', 'a0112358');
insert into ausiliarioAppuntamento values ('2020-03-12', 13, 'A', 'c011235812213455', 'a0112358');
insert into ausiliarioAppuntamento values ('2020-03-12', 13, 'A', 'c011235812213455', 'c0112358');
insert into ausiliarioAppuntamento values ('2019-09-15', 17, 'B', 'e011235812213455', 'd0112358');
insert into ausiliarioAppuntamento values ('2018-12-02', 12, 'C', 'f011235812213455', 'e0112358');

insert into appuntamento values ('2021-04-20','2021-02-22','a011235812213455', 'urologia' ,10);
insert into appuntamento values ('2021-04-27','2021-01-01','a011235812213455', 'oculistica' ,12);
insert into appuntamento values ('2021-05-27','2021-01-01','b011235812213455', 'ortopedia' ,8);
insert into appuntamento values ('2021-06-28','2021-01-02','f011235812213455', 'oculistica' ,18);

insert into appuntamento values ('2019-01-01','2019-01-01','e011235812213455', 'urologia' ,13);
insert into appuntamento values ('2020-01-01','2020-01-01','e011235812213455', 'ortopedia' ,12);
insert into appuntamento values ('2019-02-13','2020-01-01','a011235812213455', 'radiologia' ,18);

insert into programmato values ('2021-04-20','2021-02-22','a011235812213455', 'urologia' ,10);
insert into programmato values ('2021-04-27','2021-01-01','a011235812213455', 'oculistica' ,12);
insert into programmato values ('2021-05-27','2021-01-01','b011235812213455', 'ortopedia' ,8);
insert into programmato values ('2021-06-28','2021-01-02','f011235812213455', 'oculistica' ,18);

insert into accettato values ('2019-01-01','2019-01-01','e011235812213455', 'urologia' ,'A');
insert into accettato values ('2020-01-01','2020-01-01','e011235812213455', 'ortopedia' ,'A');
insert into accettato values ('2019-02-13','2020-01-01','a011235812213455', 'radiologia' ,'B');

insert into medicoAppuntamento values ('b1234567', '2019-01-01','2019-01-01','e011235812213455', 'urologia');
insert into medicoAppuntamento values ('a1234567', '2020-01-01','2020-01-01','e011235812213455', 'ortopedia');
insert into medicoAppuntamento values ('c1234567', '2020-01-01','2020-01-01','e011235812213455', 'ortopedia');
insert into medicoAppuntamento values ('b1234567', '2019-02-13','2020-01-01','a011235812213455', 'radiologia');

insert into ausiliarioAppuntamento values ('a0112358', '2019-01-01','2019-01-01','e011235812213455', 'urologia');
insert into ausiliarioAppuntamento values ('c0112358', '2020-01-01','2020-01-01','e011235812213455', 'ortopedia');
insert into ausiliarioAppuntamento values ('c0112358', '2019-02-13','2020-01-01','a011235812213455', 'radiologia');
insert into ausiliarioAppuntamento values ('d0112358', '2019-02-13','2020-01-01','a011235812213455', 'radiologia');
insert into ausiliarioAppuntamento values ('e0112358', '2020-01-01','2020-01-01','e011235812213455', 'ortopedia');
insert into ausiliarioAppuntamento values ('c0112358', '2019-01-01','2019-01-01','e011235812213455', 'urologia');

