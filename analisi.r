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

pdf("pazienti_per_medico.pdf")
df <- dbGetQuery(con,"SELECT codicemedico, count(distinct cf) FROM medicoappuntamento GROUP BY codicemedico ORDER BY codicemedico")
matr <- matrix(df$count, nrow=100)
rownames(matr) <- df$codicemedico
matrT <- t(matr)
barplot(matrT, main="numero di pazienti per ogni medico", xlab="codice medico", ylab="numero di pazienti", las=2)

pdf("ore_per_categoria.pdf")
df_med_ext <- dbGetQuery(con,"select medicoregistra.codiceMedico, tipo, (SUM(ordinario) + SUM(straordinario)) as \"sum\" from medicoregistra join medico on medico.codicemedico = medicoregistra.codicemedico group by medicoregistra.codiceMedico, tipo having tipo <> 'interno'")

df_med_int <- dbGetQuery(con,"select medicoregistra.codiceMedico, tipo, (SUM(ordinario) + SUM(straordinario)) as \"sum\" from medicoregistra join medico on medico.codicemedico = medicoregistra.codicemedico group by medicoregistra.codiceMedico, tipo having tipo <> 'esterno'")

df_aus_ass <- dbGetQuery(con,"select ausiliarioregistra.codicePersonale, tipo, (SUM(ordinario) + SUM(straordinario)) as \"sum\" from ausiliarioregistra join membroPersonaleAusiliario on membroPersonaleAusiliario.codicePersonale = ausiliarioregistra.codicePersonale group by ausiliarioregistra.codicePersonale, tipo having tipo = 'assistente medico'")

df_aus_amm <- dbGetQuery(con,"select ausiliarioRegistra.codicePersonale, tipo, (SUM(ordinario) + SUM(straordinario)) as \"sum\" from ausiliarioregistra join membroPersonaleAusiliario on membroPersonaleAusiliario.codicePersonale = ausiliarioregistra.codicePersonale group by ausiliarioregistra.codicePersonale, tipo having tipo = 'amministrativo'")

boxplot(df_med_ext$sum, df_med_int$sum, df_aus_ass$sum, df_aus_amm$sum, names=c("medici esterni", "medici interni", "ausiliari ass med", "ausiliari amm"), main="ore cumulative per categoria", xlab="categoria", ylab="ore lavorate")

pdf("eta_vs_sedute.pdf")
eta_vs_sedute <- dbGetQuery(con, "select extract(year from age(dataDiNascita)) eta, count(*) sedute
                                  from seduta natural join paziente
                                  group by cf,dataDiNascita;")
plot(eta_vs_sedute, main = "#sedute in relazione ad età del paziente")

pdf("andamento_ore.pdf")
andamento_ore <- dbGetQuery(con, "select
                                    extract(year from s.mese) + ((extract(month from s.mese) - 1) / 12) mese,
                                    sum(a.ordinario + a.straordinario) ore_ausiliario,
                                    sum(m.ordinario + m.straordinario) ore_medico
                                  from (storico as s join ausiliarioRegistra as a on s.mese = a.mese) join medicoRegistra as m  on s.mese = m.mese
                                  group by s.mese
                                  order by s.mese;")
plot(andamento_ore$mese, andamento_ore$ore_medico, lty = 1, type = "l", main = "Andamento ore mensili", ylab = "#ore", xlab = "mese")
lines(andamento_ore$mese, andamento_ore$ore_ausiliario, lty = 4, type = "l")
legend("topleft", legend = c("ore medici", "ore ausiliari"), lty = c(1, 4))

dev.off()