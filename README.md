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

*Nota: i flags nel simulatore sono rossi quando valgono 1 (attivi)*