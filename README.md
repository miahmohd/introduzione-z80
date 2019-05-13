# Introduzione alla programmazione dello z80
## Istruzioni di caricamento `ld`
La istruzione `ld` viene utilizzata per il caricamento dei valori nei registri e nella memoria. L'struzione appare in diverse forme a seconda di dove e cosa caricare.


### `ld r, n`
Serve per caricare il valore `n` direttamente nel registro `r`. È possibile utilizzarla per caricare numeri decimali, numeri esadecimali, e caratteri ascii.
```
ld a, 10
ld b, 0x10
ld c, "a"
```
- `ld a, 10` carica in `a` *10* decimale, nel simulatora verrà visualizzato *0A* (valore esadecimale)
- `ld b, 0x10` carica in b *0x10* esadecimale, nel simulatora verrà visualizzato *10* (valore esadecimale)
- `ld c, "a"` carica in c il valore del carattere *"a"*, nel simulatore viene visualizzato *61* (valore esadecimale ascii del carattere *a*)


### `ld r, r'`
Questa forma permette il caricamento da registro a registro, quindi copia il valore del registro `r'` in `r`.
```
ld b, 7     ;b=7
ld c, 4     ;c=4
ld b, c     ;b=c
ld a, b     ;a=b
```
al termine dell'esecuzione i registri `a`, `b` e `c` saranno uguali a *4*


### `ld A, (nn)` e `ld (nn), A`
Servono per il trasferimento diretto dei dati tra l'accumulatore e la memoria.
- `ld a, (nn)` carica il contenuto della cella all'indirizzo *nn* nell'accumulatore (registro `a`)
- `ld (nn), a` salva il contenuto dell'accumulatore nella cella di memoria *nn*

Esempio per salvare *0x14* nella cella *0x1020*
```
ld a, 0x14
ld (0x1020), a
```

Esempio per caricare il contenuto della cella *0x0020* in `a`
```
ld a, (0x0020)
```
Al termine dell'esecuzione in `a` mi ritrovo *0x14*
```
ld a, 0x14
ld (0x1020), a
ld a, 5
ld a, (0x1020)
```

***Attenzione***: il caricamento diretto tra registro e memoria funziona solo con l'*accumulatore*, per utilizzare gli altri registri è necessario usare un registro di appoggio dove è salvato l'indirizzo di memoria.


### `ld r, (HL)` e `ld (HL), r`
Questa è la versione di `ld` che viene utilizzata per il trasferimento di valori tra un registro qualsiasi `r` e la cella di memoria indirizzata da `hl`.  
Questo metodo si chiama **caricamento indiretto**.  

Ad esempio se volessi caricare il contenuto della cella *0x1020* nel registro `b` non posso fare `ld b, (0x1020)`, ma devo caricare in `hl` il valore *0x1020* e in seguito fare `ld b, (hl)`.
```
;salvo 0x14 nella memoria all'indirizzo 0x1020
ld a, 0x14
ld (0x1020), a

;carico il contenuto della cella 0x1020 in b
ld hl, 0x1020
ld b, (hl)

;salvo il contenuto di b all'indirizzo 0x0020
ld hl, 0x0020
ld (hl), b
```
***Osservazioni***: utilizzando `hl` è possibile utilizzare un qualsiasi registro per il caricamento anche `a`.  
Però se volessi utilizzare un'altro registro a 16 bit diverso da `hl`, quindi o `bc` o `de` il caricamento indiretto funziona solo con il registro `a`.
Funzionano:
```
ld a, (bc)
ld a, (de)

ld (bc), a
ld (de), a
```
ma danno errore ad esempio:
```
ld b, (de)
ld (de), c
```

## Operazioni aritmetiche
### `add A, n` e `sub A, n`
Queste istruzioni servono, ripettivamente, per sommare o sottrarre al reg. `a` il numero *n*.
Il risultato dell'operazione viene salvato in `a`.
```
ld a, 5
sub a, 4
add a, 2
```
al termine dell'esecuzione mi ritrovo in `a` il numero *3*.

