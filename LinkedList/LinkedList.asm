SSEG 	SEGMENT PARA STACK 'STACK'
	DW 32 DUP (?)
SSEG 	ENDS

DSEG				SEGMENT PARA 'DATA'
head				DW -1
dizi 				DW 100 DUP (?)
adresler			DW 100 DUP (?)
boyut				DW 100
CR					EQU 13
LF					EQU 10
OGRENCI				DB CR, LF,LF,'Engin Memis',LF, '19011040',LF,0
BOSLUK				DB '   ', 0
BOSDIZI				DB CR, LF,LF, '******Dizide Eleman Yok******', LF,LF, 0
ELEMANLAR			DB CR, LF,LF, '******Dizinin Elemanlari******', LF, 0
ENKUCUK				DB CR, LF,LF, '******En Kucuk Eleman Indisi******', LF, 0
ADRES				DB CR, LF,LF, '******Linkler******', LF, 0
SIRALI				DB CR, LF,LF, '******Dizinin Sirali Sekildeki Hali', LF, 0
HATA				DB CR, LF, 'Dikkat !!! Sayi vermediniz yeniden giris yapiniz.!!!  ', 0
MENU				DB LF,LF, '       MENU',LF, '1.Yeni Dizi Gir!', LF, '2.Diziyi Gorsellestir!',LF, '3.Yeni Eleman Ekle:',LF, '4.Cikis',LF, 0
nAl					DB 'Dizinin Boyutunu Giriniz:', 0
ElemanAl			DB 'Dizinin Elemanlarini Giriniz:',LF, 0
YeniEleman			DB 'Eklenilecek Yeni Elemani Giriniz:',LF, 0
n					DW (?)
secim				DW (?)

DSEG 	ENDS 

CSEG 				SEGMENT PARA 'CODE'
					ASSUME CS:CSEG, DS:DSEG, SS:SSEG
ANA 				PROC FAR

					PUSH DS
					XOR AX,AX
					PUSH AX
					MOV AX, DSEG 
					MOV DS, AX
					
					XOR SI, SI
dongu:				MOV AX, OFFSET OGRENCI
					CALL PUT_STR
					MOV AX, OFFSET MENU
					CALL PUT_STR
					CALL GETN
					MOV secim, AX								;MENÜDE GİRMEK İSTENİLEN SEÇENEĞİ secim DEĞİŞKENİNE ATIYORUM
					
					CMP secim, 1								;MENÜDE HANGİ SEÇENEĞE GİRMEK İSTEDİĞİMİZİ KARŞILAŞTIRIYORUM
					JE elemanGir
					CMP secim, 2
					JE yazdir
					CMP secim , 3
					JE yeniElemanGir
					CMP secim, 4
					JE bitis
					JMP dongu
					
yazdir:				MOV AX, OFFSET OGRENCI
					CALL PUT_STR
					CALL DIZIYAZ								;ELEMANLARIN BULUNDUĞU DİZİYİ YAZDIRAN FONKSİYONU ÇAĞIRIYORUM
					JMP dongu									;TEKRAR MENÜYE DÖNMEK İÇİN GERİ DÖNÜYORUZ

elemanGir:			MOV AX, OFFSET OGRENCI
					CALL PUT_STR
					CALL TEMIZLE								;TEKRAR TEKRAR YENİ DİZİ GİRMEK İÇİN İLK OLARAK DİZİYİ TEMİZLEYEN FONKSİYON ÇAĞRIYORUM
					CALL ELEMANEKLE								;DİZİYE ELEMAN EKLEYEN FONKSİYON ÇAĞIRIYORUM
					JMP dongu									;TEKRAR MENÜYE DÖNMEK İÇİN GERİ DÖNÜYORUZ
					
yeniElemanGir:		MOV AX, OFFSET OGRENCI
					CALL PUT_STR
					MOV AX, OFFSET YeniEleman					
					CALL PUT_STR
					CALL GETN									;YENİ EKLENİLCEK ELEMANI İNPUT OLARAK ALIYORUZ
					MOV dizi[SI], 0								;ELEMANI DİZİYE EKLİYORUM
					MOV adresler[SI], -1						;ADRESLER DİZİSİNDE ELEMANIN OLDUĞU İNDİSE -1 KOYUYORUM
					ADD n, 1									;DİZİDEKİ ELEMAN SAYISINI 1 ARTTIRIYORUM
					CALL LINK									;LİNKLEYİ YAPAN FONKSİYONU ÇAĞIRIYORUM
					ADD SI, 2									;İNDİSİ ARTTIRIYORUM
					JMP dongu									;TEKRAR MENÜYE DÖNMEK İÇİN GERİ DÖNÜYORUZ
					
