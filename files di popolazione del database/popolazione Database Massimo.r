#Massimo: Medico, Ausiliario, storico, ausiliarioRegistra, medicoRegistra, corsi di aggiornamento (a mano)
library("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv,
	dbname="studiomedico",
	host="localhost",
	port=5432,
	user="postgres",
	password="postgres")
v_nomi <- readLines("nomi.txt", warn=FALSE)
v_cognomi <- readLines("cognomi.txt", warn=FALSE)
v_indirizzi <- readLines("indirizzi.csv", warn=FALSE)

codice_int_medico <- paste(sample(1:10000, 50, replace=F))
codice_ext_medico <- paste(sample(10001:20000, 50, replace=F))

codice_medico <- c(codice_int_medico, codice_ext_medico)

medici_int_df <- data.frame(
                            codicemedico=codice_int_medico, 
                            recapitotelefonico=sample(1143000000:1167000000, 50, replace=F), 
                            indirizzo=sample(v_indirizzi, 50, replace=T), 
                            cognome=sample(v_cognomi, 50, replace=T), 
                            nome=sample(v_nomi, 50, replace=T),
                            tipo="interno",
                            percentualeincassi=sample(1:100, 50, replace=T),
                            tariffaoraria=NA)

medici_ext_df <- data.frame(
                            codicemedico=codice_ext_medico,
                            recapitotelefonico=sample(1143000000:1167000000, 50, replace=F), 
                            indirizzo=sample(v_indirizzi, 50, replace=T),
                            cognome=sample(v_cognomi, 50, replace=T),
                            nome=sample(v_nomi, 50, replace=T),
                            tipo="esterno",
                            percentualeincassi=NA,
                            tariffaoraria=sample(30:120, 50, replace=T))

v_codes <- readLines("8char_codes.csv", warn=FALSE)
codici_personale_ausiliario <- sample(v_codes, 100, replace=F)
ausiliario_df <- data.frame(
                            codicepersonale=codici_personale_ausiliario,
                            recapitotelefonico=sample(1173000000:1187000000, 100, replace=F),
                            indirizzo=sample(v_indirizzi, 100, replace=T),
                            cognome=sample(v_cognomi, 100, replace=T),
                            nome=sample(v_nomi, 100, replace=T),
                            tipopersonale=sample(c("assistente medico", "amministrativo", "entrambi"),100,replace=T))

mesi_seq <-seq(as.Date("2000/1/1"), as.Date("2021/1/1"), "month")
storico_df <- data.frame(mese=mesi_seq)

ausiliarioRegistra_df <- data.frame(
                                    mese=sample(mesi_seq, 1000, replace=T),
                                    codicepersonale=sample(codici_personale_ausiliario, 1000, replace=T),
                                    ordinario=sample(1:48, 1000, replace=T),
                                    straordinario=sample(1:24, 1000, replace=T))

medicoRegistra_df <- data.frame(
                                mese=sample(mesi_seq, 1000, replace=T),
                                codicemedico=sample(codice_medico, 1000, replace=T),
                                ordinario=sample(1:48, 1000, replace=T),
                                straordinario=sample(1:24, 1000, replace=T))

luoghi <- c("gilda dei medici", "associazione dentisti", "sultanato ortopedici", "Tema dei chirurghi", "corporazione neuroscienziati")
denominazione <- c("protesi e installazione", "Logopedia","Geriatria applicata", "i bisogni dei pazienti", "fisioterapia", "salute pubblica")
giorni_seq <-seq(as.Date("2021/5/1"), as.Date("2021/10/1"), "day")
corsi_di_aggiornamento_df <- data.frame(
                                        luogo=sample(luoghi, 10, replace=T),
                                        denominazione=sample(denominazione, 10, replace=T),
                                        data=sample(giorni_seq, 10, replace=T))



dbWriteTable( con,name=c("studio", "medico"),value=medici_int_df,append=T,row.names=F)
dbWriteTable( con,name=c("studio", "medico"),value=medici_ext_df,append=T,row.names=F)
dbWriteTable( con,name=c("studio", "membroPersonaleAusiliario"),value=ausiliario_df,append=T,row.names=F)
dbWriteTable( con,name=c("studio", "storico"),value=storico_df,append=T,row.names=F)
dbWriteTable( con,name=c("studio", "ausiliarioRegistra"),value=ausiliarioRegistra_df,append=T,row.names=F)
dbWriteTable( con,name=c("studio", "medicoRegistra"),value=medicoRegistra_df,append=T,row.names=F)
dbWriteTable( con,name=c("studio", "corsoDiAggiornamento"),value=corsi_di_aggiornamento_df,append=T,row.names=F)


