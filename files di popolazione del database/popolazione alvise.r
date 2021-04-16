library("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv,
	dbname="studiomedico",
	host="localhost",
	port=5432,
	user="postgres",
	password="postgres")
# Campioni
nomi <- readLines("nomi.txt")
cognomi <- readLines("cognomi.txt")
dat <- seq(as.Date('1922/01/01'), as.Date('2021/01/01'), by="day")
indirizzi <- readLines("indirizzi.csv")

# Tabella di specializzazioni
tipodispecializzazione <- c("Cardiologia", "Pneumologia", "Neurologia", "Dermatologia", "Nefrologia", "Infettivologia", "Medicina Interna", "Chirurgia generale")

# Pazienti parziali (manca il tipo di paziente)
cf <- paste(1:10000)
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

# Terapia prolungata
cf_terapia <- sample(cf, 5000, replace=T)
tipodispecializzazione_terapia <- sample(tipodispecializzazione, 5000, replace=T)
numeroappuntamenti <- 0
datadiinizio <- sample(dat, 5000, replace=T)
datadifine <- sample(dat, 5000, replace=T)
tipoditerapia <- c()
for(i in 1:length(datadifine)) {
    if(datadifine[i] < datadiinizio[i]) {
        datadifine[i]  <- NA
        tipoditerapia[i] <- "aperta"
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
dbWriteTable(con, name = c("studio", "specializzazione"), value = specializzazione, row.names=F, append = T)
dbWriteTable(con, name = c("studio", "paziente"), value = paziente, row.names=F, append = T)
dbWriteTable(con, name = c("studio", "terapiaProlungata"), value = terapiaprolungata, row.names=F, append = T)
dbWriteTable(con, name = c("studio", "seduta"), value = seduta, row.names=F, append = T)
