.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Exemplu proiect desenare",0
area_width EQU 640
area_height EQU 480
area DD 0
colt_stanga_X EQU 130
colt_stanga_Y EQU 100
linie_tabel EQU 100
verifica db 0
counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

xo db 0, 0, 0,
      0, 0, 0,
      0, 0, 0

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0ccf2ffh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

linie_orizontala macro x,y,len,color
local bucla_linie
	mov eax,y ;eax=y
	mov ebx, area_width
	mul ebx ; eax= y*area_width
	add eax,x ; eax=y*area_width +x
	shl eax,2 ;eax=(y*area_width +x)*4
	add eax, area
	mov ecx, len
bucla_linie:
	mov dword ptr[eax],color
	add eax,4
	loop bucla_linie
endm
 
linie_verticala macro x,y,len,color
local bucla_linie
	mov eax,y ;eax=y
	mov ebx, area_width
	mul ebx ; eax= y*area_width
	add eax,x ; eax=y*area_width +x
	shl eax,2 ;eax=(y*area_width +x)*4
	add eax, area
	mov ecx, len
bucla_linie:
	mov dword ptr[eax],color
	add eax,4*area_width
	loop bucla_linie
endm	

verificare macro x, y, i, j
	local par, impar, final
	cmp verifica, 15
	je final
	cmp verifica, 0
	je par
	cmp verifica, 2
	je par		
	cmp verifica, 4
	je par
	cmp verifica, 6
	je par
	cmp verifica, 8
	je par
	jmp impar
par:
	make_text_macro 'X', area, x, y
	mov xo[i][j], 1
	inc verifica
	jmp final
impar:
	make_text_macro 'O', area, x, y
	mov xo[i][j], 10
	inc verifica
final:
endm

verificare_matrice macro i, j
	cmp xo[i][j], 0
	jne sfarsit
endm

verificare_castigare macro x, y
		local castiga_x, castiga_o, final_verificare
	;prima linie
	pusha 
	mov eax, 0
	mov ebx, 0
	mov ecx, 0
    add al, xo[ebx][ecx]
	add ecx, 1
	add al, xo[ebx][ecx]
	add ecx, 1
	add al, xo[ebx][ecx]
	cmp eax, 3
	je castiga_x
	cmp eax, 30
	je castiga_o
	;a doua linie
	mov eax, 0
	mov ebx, 3
	mov ecx, 0
    add al, xo[ebx][ecx]
	add ecx, 1
	add al, xo[ebx][ecx]
	add ecx, 1
	add al, xo[ebx][ecx]
	cmp eax, 3
	je castiga_x
	cmp eax, 30
	je castiga_o
	;a treia linie
	mov eax, 0
	mov ebx, 6
	mov ecx, 0
    add al, xo[ebx][ecx]
	add ecx, 1
	add al, xo[ebx][ecx]
	add ecx, 1
	add al, xo[ebx][ecx]
	cmp eax, 3
	je castiga_x
	cmp eax, 30
	je castiga_o
	; prima coloana
	mov eax, 0
	mov ebx, 0
	mov ecx, 0
    add al, xo[ebx][ecx]
	add ebx, 3
	add al, xo[ebx][ecx]
	add ebx, 3
	add al, xo[ebx][ecx]
	cmp eax, 3
	je castiga_x
	cmp eax, 30
	je castiga_o
	; a doua coloana
	mov eax, 0
	mov ebx, 0
	mov ecx, 1
    add al, xo[ebx][ecx]
	add ebx, 3
	add al, xo[ebx][ecx]
	add ebx, 3
	add al, xo[ebx][ecx]
	cmp eax, 3
	je castiga_x
	cmp eax, 30
	je castiga_o
	; a treia coloana
		mov eax, 0
	mov ebx, 0
	mov ecx, 2
    add al, xo[ebx][ecx]
	add ebx, 3
	add al, xo[ebx][ecx]
	add ebx, 3
	add al, xo[ebx][ecx]
	cmp eax, 3
	je castiga_x
	cmp eax, 30
	je castiga_o
	; diagonala principala
	mov eax, 0
	mov ebx, 0
	mov ecx, 0
    add al, xo[ebx][ecx]
	add ebx, 3
	add ecx, 1
	add al, xo[ebx][ecx]
	add ebx, 3
	add ecx, 1
	add al, xo[ebx][ecx]
	cmp eax, 3
	je castiga_x
	cmp eax, 30
	je castiga_o
	; diagonala secundara
		mov eax, 0
	mov ebx, 0
	mov ecx, 2
    add al, xo[ebx][ecx]
	add ebx, 3
	sub ecx, 1
	add al, xo[ebx][ecx]
	add ebx, 3
	sub ecx, 1
	add al, xo[ebx][ecx]
	cmp eax, 3
	je castiga_x
	cmp eax, 30
	je castiga_o
	;verificare remiza
	cmp verifica, 9
	jne final_verificare
