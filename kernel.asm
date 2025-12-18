bits 16
org 0x0000

VGA equ 0xB800
cli
mov ax, cs
mov ds, ax
mov ss, ax
mov sp, 0x7C00
sti

mov ax, VGA
mov es, ax
mov ax, 0x0001
int 0x10
mov ah, 01h
mov cx, 2000h   ; start > end → cursor off
int 10h

start:
    call clearscreen
    call askram
start2:
    mov ah, 0x1F
    mov di, 44*2
    mov si, line1
    call print
    mov di, 121*2
    mov si, line2
    call print
    mov di, (120+17)*2
    mov si, ram
    call print
    mov di, (120+17+5)*2
    mov si, line3
    call print
    mov di, 5*40*2
    mov si, line4
    call print
    jmp halt


askram:
    pusha
    mov ah, 0x88
    int 0x15
    add ax, 640
    call itoa_16_to_ram 
    popa
    ret

itoa_16_to_ram:
    pusha
    mov cx, 5
    mov si, ram + 4  

convert_loop:
    mov dx, 0
    mov bx, 10
    div bx
    add dl, '0'
    mov [si], dl
    dec si
    loop convert_loop
    mov byte [ram+5], 0
    popa
    ret
    
print:
    lodsb
    test al, al
    jz done
    mov ah, 0x1F
    mov [es:di], ax
    add di, 2
    jmp print

clearscreen:
    mov ax, VGA
    mov es, ax
    mov ax, 0x9F20
    mov di, 0x0000
    mov cx, 1000
    rep stosw
    ret

done:
    ret

halt:
    hlt

line1 db "**** COMMODORE 64 BASIC V2 ****", 0
line2 db "64K RAM SYSTEM  ",0
line3 db " BASIC BYTES FREE",0
line4 db "READY.", 0
space db " ", 0
ram db "00000",0