bitis:				RETF 
ANA 				ENDP


ELEMANEKLE			PROC NEAR
					
					PUSH AX
					PUSH CX
					
yeniden:			MOV AX, OFFSET nAl
					CALL PUT_STR
					CALL GETN					;DİZİ GİRİLECEK OLDUĞUNDA DİZİNİN BOYUTUNU İNPUT OLARAK ALIYORUZ
					CMP AX, 1					;EĞER DİZİNİN BOYUTU 0 YA DA NEGATİF GİRİLİRSE TEKRAR GİRMESİNİ İSTİYORUZ
					JL yeniden
					MOV n, AX
					
					XOR SI, SI
					MOV CX,n
					MOV AX, OFFSET ElemanAl
					CALL PUT_STR
L1:					CALL GETN									;DÖNGÜ İLE ELEMANLARI TEK TEK ALIP LİNKLENMESİ İÇİN LINK FONKSİYONUNU ÇAĞIRIYORUM
					CALL LINK
					ADD SI, 2
					LOOP L1
						
					POP CX
					POP AX
					RET
ELEMANEKLE			ENDP



LINK				PROC NEAR
					
					PUSH DX
					PUSH SI
					PUSH AX
					PUSH BX
					PUSH DI
					PUSH CX
					
					;DİZİDE HİÇ ELEMAN YOK İSE
					
					CMP head, -1
					JNE ikinci
					MOV dizi[SI], AX
					MOV adresler[SI], -1
					MOV head, SI
					JMP son


					;GELEN ELEMAN EN BAŞTAKİ ELEMANDAN KÜÇÜK İSE 
					
ikinci:				MOV DI, head
					CMP AX, dizi[DI]
					JGE ucuncu
					MOV dizi[SI], AX
					MOV BX, head
					MOV adresler[SI], BX
					MOV head, SI
					JMP son
					
					;DİZİDE 1DEN FAZLA ELEMAN VARSA YERİNİ BULUP EKLENECEK
					
ucuncu:				MOV dizi[SI], AX
					MOV DI, head
bas:				CMP adresler[DI], -1
					JE bulundu
					MOV BX, adresler[DI]
					CMP AX, dizi[BX]
					JL bulundu
					MOV DI, adresler[DI]
					JMP bas
						
						
					;BULUNAN YERE YENİ ELEMANIN LİNKLENMESİ
					
bulundu:			MOV CX, adresler[DI]
					MOV adresler[SI], CX
					MOV adresler[DI], SI
					JMP son
				

son:				POP CX
					POP DI
					POP BX
					POP AX
					POP SI
					POP DX
					RET
LINK				ENDP


TEMIZLE				PROC NEAR							;YENİ DİZİ GİRİLMESİ İÇİN DİZİNİN TAMAMINI TEMİZLEYEN FONKSİYON
					
					PUSH CX
					PUSH SI
					
					MOV CX, boyut
					XOR SI, SI
					MOV head, -1
temizlenmedi:		MOV dizi[SI], 0
					CMP adresler[SI], -1
					JNE temizlendi
					ADD SI, 2
					LOOP temizlenmedi
					
temizlendi:			POP SI
					POP CX
					
					RET
TEMIZLE				ENDP

DIZIYAZ				PROC NEAR							;DİZİNİN GÖRSELLEŞTİRİLMESİNİ YAPAN FONKSİYON
					PUSH SI
					PUSH CX
					
					CMP head, -1
					JE	eleman_yok_dizi
					MOV AX, OFFSET ELEMANLAR
					CALL PUT_STR
					
					XOR SI,SI												;DİZİYİ YAZDIRAN KISIM
					MOV CX, n
dizi_devam:			MOV AX, dizi[SI]
					CALL PUTN
					MOV AX, OFFSET BOSLUK
					CALL PUT_STR
					ADD SI, 2
					LOOP dizi_devam
					
					XOR SI, SI												;ADRES DİZİSİNİ YAZDIRAN KISIM
					MOV CX, n
					MOV AX, OFFSET ADRES
					CALL PUT_STR
