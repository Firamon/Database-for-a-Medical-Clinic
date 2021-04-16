#Massimo: Medico, Ausiliario, storico, ausiliarioRegistra, medicoRegistra, corsi di aggiornamento (a mano)

v_nomi <- readLines("C:/Users/grand/Desktop/nomi.txt", warn=FALSE)
v_cognomi <- readLines("C:/Users/grand/Desktop/cognomi.txt", warn=FALSE)
v_indirizzi <- readLines("C:/Users/grand/Desktop/indirizzi.csv", warn=FALSE)

codice_int_medico <- sample(1:10000, 50, replace=F)
codice_ext_medico <- sample(1:10000, 50, replace=F)

codice_medico <- c(codice_int_medico, codice_ext_medico)

medici_int_df <- data.frame(codiceMedico=codice_int_medico, recapitoTelefonico=sample(1143000000:1167000000, 50, replace=F), indirizzo=sample(v_indirizzi, 50, replace=T), cognome=sample(v_cognomi, 50, replace=T), nome=sample(v_nomi, 50, replace=T), tipoMedico = "interno", percentualeIncassi=sample(0:1, 50, replace=T), tariffaOraria=NA)
medici_ext_df <- data.frame(codiceMedico=codice_ext_medico, recapitoTelefonico=sample(1143000000:1167000000, 50, replace=F), indirizzo=sample(v_indirizzi, 50, replace=T), cognome=sample(v_cognomi, 50, replace=T), nome=sample(v_nomi, 50, replace=T), tipoMedico = "esterno", percentualeIncassi=NA, tariffaOraria=sample(30:120, 50, replace=T))

v_codes <- readLines("C:/Users/grand/Desktop/8char_codes.csv", warn=FALSE)
codici_personali_ausiliario <- sample(v_codes, 100, replace=F)
ausiliario_df <- data.frame(codicePersonale=codici_personali_ausiliario, recapitoTelefonico=sample(1173000000:1187000000, 100, replace=F), indirizzo=sample(v_indirizzi, 100, replace=T), cognome=sample(v_cognomi, 100, replace=T), nome=sample(v_nomi, 100, replace=T), tipoPersonale=sample(c("assistente medico", "amministrativo", "entrambi"),100,replace=T))

mesi_seq <-seq(as.Date("2000/1/1"), as.Date("2021/1/1"), "month")
storico_df <- data.frame(mesi_seq)

ausiliarioRegistra_df <- data.frame(mese=sample(mesi_seq, 1000, replace=T), codicePersonale=sample(codici_personale_ausiliario, 1000, replace=T), ordinario=sample(1:48, 1000, replace=T), straordinario=sample(1:24, 1000, replace=T))

medicoRegistra_df <- data.frame(mese=sample(mesi_seq, 1000, replace=T), codiceMedico=sample(codice_medico, 1000, replace=T), ordinario=sample(1:48, 1000, replace=T), straordinario=sample(1:24, 1000, replace=T))

luoghi <- c("gilda dei medici", "associazione dentisti", "sultanato ortopedici", "Tema dei chirurghi", "corporazione neuroscienziati")
denominazione <- c("protesi e installazione", "Logopedia","Geriatria applicata", "i bisogni dei pazienti", "fisioterapia", "salute pubblica")
giorni_seq <-seq(as.Date("2021/5/1"), as.Date("2021/10/1"), "day")
corsi_di_aggiornamento_df <- data.frame(luogo=sample(luoghi, 10, replace=T), denominazione=sample(denominazioni, 10, replace=T), data=sample(giorni_seq, 10, replace=T))



dbWriteTable( con,name=c("studio", "medico"),value=medici_int_df,append=F,row.names=F)
dbWriteTable( con,name=c("studio", "medico"),value=medici_ext_df,append=T,row.names=F)
dbWriteTable( con,name=c("studio", "membroPersonaleAusiliario"),value=ausiliario_df,append=F,row.names=F)
dbWriteTable( con,name=c("studio", "storico"),value=storico_df,append=F,row.names=F)
dbWriteTable( con,name=c("studio", "ausiliarioRegistra"),value=ausiliarioRegistra_df,append=F,row.names=F)
dbWriteTable( con,name=c("studio", "medicoRegistra"),value=medicoRegistra_df,append=F,row.names=F)
dbWriteTable( con,name=c("studio", "corsoDiAggiornamento"),value=corsi_di_aggiornamento_df,append=F,row.names=F)