Visto che queste operazioni sono possibili solo coll'accumulatore è possibile omettere il registro nell'istruzione:
```
ld a, 5
sub 4
add 2
```
ha lo stesso risultato di prima.

### `add A, r` e `sub A, r`
Queste varianti servono per sommare o sottrarre al reg. `a` il numero contenuto nel reg. `r`.
```
ld a, 5
ld b, 4
ld c, 2

sub a, b
add a, c
```
al termine dell'esecuzione mi ritrovo in `a` il numero *3*.  
*Valgono le stesse osservazioni di prima*

### `inc r` e `dec r`
Servono rispettivamente ad incrementare o decrementare di *1* il registro `r`.  
`inc a` equivale ad `add a, 1`  
`dec a` equivale ad `sub a, 1`
```
ld b, 0
inc b
inc b
inc b
```
al termine b conterra *3*

## Direttive e Tag
Le direttive possiamo considerarle delle *'istruzioni speciali'* che vengono eseguite prima che parta il programma.
### `.seg name (abs)` e `.org nn`
per poter utilizzare `.org`, è necessario che il codice del programma inizi con `.seg`.

`.seg NOME (abs)` assegna il nome *'NOME'* alla porzione di codice che segue la direttiva.
`.org 0x1020` questa direttiva indica al processore di salvare la traduzione delle istruzioni a partire dall'indirizzo *0x1020*
```
.seg main (abs)
ld a, 1
ld b, 3

.org 0x1000
add a, 3
dec b
```
andando sul simulatore possiamo vedere che le prime due istruzioni (`ld a, 1` e `ld b, 3`) sono state tradotte in codice macchina e salvate in memoria nelle 4 celle consecutive a partire dall'indirizzo *0x0000*.  
Le ultime due istruzioni, visto che sono precedute da `.org 0x1000`, sono salvate a partire dall'indirizzo *0x1000*.

### `.asciz "abc"`
Questa direttiva serve per salvare in memoria una stringa.  
Ogni carattere occupa una cella i memoria, e l'ultimo carattere sarà sempre lo *'0'* che sta ad indicare che la stringa è finita.
```
.asciz "abc"
```
questa istruzione salverà la stringa nel seguente modo:

Ind. memoria | Valore
--- | ---
0x0000 | 0x61
0x0001 | 0x62
0x0002 | 0x63
0x0003 | 0x00

*I valori sono il codice ascii dei caratteri*

### `.db n`
Serve per salvare il valore *n* in un byte (una cella di memoria).
```
.db 5
```
Salva all'indirizzo *0x0000* il numero *5*.

### Utilizzo dei *tag*
Un tag serve per *taggare* un'indirizzo di memoria. In questo modo nelle istruzione posso fare riferimento all'indirizzo della memoria utilizzando il nome del tag al posto del valore numerico dell'indirizzo.

### Per riassumere...
Naturalmente tutte queste direttive possono essere utilizzate in combinazione.

```
.seg main (abs)
ld hl, 0x1000
ld a, (hl)

.org 0x1000
.asciz "abcd"
```
in questo codice utilizzo `.org` e  `.asciz` per salvare la stringa *"abcdef"* a partire dall'indirizzo *0x1000*, sempre tenendo in mente il funzionamento di `.asciz` quindi un carattere per cella di memoria in celle consecutive.

Ind. memoria | Valore
--- | ---
0x1000 | 0x61
0x1001 | 0x62
0x1002 | 0x63
0x1003 | 0x64
0x1003 | 0x00


Alla fine dell'esecuzione avrò in `a` il valore *0x61* (esadecimale di *'a'*). Perchè la *'a'* si trova nella cella *0x1000*, ed utilizzo il caricamento indiretto per caricare in `a` il valore della cella *0x1000*. 

Naturalmente posso caricare anche l'ennesimo carattere della stringa, visto che i caratteri sono salvati in celle consecutive.  
Ad esempio per caricare il terzo carattere:
```
.seg main (abs)

ld hl, 0x1000
inc hl
inc hl
ld a, (hl)

.org 0x1000
.asciz "abcdef"
```
oppure
```
.seg main (abs)

ld hl, 0x1002
ld a, (hl)

.org 0x1000
.asciz "abcdef"
```

