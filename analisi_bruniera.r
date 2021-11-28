#!/usr/bin/env Rscript
library("RPostgreSQL")
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv,
	dbname="studiomedico",
	host="localhost",
	port=5432,
	user="postgres",
	password="postgres")
silent <- dbGetQuery(con, "set search_path to studio;")

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
