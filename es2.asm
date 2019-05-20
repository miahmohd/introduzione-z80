.seg main (abs)

ld hl, dati
ld a, 0
add a, (hl)
inc hl
add a, (hl)

ld (0x1000), a


.org 0x1020
dati:
    .db 2
    .db 3