adres_devam:		MOV AX, adresler[SI]
					SAR AX, 1
					CALL PUTN
					MOV AX, OFFSET BOSLUK
					CALL PUT_STR
					ADD SI,2 
					LOOP adres_devam
					
					MOV AX, OFFSET ENKUCUK									;EN KUCUK ELEMANIN İNDİSİNİ YAZAN KISIM
					CALL PUT_STR
					MOV AX, head
					SAR AX, 1
					CALL PUTN
					
					CALL LINKLIYAZ											;ELEMANLARI KUCUKTEN BÜYÜĞE YAZDIRAN FONKSİYONUN ÇAĞRILMASI
					JMP dizi_son
					
eleman_yok_dizi:	MOV AX, OFFSET BOSDIZI
					CALL PUT_STR
					
dizi_son:			POP CX
					POP SI
					RET
DIZIYAZ				ENDP


LINKLIYAZ			PROC NEAR												;ELEMANLARI KÜÇÜKTEN BÜYÜĞE LİNKLERE GÖRE YAZDIRAN FONKSİYON
					
					PUSH SI
					PUSH DI
						
					CMP head, -1
					JE	eleman_yok
					MOV AX, OFFSET SIRALI
					CALL PUT_STR
					
					XOR SI,SI
					MOV SI, head
devam_dizi:			MOV AX, dizi[SI]
					CALL PUTN
					MOV AX, OFFSET BOSLUK
					CALL PUT_STR
					MOV SI, adresler[SI]
					CMP SI, -1
					JNE devam_dizi
					
					
					JMP yaz_son
					
eleman_yok:			MOV AX, OFFSET BOSDIZI
					CALL PUT_STR
					
yaz_son:			POP DI
					POP SI
					
					RET
LINKLIYAZ			ENDP


;GİTHUBTAN KOPYALADIĞIM EKRANA YAZDIRMA VE İNPUT ALMA KODLARI


GETC	PROC NEAR
        ;------------------------------------------------------------------------
        ; Klavyeden basılan karakteri AL yazmacına alır ve ekranda gösterir. 
        ; işlem sonucunda sadece AL etkilenir. 
        ;------------------------------------------------------------------------
        MOV AH, 1h
        INT 21H
        RET 
GETC	ENDP 

PUTC	PROC NEAR
        ;------------------------------------------------------------------------
        ; AL yazmacındaki değeri ekranda gösterir. DL ve AH değişiyor. AX ve DX 
        ; yazmaçlarının değerleri korumak için PUSH/POP yapılır. 
        ;------------------------------------------------------------------------
        PUSH AX
        PUSH DX
        MOV DL, AL
        MOV AH,2
        INT 21H
        POP DX
        POP AX
        RET 
PUTC 	ENDP 

GETN 	PROC NEAR
        ;------------------------------------------------------------------------
        ; Klavyeden basılan sayiyi okur, sonucu AX yazmacı üzerinden dondurur. 
        ; DX: sayının işaretli olup/olmadığını belirler. 1 (+), -1 (-) demek 
        ; BL: hane bilgisini tutar 
        ; CX: okunan sayının islenmesi sırasındaki ara değeri tutar. 
        ; AL: klavyeden okunan karakteri tutar (ASCII)
        ; AX zaten dönüş değeri olarak değişmek durumundadır. Ancak diğer 
        ; yazmaçların önceki değerleri korunmalıdır. 
        ;------------------------------------------------------------------------
        PUSH BX
        PUSH CX
        PUSH DX
GETN_START:
        MOV DX, 1	                        ; sayının şimdilik + olduğunu varsayalım 
        XOR BX, BX 	                        ; okuma yapmadı Hane 0 olur. 
        XOR CX,CX	                        ; ara toplam değeri de 0’dır. 
NEW:
        CALL GETC	                        ; klavyeden ilk değeri AL’ye oku. 
        CMP AL,CR 
        JE FIN_READ	                        ; Enter tuşuna basilmiş ise okuma biter
        CMP  AL, '-'	                        ; AL ,'-' mi geldi ? 
        JNE  CTRL_NUM	                        ; gelen 0-9 arasında bir sayı mı?
NEGATIVE:
        MOV DX, -1	                        ; - basıldı ise sayı negatif, DX=-1 olur
        JMP NEW		                        ; yeni haneyi al