Utilizzando i *tag* ottengo questo:
```
.seg main (abs)

ld hl, stringa
ld a, (hl)

.org 0x1000
stringa:
    .asciz "abcdef"
```
ho taggato la cella *0x1000* con *"stringa"*, in questo modo nelle istruzioni posso usare il tag al posto del valore numerico.

Senza usare *il caricamento indiretto* per caricare in `a` il valore potevo fare:
```
.seg main (abs)

ld a, (stringa)

.org 0x1000
stringa:
    .asciz "abcdef"
```

Un'altro esempio:
```
.seg main (abs)

ld a, (valore1)
ld b, a
ld a, (valore2)
ld c, a

.org 0x1000
valore1:
    .db 5

.org 0x1020
valore2:
    .db 4
```
in questo codice utilizzo `.db` per salvare *5* e *4* nelle celle *0x1000* e *0x1020*, successivamente utilizzo la `ld` per caricarle in `b` e `c` rispettivamente.

Le combinazioni possibili sono infinite, lascio allo studente il compito di sperimentare.

## Flags 
I *flag* sono dei registri particolari del processore. Si chiamano 'flag' perchè possono assumere soltanto due valori o *1* o *0* (*true* o *false*).  
L'assunzione del valore *1* sta ad indicare che è accaduto un certo *evento*.  
Al contrario lo *0* sta ad indicare che l'*evento* non è accaduto.
### Flag `z` e istruzione `cp`
Il flag `z` (zero) si attiva quando l'operazione precedente ha dato come risultato *0*.  
Alcuni casi in cui si attiva il flag:
```
ld a, 5
sub a, 5    ;5-5=0 ==> z=1 (attivo)

ld b, 3     
dec b       ;3-1=2 ==> z=0
dec b       ;2-1=1 ==> z=0
dec b       ;1-1=0 ==> z=1

ld a, -7
add a, 7    ;-7+7=0 ==> z=1
```

L'istruzione `cp` sta per *compare*, viene utilizzato per vedere se nell'accumulatore c'è un certo valore.

`cp n` confronta n con il valore dell'accumulatore, per confrontarlo sottrae ad `a` *n* e modifica il flag `z` in base al risultato.  
Se `a` = *n*, allora `a`-*n*=0 quindi `z`= 1  
Se `a` != *n*, allora `a`-*n* != 0 quindi `z`= 0

`cp r` confronta il valore del registro `r` con l'accumulatore.

**Confronta sempre con l'accumulatore**

Essenzialmente la `cp` ha un funzionamento analogo ad `sub`.  
**Attenzione**: `cp` al termine dell'operazione non modifica il contenuto di `a`, mentre la `sub` si, al termine della `sub` nell'accumulatore si trova il risultato.
```
ld a, 7
cp 5        ;7-5=2 ==> z=0, a=7
cp 7        ;7-7=0 ==> z=1, a=7
sub a, 7    ;7-7=0 ==> z=1, a=0
cp 7        ;0-7=-7 ==> z=0
cp 0        ;0-0=0 ==> z=1     
```

*Nota: i flags nel simulatore diventano rossi quando valgono 1 (attivi)*

## Istruzioni di salto `jp`
Le istruzioni del microprocessore vengono eseguite in sequenza uno dopo l'altro.  
La `jp` serve per rompere questa sequenza, al posto di continuare l'esecuzione dall'istruzione successiva, si continua dall'istruzione indicata dall `jp`.

La `jp` è alla base della costruzione del costrutto *`if`* e *`while`*.

### `jp nn`
Questo è il salto incondizionato.
Quando viene eseguita si salta sempre all'istruzione all'indirizzo *nn*, e da li si continua. Naturalmente è possibile utilizzartlo con i tag.
```
inizio:
    ld a, 0
    ld a, 1
    jp fine
    ld a, 2

fine:
    ld a, 3
    ld a, 4
    halt
``` 
Il programma parte e vengono eseguite in sequenza `ld a, 0` e `ld a, 1`.  
Poi viene eseguita la `jp fine`, quindi si salta all'istruzione `ld a, 3` (poichè è quella contenuta all'indirizza taggato da *fine*).  
L'esecuzione continua e vengono eseguite `ld a, 4` e `halt`.

