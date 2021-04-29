library("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv,
	dbname="ospedale",
	host="localhost",
	port=5432,
	user="postgres",
	password="Maximo98--")
# Settiamo lo schema così non serve indicarlo
dbGetQuery(con, "set search_path to studio")
# Campioni
nomi <- readLines("C:/Users/grand/Desktop/Programming/Database-Project-2020/files di popolazione del database/nomi.txt")
cognomi <- readLines("C:/Users/grand/Desktop/Programming/Database-Project-2020/files di popolazione del database/cognomi.txt")
dat <- seq(as.Date('1922/01/01'), as.Date('2021/01/01'), by="day")
indirizzi <- readLines("C:/Users/grand/Desktop/Programming/Database-Project-2020/files di popolazione del database/indirizzi.csv")
moneta <- c("testa", "croce")
cf <- readLines("C:/Users/grand/Desktop/Programming/Database-Project-2020/files di popolazione del database/cf.txt")

# Tabella di specializzazioni
tipodispecializzazione <- c("Cardiologia", "Pneumologia", "Neurologia", "Dermatologia", "Nefrologia", "Infettivologia", "Medicina Interna", "Chirurgia generale", "Fisiatria", "Geriatria", "Odontoiatria")

# Pazienti parziali (manca il tipo di paziente)
nome <- sample(nomi, 10000, replace=T)
cognome <- sample(cognomi, 10000, replace=T)
indirizzo <- sample(indirizzi, 10000, replace=T)
recapitotelefonico <- sample(1:10000000000, 10000, replace=T)
datadinascita <- sample(dat, 10000)
eta <- sample(1:99, 10000, replace=T)

# Seduta
cf_seduta <- sample(cf, 20000, replace=T)
ora <- sample(1:24, 20000, replace=T)
ambulatorio <- sample(LETTERS[1:26], 20000, replace=T)
data_seduta <- sample(dat, 20000, replace=T)
# cf[!(cf%in%cf_seduta)]

# Terapie aperte (frame di appoggio per controllare i vincoli)
aperte <- data.frame(matrix(ncol = 2, nrow=0))
colnames(aperte) <- c("cf", "spec")
# Terapia prolungata
cf_terapia <- sample(cf, 5000, replace=T)
tipodispecializzazione_terapia <- sample(tipodispecializzazione, 5000, replace=T)
numeroappuntamenti <- 0
datadiinizio <- sample(dat, 5000, replace=T)
datadifine <- sample(dat, 5000, replace=T)
tipoditerapia <- c()
for(i in 1:length(datadifine)) {
    if(datadifine[i] < datadiinizio[i]) {
        # Controlla i vincoli
        record <- data.frame(cf = c(cf_terapia[i]), spec = c(tipodispecializzazione_terapia[i]))
        if(!duplicated(rbind(aperte, record))[nrow(aperte)+1]) {
            datadifine[i]  <- NA
            tipoditerapia[i] <- "aperta"
            aperte <- rbind(aperte, record)
        } else {
            datadifine[i] <- datadiinizio[i] + 1
            tipoditerapia[i] <- "chiusa"
        }
    } else {
        tipoditerapia[i] <- "chiusa"
    }
}

# Fine di paziente
tipo = c()
for(i in 1:length(cf)) {
    regolare <- cf[i]%in%cf_terapia
    occasionale <- cf[i]%in%cf_seduta
    if(regolare && occasionale) {
        tipo[i] <- "entrambi"
    } else {
        if(regolare) {
            tipo[i] <- "regolare"
        } else {
            if(occasionale) {
                tipo[i] <- "occasionale"
            } else {
                tipo[i] <- "occasionale"
                append(cf_seduta, cf[i])
                append(ora, sample(1:24, 1, replace=T))
                append(ambulatorio, sample(LETTERS[1:26], 1, replace=T))
                append(data_seduta, sample(dat, 1, replace=T))
            }
        }
    }
}

# Costruzione dei dataframe
specializzazione <- data.frame(
                               tipodispecializzazione = tipodispecializzazione
)

paziente <- data.frame( cf = cf, 
                       nome = nome, 
                       cognome = cognome, 
                       indirizzo = indirizzo, 
                       recapitotelefonico = recapitotelefonico, 
                       datadinascita = datadinascita, 
                       eta = eta, 
                       tipo = tipo
)

terapiaprolungata <- data.frame(
                                datadiinizio = datadiinizio,
                                cf = cf_terapia,
                                datadifine =  datadifine,
                                tipoditerapia = tipoditerapia,
                                tipodispecializzazione = tipodispecializzazione_terapia,
                                numeroappuntamenti = numeroappuntamenti
)

seduta <- data.frame(
                     data = data_seduta,
                     ora = ora,
                     ambulatorio = ambulatorio,
                     cf = cf_seduta
)

# Scrittura tabelle sul DB
# Non devono esserci gli schemi nel nome della tabella
dbWriteTable(con, name = c("specializzazione"), value = specializzazione, row.names=F, append = T)
dbWriteTable(con, name = c("paziente"), value = paziente, row.names=F, append = T)
dbWriteTable(con, name = c("terapiaprolungata"), value = terapiaprolungata, row.names=F, append = T)
dbWriteTable(con, name = c("seduta"), value = seduta, row.names=F, append = T)





v_nomi <- readLines("C:/Users/grand/Desktop/Programming/Database-Project-2020/files di popolazione del database/nomi.txt", warn=FALSE)
v_cognomi <- readLines("C:/Users/grand/Desktop/Programming/Database-Project-2020/files di popolazione del database/cognomi.txt", warn=FALSE)
v_indirizzi <- readLines("C:/Users/grand/Desktop/Programming/Database-Project-2020/files di popolazione del database/indirizzi.csv", warn=FALSE)
v_cf <- readLines("C:/Users/grand/Desktop/Programming/Database-Project-2020/files di popolazione del database/cf.txt", warn=FALSE)

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

