BITS 16
ORG 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    ; képernyő törlés (text mode)

    ; BIOS által adott boot drive mentése
    mov [BOOT_DRIVE], dl

    ; -------------------------------------------------
    ; Kernel betöltése 0x1000:0x0000 → fizikai 0x10000
    ; -------------------------------------------------
    mov ax, 0x1000
    mov es, ax
    xor bx, bx

    mov ah, 0x02        ; BIOS read sectors
    mov al, 1           ; 1 szektor (teszt)
    mov ch, 0
    mov cl, 2          ; 2. szektor (boot után)
    mov dh, 0
    mov dl, [BOOT_DRIVE]
    int 0x13
    jc disk_error

    ; ugrás a kernelhez
    jmp 0x1000:0x0000

; -------------------------------------------------
; Hiba esetén üzenet
; -------------------------------------------------
disk_error:
    mov si, err
    call print
    hlt
    jmp $

; -------------------------------------------------
; Sztring kiírás BIOS-szal
; DS:SI -> 0-terminált string
; -------------------------------------------------
print:
    mov ah, 0x0E
.next:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .next
.done:
    ret

err db "Disk error!", 0

BOOT_DRIVE db 0

; -------------------------------------------------
; Boot szektor aláírás
; -------------------------------------------------
times 510-($-$$) db 0
dw 0xAA55
