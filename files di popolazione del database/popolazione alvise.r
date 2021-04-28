library("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv,
	dbname="studiomedico",
	host="localhost",
	port=5432,
	user="postgres",
	password="postgres")
# Settiamo lo schema così non serve indicarlo
dbGetQuery(con, "set search_path to studio")
# Campione di terapie associate ai pazienti
terapie_pazienti <- dbGetQuery(con, "select * from paziente natural join terapiaprolungata")

# Creo da 1 a 10 appuntamenti per ogni terapia
ora_ap = c()
data_ap = c()
datadiinizio = c()
cf = c()
tipodispecializzazione = c()
for(i in 1:nrow(terapie_pazienti)) {
    ter <- terapie_pazienti[i,]
    n <- sample(1:10, 1)
    if(ter$tipoditerapia == "aperta") {
        # Scelgo la data (senza ripetizioni) tra quella di inizio ed una futura
        date_ap <- sample(
                      seq(
                          as.Date(ter$datadiinizio),
                          as.Date("2022/12/31"),
                          by="day"),
                      n, replace=F)
    } else {
        # Non posso avere più appuntamenti che giorni di terapia
        n <- min(n, ter$datadifine - ter$datadiinizio + 1)
        # Scelgo la data (senza ripetizioni) tra quella di inizio e quella di fine
        date_ap <- sample(
                      seq(
                          as.Date(ter$datadiinizio),
                          as.Date(ter$datadifine),
                          by="day"),
                      n, replace=F)
    }
    # Append di tutti i blocchi di dati
    orari <- sample(1:24, n, replace = T)
    ora_ap <- append(ora_ap, orari)
    data_ap <- append(data_ap, date_ap)
    datadiinizio <- append(datadiinizio, rep(ter$datadiinizio, n))
    cf <- append(cf, rep(ter$cf, n))
    tipodispecializzazione <- append(tipodispecializzazione, rep(ter$tipodispecializzazione, n))
}

# Creo e carico il dataframe
appuntamento <- data.frame(
                           datadiinizio = datadiinizio,
                           cf = cf,
                           tipodispecializzazione = tipodispecializzazione,
                           data = data_ap,
                           ora = ora_ap)


dbWriteTable(con, name=c("appuntamento"), value=appuntamento, append=T, row.names=F)

# Campione di appuntamenti passati
appuntamenti_passati <- dbGetQuery(con, "select * from appuntamento where data <= CURRENT_DATE")
passati = nrow(appuntamenti_passati)
accettati <- appuntamenti_passati[sample(1:passati, passati / 2, replace=F),]
ambulatorio <- sample(LETTERS, passati / 2, replace=T)

# Creo e carico il dataframe
accettato <- data.frame(
                        ambulatorio = ambulatorio,
                        data = accettati$data,
                        datadiinizio = accettati$datadiinizio,
                        tipodispecializzazione = accettati$tipodispecializzazione,
                        cf = accettati$cf)

dbWriteTable(con, name=c("accettato"), value=accettato, append=T, row.names=F)

# Campione di specializzazioni
specializzazione <- dbGetQuery(con, "select * from specializzazione")

medici_specializzati = new.env()
for(i in 1:nrow(specializzazione)) {
    spec = specializzazione[i,]
    medici_specializzati[[spec]] <- dbGetQuery(con, "select codicemedico from specializzare")
}

#   codicemedico = c()
#   data_ac = c()
#   datadiinizio = c()
#   cf = c()
#   tipodispecializzazione = c()
#   for(i in 1:nrow(accettato)) {
#       app = accettato[i,]
#       n = sample(1:3, 1)
#       medici <- sample(medici_specializzati[[app$tipodispecializzazione]], n, replace=F)
#       codicemedico <- append(codicemedico, medici)
#       data_ac <- append(data_ac, rep(app$data, n))
#       datadiinizio <- append(datadiinizio, rep(app$datadiinizio, n))
#       cf <- append(cf, rep(app$cf, n))
#       tipodispecializzazione <- append(tipodispecializzazione, rep(app$tipodispecializzazione, n))
#   }
#
#   # Creo e carico il dataframe
#   medicoappuntamento <- data.frame(
#                                    cf = cf,
#                                    data = data_ac,
#                                    codicemedico = codicemedico,
#                                    datadiinizio = datadiinizio,
#                                    tipodispecializzazione = tipodispecializzazione)
#
#   dbWriteTable(con, name=c("medicoappuntamento"), value=medicoappuntamento, append=T, row.names=F)

# Campione di medici
personale <- dbGetQuery(con, "select * from membropersonaleausiliario")

codicepersonale = c()
data_ac = c()
datadiinizio = c()
cf = c()
tipodispecializzazione = c()
for(i in 1:nrow(accettato)) {
    app = accettato[i,]
    n = sample(1:3, 1)
    medici <- sample(personale$codicepersonale, n, replace=F)
    codicepersonale <- append(codicepersonale, medici)
    data_ac <- append(data_ac, rep(app$data, n))
    datadiinizio <- append(datadiinizio, rep(app$datadiinizio, n))
    cf <- append(cf, rep(app$cf, n))
    tipodispecializzazione <- append(tipodispecializzazione, rep(app$tipodispecializzazione, n))
}

# Creo e carico il dataframe
ausiliarioappuntamento <- data.frame(
                                 cf = cf,
                                 data = data_ac,
                                 codicepersonale = codicepersonale,
                                 datadiinizio = datadiinizio,
                                 tipodispecializzazione = tipodispecializzazione)

dbWriteTable(con, name=c("ausiliarioappuntamento"), value=ausiliarioappuntamento, append=T, row.names=F)
