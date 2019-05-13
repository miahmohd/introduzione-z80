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
- `ld c, "a"` carica in c il valore del carattere *"a"*, nel simulatore viene visualizzato *61* (valore esadecimale ascii di *a*)


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
...
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