*Notare che l'istruzione* `ld a, 2` *non verrà mai eseguita*.

***Attenzione a non creare loop infiniti indesiderati:***
```
inizio:
    ld a, 0
    ld a, 1
    jp inizio
    ld a, 2

fine:
    halt
``` 
il programma eseguirà senza mai fermarsi  `ld a, 0` e `ld a, 1`.  

Esempio: scrivere un programma che incrementa l'accumulatore di 1 all'infinito.
```
ld a, 0
inizio:
    inc a
    jp inizio
```

### `jp z, nn` e `jp nz, nn`
Queste varianti del `jp` vengono usate per fare dei *salti condizionati*.
- `jp z, nn` salta a *nn* se il flag `z` è attivo;
- `jp nz, nn` salta a *nn* se il flag `z` non è attivo;

Esempio: scrivere un programma che carica in `b` *1* se l'accumulatore contiene *7*, altrimenti carica in `b` *2*.
```
ld a, 7
cp 7
jp z, contiene_7

non_contiene_7:
    ld b, 2 
    halt

contiene_7:
    ld b, 1
    halt
```
questo è il caso in qui `a` contiene *7* quindi `jp z, contiene_7`  è vera e il salto viene eseguito, l'esecuzione continua con `ld b, 1` e `halt`.


```
ld a, 5
cp 7
jp z, contiene_7

non_contiene_7:
    ld b, 2 
    halt

contiene_7:
    ld b, 1
    halt
```
in questo caso `a` non contiene *7* quindi `jp z, contiene_7` è falsa (`z` non è attivo) e il salto non viene eseguito, l'esecuzione continua con le istruzioni successive `ld b, 2 ` e `halt`.

Il codice qui sopra è un esempio del costrutto *if*:
```c
if(a == 7)
{
    b=1
}
else
{
    b=2
}
```

```
ld a, 4
cp 7
jp nz, non_contiene_7

contiene_7:
    ld b, 1
    halt

non_contiene_7:
    ld b, 2 
    halt
```
variante con `jp nz, nn`

---


Vediamo ora come potremmo costruire un ciclo condizionato.  

Voglio scrivere un programma che partendo da 0, incrementi l'accumulatore fino ad arrivare a 10, per poi fermarsi.  

Partiamo dal codice del contatore precedente:
```
ld a, 0
inizio:
    inc a
    jp inizio
```
qui l'accumulatore viene incrementato all'infinito, ma io voglio che si fermi a *10*.

L'idea è di inserire all'interno del ciclo una salto condizionato che salta **fuori** dal ciclo quando si verifica la condizione: *l'accumulatore è 10*.  
Una possibile soluzione è:
```
ld a, 0

inizio:
    inc a
    cp 10
    jp z, fine
    jp inizio

fine:
    halt
```
se `a` contiene 10, `cp 10` mi attiva il flag `z`, essendo il flag attivo il salto `jp z, fine` viene eseguito e quindi il programma si ferma.  
se `a` **non** contiene 10, `cp 10` **non** mi attiva il flag `z`, essendo il flag **non attivo** il salto `jp z, fine` **non** viene eseguito e quindi il programma continua con `jp inizio` e ricomincia il ciclo.

Un altro esempio di ciclo e quello sui caratteri di una stringa.
```
ld hl, stringa

inizio:
    ld a, (hl)
    cp 0
    jp z, fine
    inc hl
    jp inizio

fine:
    halt

stringa:
    .asciz "abcd"
```
Partendo dalla prima posizione carico carattere per carattere i valori nell'accumulatore, termino il ciclo quando nell'accumulatore trovo *0* (carattere di fine stringa).


# Esercizi

