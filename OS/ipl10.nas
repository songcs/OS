; haribote-ipl
; TAB=4

CYLS	EQU		10				; どこまで読み込むか

		ORG		0x7c00			; 指明程序的装?地址

; ?准FAT12格式??的?述

		JMP		entry
		DB		0x90
		DB		"HARIBOTE"		; ??区的名字可以是任意的字符串（8字?）
		DW		512				; ?个扇区(sector)的大小(必??512字?)
		DB		1				; 簇（cluster）的大小（必??1个扇区）
		DW		1				; FAT的起始位置（一般从第一个扇区?始）
		DB		2				; FAT的个数（必??2）
		DW		224				; 根目?的大小（一般??224?）
		DW		2880			; ?磁?的大小（必?是2880扇区）
		DB		0xf0			; 磁?的??（必?是0xf0）
		DW		9				; FAT的?度（必?是9扇区）
		DW		18				; 1个磁道(track)有几个扇区（必?是18）
		DW		2				; 磁?数（必?是2）
		DD		0				; 不使用分区，必?是0
		DD		2880			; 重写一次磁?大小
		DB		0,0,0x29		; 意?不明，固定
		DD		0xffffffff		; (可能是)卷?号?
		DB		"HARIBOTEOS "	; 磁?的名称（11字?）
		DB		"FAT12   "		; 磁?格式名称（8字?）
		RESB	18				; 先空出18字?

; 程序核心

entry:
		MOV		AX,0			; 初始化寄存器
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX

; ディスクを読む

		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; 柱面0
		MOV		DH,0			; 磁?0
		MOV		CL,2			; 扇区2
readloop:
		MOV		SI,0			; ??失?次数的寄存器
retry:
		MOV		AH,0x02			; AH=0x02:?入磁?
		MOV		AL,1			; 1个扇区
		MOV		BX,0
		MOV		DL,0x00			; A??器
		INT		0x13			; ?用磁?BIOS
		JNC		next			; 没出?就跳?到next
		ADD		SI,1			; 往SI加一
		CMP		SI,5			; 比?SI与5
		JAE		error			; SI>=5跳?到error
		MOV		AH,0x00
		MOV		DL,0x00			; A??器
		INT		0x13			; 重置??器
		JMP		retry
next:
		MOV		AX,ES			; 把内存地址后移0x200
		ADD		AX,0x0020
		MOV		ES,AX			; 因?没有ADD ES,0x0020指令
		ADD		CL,1			; 往CL加一
		CMP		CL,18			; 比?CL和18
		JBE		readloop		; 如果CL <= 18 跳?至readloop？？？
		MOV		CL,1
		ADD		DH,1
		CMP		DH,2
		JB		readloop		; 如果DH < 2,?跳?到readlloop
		MOV		DH,0
		ADD		CH,1
		CMP		CH,CYLS
		JB		readloop		; CH < CYLS ?跳?到readloop

; 読み終わったのでharibote.sysを実行だ！

		MOV		[0x0ff0],CH		; 将CYLS的?写到内存地址址0x0ff0中，?了告?haribote.sys磁?装?内容
		JMP		0xc200			; 跳?到haribote.sys 

error:
		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			; SIに1を足す
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			; ?示一个文字
		MOV		BX,15			; 指定字符?色
		INT		0x10			; ?用??BIOS
		JMP		putloop
fin:
		HLT						; ?cpu停止，等待指令
		JMP		fin				; 无限循?
msg:
		DB		0x0a, 0x0a		; ?行2次
		DB		"load error"
		DB		0x0a			; 改行
		DB		0

		RESB	0x7dfe-$		; 填写0x00,直到 0x7dfe

		DB		0x55, 0xaa
