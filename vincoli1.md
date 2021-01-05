Vincoli aziendali:
* Ogni paziente regolare deve sottoporsi ad almeno una terapia aperta
  * Tipo di paziente diventa un attributo derivato
* [x] Ad una terapia prolungata aperta deve essere associato almeno un appuntamento programmato
* Ad una terapia polungata chiusa possono essere associati solo appuntamenti accettati o saltati
  * Trigger, quando si chiude la terapia si controllano gli appuntamenti
* Il medico che si occupa dell'appuntamento deve essere specializzato secondo la specializzazione richiesta dalla terapia
  * Trigger all'inserimento della tupla su medicoAppuntamento
* Lo stesso paziente non può sottoporsi a più terapie dello stesso tipo contemporaneamente
  * Si rendono uniche data ed ora e cf
  * Conoscendo questo vincolo, il cf e data ed ora sono una chiave primaria candidata e sono un sottoindieme della chiave scelta dal concettuale
  * Ma nel concettuale il campo cf non è visibile, quindi non si può prendere in considerazione, bisogna decidere cosa fare
* Gli appuntamenti programmati sono programmati per una data ed ora future
  * Vincolo semplice
  * Bisogna unire data ed ora in un singolo campo
* Gli appuntamenti saltati ed accettati sono programmati per una data ed ora passate
  * Ogni giorno un infermiere controlla chi si presenta o meno e segna gli appuntamenti