### es 1
Salvare un numero nella cella di memoria 0x1020, e uno nella cella 0x1021.  
Scrivi il programma nelle 3 varianti: utilizzando il caricamento diretto, il caricamento indiretto, e  la direttiva `.db`

### es 2
Fare la somma di due numeri salvati nelle celle consecutive a partire da 0x1020 e salvare il risultato alla cella 0x1000.

### es 3
Carica in `a`, `b` e in `c` un numero. Calcolare l'espressione `(a+b)-(a+c)` e salvare il risultato in 0x1000.
Per esempio se `a=7`, `b=5`, `c=2` in 0x1000 devo salvare `(7+5)-(7-2) = 3`

### es 4
Fare la differenza di due numeri salvati nelle celle consecutive a partire da 0x1020 e salvare il risultato alla cella 0x1000, se i due numeri sono uguali (differenza fa 0), altrimenti salvare il risultato in 0x2000.

### es 5
Scrivere un programma che decrementa il valore dell'accumulatore finchè non raggiunge lo 0.
Ad esempio se l'accumulatore contiene 20, il programma deve decrementare `a` fino ad arrivare a 0 per poi fermarsi. (20, 19, 18, 17, 16, ..., 3, 2, 1, 0)

### es 6
Scrivere un programma che partendo dalla cella di memoria 0x1000 setti le 20 celle consecutive con il valore 0x00.

### es 7
Scrivere un programma che scrive in memoria a partire dall'indirizzo 0x1000 la sequenza di numeri 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, ... fino a 100.

### es 8
Scrivere un programma che somma il contenuto di 4 celle consecutive situate all'indirizzo 0x1000; caricare le 4 celle utilizzando `.db` ed utilizzando un ciclo calcolare la somma e salvarla nel reg. `c`.  
*Suggerimento: sai a priori che le celle sono 4, quindi usa un registro come contatore che viene decrementato partendo da 4*

### es 9
Calcolare la lunghezza di una stringa salvata all'indirizzo 0x1000.

### es 10
Dati 2 numeri fare la moltiplicazione tra i due numeri, e salvare il risultato in 0x1000.  

### es 10.5
Dati 2 numeri fare la divisione tra i due numeri, e salvare il risultato in 0x1000. 
(supponi che i numeri siano uno multiplo dell'altro, quindi facendo le sottrazioni succcessive prima o poi si ottiene 0).

### es 11 (verifica 2017/2018)
Date 2 stringhe s1 e s2:
- Determina quale delle due è più corta.
- Se **s1<=s2 poni `d` = 1**, mentre se **s1 > s2 poni `d` = 2**

### es 12
Data una stringa salvata all'indirizzo 0x1000, trasformare la stringa in maiuscolo e risalvala nella stessa posizione. (supponi che la stringa abbia solo lettere minuscole)

### es 13
Data una stringa salvata all'indirizzo 0x1000, scrivi un programma che me la copi all'indirizzo 0x2000. Es "ciao" è da 0x1000 – 0x1003, il programma deve porre "ciao" a 0x2000-0x2003.

### es 14 (verifica 2017/2018)
Data una stringa salvata a apartire dall’ind 0x1000, scrivi un programma che ponga la stessa stringa in forma maiuscola a partire da 0x2000 Es “ciao” è da 0x1000 – 0x1003, il programma deve porre “CIAO” a 0x2000-0x2003.

### es 15
Data una stringa calcolare quante volte compare la lettera "a" al suo interno. Salvare il risultato in 0x1000. Ad esempio per "ciao, come va la vita?" bisogna salvare 4

### es 16 
Data una stringa calcolare quante volte compaiono le vocali. Salvare il risultato in 0x1000.
Ad esempio per "ciao, come va la vita?" bisogna salvare 9

### es 17 (verifica 2017/2018)
Date 2 stringhe s1 e s2:
- Verificare se queste sono uguali o meno.
- Se queste sono uguali poni a = 1, altrimenti a = 0.

Supponi che le due stringhe abbiano la stessa lunghezza.  
(Suggerimento: salva i due caratteri nella stessa posizione uno in `a` l'altro in `b` così puoi fare `cp b`....)