remiza:
		make_text_macro 'R', area, x-80, y
		make_text_macro 'E', area, x-70, y
		make_text_macro 'M', area, x-60, y
		make_text_macro 'I', area, x-50, y
		make_text_macro 'Z', area, x-40, y
		make_text_macro 'A', area, x-30, y
	mov verifica, 15
	jmp final_verificare
castiga_x:
		make_text_macro 'C', area, x-80, y
		make_text_macro 'A', area, x-70, y
		make_text_macro 'S', area, x-60, y
		make_text_macro 'T', area, x-50, y
		make_text_macro 'I', area, x-40, y
		make_text_macro 'G', area, x-30, y
		make_text_macro 'A', area, x-20, y
		make_text_macro 'T', area, x-10, y
		make_text_macro 'O', area, x, y
		make_text_macro 'R', area, x+10, y
		make_text_macro 'U', area, x+20, y
		make_text_macro 'L', area, x+30, y
		make_text_macro ' ', area, x+40, y
		make_text_macro 'E', area, x+50, y
		make_text_macro 'S', area, x+60, y
		make_text_macro 'T', area, x+70, y
		make_text_macro 'E', area, x+80, y
		make_text_macro ' ', area, x+90, y
		make_text_macro 'X', area, x+100, y
		mov verifica, 15
		jmp final_verificare
		
castiga_o:
		make_text_macro 'C', area, x-80, y
		make_text_macro 'A', area, x-70, y
		make_text_macro 'S', area, x-60, y
		make_text_macro 'T', area, x-50, y
		make_text_macro 'I', area, x-40, y
		make_text_macro 'G', area, x-30, y
		make_text_macro 'A', area, x-20, y
		make_text_macro 'T', area, x-10, y
		make_text_macro 'O', area, x, y
		make_text_macro 'R', area, x+10, y
		make_text_macro 'U', area, x+20, y
		make_text_macro 'L', area, x+30, y
		make_text_macro ' ', area, x+40, y
		make_text_macro 'E', area, x+50, y
		make_text_macro 'S', area, x+60, y
		make_text_macro 'T', area, x+70, y
		make_text_macro 'E', area, x+80, y
		make_text_macro ' ', area, x+90, y
		make_text_macro 'O', area, x+100, y
		mov verifica, 15
final_verificare:
	popa
endm

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

fundal macro x,y,color
local bucla_linie
local bucla_coloana
	mov eax,y ;eax=y
	mov ebx, area_width
	mul ebx ; eax= y*area_width
	add eax,x ; eax=y*area_width +x
	shl eax,2 ;eax=(y*area_width +x)*4
	add eax, area
	mov ecx,area_height
bucla_coloana:
	push ecx
	mov ecx,area_width
bucla_linie:
	mov dword ptr[eax],color
	add eax,4
	loop bucla_linie
	pop ecx
	loop bucla_coloana
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:
buton1:
;detectare
	mov ebx,[ebp + arg2]
	cmp ebx,colt_stanga_X + 0 * linie_tabel
	jle buton2
	cmp ebx,colt_stanga_X + 1 * linie_tabel
	jge buton2
	mov ebx,[ebp + arg3]
	cmp ebx,colt_stanga_Y + 0 * linie_tabel
	jle buton2
	cmp ebx,colt_stanga_Y + 1 * linie_tabel
	jge buton2
;actiune
	verificare_matrice 0, 0
	verificare 175, 140, 0, 0
	jmp afisare_litere	