v_codes <- readLines("C:/Users/grand/Desktop/Programming/Database-Project-2020/files di popolazione del database/8char_codes.csv", warn=FALSE)
codici_personale_ausiliario <- sample(v_codes, 100, replace=F)
ausiliario_df <- data.frame(
                            codicepersonale=codici_personale_ausiliario,
                            recapitotelefonico=sample(1173000000:1187000000, 100, replace=F),
                            indirizzo=sample(v_indirizzi, 100, replace=T),
                            cognome=sample(v_cognomi, 100, replace=T),
                            nome=sample(v_nomi, 100, replace=T),
                            tipo=sample(c("assistente medico", "amministrativo", "entrambi"),100,replace=T))

mesi_seq <-seq(as.Date("2000/1/1"), as.Date("2021/1/1"), "month")
storico_df <- data.frame(mese=mesi_seq)

mesi_au = c()
personale_au = c()
for(mese in mesi_seq) {
    n <- sample(1:100, 1)
    persone <- sample(codici_personale_ausiliario, n, replace=F)
    personale_au <- append(personale_au, persone)
    mesi_au <- append(mesi_au, rep(as.Date(mese, origin="1970/01/01"), n))
}
ausiliarioRegistra_df <- data.frame(
                                    mese=mesi_au,
                                    codicepersonale=personale_au,
                                    ordinario=sample(20:160, length(mesi_au), replace=T),
                                    straordinario=sample(0:24, length(mesi_au), replace=T))

mesi_md = c()
medici_st = c()
for(mese in mesi_seq) {
    n <- sample(1:100, 1)
    persone <- sample(codice_medico, n, replace=F)
    medici_st <- append(medici_st, persone)
    mesi_md <- append(mesi_md, rep(as.Date(mese, origin="1970/01/01"), n))
}
medicoRegistra_df <- data.frame(
                                mese=mesi_md,
                                codicemedico=medici_st,
                                ordinario=sample(20:160, length(mesi_md), replace=T),
                                straordinario=sample(0:24, length(mesi_md), replace=T))

luoghi <- c("gilda dei medici", "associazione dentisti", "sultanato ortopedici", "Tema dei chirurghi", "corporazione neuroscienziati")
denominazione <- c("protesi e installazione", "Logopedia","Geriatria applicata", "i bisogni dei pazienti", "fisioterapia", "salute pubblica")
giorni_seq <-seq(as.Date("2021/5/1"), as.Date("2021/10/1"), by="day")
corsi_di_aggiornamento_df <- data.frame(
                                        luogo=sample(luoghi, 10, replace=T),
                                        denominazione=sample(denominazione, 10, replace=T),
                                        data=sample(giorni_seq, 10, replace=T))
	

medicoSeduta_df <- data.frame(
   						codicemedico=codice_medico,
  						data=data_seduta,
   						ora=ora,
   						cf=cf_seduta
   						)

ausiliarioSeduta_df <- data.frame(
   						codicepersonale=codici_personale_ausiliario,
  						data=data_seduta,
   						ora=ora,
   						cf=cf_seduta
   						)

							
qualifiche <- c("diploma di ragioneria", "tecnico cardiologo", "laurea infermieristica", "B2 inglese", "C1 inglese", "B2 copto")

qualifica_df <- data.frame(
							tipodiqualifica=qualifiche
)

spec_md = c()
medici_sp = c()
for(medico in codice_medico) {
    n <- sample(1:4, 1)
    spec <- sample(tipodispecializzazione, n, replace=F)
    spec_md <- append(spec_md, spec)
    medici_sp <- append(medici_sp, rep(medico, n))
}
specializzare_df <- data.frame(
							codicemedico=medici_sp,
							tipodispecializzazione=spec_md
							)

pers_qu = c()
qual_au = c()
for(pers in codici_personale_ausiliario) {
    n <- sample(1:4, 1)
    qual <- sample(qualifiche, n, replace=F)
    qual_au <- append(qual_au, qual)
    pers_qu <- append(pers_qu, rep(pers, n))
}
qualificare_df <- data.frame(
						codicepersonale=pers_qu,
						tipodiqualifica=qual_au
						)







dbWriteTable( con,name=c("medico"),value=medici_ext_df,append=T,row.names=F)
dbWriteTable( con,name=c("medico"),value=medici_int_df,append=T,row.names=F)
dbWriteTable( con,name=c("membropersonaleausiliario"),value=ausiliario_df,append=T,row.names=F)
dbWriteTable( con,name=c("storico"),value=storico_df,append=T,row.names=F)
dbWriteTable( con,name=c("ausiliarioregistra"),value=ausiliarioRegistra_df,append=T,row.names=F)
dbWriteTable( con,name=c("medicoregistra"),value=medicoRegistra_df,append=T,row.names=F)
dbWriteTable( con,name=c("corsodiaggiornamento"),value=corsi_di_aggiornamento_df,append=T,row.names=F)
dbWriteTable( con,name=c("medicoseduta"),value=medicoSeduta_df,append=T,row.names=F)
dbWriteTable( con,name=c("ausiliarioseduta"),value=ausiliarioSeduta_df,append=T,row.names=F)
dbWriteTable( con,name=c("qualifica"),value=qualifica_df,append=T,row.names=F)
dbWriteTable( con,name=c("qualificare"),value=qualificare_df,append=T,row.names=F)
dbWriteTable( con,name=c("specializzare"),value=specializzare_df,append=T,row.names=F)
