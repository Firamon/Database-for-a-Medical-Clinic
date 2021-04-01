create index cf_terapiaProlungata on terapiaProlungata (cf);
create index cf_appuntamento on appuntamento (cf);
create index cf_programmato on programmato (cf);
create index cf_accettato on accettato (cf);
create index cf_seduta on seduta (cf);
create index terapia_appuntamento on appuntamento (dataDiInizio,cf,tipoDiSpecializzazione);
create index codiceMedico_medicoAppuntamento on medicoAppuntamento (codiceMedico);
create index codiceMedico_medicoSeduta on medicoSeduta (codiceMedico);
