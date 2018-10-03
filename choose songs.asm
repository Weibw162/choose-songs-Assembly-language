;利用汇编语言编写程序代码使8086PC机能够
;选奏《两只老虎》、《小星星》、《太湖船》
data segment
A	db 'Please select the track you want to play:$' 
B	db '1 Two tigers   2 Little stars   3 Taihu Lake  $'
C	db 'Input error! Please enter again$'
mus_freg1 dw 2 dup(262,294,330,262)
		 dw 2 dup(330,349,392)
		 dw 2 dup(392,440,392,349,330,262)
		 dw 2 dup(294,196,262),-1
mus_time1 dw 8 dup(25)
		 dw 2 dup(25),50
		 dw 2 dup(25),50
		 dw 5 dup(25),25,5 dup(25),25
		 dw 2 dup(25,25,50),10
mus_freg2 dw 196,147,196,147,294,147,294,147,330,196,330,196,294
      dw 262,196,262,196,247,196,247,196,220,147,220,147,196
      dw 294,147,294,147,262,196,262,196,247,196,247,196,220
      dw 294,147,294,147,262,196,262,196,247,196,247,196,220
      dw 196,147,196,147,294,147,294,147,330,196,330,196,294
      dw 262,196,262,196,247,196,247,196,220,147,220,147,196,-1
mus_time2 dw 12 dup(25),100
      dw 12 dup(25),100
      dw 12 dup(25),100
      dw 12 dup(25),100
      dw 12 dup(25),100
      dw 12 dup(25),100
mus_freg3  DW 330,294,262,294,3 DUP(330)
           DW 3 DUP(294),330,392,392
           DW 330,294,262,294,4 DUP(330)
           DW 294,294,330,294,262,-1
mus_time3  DW 6 DUP(25),50
           DW 2 DUP(25,25,50)
           DW 12 DUP(25),100
data ends
;数据段分别存放曲谱频率表和节拍时长表
code segment
assume cs:code,ds:data
;*****************************************
;music主调用程序
music proc far
start:
	call clean
    mov ax,data
    mov ds,ax
	lea	dx,A
	mov ah,9
	int 21h
	call huan 
	lea dx,B
	mov ah,9
	int 21h
	call huan
again:
	mov ah,01h
	int 21h
	call choose
soundf:
	call sound
    add si,2
    add bp,2
    jmp soundf
endf:
	jmp again
    mov ax,4c00h
    int 21h
error:
	call huan
	lea dx,C
	mov ah,9
	int 21h
	call huan
	jmp again
music endp
;******************************
;曲目选择子程序
choose proc near
	;mov al,30h
	cmp al,'1'
	je qu1
	cmp al,'2'
	je qu2
	cmp al,'3'
	je qu3
	cmp al,'1'
	jb error
	cmp al,'3'
	ja error
	ret
qu1:
	call q1
	jmp soundf
qu2:
	call q2
	jmp soundf
qu3:
	call q3
	jmp soundf
	ret
choose endp
;***********************************
;曲目子程序（提取各个曲目地址）
q1 proc near
	lea si,mus_freg1
    lea bp,ds:mus_time1
	ret
q1 endp
q2 proc near
	lea si,mus_freg2
    lea bp,ds:mus_time2
	ret
q2 endp
q3 proc near
	lea si,mus_freg3
    lea bp,ds:mus_time3
	ret
q3 endp
;*************************************
;发声子程序
sound proc near
    mov di,[si]
    cmp di,-1
    je  endf
    mov bx,ds:[bp]
    mov al,0b6h
    out 43h,al
    mov dx,12h
    mov ax,348ch
    div di
    out 42h,al
    mov al,ah
    out 42h,al
    in  al,61h
    mov ah,al
    or al,3
    out 61h,al
wait1:
    mov cx,330
    call waitf
long:
    loop long
    dec bx
    jnz wait1
    mov al,ah
    out 61h,al
	ret
sound endp
;************************************
;时间延迟子程序
waitf proc near
	push ax
waitf1:
	in al,61h
	and al,10h
	cmp al,ah
	je waitf1
	mov ah,al
	loop waitf1
	pop ax
	ret
waitf endp
;*******************************
;清屏子程序
clean proc near
	push ax
	push bx
	push cx
	push dx
	mov ah,6
	mov al,0
	mov bh,7
	mov ch,0
	mov cl,0
	mov dh,24
	mov dl,79
	int 10h
	mov dx,0
	mov ah,2
	int 10h
	pop dx
	pop cx
	pop bx
	pop ax
	ret
clean endp
;**************************
;换行子程序
huan proc near
	mov dl,0dh
	mov ah,02h
	int 21h
	mov dl,0ah
	mov ah,02h
	int 21h
	ret
huan endp
code ends
     end music