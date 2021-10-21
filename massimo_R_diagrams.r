#!/usr/bin/env Rscript
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
df <- dbGetQuery(con,"SELECT codicemedico, count(distinct cf) FROM medicoappuntamento GROUP BY codicemedico ORDER BY codicemedico")
matr <- matrix(df$count, nrow=100)
rownames(matr) <- df$codicemedico
matrT <- t(matr)
barplot(matrT, main="numero di pazienti per ogni medico", xlab="codice medico", ylab="numero di pazienti", las=2)
pdf("pazienti per medico.pdf")


df_med_ext <- dbGetQuery(con,"select medicoregistra.codiceMedico, tipo, (SUM(ordinario) + SUM(straordinario)) as \"sum\" from medicoregistra join medico on medico.codicemedico = medicoregistra.codicemedico group by medicoregistra.codiceMedico, tipo having tipo <> 'interno'")

df_med_int <- dbGetQuery(con,"select medicoregistra.codiceMedico, tipo, (SUM(ordinario) + SUM(straordinario)) as \"sum\" from medicoregistra join medico on medico.codicemedico = medicoregistra.codicemedico group by medicoregistra.codiceMedico, tipo having tipo <> 'esterno'")

df_aus_ass <- dbGetQuery(con,"select ausiliarioregistra.codicePersonale, tipo, (SUM(ordinario) + SUM(straordinario)) as \"sum\" from ausiliarioregistra join membroPersonaleAusiliario on membroPersonaleAusiliario.codicePersonale = ausiliarioregistra.codicePersonale group by ausiliarioregistra.codicePersonale, tipo having tipo = 'assistente medico'")

df_aus_amm <- dbGetQuery(con,"select ausiliarioRegistra.codicePersonale, tipo, (SUM(ordinario) + SUM(straordinario)) as \"sum\" from ausiliarioregistra join membroPersonaleAusiliario on membroPersonaleAusiliario.codicePersonale = ausiliarioregistra.codicePersonale group by ausiliarioregistra.codicePersonale, tipo having tipo = 'amministrativo'")

boxplot(df_med_ext$sum, df_med_int$sum, df_aus_ass$sum, df_aus_amm$sum, names=c("medici esterni", "medici interni", "ausiliari ass med", "ausiliari amm"))
pdf("ore per categoria.pdf")