buton2:
;detectare
	mov ebx,[ebp + arg2]
	cmp ebx,colt_stanga_X + 1 * linie_tabel
	jle buton3
	cmp ebx,colt_stanga_X + 2 * linie_tabel
	jge buton3
	mov ebx,[ebp + arg3]
	cmp ebx,colt_stanga_Y + 0 * linie_tabel
	jle buton3
	cmp ebx,colt_stanga_Y + 1 * linie_tabel
	jge buton3
;actiune
	verificare_matrice 0, 1
	verificare 275, 140, 0, 1
	jmp afisare_litere	

buton3:
;detectare
	mov ebx,[ebp + arg2]
	cmp ebx,colt_stanga_X + 2 * linie_tabel
	jle buton4
	cmp ebx,colt_stanga_X + 3 * linie_tabel
	jge buton4
	mov ebx,[ebp + arg3]
	cmp ebx,colt_stanga_Y + 0 * linie_tabel
	jle buton4
	cmp ebx,colt_stanga_Y + 1 * linie_tabel
	jge buton4
;actiune
	verificare_matrice 0, 2
	verificare 375, 140, 0, 2
	jmp afisare_litere	

buton4:
;detectare
	mov ebx,[ebp + arg2]
	cmp ebx,colt_stanga_X + 0 * linie_tabel
	jle buton5
	cmp ebx,colt_stanga_X + 1 * linie_tabel
	jge buton5
	mov ebx,[ebp + arg3]
	cmp ebx,colt_stanga_Y + 1 * linie_tabel
	jle buton5
	cmp ebx,colt_stanga_Y + 2 * linie_tabel
	jge buton5
;actiune
	verificare_matrice 3, 0
	verificare 175, 240, 3, 0
	jmp afisare_litere	

buton5:
;detectare
	mov ebx,[ebp + arg2]
	cmp ebx,colt_stanga_X + 1 * linie_tabel
	jle buton6
	cmp ebx,colt_stanga_X + 2 * linie_tabel
	jge buton6
	mov ebx,[ebp + arg3]
	cmp ebx,colt_stanga_Y + 1 * linie_tabel
	jle buton6
	cmp ebx,colt_stanga_Y + 2 * linie_tabel
	jge buton6
;actiune
	verificare_matrice 3, 1
	verificare 275, 240, 3, 1
	jmp afisare_litere	
	
buton6:
;detectare
	mov ebx,[ebp + arg2]
	cmp ebx,colt_stanga_X + 2 * linie_tabel
	jle buton7
	cmp ebx,colt_stanga_X + 3 * linie_tabel
	jge buton7
	mov ebx,[ebp + arg3]
	cmp ebx,colt_stanga_Y + 1 * linie_tabel
	jle buton7
	cmp ebx,colt_stanga_Y + 2 * linie_tabel
	jge buton7
;actiune
	verificare_matrice 3, 2
	verificare 375, 240, 3, 2
	jmp afisare_litere		

buton7:
;detectare
	mov ebx,[ebp + arg2]
	cmp ebx,colt_stanga_X + 0 * linie_tabel
	jle buton8
	cmp ebx,colt_stanga_X + 1 * linie_tabel
	jge buton8
	mov ebx,[ebp + arg3]
	cmp ebx,colt_stanga_Y + 2 * linie_tabel
	jle buton8
	cmp ebx,colt_stanga_Y + 3 * linie_tabel
	jge buton8
;actiune
	verificare_matrice 6, 0
	verificare 175, 340, 6, 0
	jmp afisare_litere	

buton8:
;detectare
	mov ebx,[ebp + arg2]
	cmp ebx,colt_stanga_X + 1 * linie_tabel
	jle buton9
	cmp ebx,colt_stanga_X + 2 * linie_tabel
	jge buton9
	mov ebx,[ebp + arg3]
	cmp ebx,colt_stanga_Y + 2 * linie_tabel
	jle buton9
	cmp ebx,colt_stanga_Y + 3 * linie_tabel
	jge buton9
;actiune
	verificare_matrice 6, 1
	verificare 275, 340, 6, 1
	jmp afisare_litere	
	
buton9:
;detectare
	mov ebx,[ebp + arg2]
	cmp ebx,colt_stanga_X + 2 * linie_tabel
	jle afisare_litere
	cmp ebx,colt_stanga_X + 3 * linie_tabel
	jge afisare_litere
	mov ebx,[ebp + arg3]
	cmp ebx,colt_stanga_Y + 2 * linie_tabel
	jle afisare_litere
	cmp ebx,colt_stanga_Y + 3 * linie_tabel
	jge afisare_litere