CTRL_NUM:
        CMP AL, '0'	                        ; sayının 0-9 arasında olduğunu kontrol et.
        JB error 
        CMP AL, '9'
        JA error		                ; değil ise HATA mesajı verilecek
        SUB AL,'0'	                        ; rakam alındı, haneyi toplama dâhil et 
        MOV BL, AL	                        ; BL’ye okunan haneyi koy 
        MOV AX, 10 	                        ; Haneyi eklerken *10 yapılacak 
        PUSH DX		                        ; MUL komutu DX’i bozar işaret için saklanmalı
        MUL CX		                        ; DX:AX = AX * CX
        POP DX		                        ; işareti geri al 
        MOV CX, AX	                        ; CX deki ara değer *10 yapıldı 
        ADD CX, BX 	                        ; okunan haneyi ara değere ekle 
        JMP NEW 		                ; klavyeden yeni basılan değeri al 
ERROR:
        MOV AX, OFFSET HATA 
        CALL PUT_STR	                        ; HATA mesajını göster 
        JMP GETN_START                          ; o ana kadar okunanları unut yeniden sayı almaya başla 
FIN_READ:
        MOV AX, CX	                        ; sonuç AX üzerinden dönecek 
        CMP DX, 1	                        ; İşarete göre sayıyı ayarlamak lazım 
        JE FIN_GETN
        NEG AX		                        ; AX = -AX
FIN_GETN:
        POP DX
        POP CX
        POP DX
        RET 
GETN 	ENDP 

PUTN 	PROC NEAR
        ;------------------------------------------------------------------------
        ; AX de bulunan sayiyi onluk tabanda hane hane yazdırır. 
        ; CX: haneleri 10’a bölerek bulacağız, CX=10 olacak
        ; DX: 32 bölmede işleme dâhil olacak. Soncu etkilemesin diye 0 olmalı 
        ;------------------------------------------------------------------------
        PUSH CX
        PUSH DX 	
        XOR DX,	DX 	                        ; DX 32 bit bölmede soncu etkilemesin diye 0 olmalı 
        PUSH DX		                        ; haneleri ASCII karakter olarak yığında saklayacağız.
                                                ; Kaç haneyi alacağımızı bilmediğimiz için yığına 0 
                                                ; değeri koyup onu alana kadar devam edelim.
        MOV CX, 10	                        ; CX = 10
        CMP AX, 0
        JGE CALC_DIGITS	
        NEG AX 		                        ; sayı negatif ise AX pozitif yapılır. 
        PUSH AX		                        ; AX sakla 
        MOV AL, '-'	                        ; işareti ekrana yazdır. 
        CALL PUTC
        POP AX		                        ; AX’i geri al 
        
CALC_DIGITS:
        DIV CX  		                ; DX:AX = AX/CX  AX = bölüm DX = kalan 
        ADD DX, '0'	                        ; kalan değerini ASCII olarak bul 
        PUSH DX		                        ; yığına sakla 
        XOR DX,DX	                        ; DX = 0
        CMP AX, 0	                        ; bölen 0 kaldı ise sayının işlenmesi bitti demek
        JNE CALC_DIGITS	                        ; işlemi tekrarla 
        
DISP_LOOP:
                                                ; yazılacak tüm haneler yığında. En anlamlı hane üstte 
                                                ; en az anlamlı hane en alta ve onu altında da 
                                                ; sona vardığımızı anlamak için konan 0 değeri var. 
        POP AX		                        ; sırayla değerleri yığından alalım
        CMP AX, 0 	                        ; AX=0 olursa sona geldik demek 
        JE END_DISP_LOOP 
        CALL PUTC 	                        ; AL deki ASCII değeri yaz
        JMP DISP_LOOP                           ; işleme devam
        
END_DISP_LOOP:
        POP DX 
        POP CX
        RET
PUTN 	ENDP 

PUT_STR	PROC NEAR
        ;------------------------------------------------------------------------
        ; AX de adresi verilen sonunda 0 olan dizgeyi karakter karakter yazdırır.
        ; BX dizgeye indis olarak kullanılır. Önceki değeri saklanmalıdır. 
        ;------------------------------------------------------------------------
	PUSH BX 
        MOV BX,	AX			        ; Adresi BX’e al 
        MOV AL, BYTE PTR [BX]	                ; AL’de ilk karakter var 
PUT_LOOP:   
        CMP AL,0		
        JE  PUT_FIN 			        ; 0 geldi ise dizge sona erdi demek
        CALL PUTC 			        ; AL’deki karakteri ekrana yazar
        INC BX 				        ; bir sonraki karaktere geç
        MOV AL, BYTE PTR [BX]
        JMP PUT_LOOP			        ; yazdırmaya devam 
PUT_FIN:
	POP BX
	RET 
PUT_STR	ENDP

CSEG 	ENDS 
	END ANA