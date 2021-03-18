-- segnare appuntamenti saltati
delete from programmato
where ((data > CURRENT_DATE)
    and (data = CURRENT_DATE
        and ora < extract(hour from CURRENT_TIME)));

-- medici che hanno seguito le terapie aperte del paziente ABCDEF
select codiceMedico, nome, cognome
from (terapiaProlungata natural join medicoAppuntamento) join medico on medicoAppuntamento.codiceMedico = medico.codiceMedico
where tipoDiTerapia = 'aperta' and cf = 'ABCDEF';

-- medici che hanno seguito solo ed almeno una terapie che richiedevano la specializzazione ABCDEF
select codiceMedico, nome, cognome 
from (medico m1 natural join medicoAppuntamento) natural join terapiaProlungata t1
where t1.tipoDiSpecializzazione = 'ABCDEF'
and not exists (select *
    from (medico m2 natural join medicoAppuntamento) natural join terapiaProlungata t2
    where t2.tipoDiSpecializzazione <> 'ABCDEF'
    and m1.codiceMedico = m2. codiceMedico);

-- per ogni paziente, i medici che lo hanno visitato più spesso per problemi occasionali
create view pazienteSedutaMedico as
select cf, p1.nome nomePaziente, p1.cognome cognomePaziente, m1.codiceMedico codiceMedico, m1.nome nomeMedico, m1.cognome cognomeMedico, count(*) sedute
from ((paziente p1 natural join seduta) natural join medicoSeduta) join medico m1 on medicoSeduta.codiceMedico = m1.codiceMedico
group by p1.cf, m1.codiceMedico;

select *
from pazienteSedutaMedico s1
where not exists (select *
    from pazienteSedutaMedico s2
    where s1.cf = s2.cf
    and s1.codiceMedico = s2.codiceMedico
    and s2.sedute > s1.sedute);