;actiune
	verificare_matrice 6, 2
	verificare 375, 340, 6, 2
	jmp afisare_litere		
	
evt_timer:
	inc counter
	verificare_castigare 250, 435
sfarsit:
	
afisare_litere:
	;punem culoare
	cmp counter, 0
	jnz continuare_afisare
	fundal 0, 0, 0ccf2ffh
continuare_afisare: 

	;scriem un mesaj
	make_text_macro 'X', area, 215, 30
	make_text_macro ' ', area, 225, 30
	make_text_macro 'S', area, 235, 30
	make_text_macro 'I', area, 245, 30
	make_text_macro ' ', area, 255, 30
	make_text_macro 'O', area, 265, 30
	
	make_text_macro 'P', area, 285, 30
	make_text_macro 'R', area, 295, 30
	make_text_macro 'O', area, 305, 30
	make_text_macro 'I', area, 315, 30
	make_text_macro 'E', area, 325, 30
	make_text_macro 'C', area, 335, 30
	make_text_macro 'T', area, 345, 30

	linie_verticala colt_stanga_X, colt_stanga_Y, linie_tabel, 000000h
	linie_orizontala colt_stanga_X, colt_stanga_Y, linie_tabel, 000000h
	linie_orizontala colt_stanga_X, colt_stanga_Y+linie_tabel, linie_tabel, 000000h
	linie_verticala colt_stanga_X+linie_tabel, colt_stanga_Y, linie_tabel, 000000h
	linie_orizontala colt_stanga_X+linie_tabel, colt_stanga_Y, linie_tabel, 000000h
	linie_orizontala colt_stanga_X+2*linie_tabel, colt_stanga_Y, linie_tabel, 000000h
	linie_verticala colt_stanga_X, colt_stanga_Y+linie_tabel, linie_tabel, 000000h
	linie_verticala colt_stanga_X, colt_stanga_Y+2*linie_tabel, linie_tabel, 000000h
	linie_orizontala colt_stanga_X, colt_stanga_Y+2*linie_tabel, linie_tabel, 000000h
	linie_orizontala colt_stanga_X, colt_stanga_Y+3*linie_tabel, linie_tabel, 000000h
	linie_verticala colt_stanga_X+2*linie_tabel, colt_stanga_Y, linie_tabel, 000000h
	linie_verticala colt_stanga_X+3*linie_tabel, colt_stanga_Y, linie_tabel, 000000h
	linie_orizontala colt_stanga_X+linie_tabel, colt_stanga_Y+linie_tabel, linie_tabel, 000000h
	linie_orizontala colt_stanga_X+linie_tabel, colt_stanga_Y+2*linie_tabel, linie_tabel, 000000h
	linie_orizontala colt_stanga_X+linie_tabel, colt_stanga_Y+3*linie_tabel, linie_tabel, 000000h
	linie_orizontala colt_stanga_X+2*linie_tabel, colt_stanga_Y+linie_tabel, linie_tabel, 000000h
	linie_orizontala colt_stanga_X+2*linie_tabel, colt_stanga_Y+2*linie_tabel, linie_tabel, 000000h
	linie_orizontala colt_stanga_X+2*linie_tabel, colt_stanga_Y+3*linie_tabel, linie_tabel, 000000h
	linie_verticala colt_stanga_X+linie_tabel, colt_stanga_Y+linie_tabel, linie_tabel, 000000h
	linie_verticala colt_stanga_X+linie_tabel, colt_stanga_Y+2*linie_tabel, linie_tabel, 000000h
	linie_verticala colt_stanga_X+2*linie_tabel, colt_stanga_Y+linie_tabel, linie_tabel, 000000h
	linie_verticala colt_stanga_X+2*linie_tabel, colt_stanga_Y+2*linie_tabel, linie_tabel, 000000h
	linie_verticala colt_stanga_X+3*linie_tabel, colt_stanga_Y+linie_tabel, linie_tabel, 000000h
	linie_verticala colt_stanga_X+3*linie_tabel, colt_stanga_Y+2*linie_tabel, linie_tabel, 000000h
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start