INCLUDE Irvine32.inc

;===============================================================================
; CONSTANTS AND CONFIGURATION
;===============================================================================
.stack 4096

.data

; Screen dimensions and Boundaries
SCREEN_WIDTH = 155
SCREEN_HEIGHT = 30
GROUND_LEVEL = 25

; --- FIX: Added Missing Boundary Constants ---
MIN_X = 0
MAX_X = 154         ; Slightly less than Width to prevent overflow
MIN_Y = 0
MAX_Y = 30
; ---------------------------------------------

timerTickCounter BYTE 0 

; Game states
STATE_TITLE = 0
STATE_MENU = 1
STATE_INSTRUCTIONS = 2
STATE_GAMEPLAY = 3
STATE_PAUSED = 4
STATE_LEVEL_COMPLETE = 5
STATE_GAME_OVER = 6

; Colors
COLOR_SKY = 1          
COLOR_GROUND = 2       
COLOR_MARIO = 14       
COLOR_ENEMY = 4        
COLOR_COIN = 14        
COLOR_HUD = 15         

;===============================================================================
; PHYSICS AND GAMEPLAY CONSTANTS
;===============================================================================
GRAVITY_STRENGTH = 1        
JUMP_POWER = -4             
MAX_FALL_SPEED = 4          
SPRING_JUMP_POWER = -7      
HORIZONTAL_SPEED = 2        
ENEMY_SPEED = 2             
DOUBLE_JUMP_ENABLED = 1     
SHELL_SPEED = 4             ; New constant for Shell Speed

;===============================================================================
; LEVEL 2 BLOCK DATA (Modified positions)
;===============================================================================
level2BlockX       SWORD 25, 55, 91, 25, 138
level2BlockY       SWORD 14, 12, 14, 16, 12
level2BlockWidth   BYTE  5,  8,  6,   7,  5
level2BlockContent BYTE  0,  1,  1,   0,  1

;===============================================================================
; POWER-UP DATA (UPDATED)
;===============================================================================
MAX_POWERUPS = 3                ; Increased from 2 to 3
powerupX      SWORD 40, 95, 0   ; Added 3rd slot (0 is placeholder)
powerupY      SWORD 10, 12, 0   ; Added 3rd slot
powerupOldX   SWORD 40, 95, 0   
powerupOldY   SWORD 10, 12, 0   
powerupType BYTE 1, 2, 3   ; 1=Spring, 2=Mushroom, 3=FireFlower, 4=Star
powerupActive BYTE  0,  0,  0   
powerupVelX   SWORD 1, -1,  1   

springBoostActive BYTE 0
springBoostTimer  WORD 0
originalJumpPower SWORD -4       

; NEW VARIABLES FOR BIG MARIO
marioIsBig        BYTE 0        ; 0 = Normal, 1 = Big
marioBigTimer     WORD 0        ; Counter for 10 seconds
marioRetainState  BYTE 0  


; MARIO POWER STATE SYSTEM
MARIO_SMALL = 0
MARIO_SUPER = 1
MARIO_FIRE = 2
MARIO_STAR = 3

marioPowerState BYTE 0        ; 0=Small, 1=Super, 2=Fire, 3=Star
marioStarTimer WORD 0         ; Timer for star invincibility (200 frames = 10 sec)
marioFlashCounter BYTE 0      ; For star flashing effect

; FIREBALL DATA
MAX_FIREBALLS = 2
fireballX SWORD 0, 0
fireballY SWORD 0, 0
fireballVelX SWORD 0, 0
fireballActive BYTE 0, 0


;===============================================================================
; LEVEL 2 SPECIFIC DATA
;===============================================================================
; Piranha Plant Data
MAX_PIRANHAS = 3
piranhaX SWORD 28, 85, 120        ; Match pipe positions
piranhaPipeIndex BYTE 0, 2, 3     ; Which pipe each piranha belongs to
piranhaY SWORD 23, 23, 23         ; Current Y position
piranhaState BYTE 0, 0, 0         ; 0 = Hidden, 1 = Rising, 2 = Visible, 3 = Lowering
piranhaTimer WORD 0, 0, 0         ; Timer for animation
piranhaActive BYTE 0, 0, 0        ; 0 in Level 1, 1 in Level 2

; Moving Platform Data
MAX_MOVING_PLATFORMS = 2
movingPlatX SWORD 40, 100
movingPlatY SWORD 18, 16
movingPlatWidth BYTE 6, 8
movingPlatVelX SWORD 1, -1
movingPlatMinX SWORD 30, 85
movingPlatMaxX SWORD 60, 120
movingPlatActive BYTE 0, 0        ; 0 in Level 1, 1 in Level 2

; Elevator Platform Data
MAX_ELEVATOR_PLATFORMS = 2
elevatorPlatX SWORD 70, 130
elevatorPlatY SWORD 15, 12
elevatorPlatWidth BYTE 6, 6
elevatorPlatVelY SWORD 1, -1
elevatorPlatMinY SWORD 10, 8
elevatorPlatMaxY SWORD 22, 20
elevatorPlatActive BYTE 0, 0      ; 0 in Level 1, 1 in Level 2

; Level 2 Pit Configuration
level2PitX SWORD 25, 95, 140
level2PitWidth BYTE 10, 8, 6


;===============================================================================
; GAME STATE VARIABLES
;===============================================================================

gameState BYTE STATE_TITLE

; HUD strings
strScore BYTE "MARIO: ",0
strCoins BYTE "COINS: ",0
strWorld BYTE "WORLD ",0
strLevel BYTE "-",0
strTime BYTE "TIME: ",0
strLives BYTE " x",0

; Title screen
titleLine1 BYTE "  ____  _   _ ____  _____ ____    __  __    _    ____ ___ ___  ",0
titleLine2 BYTE " / ___|| | | |  _ \| ____|  _ \  |  \/  |  / \  |  _ \_ _/ _ \ ",0
titleLine3 BYTE " \___ \| | | | |_) |  _| | |_) | | |\/| | / _ \ | |_) | | | | |",0
titleLine4 BYTE "  ___) | |_| |  __/| |___|  _ <  | |  | |/ ___ \|  _ <| | |_| |",0
titleLine5 BYTE " |____/ \___/|_|   |_____|_| \_\ |_|  |_/_/   \_\_| \_\___\___/ ",0
titleRollNo BYTE "                    Roll Number: 242216",0
titlePress BYTE "              Press ENTER to continue...",0

; Menu strings
menuTitle BYTE "            === MAIN MENU ===",0
strHighScore BYTE "High Score: ",0
menuOption1 BYTE "            1. Start Game",0
menuOption2 BYTE "            2. Instructions",0
menuOption3 BYTE "            3. Exit",0
menuPrompt BYTE "            Select option (1-3): ",0

; Instructions
instrTitle BYTE "            === GAME INSTRUCTIONS ===",0
instrLine1 BYTE "  Controls:",0
instrLine2 BYTE "    A / LEFT ARROW  - Move Left",0
instrLine3 BYTE "    D / RIGHT ARROW - Move Right",0
instrLine4 BYTE "    W / SPACE       - Jump",0
instrLine5 BYTE "    F               - Shoot Fireball (when powered up)",0
instrLine6 BYTE "    P               - Pause Game",0
instrLine8 BYTE "  Objective:",0
instrLine9 BYTE "    - Collect coins and defeat enemies",0
instrLine10 BYTE "    - Reach the flagpole to complete the level",0
instrLine11 BYTE "    - Rescue Princess Peach from Bowser!",0
instrBack BYTE "            Press any key to return to menu...",0

; Pause screen
pauseTitle BYTE "            === PAUSED ===",0
pauseOption1 BYTE "            1. Resume",0
pauseOption2 BYTE "            2. Exit to Menu",0

;===============================================================================
; PLAYER (MARIO) DATA
;===============================================================================
marioX SWORD 10
marioY SWORD GROUND_LEVEL - 2
marioOldX SWORD 10
marioOldY SWORD GROUND_LEVEL - 2
marioVelX SWORD 0
marioVelY SWORD 0
marioState BYTE 0          
marioLives BYTE 3
marioScore DWORD 0
marioCoins BYTE 0
marioJumpCount BYTE 0      
marioDirection BYTE 1      
marioInvincible WORD 0     
marioHasMoved BYTE 0       

currentWorld BYTE 1
currentLevel BYTE 1
gameTimer WORD 400         

;===============================================================================
; ENEMY DATA (Updated for Koopas)
;===============================================================================
MAX_ENEMIES = 5

; 0 = Goomba, 1 = Koopa Troopa
enemyType BYTE 0, 0, 0, 1, 1      

; 0 = Normal/Walking, 1 = Shell (Stationary)
enemyState BYTE 0, 0, 0, 0, 0     

; Positions (Added 2 Koopas at the end)
enemyX SWORD 50, 90, 130, 80, 120
enemyY SWORD 23, 23, 23, 23, 23   ; 23 is (GROUND_LEVEL - 2)
enemyOldX SWORD 50, 90, 130, 80, 120
enemyOldY SWORD 23, 23, 23, 23, 23

; Velocities
enemyVelX SWORD -2, 2, -2, -2, 2  

enemyActive BYTE 1, 1, 1, 1, 1
enemySquashed BYTE 0, 0, 0, 0, 0
squashTimer BYTE 0, 0, 0, 0, 0




;===============================================================================
; COIN DATA
;===============================================================================
MAX_COINS = 7
coinX SWORD 30, 70, 110, 46, 76, 130, 20, 100
coinY SWORD 15, 10, 12, 18, 8, 14, 16
coinActive BYTE 1, 1, 1, 1, 1, 1, 1

;===============================================================================
; CLOUD DATA
;===============================================================================
MAX_CLOUDS = 8
cloudX SWORD 15, 45, 75, 105, 135, 25, 85, 115
cloudY SWORD 4, 6, 5, 7, 4, 8, 9, 6

;===============================================================================
; PIT DATA
;===============================================================================
MAX_PITS = 3
pitX SWORD 35,75,100     
pitWidth BYTE 8,10,8     
pitActive BYTE 1, 1, 1     

;===============================================================================
; FLAGPOLE DATA
;===============================================================================
flagpoleX SWORD 145
flagpoleY SWORD 10
flagpoleHeight BYTE 15
flagpoleActive BYTE 1

; Level complete messages
msgLevelComplete BYTE "    === LEVEL COMPLETE! ===",0
msgWellDone BYTE "      Well Done!",0
msgFlagBonus BYTE "   Flag Bonus: ",0
msgTimeBonus BYTE "   Time Bonus: ",0
msgFireworks BYTE "   Fireworks! +",0
msgTotalScore BYTE "   Total Score: ",0
msgNextLevel BYTE "   Press ENTER to continue...",0
msgTopFlag BYTE " (Top of flagpole!)",0
msgMidFlag BYTE " (Middle)",0
msgBottomFlag BYTE " (Bottom)",0

flagBonusPoints DWORD 0
timeBonusPoints DWORD 0
fireworksBonus DWORD 0

;===============================================================================
; FILE HANDLING DATA
;===============================================================================
filenameHighScore BYTE "highscore.txt",0
filenameProgress BYTE "progress.txt",0
filenamePlayer BYTE "player.txt",0
fileHandle DWORD ?
playerName BYTE 50 DUP(?)
playerNamePrompt BYTE "Enter your name: ",0
highScoreName BYTE 50 DUP(?)
highScoreValue DWORD 0
fileBuffer BYTE 256 DUP(?)
bytesWritten DWORD ?

;===============================================================================
; PLATFORM/BLOCK DATA (UPDATED)
;===============================================================================
MAX_BLOCKS = 5
blockState BYTE MAX_BLOCKS DUP(0)

; UPDATED: Index 2 is now '1' (Power-up) instead of '0' (Coin)
; Previous: 0, 1, 0, 0, 1
; New:      0, 1, 1, 0, 1 
; Add breakable brick blocks (use value 2 for brick)
blockContent BYTE 1, 1, 1, 2, 1  ; 0=Coin, 1=Powerup, 2=Brick  

blockX       SWORD 25, 65, 105, 15, 135
blockY       SWORD 18, 15, 17, 20, 16
blockWidth   BYTE  5,  8,  6,   7,  5
blockActive  BYTE  1,  1,  1,   1,  1

;===============================================================================
; LEVEL DATA
;===============================================================================
ground_y = GROUND_LEVEL
ground_char BYTE '='

; ================= PIPE DATA =================
MAX_PIPES = 4
pipeX      SWORD 28, 60, 85, 120  
pipeHeight WORD  3,  4,6,7   
pipeWidth  BYTE  4,  4,  4,  4    

;===============================================================================
; TEMPORARY VARIABLES 
;===============================================================================
inputChar BYTE ?

;===============================================================================
; CODE SECTION
;===============================================================================
.code

; ... (Include File Handling and Sound Procedures as per original) ...
GetPlayerName PROC
	pushad
	mov eax, white + (black * 16)
	call SetTextColor
	mov dl, 30
	mov dh, 12
	call Gotoxy
	mov edx, OFFSET playerNamePrompt
	call WriteString
	mov edx, OFFSET playerName
	mov ecx, 49
	call ReadString
	call SavePlayerName
	popad
	ret
GetPlayerName ENDP

SavePlayerName PROC
	pushad
	mov edx, OFFSET filenamePlayer
	call CreateOutputFile
	mov fileHandle, eax
	cmp eax, INVALID_HANDLE_VALUE
	je SPN_error
	mov eax, fileHandle
	mov edx, OFFSET playerName
	mov ecx, 50
	call WriteToFile
	mov eax, fileHandle
	call CloseFile
SPN_error:
	popad
	ret
SavePlayerName ENDP

LoadPlayerName PROC
	pushad
	mov edx, OFFSET filenamePlayer
	call OpenInputFile
	mov fileHandle, eax
	cmp eax, INVALID_HANDLE_VALUE
	je LPN_error
	mov eax, fileHandle
	mov edx, OFFSET playerName
	mov ecx, 50
	call ReadFromFile
	mov eax, fileHandle
	call CloseFile
LPN_error:
	popad
	ret
LoadPlayerName ENDP

SaveHighScore PROC
	pushad
	mov eax, marioScore
	cmp eax, highScoreValue
	jle SHS_skip
	mov highScoreValue, eax
	push esi
	push edi
	mov esi, OFFSET playerName
	mov edi, OFFSET highScoreName
	mov ecx, 50
	rep movsb
	pop edi
	pop esi
	mov esi, OFFSET highScoreName
	mov edi, OFFSET fileBuffer
	mov ecx, 50
	rep movsb
	mov eax, highScoreValue
	mov edi, OFFSET fileBuffer
	add edi, 50
	call DWordToString
	mov edx, OFFSET filenameHighScore
	call CreateOutputFile
	mov fileHandle, eax
	cmp eax, INVALID_HANDLE_VALUE
	je SHS_skip
	mov eax, fileHandle
	mov edx, OFFSET fileBuffer
	mov ecx, 60
	call WriteToFile
	mov eax, fileHandle
	call CloseFile
SHS_skip:
	popad
	ret
SaveHighScore ENDP

LoadHighScore PROC
	pushad
	mov edx, OFFSET filenameHighScore
	call OpenInputFile
	mov fileHandle, eax
	cmp eax, INVALID_HANDLE_VALUE
	je LHS_error
	mov eax, fileHandle
	mov edx, OFFSET fileBuffer
	mov ecx, 60
	call ReadFromFile
	mov bytesWritten, eax
	mov esi, OFFSET fileBuffer
	mov edi, OFFSET highScoreName
	mov ecx, 50
	rep movsb
	mov esi, OFFSET fileBuffer
	add esi, 50
	call StringToDWord
	mov highScoreValue, eax
	mov eax, fileHandle
	call CloseFile
LHS_error:
	popad
	ret
LoadHighScore ENDP

SaveLevelProgress PROC
	pushad
	mov al, currentWorld
	mov fileBuffer[0], al
	mov al, currentLevel
	mov fileBuffer[1], al
	mov al, marioLives
	mov fileBuffer[2], al
	mov eax, marioScore
	mov edi, OFFSET fileBuffer
	add edi, 3
	call DWordToString
	mov edx, OFFSET filenameProgress
	call CreateOutputFile
	mov fileHandle, eax
	cmp eax, INVALID_HANDLE_VALUE
	je SLP_error
	mov eax, fileHandle
	mov edx, OFFSET fileBuffer
	mov ecx, 20
	call WriteToFile
	mov eax, fileHandle
	call CloseFile
SLP_error:
	popad
	ret
SaveLevelProgress ENDP

LoadLevelProgress PROC
	pushad
	mov edx, OFFSET filenameProgress
	call OpenInputFile
	mov fileHandle, eax
	cmp eax, INVALID_HANDLE_VALUE
	je LLP_error
	mov eax, fileHandle
	mov edx, OFFSET fileBuffer
	mov ecx, 20
	call ReadFromFile
	mov al, fileBuffer[0]
	mov currentWorld, al
	mov al, fileBuffer[1]
	mov currentLevel, al
	mov al, fileBuffer[2]
	mov marioLives, al
	mov esi, OFFSET fileBuffer
	add esi, 3
	call StringToDWord
	mov marioScore, eax
	mov eax, fileHandle
	call CloseFile
LLP_error:
	popad
	ret
LoadLevelProgress ENDP

DWordToString PROC
	pushad
	mov ebx, 10
	mov ecx, 0
DTS_loop:
	xor edx, edx
	div ebx
	add dl, '0'
	push edx
	inc ecx
	cmp eax, 0
	jne DTS_loop
DTS_pop:
	pop eax
	stosb
	loop DTS_pop
	mov al, 0
	stosb
	popad
	ret
DWordToString ENDP

StringToDWord PROC
	push ebx
	push ecx
	push edx
	xor eax, eax
	xor ebx, ebx
	mov ecx, 10
STD_loop:
	mov bl, BYTE PTR [esi]
	cmp bl, 0
	je STD_done
	cmp bl, '0'
	jl STD_done
	cmp bl, '9'
	jg STD_done
	sub bl, '0'
	mul ecx
	add eax, ebx
	inc esi
	jmp STD_loop
STD_done:
	pop edx
	pop ecx
	pop ebx
	ret
StringToDWord ENDP

MakeSound PROC
	ret
MakeSound ENDP
UpdateTimer PROC
    pushad
    inc timerTickCounter
    mov al, timerTickCounter
    cmp al, 20  
    jl UT_Exit  
    
    mov timerTickCounter, 0
    
    cmp gameTimer, 0
    je UT_TimesUp
    dec gameTimer
    
    ; Update Star Timer
    cmp marioPowerState, MARIO_STAR
    jne UT_DrawHUD
    cmp marioStarTimer, 0
    je UT_ResetStar
    dec marioStarTimer
    inc marioFlashCounter
    jmp UT_DrawHUD

UT_ResetStar:
    ; Star expired - REVERT to previous state stored in marioRetainState
    mov al, marioRetainState
    mov marioPowerState, al
    mov marioInvincible, 60     ; Give brief invincibility frame after star wears off
    jmp UT_DrawHUD

UT_DrawHUD:
    call DrawHUD 
    jmp UT_Exit

UT_TimesUp:
    cmp gameTimer, 0
    jne UT_Exit
    push eax
    mov ax, marioX
    mov dl, al
    mov ax, marioY
    mov dh, al
    call Gotoxy
    mov eax, black + (black * 16)
    call SetTextColor
    mov al, ' '
    call WriteChar
    pop eax
    dec marioLives
    mov marioX, 10 
    mov marioY, GROUND_LEVEL - 2
    mov marioOldX, 10
    mov marioOldY, GROUND_LEVEL - 2
    mov marioVelX, 0
    mov marioVelY, 0
    mov marioJumpCount, 0
    mov marioHasMoved, 1  
    mov gameTimer, 400 
    
    ; Reset States on Death
    mov marioPowerState, MARIO_SMALL
    mov marioRetainState, MARIO_SMALL
    
    cmp marioLives, 0
    jg UT_Exit
    mov gameState, STATE_GAME_OVER 

UT_Exit:
    popad
    ret
UpdateTimer ENDP




InitializeGame PROC
	call InitializeMario
	call InitializeLevel
	ret
InitializeGame ENDP
InitializeMario PROC
    mov marioX, 10
    mov marioY, GROUND_LEVEL - 2
    mov marioOldX, 10
    mov marioOldY, GROUND_LEVEL - 2
    mov marioVelX, 0
    mov marioVelY, 0
    mov marioJumpCount, 0
    mov marioLives, 3
    mov marioScore, 0
    mov marioCoins, 0
    mov marioInvincible, 0
    
    ; Reset Power States
    mov marioPowerState, MARIO_SMALL
    mov marioRetainState, MARIO_SMALL   ; <--- ADDED THIS
    mov marioStarTimer, 0
    mov marioFlashCounter, 0
    
    ; Reset Fireballs
    mov ecx, MAX_FIREBALLS
    mov esi, 0
IM_ResetFireballs:
    mov fireballActive[esi], 0
    inc esi
    loop IM_ResetFireballs
    
    ret
InitializeMario ENDP


InitializeLevel PROC
    pushad
    
    ; Check which level we're on
    mov al, currentLevel
    cmp al, 2
    je IL_Level2Setup
    
    ; ===================================================================
    ; LEVEL 1 SETUP
    ; ===================================================================
IL_Level1Setup:
    ; Reset positions for Level 1
    mov pipeX[0], 28       
    
    ; Reset Enemies
    mov ecx, MAX_ENEMIES
    mov esi, 0
IL_EnemyLoop:
    mov enemyActive[esi], 1
    mov enemyState[esi], 0
    inc esi
    loop IL_EnemyLoop

    mov enemyX[0], 50
    mov enemyX[2], 90
    mov enemyX[4], 130
    mov enemyX[6], 80
    mov enemyX[8], 120
    
    ; (Reset Y positions logic...)
    mov ecx, MAX_ENEMIES
    mov esi, 0
IL_ResetY:
    mov ebx, esi
    shl ebx, 1
    mov ax, GROUND_LEVEL
    sub ax, 2
    mov enemyY[ebx], ax
    mov enemyOldY[ebx], ax
    inc esi
    loop IL_ResetY

    mov enemyVelX[0], -2
    mov enemyVelX[2], 2
    mov enemyVelX[4], -2
    mov enemyVelX[6], -2
    mov enemyVelX[8], 2

    ; Level 1 Pits
    mov pitX[0], 35
    mov pitX[2], 75
    mov pitX[4], 100
    mov pitWidth[0], 8
    mov pitWidth[1], 10
    mov pitWidth[2], 8
    
    ; Level 1 Blocks
    mov ax, 25
    mov blockX[0], ax
    mov ax, 65
    mov blockX[2], ax
    mov ax, 105
    mov blockX[4], ax
    mov ax, 15
    mov blockX[6], ax
    mov ax, 135
    mov blockX[8], ax
    
    mov ax, 18
    mov blockY[0], ax
    mov ax, 15
    mov blockY[2], ax
    mov ax, 17
    mov blockY[4], ax
    mov ax, 20
    mov blockY[6], ax
    mov ax, 16
    mov blockY[8], ax
    
    ; Deactivate Level 2 features
    mov ecx, MAX_PIRANHAS
    mov esi, 0
IL_DeactivatePiranhas:
    mov piranhaActive[esi], 0
    inc esi
    loop IL_DeactivatePiranhas
    
    mov ecx, MAX_MOVING_PLATFORMS
    mov esi, 0
IL_DeactivateMoving:
    mov movingPlatActive[esi], 0
    inc esi
    loop IL_DeactivateMoving
    
    mov ecx, MAX_ELEVATOR_PLATFORMS
    mov esi, 0
IL_DeactivateElevator:
    mov elevatorPlatActive[esi], 0
    inc esi
    loop IL_DeactivateElevator
    
    jmp IL_CommonSetup

    ; ===================================================================
    ; LEVEL 2 SETUP
    ; ===================================================================
IL_Level2Setup:
    ; Move First Pipe to Left of Pit
    mov pipeX[0], 18       
    
    ; Reset Enemies
    mov ecx, MAX_ENEMIES
    mov esi, 0
IL_Enemy2Loop:
    mov enemyActive[esi], 1
    mov enemyState[esi], 0
    inc esi
    loop IL_Enemy2Loop

    mov enemyX[0], 45
    mov enemyX[2], 85
    mov enemyX[4], 125
    mov enemyX[6], 65
    mov enemyX[8], 115
    
    ; Reset Enemy Y
    mov ecx, MAX_ENEMIES
    mov esi, 0
IL_Reset2Y:
    mov ebx, esi
    shl ebx, 1
    mov ax, GROUND_LEVEL
    sub ax, 2
    mov enemyY[ebx], ax
    mov enemyOldY[ebx], ax
    inc esi
    loop IL_Reset2Y
    
    mov enemyVelX[0], -2
    mov enemyVelX[2], 2
    mov enemyVelX[4], -2
    mov enemyVelX[6], 2
    mov enemyVelX[8], -2

    ; Level 2 Pits
    mov ax, level2PitX[0]
    mov pitX[0], ax
    mov ax, level2PitX[2]
    mov pitX[2], ax
    mov ax, level2PitX[4]
    mov pitX[4], ax
    
    mov al, level2PitWidth[0]
    mov pitWidth[0], al
    mov al, level2PitWidth[1]
    mov pitWidth[1], al
    mov al, level2PitWidth[2]
    mov pitWidth[2], al
    
    ; Level 2 Blocks
    mov ax, level2BlockX[0]
    mov blockX[0], ax
    mov ax, level2BlockX[2]
    mov blockX[2], ax
    mov ax, level2BlockX[4]
    mov blockX[4], ax
    mov ax, level2BlockX[6]
    mov blockX[6], ax
    mov ax, level2BlockX[8]
    mov blockX[8], ax
    
    mov ax, level2BlockY[0]
    mov blockY[0], ax
    mov ax, level2BlockY[2]
    mov blockY[2], ax
    mov ax, level2BlockY[4]
    mov blockY[4], ax
    mov ax, level2BlockY[6]
    mov blockY[6], ax
    mov ax, level2BlockY[8]
    mov blockY[8], ax
    
    mov al, level2BlockWidth[0]
    mov blockWidth[0], al
    mov al, level2BlockWidth[1]
    mov blockWidth[1], al
    mov al, level2BlockWidth[2]
    mov blockWidth[2], al
    mov al, level2BlockWidth[3]
    mov blockWidth[3], al
    mov al, level2BlockWidth[4]
    mov blockWidth[4], al
    
    mov al, level2BlockContent[0]
    mov blockContent[0], al
    mov al, level2BlockContent[1]
    mov blockContent[1], al
    mov al, level2BlockContent[2]
    mov blockContent[2], al
    mov al, level2BlockContent[3]
    mov blockContent[3], al
    mov al, level2BlockContent[4]
    mov blockContent[4], al
    
    ; **ACTIVATE PIRANHA PLANTS (FIXED POSITIONING)**
    mov ecx, MAX_PIRANHAS
    mov esi, 0
IL_ActivatePiranhas:
    mov piranhaActive[esi], 1
    mov piranhaState[esi], 0
    mov piranhaTimer[esi], 0
    
    ; Get pipe index
    movzx ebx, piranhaPipeIndex[esi]
    shl ebx, 1
    
    ; FIX: Set Piranha X to Pipe X + 1 (Center in pipe)
    mov ax, pipeX[ebx]
    inc ax
    mov edi, esi
    shl edi, 1
    mov piranhaX[edi], ax
    
    ; Set Piranha Y (Pipe Height Logic)
    movzx ecx, pipeHeight[ebx]
    mov ax, GROUND_LEVEL
    sub ax, cx
    add ax, 2
    mov piranhaY[edi], ax
    
    inc esi
    cmp esi, MAX_PIRANHAS
    jl IL_ActivatePiranhas
    
    ; Activate Platforms
    mov ecx, MAX_MOVING_PLATFORMS
    mov esi, 0
IL_ActivateMoving:
    mov movingPlatActive[esi], 1
    inc esi
    loop IL_ActivateMoving
    
    mov ecx, MAX_ELEVATOR_PLATFORMS
    mov esi, 0
IL_ActivateElevator:
    mov elevatorPlatActive[esi], 1
    inc esi
    loop IL_ActivateElevator

IL_CommonSetup:
    ; Reset Coins
    mov ecx, MAX_COINS
    mov esi, 0
IL_CoinLoop:
    mov coinActive[esi], 1
    inc esi
    loop IL_CoinLoop
    
    ; Reset Blocks
    mov ecx, MAX_BLOCKS
    mov esi, 0
IL_BlockLoop:
    mov blockActive[esi], 1
    mov blockState[esi], 0
    inc esi
    loop IL_BlockLoop
    
    ; Reset Powerups
    mov ecx, MAX_POWERUPS
    mov esi, 0
IL_PowerupLoop:
    mov powerupActive[esi], 0
    inc esi
    loop IL_PowerupLoop
    
    mov springBoostActive, 0
    mov springBoostTimer, 0
    mov flagpoleActive, 1
    
    popad
    ret
InitializeLevel ENDP




; ... (Main, Title, Menu, Instructions, Pause, HUD procedures remain the same) ...
main PROC
	call Clrscr
	call Randomize
	call LoadHighScore
	call LoadPlayerName
	mainStateLoop:
		mov al, gameState
		cmp al, STATE_TITLE
		je doTitleScreen
		cmp al, STATE_MENU
		je doMainMenu
		cmp al, STATE_INSTRUCTIONS
		je doInstructions
		cmp al, STATE_GAMEPLAY
		je doGameplay
		cmp al, STATE_PAUSED
		je doPauseScreen
		cmp al, STATE_GAME_OVER
		je exitGame
		jmp mainStateLoop
	doTitleScreen:
		call ShowTitleScreen
		jmp mainStateLoop
	doMainMenu:
		call ShowMainMenu
		jmp mainStateLoop
	doInstructions:
		call ShowInstructionsScreen
		jmp mainStateLoop
	doGameplay:
		call GameLoop
		jmp mainStateLoop
	doPauseScreen:
		call ShowPauseScreen
		jmp mainStateLoop
	exitGame:
		call Clrscr
		exit
main ENDP

ShowTitleScreen PROC
	call Clrscr
	mov eax, COLOR_MARIO + (black * 16)
	call SetTextColor
	mov dl, 42
	mov dh, 6
	call Gotoxy
	mov edx, OFFSET titleLine1
	call WriteString
	mov dl, 42
	mov dh, 7
	call Gotoxy
	mov edx, OFFSET titleLine2
	call WriteString
	mov dl, 42
	mov dh, 8
	call Gotoxy
	mov edx, OFFSET titleLine3
	call WriteString
	mov dl, 42
	mov dh, 9
	call Gotoxy
	mov edx, OFFSET titleLine4
	call WriteString
	mov dl, 42
	mov dh, 10
	call Gotoxy
	mov edx, OFFSET titleLine5
	call WriteString
	mov eax, white + (black * 16)
	call SetTextColor
	mov dl, 40
	mov dh, 13
	call Gotoxy
	mov edx, OFFSET titleRollNo
	call WriteString
	mov dl, 45
	mov dh, 18
	call Gotoxy
	mov edx, OFFSET titlePress
	call WriteString
	call ReadChar
	mov gameState, STATE_MENU
	ret
ShowTitleScreen ENDP

ShowMainMenu PROC
	call Clrscr
	mov eax, red + (black * 16)
	call SetTextColor
	call Clrscr
	mov dl, 30
	mov dh, 8
	call Gotoxy
	mov edx, OFFSET menuTitle
	call WriteString
	mov eax, yellow + (black * 16)
	call SetTextColor
	mov dl, 30
	mov dh, 10
	call Gotoxy
	mov edx, OFFSET strHighScore
	call WriteString
	mov edx, OFFSET highScoreName
	call WriteString
	mov al, ' '
	call WriteChar
	mov al, '-'
	call WriteChar
	mov al, ' '
	call WriteChar
	mov eax, highScoreValue
	call WriteDec
	mov eax, red + (black * 16)
	call SetTextColor
	mov dl, 30
	mov dh, 13
	call Gotoxy
	mov edx, OFFSET menuOption1
	call WriteString
	mov dl, 30
	mov dh, 15
	call Gotoxy
	mov edx, OFFSET menuOption2
	call WriteString
	mov dl, 30
	mov dh, 17
	call Gotoxy
	mov edx, OFFSET menuOption3
	call WriteString
	mov dl, 30
	mov dh, 20
	call Gotoxy
	mov edx, OFFSET menuPrompt
	call WriteString
	call ReadChar
	mov inputChar, al
	cmp inputChar, '1'
	je startGame
	cmp inputChar, '2'
	je showInstr
	cmp inputChar, '3'
	je quitGame
	jmp ShowMainMenu
	startGame:
		call GetPlayerName
		call InitializeGame
		mov gameState, STATE_GAMEPLAY
		ret
	showInstr:
		mov gameState, STATE_INSTRUCTIONS
		ret
	quitGame:
		mov gameState, STATE_GAME_OVER
		ret
ShowMainMenu ENDP

UpdatePiranhaPlants PROC
    pushad
    
    mov ecx, 0
UPP_Loop:
    cmp ecx, MAX_PIRANHAS
    jge UPP_Done
    
    lea ebx, piranhaActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 0
    je UPP_Next
    
    ; Get pipe index
    lea edi, piranhaPipeIndex
    add edi, ecx
    movzx esi, BYTE PTR [edi]
    
    ; Calculate pipe top Y
    shl esi, 1
    movzx edx, pipeHeight[esi]
    mov ax, GROUND_LEVEL
    sub ax, dx
    mov dx, ax                    ; DX = pipe top Y
    
    ; Get current state
    mov ebx, ecx
    shl ebx, 1
    lea edi, piranhaState
    add edi, ecx
    mov al, BYTE PTR [edi]
    
    cmp al, 0
    je UPP_Hidden
    cmp al, 1
    je UPP_Rising
    cmp al, 2
    je UPP_Visible
    cmp al, 3
    je UPP_Lowering
    jmp UPP_Next

UPP_Hidden:
    ; Increment timer
    inc piranhaTimer[ebx]
    cmp piranhaTimer[ebx], 60     ; Wait 3 seconds
    jl UPP_Next
    mov piranhaTimer[ebx], 0
    mov BYTE PTR [edi], 1         ; Start rising
    jmp UPP_Next

UPP_Rising:
    ; Move up
    dec piranhaY[ebx]
    mov ax, piranhaY[ebx]
    sub ax, 4                     ; Rise 4 units above pipe
    cmp ax, dx
    jge UPP_Next
    mov BYTE PTR [edi], 2         ; Now visible
    mov piranhaTimer[ebx], 0
    jmp UPP_Next

UPP_Visible:
    ; Stay visible
    inc piranhaTimer[ebx]
    cmp piranhaTimer[ebx], 40     ; Stay for 2 seconds
    jl UPP_Next
    mov piranhaTimer[ebx], 0
    mov BYTE PTR [edi], 3         ; Start lowering
    jmp UPP_Next

UPP_Lowering:
    ; Move down
    inc piranhaY[ebx]
    mov ax, piranhaY[ebx]
    add ax, 2                     ; Back inside pipe
    cmp ax, dx
    jle UPP_Next
    mov BYTE PTR [edi], 0         ; Hidden again
    mov piranhaTimer[ebx], 0
    jmp UPP_Next

UPP_Next:
    inc ecx
    jmp UPP_Loop

UPP_Done:
    popad
    ret
UpdatePiranhaPlants ENDP
UpdateMovingPlatforms PROC
    pushad
    
    mov ecx, 0
UMP_Loop:
    cmp ecx, MAX_MOVING_PLATFORMS
    jge UMP_Done
    
    lea ebx, movingPlatActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 0
    je UMP_Next
    
    mov ebx, ecx
    shl ebx, 1
    
    ; Move platform
    mov ax, movingPlatX[ebx]
    add ax, movingPlatVelX[ebx]
    
    ; Check boundaries
    cmp ax, movingPlatMinX[ebx]
    jge UMP_CheckMax
    mov ax, movingPlatMinX[ebx]
    neg movingPlatVelX[ebx]
    jmp UMP_Update

UMP_CheckMax:
    cmp ax, movingPlatMaxX[ebx]
    jle UMP_Update
    mov ax, movingPlatMaxX[ebx]
    neg movingPlatVelX[ebx]

UMP_Update:
    mov movingPlatX[ebx], ax

UMP_Next:
    inc ecx
    jmp UMP_Loop

UMP_Done:
    popad
    ret
UpdateMovingPlatforms ENDP

UpdateElevatorPlatforms PROC
    pushad
    
    mov ecx, 0
UEP_Loop:
    cmp ecx, MAX_ELEVATOR_PLATFORMS
    jge UEP_Done
    
    lea ebx, elevatorPlatActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 0
    je UEP_Next
    
    mov ebx, ecx
    shl ebx, 1
    
    ; Move platform
    mov ax, elevatorPlatY[ebx]
    add ax, elevatorPlatVelY[ebx]
    
    ; Check boundaries
    cmp ax, elevatorPlatMinY[ebx]
    jge UEP_CheckMax
    mov ax, elevatorPlatMinY[ebx]
    neg elevatorPlatVelY[ebx]
    jmp UEP_Update

UEP_CheckMax:
    cmp ax, elevatorPlatMaxY[ebx]
    jle UEP_Update
    mov ax, elevatorPlatMaxY[ebx]
    neg elevatorPlatVelY[ebx]

UEP_Update:
    mov elevatorPlatY[ebx], ax

UEP_Next:
    inc ecx
    jmp UEP_Loop

UEP_Done:
    popad
    ret
UpdateElevatorPlatforms ENDP

DrawPiranhaPlants PROC
    pushad
    
    mov ecx, 0
DPP_Loop:
    cmp ecx, MAX_PIRANHAS
    jge DPP_Done
    
    lea ebx, piranhaActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 0
    je DPP_Next
    
    ; Check if visible
    lea edi, piranhaState
    add edi, ecx
    mov al, BYTE PTR [edi]
    cmp al, 0                     ; Hidden
    je DPP_Next
    
    ; Draw piranha
    mov eax, red + (black * 16)
    call SetTextColor
    
    mov ebx, ecx
    shl ebx, 1
    mov ax, piranhaX[ebx]
    mov dl, al
    mov ax, piranhaY[ebx]
    mov dh, al
    call Gotoxy
    
    mov al, 'P'
    call WriteChar

DPP_Next:
    inc ecx
    jmp DPP_Loop

DPP_Done:
    popad
    ret
DrawPiranhaPlants ENDP

ErasePiranhaPlants PROC
    pushad
    
    mov ecx, 0
EPP_Loop:
    cmp ecx, MAX_PIRANHAS
    jge EPP_Done
    
    lea ebx, piranhaActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 0
    je EPP_Next
    
    ; Check if was visible in previous frame
    lea edi, piranhaState
    add edi, ecx
    mov al, BYTE PTR [edi]
    cmp al, 0                     ; If hidden, no need to erase
    je EPP_Next
    
    ; Erase old position
    mov eax, black + (black * 16)
    call SetTextColor
    
    mov ebx, ecx
    shl ebx, 1
    
    ; Erase a 2-row area to cover movement
    mov ax, piranhaX[ebx]
    mov dl, al
    
    ; Erase above
    mov ax, piranhaY[ebx]
    dec ax
    mov dh, al
    call Gotoxy
    mov al, ' '
    call WriteChar
    
    ; Erase current
    inc dh
    call Gotoxy
    mov al, ' '
    call WriteChar
    
    ; Erase below
    inc dh
    call Gotoxy
    mov al, ' '
    call WriteChar

EPP_Next:
    inc ecx
    jmp EPP_Loop

EPP_Done:
    popad
    ret
ErasePiranhaPlants ENDP


DrawMovingPlatforms PROC
    pushad
    
    mov ecx, 0
DMP_Loop:
    cmp ecx, MAX_MOVING_PLATFORMS
    jge DMP_Done
    
    lea ebx, movingPlatActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 0
    je DMP_Next
    
    mov eax, cyan + (black * 16)
    call SetTextColor
    
    mov ebx, ecx
    shl ebx, 1
    mov ax, movingPlatX[ebx]
    mov dl, al
    mov ax, movingPlatY[ebx]
    mov dh, al
    call Gotoxy
    
    lea edi, movingPlatWidth
    add edi, ecx
    movzx esi, BYTE PTR [edi]

DMP_DrawWidth:
    cmp esi, 0
    jle DMP_Next
    mov al, '='
    call WriteChar
    dec esi
    jmp DMP_DrawWidth

DMP_Next:
    inc ecx
    jmp DMP_Loop

DMP_Done:
    popad
    ret
DrawMovingPlatforms ENDP

EraseMovingPlatforms PROC
    pushad
    
    mov ecx, 0
EMP_Loop:
    cmp ecx, MAX_MOVING_PLATFORMS
    jge EMP_Done
    
    lea ebx, movingPlatActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 0
    je EMP_Next
    
    ; Erase old position
    mov eax, black + (black * 16)
    call SetTextColor
    
    mov ebx, ecx
    shl ebx, 1
    
    ; Calculate old X position (current X - velocity)
    mov ax, movingPlatX[ebx]
    sub ax, movingPlatVelX[ebx]
    mov dl, al
    
    mov ax, movingPlatY[ebx]
    mov dh, al
    call Gotoxy
    
    lea edi, movingPlatWidth
    add edi, ecx
    movzx esi, BYTE PTR [edi]

EMP_EraseWidth:
    cmp esi, 0
    jle EMP_Next
    mov al, ' '
    call WriteChar
    dec esi
    jmp EMP_EraseWidth

EMP_Next:
    inc ecx
    jmp EMP_Loop

EMP_Done:
    popad
    ret
EraseMovingPlatforms ENDP



DrawElevatorPlatforms PROC
    pushad
    
    mov ecx, 0
DEP_Loop:
    cmp ecx, MAX_ELEVATOR_PLATFORMS
    jge DEP_Done
    
    lea ebx, elevatorPlatActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 0
    je DEP_Next
    
    mov eax, magenta + (black * 16)
    call SetTextColor
    
    mov ebx, ecx
    shl ebx, 1
    mov ax, elevatorPlatX[ebx]
    mov dl, al
    mov ax, elevatorPlatY[ebx]
    mov dh, al
    call Gotoxy
    
    lea edi, elevatorPlatWidth
    add edi, ecx
    movzx esi, BYTE PTR [edi]

DEP_DrawWidth:
    cmp esi, 0
    jle DEP_Next
    mov al, '='
    call WriteChar
    dec esi
    jmp DEP_DrawWidth

DEP_Next:
    inc ecx
    jmp DEP_Loop

DEP_Done:
    popad
    ret
DrawElevatorPlatforms ENDP


EraseElevatorPlatforms PROC
    pushad
    
    mov ecx, 0
EEP_Loop:
    cmp ecx, MAX_ELEVATOR_PLATFORMS
    jge EEP_Done
    
    lea ebx, elevatorPlatActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 0
    je EEP_Next
    
    ; Erase old position
    mov eax, black + (black * 16)
    call SetTextColor
    
    mov ebx, ecx
    shl ebx, 1
    
    mov ax, elevatorPlatX[ebx]
    mov dl, al
    
    ; Calculate old Y position (current Y - velocity)
    mov ax, elevatorPlatY[ebx]
    sub ax, elevatorPlatVelY[ebx]
    mov dh, al
    call Gotoxy
    
    lea edi, elevatorPlatWidth
    add edi, ecx
    movzx esi, BYTE PTR [edi]

EEP_EraseWidth:
    cmp esi, 0
    jle EEP_Next
    mov al, ' '
    call WriteChar
    dec esi
    jmp EEP_EraseWidth

EEP_Next:
    inc ecx
    jmp EEP_Loop

EEP_Done:
    popad
    ret
EraseElevatorPlatforms ENDP



ShowInstructionsScreen PROC
	call Clrscr
	mov eax, white + (black * 16)
	call SetTextColor
	mov dl, 25
	mov dh, 3
	call Gotoxy
	mov edx, OFFSET instrTitle
	call WriteString
	mov dl, 10
	mov dh, 6
	call Gotoxy
	mov edx, OFFSET instrLine1
	call WriteString
	mov dl, 10
	mov dh, 7
	call Gotoxy
	mov edx, OFFSET instrLine2
	call WriteString
	mov dl, 10
	mov dh, 8
	call Gotoxy
	mov edx, OFFSET instrLine3
	call WriteString
	mov dl, 10
	mov dh, 9
	call Gotoxy
	mov edx, OFFSET instrLine4
	call WriteString
	mov dl, 10
	mov dh, 10
	call Gotoxy
	mov edx, OFFSET instrLine5
	call WriteString
	mov dl, 10
	mov dh, 11
	call Gotoxy
	mov edx, OFFSET instrLine6
	call WriteString
	mov dl, 10
	mov dh, 14
	call Gotoxy
	mov edx, OFFSET instrLine8
	call WriteString
	mov dl, 10
	mov dh, 15
	call Gotoxy
	mov edx, OFFSET instrLine9
	call WriteString
	mov dl, 10
	mov dh, 16
	call Gotoxy
	mov edx, OFFSET instrLine10
	call WriteString
	mov dl, 10
	mov dh, 17
	call Gotoxy
	mov edx, OFFSET instrLine11
	call WriteString
	mov dl, 20
	mov dh, 22
	call Gotoxy
	mov edx, OFFSET instrBack
	call WriteString
	call ReadChar
	mov gameState, STATE_MENU
	ret
ShowInstructionsScreen ENDP

ShowPauseScreen PROC
	mov eax, black + (yellow * 16)
	call SetTextColor
	mov dl, 30
	mov dh, 10
	call Gotoxy
	mov edx, OFFSET pauseTitle
	call WriteString
	mov eax, white + (black * 16)
	call SetTextColor
	mov dl, 30
	mov dh, 13
	call Gotoxy
	mov edx, OFFSET pauseOption1
	call WriteString
	mov dl, 30
	mov dh, 15
	call Gotoxy
	mov edx, OFFSET pauseOption2
	call WriteString
	call ReadChar
	mov inputChar, al
	cmp inputChar, '1'
	je resumeGame
	cmp inputChar, '2'
	je exitToMenu
	jmp ShowPauseScreen
	resumeGame:
		mov gameState, STATE_GAMEPLAY
		ret
	exitToMenu:
		call InitializeGame
		mov gameState, STATE_MENU
		ret
ShowPauseScreen ENDP

DrawHUD PROC
	pushad
	mov eax, white + (black * 16)
	call SetTextColor
	mov dl, 2
	mov dh, 1
	call Gotoxy
	mov edx, OFFSET strScore
	call WriteString
	mov eax, marioScore
	call WriteDec
	mov dl, 25
	mov dh, 1
	call Gotoxy
	mov edx, OFFSET strCoins
	call WriteString
	movzx eax, marioCoins
	call WriteDec
	mov dl, 45
	mov dh, 1
	call Gotoxy
	mov edx, OFFSET strWorld
	call WriteString
	movzx eax, currentWorld
	call WriteDec
	mov edx, OFFSET strLevel
	call WriteString
	movzx eax, currentLevel
	call WriteDec
	mov dl, 65
	mov dh, 1
	call Gotoxy
	mov edx, OFFSET strTime
	call WriteString
	movzx eax, gameTimer
	call WriteDec
	mov dl, 85
	mov dh, 1
	call Gotoxy
	mov al, 'M'
	call WriteChar
	mov edx, OFFSET strLives
	call WriteString
	movzx eax, marioLives
	call WriteDec
		cmp springBoostActive, 1
	jne DH_noBoost
	mov eax, green + (black * 16)
	call SetTextColor
	mov dl, 105
	mov dh, 1
	call Gotoxy
	mov al, '['
	call WriteChar
	mov al, 'S'
	call WriteChar
	mov al, 'P'
	call WriteChar
	mov al, 'R'
	call WriteChar
	mov al, 'I'
	call WriteChar
	mov al, 'N'
	call WriteChar
	mov al, 'G'
	call WriteChar
	mov al, ']'
	call WriteChar
	jmp DH_done
DH_noBoost:
	mov eax, black + (black * 16)
	call SetTextColor
	mov dl, 105
	mov dh, 1
	call Gotoxy
	mov ecx, 8
DH_clearLoop:
	mov al, ' '
	call WriteChar
	loop DH_clearLoop
DH_done:
	popad
	ret
DrawHUD ENDP
HandleInput PROC
    mov marioVelX, 0
    mov marioHasMoved, 0  
    call ReadKey
    jz HI_noInput
    mov inputChar, al
    
    ; PAUSE
    cmp al, 'p'
    je HI_doPause
    cmp al, 'P'
    je HI_doPause
    
    ; FIREBALL CHECK
    cmp al, 'f'
    je HI_shootFireball
    cmp al, 'F'
    je HI_shootFireball
    
    ; JUMP
    cmp al, 'w'
    je HI_doJump
    cmp al, 'W'
    je HI_doJump
    cmp al, 32  
    je HI_doJump
    
    ; MOVE LEFT
    cmp al, 'a'
    je HI_moveLeft
    cmp al, 'A'
    je HI_moveLeft
    
    ; MOVE RIGHT
    cmp al, 'd'
    je HI_moveRight
    cmp al, 'D'
    je HI_moveRight
    jmp HI_noInput

HI_doPause:
    mov gameState, STATE_PAUSED
    jmp HI_exit

HI_shootFireball:
    ; Check logic: Must be Fire Mario (2) OR Star Mario (3) who was Fire (2)
    cmp marioPowerState, MARIO_FIRE
    je HI_canShoot
    
    cmp marioPowerState, MARIO_STAR
    jne HI_exit                 
    cmp marioRetainState, MARIO_FIRE
    jne HI_exit                 

HI_canShoot:
    ; Count active fireballs
    push ecx
    push esi
    mov ecx, 0
    mov esi, 0
    
HI_countActive:
    cmp esi, MAX_FIREBALLS
    jge HI_findEmpty
    cmp fireballActive[esi], 1
    jne HI_notActive
    inc ecx
HI_notActive:
    inc esi
    jmp HI_countActive
    
HI_findEmpty:
    ; Max 2 fireballs allowed
    cmp ecx, 2
    jge HI_noShoot
    
    ; Find first empty slot
    mov esi, 0
HI_findSlot:
    cmp esi, MAX_FIREBALLS
    jge HI_noShoot
    cmp fireballActive[esi], 0
    je HI_spawn
    inc esi
    jmp HI_findSlot
    
HI_spawn:
    ; Activate fireball
    mov fireballActive[esi], 1
    
    mov ebx, esi
    shl ebx, 1
    
    ; Position at Mario
    mov ax, marioX
    mov fireballX[ebx], ax
    mov ax, marioY
    mov fireballY[ebx], ax
    
    ; Direction based on Mario's facing
    cmp marioDirection, 1
    je HI_shootRight
    mov fireballVelX[ebx], -5
    jmp HI_shootDone
    
HI_shootRight:
    mov fireballVelX[ebx], 5
    
HI_shootDone:
    mov eax, 1200
    mov edx, 50
    call MakeSound
    
HI_noShoot:
    pop esi
    pop ecx
    jmp HI_exit

HI_doJump:
    mov al, DOUBLE_JUMP_ENABLED
    cmp al, 1
    jne HI_singleJump
    cmp marioJumpCount, 2
    jae HI_exit
    cmp springBoostActive, 1
    je HI_springDoubleJump
    mov ax, JUMP_POWER
    jmp HI_applyDoubleJump
HI_springDoubleJump:
    mov ax, SPRING_JUMP_POWER
HI_applyDoubleJump:
    mov marioVelY, ax
    inc marioJumpCount
    mov marioHasMoved, 1
    mov eax, 800        
    mov edx, 80         
    call MakeSound
    mov eax, 1000       
    mov edx, 80
    call MakeSound
    jmp HI_exit

HI_singleJump:
    cmp marioJumpCount, 0
    jne HI_exit
    cmp springBoostActive, 1
    je HI_springSingleJump
    mov ax, JUMP_POWER
    jmp HI_applySingleJump
HI_springSingleJump:
    mov ax, SPRING_JUMP_POWER
HI_applySingleJump:
    mov marioVelY, ax
    mov marioJumpCount, 1
    mov marioHasMoved, 1  
    mov eax, 800        
    mov edx, 80         
    call MakeSound
    mov eax, 1000       
    mov edx, 80
    call MakeSound
    jmp HI_exit

HI_moveLeft:
    mov ax, HORIZONTAL_SPEED
    neg ax
    mov marioVelX, ax
    mov marioDirection, 0
    mov marioHasMoved, 1  
    jmp HI_exit

HI_moveRight:
    mov ax, HORIZONTAL_SPEED
    mov marioVelX, ax
    mov marioDirection, 1
    mov marioHasMoved, 1  
    jmp HI_exit

HI_noInput:
HI_exit:
    ret
HandleInput ENDP
UpdatePhysics PROC
    ; ===================================================================
    ; SAVE OLD POSITION
    ; ===================================================================
    mov ax, marioX
    mov marioOldX, ax
    mov ax, marioY
    mov marioOldY, ax

    ; ===================================================================
    ; APPLY HORIZONTAL MOVEMENT
    ; ===================================================================
    mov ax, marioX
    add ax, marioVelX
    mov marioX, ax
    
    ; ===================================================================
    ; APPLY GRAVITY
    ; ===================================================================
    mov ax, marioVelY
    add ax, GRAVITY_STRENGTH
    cmp ax, MAX_FALL_SPEED
    jle UP_velocityOK
    mov ax, MAX_FALL_SPEED
UP_velocityOK:
    mov marioVelY, ax
    
    ; Apply vertical velocity
    mov ax, marioY
    add ax, marioVelY
    mov marioY, ax
    
    ; ===================================================================
    ; SCREEN BOUNDARIES CHECK
    ; ===================================================================
    cmp marioX, MIN_X
    jge UP_checkMaxX
    mov marioX, MIN_X
    
UP_checkMaxX:
    cmp marioX, MAX_X
    jle UP_checkMinY
    mov marioX, MAX_X
    
UP_checkMinY:
    cmp marioY, MIN_Y
    jge UP_PhysicsStart
    mov marioY, MIN_Y
    cmp marioVelY, 0
    jge UP_PhysicsStart
    mov marioVelY, 0

    ; ===================================================================
    ; HEAD COLLISION - Hitting blocks from below
    ; ===================================================================
UP_PhysicsStart:
    cmp marioVelY, 0
    jge UP_CheckPlatforms           ; Only check head collision when moving up

    mov ecx, 0
UP_HeadLoop:
    cmp ecx, MAX_BLOCKS
    jge UP_CheckPlatforms
    
    lea ebx, blockActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 1
    jne UP_NextHead
    
    mov ebx, ecx
    shl ebx, 1
    mov dx, blockX[ebx]             ; DX = block left X
    
    lea edi, blockWidth
    add edi, ecx
    movzx si, BYTE PTR [edi]
    add si, dx                      ; SI = block right X
    
    ; Check horizontal overlap
    mov ax, marioX
    cmp ax, dx
    jl UP_NextHead
    cmp ax, si
    jg UP_NextHead
    
    mov dx, blockY[ebx]
    inc dx                          ; DX = bottom of block + 1
    
    ; Check if Mario was below block before
    mov ax, marioOldY
    cmp ax, dx
    jle UP_NextHead
    
    ; Check if Mario is now at or above block bottom
    mov ax, marioY
    cmp ax, dx
    jg UP_NextHead
    
    ; === COLLISION DETECTED ===
    mov marioY, dx                  ; Push Mario down
    mov marioVelY, 0                ; Stop upward movement
    
    ; Check if block is empty (not yet hit)
    lea edi, blockState
    add edi, ecx
    cmp BYTE PTR [edi], 0
    jne UP_NextHead                 ; Already hit, skip spawning
    
    mov BYTE PTR [edi], 1           ; Mark block as hit
    
    ; ===================================================================
    ; BLOCK CONTENT HANDLING
    ; ===================================================================
UP_SpawnPowerup:
    ; Check block content type
    lea edi, blockContent
    add edi, ecx
    mov al, BYTE PTR [edi]
    
    cmp al, 2
    je UP_TryBreakBrick
    cmp al, 1
    je UP_SpawnPowerupItem
    
    ; Content type 0 = Coin
    inc marioCoins
    add marioScore, 200
    jmp UP_NextHead

UP_TryBreakBrick:
    ; Only Super/Fire/Star Mario can break bricks
    cmp marioPowerState, MARIO_SMALL
    je UP_JustBump
    
    ; Break the brick
    push ecx
    lea edi, blockActive
    add edi, ecx
    mov BYTE PTR [edi], 0
    pop ecx
    add marioScore, 50
    mov eax, 800
    mov edx, 50
    call MakeSound
    jmp UP_NextHead

UP_JustBump:
    mov eax, 400
    mov edx, 100
    call MakeSound
    jmp UP_NextHead

UP_SpawnPowerupItem:
    ; Find empty powerup slot
    push ecx            ; Save Block Index
    mov ecx, 0
    
UP_FindSlot:
    cmp ecx, MAX_POWERUPS
    jge UP_EndSpawn
    
    lea ebx, powerupActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 0
    je UP_DoSpawn
    inc ecx
    jmp UP_FindSlot
    
UP_DoSpawn:
    mov BYTE PTR [ebx], 1
    
    mov edx, [esp]      ; Retrieve Block Index (from UP_HeadLoop)
    
    lea edi, powerupType
    add edi, ecx
    
    ; ===================================================================
    ; ASSIGN SPECIFIC ITEMS TO SPECIFIC BLOCKS
    ; ===================================================================
    
    ; 1. Block Index 1 (X=65) -> SPRING
    cmp edx, 1          
    je UP_ForceSpring
    
    ; 2. Block Index 2 (X=105) -> FIRE FLOWER (The one after the Spring)
    cmp edx, 2
    je UP_ForceFireFlower
    
    ; 3. Block Index 4 (X=135) -> STAR
    cmp edx, 4
    je UP_ForceStar
    
    ; 4. All other blocks -> Standard Progression (Mushroom -> Flower)
    cmp marioPowerState, MARIO_SMALL
    je UP_SetMushroom
    jmp UP_SetFireFlower

UP_ForceSpring:
    mov BYTE PTR [edi], 1       ; Type 1 = Spring
    jmp UP_SetCoords
    
UP_ForceFireFlower:
    mov BYTE PTR [edi], 3       ; Type 3 = Fire Flower (Force spawn)
    jmp UP_SetCoords

UP_ForceStar:
    mov BYTE PTR [edi], 4       ; Type 4 = Star
    jmp UP_SetCoords

UP_SetMushroom:
    mov BYTE PTR [edi], 2       ; Type 2 = Mushroom
    jmp UP_SetCoords

UP_SetFireFlower:
    mov BYTE PTR [edi], 3       ; Type 3 = Fire Flower
    jmp UP_SetCoords
    
UP_SetCoords:
    ; Use Block Index (EDX) to set position
    shl edx, 1
    mov ebx, ecx
    shl ebx, 1
    
    mov ax, blockX[edx]
    mov powerupX[ebx], ax
    mov powerupOldX[ebx], ax
    
    mov ax, blockY[edx]
    sub ax, 2
    mov powerupY[ebx], ax
    mov powerupOldY[ebx], ax
    
    mov powerupVelX[ebx], 1
    add marioScore, 1000

UP_EndSpawn:
    pop ecx             ; Restore Block Index
    jmp UP_NextHead

UP_NextHead:
    inc ecx
    jmp UP_HeadLoop

    ; ===================================================================
    ; PLATFORM LANDING CHECKS (Standard Physics Logic)
    ; ===================================================================

UP_CheckPlatforms:
    cmp marioVelY, 0
    jl UP_CheckMovingPlatforms      ; Only check landing when falling

    mov ecx, 0
UP_LandLoop:
    cmp ecx, MAX_BLOCKS
    jge UP_CheckMovingPlatforms
    lea ebx, blockActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 1
    jne UP_NextLand
    mov ebx, ecx
    shl ebx, 1
    mov dx, blockX[ebx]             
    lea edi, blockWidth
    add edi, ecx
    movzx si, BYTE PTR [edi]
    add si, dx                      
    mov ax, marioX
    cmp ax, dx
    jl UP_NextLand
    cmp ax, si
    jg UP_NextLand
    mov dx, blockY[ebx]             
    mov ax, marioOldY
    cmp ax, dx
    jge UP_NextLand
    mov ax, marioY
    cmp ax, dx
    jl UP_NextLand
    dec dx
    mov marioY, dx                  
    mov marioVelY, 0                
    mov marioJumpCount, 0           
    jmp UP_CheckStandingOnMovingPlatform
UP_NextLand:
    inc ecx
    jmp UP_LandLoop

UP_CheckMovingPlatforms:
    mov al, currentLevel
    cmp al, 2
    jne UP_CheckElevatorPlatforms
    cmp marioVelY, 0
    jl UP_CheckElevatorPlatforms
    mov ecx, 0
UP_MovingLoop:
    cmp ecx, MAX_MOVING_PLATFORMS
    jge UP_CheckElevatorPlatforms
    lea ebx, movingPlatActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 0
    je UP_NextMoving
    mov ebx, ecx
    shl ebx, 1
    mov dx, movingPlatX[ebx]
    lea edi, movingPlatWidth
    add edi, ecx
    movzx si, BYTE PTR [edi]
    add si, dx
    mov ax, marioX
    cmp ax, dx
    jl UP_NextMoving
    cmp ax, si
    jg UP_NextMoving
    mov dx, movingPlatY[ebx]
    mov ax, marioOldY
    cmp ax, dx
    jge UP_NextMoving
    mov ax, marioY
    cmp ax, dx
    jl UP_NextMoving
    dec dx
    mov marioY, dx
    mov marioVelY, 0
    mov marioJumpCount, 0
    mov ax, movingPlatVelX[ebx]
    add marioX, ax
    cmp marioX, MIN_X
    jge UP_CheckMovingMaxX
    mov marioX, MIN_X
UP_CheckMovingMaxX:
    cmp marioX, MAX_X
    jle UP_CheckStandingOnMovingPlatform
    mov marioX, MAX_X
    jmp UP_CheckStandingOnMovingPlatform
UP_NextMoving:
    inc ecx
    jmp UP_MovingLoop

UP_CheckElevatorPlatforms:
    mov al, currentLevel
    cmp al, 2
    jne UP_CheckPipes
    cmp marioVelY, 0
    jl UP_CheckPipes
    mov ecx, 0
UP_ElevatorLoop:
    cmp ecx, MAX_ELEVATOR_PLATFORMS
    jge UP_CheckPipes
    lea ebx, elevatorPlatActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 0
    je UP_NextElevator
    mov ebx, ecx
    shl ebx, 1
    mov dx, elevatorPlatX[ebx]
    lea edi, elevatorPlatWidth
    add edi, ecx
    movzx si, BYTE PTR [edi]
    add si, dx
    mov ax, marioX
    cmp ax, dx
    jl UP_NextElevator
    cmp ax, si
    jg UP_NextElevator
    mov dx, elevatorPlatY[ebx]
    mov ax, marioOldY
    cmp ax, dx
    jge UP_NextElevator
    mov ax, marioY
    cmp ax, dx
    jl UP_NextElevator
    dec dx
    mov marioY, dx
    mov marioVelY, 0
    mov marioJumpCount, 0
    mov ax, elevatorPlatVelY[ebx]
    add marioY, ax
    cmp marioY, MIN_Y
    jge UP_CheckElevatorMaxY
    mov marioY, MIN_Y
UP_CheckElevatorMaxY:
    cmp marioY, MAX_Y
    jle UP_CheckStandingOnElevatorPlatform
    mov marioY, MAX_Y
    jmp UP_CheckStandingOnElevatorPlatform
UP_NextElevator:
    inc ecx
    jmp UP_ElevatorLoop

UP_CheckPipes:
    mov ecx, 0
UP_PipeLoop:
    cmp ecx, MAX_PIPES
    jge UP_CheckGround
    mov ebx, ecx
    shl ebx, 1
    mov ax, pipeX[ebx]
    dec ax
    mov dx, ax
    add dx, 6
    movzx edi, pipeHeight[ebx]
    mov si, GROUND_LEVEL
    sub si, di
    cmp marioVelY, 0
    jl UP_PipeSide
    mov ax, marioX
    mov di, pipeX[ebx]
    dec di
    cmp ax, di
    jl UP_PipeSide
    add di, 6
    cmp ax, di
    jg UP_PipeSide
    mov ax, marioOldY
    cmp ax, si
    jge UP_PipeSide
    mov ax, marioY
    cmp ax, si
    jl UP_PipeSide
    dec si
    mov marioY, si
    mov marioVelY, 0
    mov marioJumpCount, 0
    jmp UP_CheckStandingOnMovingPlatform
UP_PipeSide:
    mov ax, marioY
    cmp ax, si
    jl UP_NextPipe
    mov ax, pipeX[ebx]
    sub ax, 2
    cmp marioX, ax
    jne UP_CheckPipeRight
    cmp marioVelX, 0
    jle UP_CheckPipeRight
    mov marioX, ax
    jmp UP_NextPipe
UP_CheckPipeRight:
    mov ax, pipeX[ebx]
    add ax, 5
    cmp marioX, ax
    jne UP_NextPipe
    cmp marioVelX, 0
    jge UP_NextPipe
    mov marioX, ax
UP_NextPipe:
    inc ecx
    jmp UP_PipeLoop

UP_CheckGround:
    mov ax, marioX
    mov dl, al
    call CheckIfInPit
    cmp al, 1
    je UP_PitFall
    cmp marioY, GROUND_LEVEL - 2
    jl UP_CheckStandingOnMovingPlatform
    mov marioY, GROUND_LEVEL - 2
    mov marioVelY, 0
    mov marioJumpCount, 0
    jmp UP_CheckStandingOnMovingPlatform

UP_PitFall:
    cmp marioY, GROUND_LEVEL + 3
    jl UP_CheckStandingOnMovingPlatform
    dec marioLives
    mov marioIsBig, 0
    cmp marioLives, 0
    jle UP_GameOver
    mov marioX, 10
    mov marioY, GROUND_LEVEL - 2
    mov marioVelX, 0
    mov marioVelY, 0
    mov marioJumpCount, 0
    mov marioInvincible, 60
    jmp UP_CheckStandingOnMovingPlatform
UP_GameOver:
    mov gameState, STATE_GAME_OVER
    jmp UP_Done

UP_CheckStandingOnMovingPlatform:
    mov al, currentLevel
    cmp al, 2
    jne UP_CheckStandingOnElevatorPlatform
    cmp marioVelY, 0
    jl UP_CheckStandingOnElevatorPlatform
    mov ecx, 0
UP_StandingMovingLoop:
    cmp ecx, MAX_MOVING_PLATFORMS
    jge UP_CheckStandingOnElevatorPlatform
    lea ebx, movingPlatActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 0
    je UP_NextStandingMoving
    mov ebx, ecx
    shl ebx, 1
    mov dx, movingPlatX[ebx]
    lea edi, movingPlatWidth
    add edi, ecx
    movzx si, BYTE PTR [edi]
    add si, dx
    mov ax, marioX
    cmp ax, dx
    jl UP_NextStandingMoving
    cmp ax, si
    jg UP_NextStandingMoving
    mov dx, movingPlatY[ebx]
    dec dx
    mov ax, marioY
    sub ax, dx
    cmp ax, -2
    jl UP_NextStandingMoving
    cmp ax, 2
    jg UP_NextStandingMoving
    mov marioY, dx
    mov marioVelY, 0
    mov ax, movingPlatVelX[ebx]
    add marioX, ax
    cmp marioX, MIN_X
    jge UP_CheckStandingMovingMaxX
    mov marioX, MIN_X
    jmp UP_Done
UP_CheckStandingMovingMaxX:
    cmp marioX, MAX_X
    jle UP_Done
    mov marioX, MAX_X
    jmp UP_Done
UP_NextStandingMoving:
    inc ecx
    jmp UP_StandingMovingLoop

UP_CheckStandingOnElevatorPlatform:
    mov al, currentLevel
    cmp al, 2
    jne UP_Done
    cmp marioVelY, 0
    jl UP_Done
    mov ecx, 0
UP_StandingElevatorLoop:
    cmp ecx, MAX_ELEVATOR_PLATFORMS
    jge UP_Done
    lea ebx, elevatorPlatActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 0
    je UP_NextStandingElevator
    mov ebx, ecx
    shl ebx, 1
    mov dx, elevatorPlatX[ebx]
    lea edi, elevatorPlatWidth
    add edi, ecx
    movzx si, BYTE PTR [edi]
    add si, dx
    mov ax, marioX
    cmp ax, dx
    jl UP_NextStandingElevator
    cmp ax, si
    jg UP_NextStandingElevator
    mov dx, elevatorPlatY[ebx]
    dec dx
    mov ax, marioY
    sub ax, dx
    cmp ax, -2
    jl UP_NextStandingElevator
    cmp ax, 4
    jg UP_NextStandingElevator
    mov marioY, dx
    mov ax, elevatorPlatVelY[ebx]
    add marioY, ax
    mov marioVelY, 0
    cmp marioY, MIN_Y
    jge UP_CheckStandingElevatorMaxY
    mov marioY, MIN_Y
UP_CheckStandingElevatorMaxY:
    cmp marioY, MAX_Y
    jle UP_Done
    mov marioY, MAX_Y
    jmp UP_Done
UP_NextStandingElevator:
    inc ecx
    jmp UP_StandingElevatorLoop

UP_Done:
    mov ax, marioX
    cmp ax, marioOldX
    jne UP_Changed
    mov ax, marioY
    cmp ax, marioOldY
    jne UP_Changed
    jmp UP_Exit
UP_Changed:
    mov marioHasMoved, 1
UP_Exit:
    ret
UpdatePhysics ENDP

DrawMario PROC
    pushad
    
    ; Choose color based on power state
    cmp marioPowerState, MARIO_FIRE
    je DM_FireColor
    cmp marioPowerState, MARIO_STAR
    je DM_StarColor
    
    ; Default (Small/Super Mario)
    mov eax, blue + (black * 16)
    jmp DM_DrawChar
    
DM_FireColor:
    mov eax, white + (red * 16)
    jmp DM_DrawChar
    
DM_StarColor:
    ; Flash colors based on counter
    mov al, marioFlashCounter
    and al, 3
    cmp al, 0
    je DM_SC1
    cmp al, 1
    je DM_SC2
    cmp al, 2
    je DM_SC3
    mov eax, magenta + (black * 16)
    jmp DM_DrawChar
DM_SC1:
    mov eax, yellow + (black * 16)
    jmp DM_DrawChar
DM_SC2:
    mov eax, cyan + (black * 16)
    jmp DM_DrawChar
DM_SC3:
    mov eax, white + (black * 16)
    
DM_DrawChar:
    call SetTextColor
    
    ; Draw bottom part
    mov ax, marioX
    movzx edx, ax
    mov dl, dl
    mov ax, marioY
    mov dh, al
    call Gotoxy
    mov al, 'M'
    call WriteChar
    
    ; DECIDE IF WE DRAW TOP PART (Big Mario)
    
    ; 1. If currently Small, don't draw top
    cmp marioPowerState, MARIO_SMALL
    je DM_Done
    
    ; 2. If currently Star, check if underlying state is Small
    cmp marioPowerState, MARIO_STAR
    jne DM_DrawTop
    cmp marioRetainState, MARIO_SMALL
    je DM_Done  ; If originally small, stay small while invincible
    
DM_DrawTop:
    dec dh
    call Gotoxy
    mov al, 'M'
    call WriteChar
    
DM_Done:
    popad
    ret
DrawMario ENDP

EraseMario PROC
    pushad
    mov eax, black + (black * 16)
    call SetTextColor
    
    ; Erase Bottom Part
    mov ax, marioOldX
    movzx edx, ax
    mov dl, dl
    mov ax, marioOldY
    mov dh, al
    call Gotoxy
    mov al, ' '
    call WriteChar
    
    ; Erase Top Part (always erase 2 rows to handle size changes)
    dec dh
    call Gotoxy
    mov al, ' '
    call WriteChar
    
    dec dh
    call Gotoxy
    mov al, ' '
    call WriteChar
    
    popad
    ret
EraseMario ENDP
UpdateFireballs PROC
    pushad
    mov ecx, 0
UF_Loop:
    cmp ecx, MAX_FIREBALLS
    jge UF_Done
    
    lea ebx, fireballActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 0
    je UF_Next
    
    ; Update position
    mov ebx, ecx
    shl ebx, 1
    mov ax, fireballX[ebx]
    add ax, fireballVelX[ebx]
    
    ; Check bounds
    cmp ax, 5
    jl UF_Deactivate
    cmp ax, 150
    jg UF_Deactivate
    
    mov fireballX[ebx], ax
    jmp UF_Next
    
UF_Deactivate:
    push ecx
    lea ebx, fireballActive
    add ebx, ecx
    mov BYTE PTR [ebx], 0
    pop ecx
    
UF_Next:
    inc ecx
    jmp UF_Loop
UF_Done:
    popad
    ret
UpdateFireballs ENDP

DrawFireballs PROC
    pushad
    mov ecx, 0
DF_Loop:
    cmp ecx, MAX_FIREBALLS
    jge DF_Done
    
    lea ebx, fireballActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 0
    je DF_Next
    
    mov eax, red + (black * 16)
    call SetTextColor
    
    mov ebx, ecx
    shl ebx, 1
    mov ax, fireballX[ebx]
    mov dl, al
    mov ax, fireballY[ebx]
    mov dh, al
    call Gotoxy
    mov al, '*'
    call WriteChar
    
DF_Next:
    inc ecx
    jmp DF_Loop
DF_Done:
    popad
    ret
DrawFireballs ENDP

EraseFireballs PROC
    pushad
    mov ecx, 0
EF_Loop:
    cmp ecx, MAX_FIREBALLS
    jge EF_Done
    
    lea ebx, fireballActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 0
    je EF_Next
    
    mov eax, black + (black * 16)
    call SetTextColor
    
    mov ebx, ecx
    shl ebx, 1
    mov ax, fireballX[ebx]
    sub ax, fireballVelX[ebx]
    mov dl, al
    mov ax, fireballY[ebx]
    mov dh, al
    call Gotoxy
    mov al, ' '
    call WriteChar
    
EF_Next:
    inc ecx
    jmp EF_Loop
EF_Done:
    popad
    ret
EraseFireballs ENDP

CheckFireballCollisions PROC
    pushad
    mov esi, 0
CFC_FireballLoop:
    cmp esi, MAX_FIREBALLS
    jge CFC_Done
    
    lea ebx, fireballActive
    add ebx, esi
    cmp BYTE PTR [ebx], 0
    je CFC_NextFireball
    
    mov edi, 0
CFC_EnemyLoop:
    cmp edi, MAX_ENEMIES
    jge CFC_NextFireball
    
    lea ebx, enemyActive
    add ebx, edi
    cmp BYTE PTR [ebx], 0
    je CFC_NextEnemy
    
    mov ebx, esi
    shl ebx, 1
    movsx eax, fireballX[ebx]
    movsx edx, fireballY[ebx]
    
    mov ebx, edi
    shl ebx, 1
    movsx ecx, enemyX[ebx]
    movsx ebx, enemyY[ebx]
    
    sub eax, ecx
    cmp eax, 0
    jge CFC_AbsX
    neg eax
CFC_AbsX:
    cmp eax, 2
    jg CFC_NextEnemy
    
    sub edx, ebx
    cmp edx, 0
    jge CFC_AbsY
    neg edx
CFC_AbsY:
    cmp edx, 2
    jg CFC_NextEnemy
    
    push esi
    push edi
    
    lea ebx, enemyActive
    add ebx, edi
    mov BYTE PTR [ebx], 0
    
    lea ebx, fireballActive
    add ebx, esi
    mov BYTE PTR [ebx], 0
    
    add marioScore, 100
    
    mov eax, 1000
    mov edx, 50
    call MakeSound
    
    pop edi
    pop esi
    jmp CFC_NextFireball
    
CFC_NextEnemy:
    inc edi
    jmp CFC_EnemyLoop
    
CFC_NextFireball:
    inc esi
    jmp CFC_FireballLoop
    
CFC_Done:
    popad
    ret
CheckFireballCollisions ENDP


DrawEnemy PROC
	pushad
	mov ecx, 0
DE_loop:
	cmp ecx, MAX_ENEMIES
	jge DE_done
	lea ebx, enemyActive
	add bl, cl
	cmp BYTE PTR [ebx], 1
	jne DE_next

	; Move Cursor to Enemy Position
	mov ebx, ecx
	shl ebx, 1
	mov ax, enemyX[ebx]
	mov dl, al
	mov ax, enemyY[ebx]
	mov dh, al
	call Gotoxy

	; Check Enemy Type
	lea edi, enemyType
	add edi, ecx
	cmp BYTE PTR [edi], 1   ; 1 = Koopa
	je DE_DrawKoopa

	; -- Draw Goomba --
	mov eax, brown + (black * 16)
	call SetTextColor
	mov al, 'G'
	call WriteChar
	jmp DE_next

DE_DrawKoopa:
	; Check State (Walking or Shell)
	lea edi, enemyState
	add edi, ecx
	cmp BYTE PTR [edi], 1   ; 1 = Shell
	je DE_DrawShell

	; -- Draw Walking Koopa --
	mov eax, lightGreen + (black * 16)
	call SetTextColor
	mov al, 'K'
	call WriteChar
	jmp DE_next

DE_DrawShell:
	; -- Draw Static Shell --
	mov eax, green + (black * 16)
	call SetTextColor
	mov al, 'O'
	call WriteChar

DE_next:
	inc ecx
	jmp DE_loop
DE_done:
	popad
	ret
DrawEnemy ENDP

EraseEnemies PROC
	pushad
	mov ecx, 0
EE_loop:
	cmp ecx, MAX_ENEMIES
	jge EE_done
	lea ebx, enemyActive
	add bl, cl
	cmp BYTE PTR [ebx], 1
	jne EE_next
	mov ebx, ecx
	shl ebx, 1
	mov ax, enemyOldX[ebx]
	mov dl, al
	mov ax, enemyOldY[ebx]
	mov dh, al
	call Gotoxy
	mov al, ' '
	call WriteChar
EE_next:
	inc ecx
	jmp EE_loop
EE_done:
	popad
	ret
EraseEnemies ENDP

UpdateEnemies PROC
	pushad
	mov ecx, 0
UE_loop:
	cmp ecx, MAX_ENEMIES
	jge UE_done
	lea ebx, enemyActive
	add bl, cl
	cmp BYTE PTR [ebx], 1
	jne UE_next
	mov ebx, ecx
	shl ebx, 1
	mov ax, enemyX[ebx]
	mov enemyOldX[ebx], ax
	mov ax, enemyY[ebx]
	mov enemyOldY[ebx], ax
	mov ax, enemyX[ebx]
	mov dx, enemyVelX[ebx]
	add ax, dx
	cmp ax, 5
	jg UE_checkMax
	mov ax, 5
	neg WORD PTR enemyVelX[ebx]
UE_checkMax:
	cmp ax, 145
	jl UE_updatePos
	mov ax, 145
	neg WORD PTR enemyVelX[ebx]
UE_updatePos:
	mov enemyX[ebx], ax
UE_next:
	inc ecx
	jmp UE_loop
UE_done:
	popad
	ret
UpdateEnemies ENDP

UpdatePowerups PROC
	pushad
	cmp springBoostActive, 1
	jne UP_updatePositions
	dec springBoostTimer
	cmp springBoostTimer, 0
	jg UP_updatePositions
	mov springBoostActive, 0
UP_updatePositions:
	mov ecx, 0
UP_loop:
	cmp ecx, MAX_POWERUPS
	jge UP_done
	lea ebx, powerupActive
	add bl, cl
	cmp BYTE PTR [ebx], 1
	jne UP_next
	mov ebx, ecx
	shl ebx, 1
	mov ax, powerupX[ebx]
	mov dx, powerupVelX[ebx]
	add ax, dx
	cmp ax, 5
	jg UP_checkMax
	mov ax, 5
	neg WORD PTR powerupVelX[ebx]
UP_checkMax:
	cmp ax, 145
	jl UP_updatePos
	mov ax, 145
	neg WORD PTR powerupVelX[ebx]
UP_updatePos:
	mov powerupX[ebx], ax
UP_next:
	inc ecx
	jmp UP_loop
UP_done:
	popad
	ret
UpdatePowerups ENDP

SpawnEnemies PROC
	ret
SpawnEnemies ENDP

DrawCoins PROC
	pushad
	mov ecx, 0
DC_loop:
	cmp ecx, MAX_COINS
	jge DC_done
	lea ebx, coinActive
	add bl, cl
	cmp BYTE PTR [ebx], 1
	jne DC_next
	mov eax, yellow
	call SetTextColor
	mov ebx, ecx
	shl ebx, 1
	mov ax, coinX[ebx]
	mov dl, al
	mov ax, coinY[ebx]
	mov dh, al
	call Gotoxy
	mov al, '$'
	call WriteChar
DC_next:
	inc ecx
	jmp DC_loop
DC_done:
	popad
	ret
DrawCoins ENDP
DrawPowerups PROC
    pushad
    mov ecx, 0
DP_loop:
    cmp ecx, MAX_POWERUPS
    jge DP_done
    
    lea ebx, powerupActive
    add bl, cl
    cmp BYTE PTR [ebx], 1
    jne DP_next
    
    lea ebx, powerupType
    add bl, cl
    mov al, BYTE PTR [ebx]
    
    cmp al, 1
    je DP_drawSpring
    cmp al, 2
    je DP_drawMushroom
    cmp al, 3
    je DP_drawFire
    cmp al, 4
    je DP_drawStar
    jmp DP_next

DP_drawMushroom:
    ; Draw Mushroom (Red 'M')
    push ecx
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov ebx, ecx
    shl ebx, 1
    movsx eax, powerupX[ebx]    
    mov dl, al
    movsx eax, powerupY[ebx]    
    mov dh, al
    call Gotoxy
    mov al, 'M'
    call WriteChar
    pop ecx
    jmp DP_next

DP_drawFire:
    ; Draw Fire Flower (Orange 'F')
    push ecx
    mov eax, lightRed + (yellow * 16)
    call SetTextColor
    mov ebx, ecx
    shl ebx, 1
    movsx eax, powerupX[ebx]    
    mov dl, al
    movsx eax, powerupY[ebx]    
    mov dh, al
    call Gotoxy
    mov al, 'F'
    call WriteChar
    pop ecx
    jmp DP_next

DP_drawStar:
    ; Draw Star (Yellow '*')
    push ecx
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov ebx, ecx
    shl ebx, 1
    movsx eax, powerupX[ebx]    
    mov dl, al
    movsx eax, powerupY[ebx]    
    mov dh, al
    call Gotoxy
    mov al, '*'
    call WriteChar
    pop ecx
    jmp DP_next

DP_drawSpring:
    ; Draw Spring (Green 'S')
    push ecx
    mov eax, green + (black * 16)
    call SetTextColor
    mov ebx, ecx
    shl ebx, 1
    movsx eax, powerupX[ebx]    
    mov dl, al
    movsx eax, powerupY[ebx]    
    mov dh, al
    call Gotoxy
    mov al, 'S'
    call WriteChar
    inc dh
    call Gotoxy
    mov al, '|'
    call WriteChar
    pop ecx

DP_next:
    inc ecx
    jmp DP_loop
DP_done:
    popad
    ret
DrawPowerups ENDP


ErasePowerups PROC
	pushad
	mov ecx, 0
EP_loop:
	cmp ecx, MAX_POWERUPS
	jge EP_done
	lea ebx, powerupActive
	add bl, cl
	cmp BYTE PTR [ebx], 1
	jne EP_next
	push ecx
	mov eax, black + (black * 16)
	call SetTextColor
	mov ebx, ecx
	shl ebx, 1
	movsx eax, powerupX[ebx]
	mov dl, al
	movsx eax, powerupY[ebx]
	mov dh, al
	call Gotoxy
	mov al, ' '
	call WriteChar
	inc dh
	call Gotoxy
	mov al, ' '
	call WriteChar
	pop ecx
EP_next:
	inc ecx
	jmp EP_loop
EP_done:
	popad
	ret
ErasePowerups ENDP

DrawClouds PROC
	pushad
	mov eax, white + (black * 16)
	call SetTextColor
	mov ecx, 0
DCL_loop:
	cmp ecx, MAX_CLOUDS
	jge DCL_done
	mov ebx, ecx
	shl ebx, 1
	mov ax, cloudX[ebx]
	mov dl, al
	mov ax, cloudY[ebx]
	mov dh, al
	call Gotoxy
	mov al, ' '
	call WriteChar
	inc dl
	call Gotoxy
	mov al, 'o'
	call WriteChar
	inc dl
	call Gotoxy
	mov al, 'O'
	call WriteChar
	inc dl
	call Gotoxy
	mov al, 'o'
	call WriteChar
	inc dl
	call Gotoxy
	mov al, ' '
	call WriteChar
	mov ebx, ecx
	shl ebx, 1
	mov ax, cloudX[ebx]
	mov dl, al
	mov ax, cloudY[ebx]
	inc al  
	mov dh, al
	call Gotoxy
	mov al, 'o'
	call WriteChar
	inc dl
	call Gotoxy
	mov al, 'O'
	call WriteChar
	inc dl
	call Gotoxy
	mov al, 'O'
	call WriteChar
	inc dl
	call Gotoxy
	mov al, 'O'
	call WriteChar
	inc dl
	call Gotoxy
	mov al, 'o'
	call WriteChar
DCL_next:
	inc ecx
	jmp DCL_loop
DCL_done:
	popad
	ret
DrawClouds ENDP

DrawPipes PROC
    pushad
    mov eax, lightGreen + (black * 16) 
    call SetTextColor
    mov ecx, 0
DP_Loop:
    cmp ecx, MAX_PIPES
    jge DP_Done
    mov ebx, ecx
    shl ebx, 1 
    movsx eax, pipeX[ebx]      
    movzx edi, pipeHeight[ebx] 
    mov dh, GROUND_LEVEL
    dec dh                     
DP_DrawStem:
    cmp edi, 1                 
    jle DP_DrawCap
    mov dl, al                 
    call Gotoxy
    push eax
    mov al, '|'
    call WriteChar
    mov al, ' '
    call WriteChar
    mov al, ' '
    call WriteChar
    mov al, '|'
    call WriteChar
    pop eax
    dec dh                     
    dec edi                    
    jmp DP_DrawStem
DP_DrawCap:
    dec al
    mov dl, al
    call Gotoxy
    push eax
    mov al, '['
    call WriteChar
    mov al, '-'
    call WriteChar
    mov al, '-'
    call WriteChar
    mov al, '-'
    call WriteChar
    mov al, '-'
    call WriteChar
    mov al, ']'
    call WriteChar
    pop eax
    inc ecx
    jmp DP_Loop
DP_Done:
    popad
    ret
DrawPipes ENDP

DrawBlocks PROC
	pushad
	mov ecx, 0
DB_loop:
	cmp ecx, MAX_BLOCKS
	jge DB_done
	lea ebx, blockActive
	add ebx, ecx
	cmp BYTE PTR [ebx], 1
	jne DB_next
	mov ebx, ecx
	shl ebx, 1              
	mov ax, blockX[ebx]
	mov dl, al
	mov ax, blockY[ebx]
	mov dh, al
	call Gotoxy
	lea edi, blockState
	add edi, ecx
	mov al, BYTE PTR [edi]
	cmp al, 0
	je DB_DrawActive
	mov eax, brown + (black * 16)
	call SetTextColor
	mov bl, 'X'             
	jmp DB_DrawShape
DB_DrawActive:
	mov eax, yellow + (black * 16) 
	call SetTextColor
	mov bl, '?'             
DB_DrawShape:
	mov al, '['
	call WriteChar
	lea edi, blockWidth
	add edi, ecx
	movzx esi, BYTE PTR [edi]
	sub esi, 2
DB_FillLoop:
	cmp esi, 0
	jle DB_EndBracket
	mov al, bl              
	call WriteChar
	dec esi
	jmp DB_FillLoop
DB_EndBracket:
	mov al, ']'
	call WriteChar
DB_next:
	inc ecx
	jmp DB_loop
DB_done:
	popad
	ret
DrawBlocks ENDP

DrawFlagpole PROC
	pushad
	cmp flagpoleActive, 1
	jne DF_done
	mov eax, white + (black * 16)
	call SetTextColor
	movzx ecx, flagpoleHeight
	movsx edx, flagpoleY
	mov dh, dl                    
DF_drawPole:
	movsx eax, flagpoleX
	mov dl, al                    
	call Gotoxy
	mov al, '|'
	call WriteChar
	inc dh                        
	loop DF_drawPole
	mov eax, red + (black * 16)
	call SetTextColor
	movsx eax, flagpoleX
	inc al                        
	mov dl, al
	movsx eax, flagpoleY
	mov dh, al
	call Gotoxy
	mov al, '>'
	call WriteChar
	inc dh                        
	call Gotoxy
	mov al, '>'
	call WriteChar
DF_done:
	popad
	ret
DrawFlagpole ENDP

CheckFlagpoleCollision PROC
	pushad
	cmp flagpoleActive, 1
	jne CFC_done
	movsx eax, marioX
	movsx ebx, flagpoleX
	sub eax, ebx
	cmp eax, 0
	jge CFC_absX
	neg eax
CFC_absX:
	cmp eax, 2
	jg CFC_done
	movsx eax, marioY
	movsx ebx, flagpoleY
	cmp eax, ebx
	jl CFC_done
	movsx ebx, flagpoleY
	movzx ecx, flagpoleHeight
	add ebx, ecx
	cmp eax, ebx
	jg CFC_done
	call CalculateFlagBonus
	call ShowLevelComplete
CFC_done:
	popad
	ret
CheckFlagpoleCollision ENDP

CalculateFlagBonus PROC
	pushad
	movsx eax, marioY
	movsx ebx, flagpoleY
	sub eax, ebx
	cmp eax, 5
	jge CFB_checkMiddle
	mov flagBonusPoints, 5000
	jmp CFB_done
CFB_checkMiddle:
	cmp eax, 10
	jge CFB_bottom
	mov flagBonusPoints, 2000
	jmp CFB_done
CFB_bottom:
	mov flagBonusPoints, 100
CFB_done:
	mov eax, flagBonusPoints
	add marioScore, eax
	popad
	ret
CalculateFlagBonus ENDP

CalculateTimeBonus PROC
	pushad
	movzx eax, gameTimer
	mov ebx, 50
	mul ebx
	mov timeBonusPoints, eax
	add marioScore, eax
	popad
	ret
CalculateTimeBonus ENDP

CheckFireworks PROC
	pushad
	mov fireworksBonus, 0
	movzx eax, gameTimer
	mov ebx, 10
	xor edx, edx
	div ebx                       
	cmp edx, 1
	je CF_fireworks
	cmp edx, 3
	je CF_fireworks
	cmp edx, 6
	je CF_fireworks
	jmp CF_done
CF_fireworks:
	mov fireworksBonus, 1500
	mov eax, fireworksBonus
	add marioScore, eax
CF_done:
	popad
	ret
CheckFireworks ENDP

ShowLevelComplete PROC
	pushad
	
	; Calculate bonuses
	call CalculateTimeBonus
	call CheckFireworks
	call SaveHighScore
	
	; Display level complete screen
	mov eax, black + (yellow * 16)
	call SetTextColor
	mov dl, 30
	mov dh, 8
	call Gotoxy
	mov edx, OFFSET msgLevelComplete
	call WriteString
	
	; "Well Done!" message
	mov eax, white + (black * 16)
	call SetTextColor
	mov dl, 35
	mov dh, 10
	call Gotoxy
	mov edx, OFFSET msgWellDone
	call WriteString
	
	; Flag Bonus
	mov eax, green + (black * 16)
	call SetTextColor
	mov dl, 30
	mov dh, 12
	call Gotoxy
	mov edx, OFFSET msgFlagBonus
	call WriteString
	
	mov eax, yellow + (black * 16)
	call SetTextColor
	mov eax, flagBonusPoints
	call WriteDec
	
	; Flag position indicator
	mov eax, lightGray + (black * 16)
	call SetTextColor
	mov eax, flagBonusPoints
	cmp eax, 5000
	je SLC_topFlag
	cmp eax, 2000
	je SLC_midFlag
	mov edx, OFFSET msgBottomFlag
	jmp SLC_printFlagMsg
	
SLC_topFlag:
	mov edx, OFFSET msgTopFlag
	jmp SLC_printFlagMsg
	
SLC_midFlag:
	mov edx, OFFSET msgMidFlag
	
SLC_printFlagMsg:
	call WriteString
	
	; Time Bonus
	mov eax, green + (black * 16)
	call SetTextColor
	mov dl, 30
	mov dh, 13
	call Gotoxy
	mov edx, OFFSET msgTimeBonus
	call WriteString
	
	mov eax, yellow + (black * 16)
	call SetTextColor
	mov eax, timeBonusPoints
	call WriteDec
	
	; Time calculation breakdown
	mov eax, lightGray + (black * 16)
	call SetTextColor
	mov al, ' '
	call WriteChar
	mov al, '('
	call WriteChar
	movzx eax, gameTimer
	call WriteDec
	mov al, ' '
	call WriteChar
	mov al, 's'
	call WriteChar
	mov al, 'e'
	call WriteChar
	mov al, 'c'
	call WriteChar
	mov al, ' '
	call WriteChar
	mov al, 'x'
	call WriteChar
	mov al, ' '
	call WriteChar
	mov al, '5'
	call WriteChar
	mov al, '0'
	call WriteChar
	mov al, ')'
	call WriteChar
	
	; Fireworks Bonus (if applicable)
	cmp fireworksBonus, 0
	je SLC_noFireworks
	
	mov eax, red + (black * 16)
	call SetTextColor
	mov dl, 30
	mov dh, 14
	call Gotoxy
	mov edx, OFFSET msgFireworks
	call WriteString
	
	mov eax, yellow + (black * 16)
	call SetTextColor
	mov eax, fireworksBonus
	call WriteDec
	
	mov eax, lightGray + (black * 16)
	call SetTextColor
	mov al, ' '
	call WriteChar
	mov al, '*'
	call WriteChar
	mov al, '*'
	call WriteChar
	mov al, '*'
	call WriteChar
	
SLC_noFireworks:
	; Total Score
	mov eax, cyan + (black * 16)
	call SetTextColor
	mov dl, 30
	mov dh, 16
	call Gotoxy
	mov edx, OFFSET msgTotalScore
	call WriteString
	
	mov eax, yellow + (black * 16)
	call SetTextColor
	mov eax, marioScore
	call WriteDec
	
	; Next Level prompt
	mov eax, white + (black * 16)
	call SetTextColor
	mov dl, 32
	mov dh, 19
	call Gotoxy
	mov edx, OFFSET msgNextLevel
	call WriteString
	
	; Wait for user input
	call ReadChar
	
	; Reset bonus counters
	mov flagBonusPoints, 0
	mov timeBonusPoints, 0
	mov fireworksBonus, 0
	
	; **LEVEL PROGRESSION LOGIC**
	mov al, currentLevel
	cmp al, 1
	je SLC_AdvanceToLevel2
	cmp al, 2
	je SLC_GameComplete         ; If more levels exist, handle here
	jmp SLC_RestartSameLevel
	
SLC_AdvanceToLevel2:
	; Move to Level 2
	inc currentLevel
	call RestartLevel
	jmp SLC_Done
	
SLC_GameComplete:
	; If Level 2 is the last level, could show victory screen
	; For now, restart Level 2
	call RestartLevel
	jmp SLC_Done
	
SLC_RestartSameLevel:
	; Restart current level (shouldn't normally reach here)
	call RestartLevel
	
SLC_Done:
	popad
	ret
ShowLevelComplete ENDP


RestartLevel PROC
	pushad
	mov marioX, 10
	mov marioY, GROUND_LEVEL - 2
	mov marioOldX, 10
	mov marioOldY, GROUND_LEVEL - 2
	mov marioVelX, 0
	mov marioVelY, 0
	mov marioJumpCount, 0
	mov marioInvincible, 0
	mov gameTimer, 400
	mov timerTickCounter, 0
	call InitializeLevel
	call Clrscr
	call DrawLevel
	call DrawBlocks
	call DrawClouds
	call DrawCoins
	call DrawPowerups
	call DrawFlagpole
	call DrawHUD
	popad
	ret
RestartLevel ENDP
CheckCollisions PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    ; 1. Invincibility Timer
    cmp marioInvincible, 0
    je CC_checkCoins
    dec marioInvincible
    
    ; 2. Coin Collision
CC_checkCoins:
    xor ecx, ecx
CC_coinLoop:
    cmp ecx, MAX_COINS
    jge CC_checkPowerups
    
    lea ebx, coinActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 1
    jne CC_nextCoin
    
    push ecx
    mov ebx, ecx
    shl ebx, 1
    movsx esi, coinX[ebx]
    movsx edi, coinY[ebx]
    pop ecx
    
    movsx eax, marioX
    sub eax, esi
    cmp eax, 0
    jge CC_absX
    neg eax
CC_absX:
    cmp eax, 1
    jg CC_nextCoin
    
    movsx eax, marioY
    sub eax, edi
    cmp eax, 0
    jge CC_absY
    neg eax
CC_absY:
    cmp eax, 1
    jg CC_nextCoin
    
    ; Coin Collected
    push ecx
    lea ebx, coinActive
    add ebx, ecx
    mov BYTE PTR [ebx], 0
    pop ecx
    inc marioCoins
    add marioScore, 100
    
    ; Erase Coin
    push edx
    mov eax, esi
    mov dl, al
    mov eax, edi
    mov dh, al
    call Gotoxy
    mov al, ' '
    call WriteChar
    pop edx
    
CC_nextCoin:
    inc ecx
    jmp CC_coinLoop

    ; 3. Powerup Collision
CC_checkPowerups:
    xor ecx, ecx
CC_powerupLoop:
    cmp ecx, MAX_POWERUPS
    jge CC_checkPiranhas            
    
    lea ebx, powerupActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 1
    jne CC_nextPowerup
    
    push ecx
    mov ebx, ecx
    shl ebx, 1
    movsx esi, powerupX[ebx]
    movsx edi, powerupY[ebx]
    pop ecx
    
    movsx eax, marioX
    sub eax, esi
    cmp eax, 0
    jge CC_absPowerX
    neg eax
CC_absPowerX:
    cmp eax, 2
    jg CC_nextPowerup
    
    movsx eax, marioY
    sub eax, edi
    cmp eax, 0
    jge CC_absPowerY
    neg eax
CC_absPowerY:
    cmp eax, 1
    jg CC_nextPowerup
    
    ; === POWERUP COLLECTED ===
    push ecx
    lea ebx, powerupActive
    add ebx, ecx
    mov BYTE PTR [ebx], 0
    lea ebx, powerupType
    add ebx, ecx
    mov al, BYTE PTR [ebx]
    pop ecx
    
    cmp al, 1
    je CC_EffectSpring
    cmp al, 2
    je CC_EffectMushroom
    cmp al, 3
    je CC_EffectFire
    cmp al, 4
    je CC_EffectStar
    jmp CC_nextPowerup

CC_EffectSpring:
    mov springBoostActive, 1
    mov springBoostTimer, 180       
    add marioScore, 1000
    jmp CC_nextPowerup

CC_EffectMushroom:
    ; Become Super Mario
    cmp marioPowerState, MARIO_SMALL
    jne CC_MushroomScoreOnly 
    mov marioPowerState, MARIO_SUPER
    mov marioRetainState, MARIO_SUPER
    mov marioY, GROUND_LEVEL - 3 
    add marioScore, 1000
    mov eax, 900
    mov edx, 100
    call MakeSound
    jmp CC_nextPowerup
CC_MushroomScoreOnly:
    add marioScore, 1000
    jmp CC_nextPowerup

CC_EffectFire:
    ; === FIX: ALWAYS BECOME FIRE MARIO ===
    ; Even if Small or Big, getting the flower makes you Fire
    mov marioPowerState, MARIO_FIRE
    mov marioRetainState, MARIO_FIRE
    add marioScore, 1000
    mov eax, 1100
    mov edx, 100
    call MakeSound
    jmp CC_nextPowerup

CC_EffectStar:
    cmp marioPowerState, MARIO_STAR
    je CC_ExtendStar 
    mov al, marioPowerState
    mov marioRetainState, al
    mov marioPowerState, MARIO_STAR
    mov marioStarTimer, 200  
    add marioScore, 1000
    mov eax, 1400
    mov edx, 100
    call MakeSound
    jmp CC_nextPowerup
CC_ExtendStar:
    mov marioStarTimer, 200
    add marioScore, 1000
    jmp CC_nextPowerup
    
CC_nextPowerup:
    inc ecx
    jmp CC_powerupLoop
    
    ; 4. Piranha Plants
CC_checkPiranhas:
    mov al, currentLevel
    cmp al, 2
    jne CC_checkEnemies             
    cmp marioInvincible, 0
    jne CC_checkEnemies
    cmp marioPowerState, MARIO_STAR
    je CC_checkEnemies
    xor ecx, ecx
CC_piranhaLoop:
    cmp ecx, MAX_PIRANHAS
    jge CC_checkEnemies
    lea ebx, piranhaActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 1
    jne CC_nextPiranha
    lea edi, piranhaState
    add edi, ecx
    mov al, BYTE PTR [edi]
    cmp al, 0
    je CC_nextPiranha
    push ecx
    mov ebx, ecx
    shl ebx, 1
    movsx esi, piranhaX[ebx]
    movsx edi, piranhaY[ebx]
    pop ecx
    movsx eax, marioX
    sub eax, esi
    cmp eax, 0
    jge CC_pirAbsX
    neg eax
CC_pirAbsX:
    cmp eax, 1
    jg CC_nextPiranha
    movsx eax, marioY
    sub eax, edi
    cmp eax, 0
    jge CC_pirAbsY
    neg eax
CC_pirAbsY:
    cmp eax, 1
    jg CC_nextPiranha
    call ApplyDamageToMario
    jmp CC_done
CC_nextPiranha:
    inc ecx
    jmp CC_piranhaLoop
    
    ; 5. Enemies
CC_checkEnemies:
    cmp marioInvincible, 0
    jne CC_done
    cmp marioPowerState, MARIO_STAR
    je CC_starKillEnemies
    xor ecx, ecx
CC_enemyLoop:
    cmp ecx, MAX_ENEMIES
    jge CC_done
    lea ebx, enemyActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 1
    jne CC_nextEnemy
    push ecx
    mov ebx, ecx
    shl ebx, 1
    movsx esi, enemyX[ebx]
    movsx edi, enemyY[ebx]
    pop ecx
    movsx eax, marioX
    sub eax, esi
    cmp eax, 0
    jge CC_enemyAbsX
    neg eax
CC_enemyAbsX:
    cmp eax, 1
    jg CC_nextEnemy
    movsx eax, marioY
    sub eax, edi
    cmp eax, 0
    jge CC_enemyAbsY
    neg eax
CC_enemyAbsY:
    cmp eax, 1
    jg CC_nextEnemy
    
    ; Stomp Check
    movsx eax, marioY
    movsx ebx, marioOldY
    sub eax, ebx
    cmp eax, 0
    jg CC_stompLogic
    cmp marioVelY, 0
    jg CC_stompLogic
    movsx eax, marioY
    cmp eax, edi
    jl CC_stompLogic
    
    ; Damage Check
    lea ebx, enemyType
    add ebx, ecx
    cmp BYTE PTR [ebx], 1
    jne CC_takeDamage
    lea ebx, enemyState
    add ebx, ecx
    cmp BYTE PTR [ebx], 1
    je CC_shellInteraction
    
CC_takeDamage:
    call ApplyDamageToMario
    jmp CC_done

CC_shellInteraction:
    mov ebx, ecx
    shl ebx, 1
    cmp enemyVelX[ebx], 0
    jne CC_takeDamage
    movsx eax, marioX
    movsx edx, enemyX[ebx]
    cmp eax, edx
    jl CC_KickRight
CC_KickLeft:
    mov enemyVelX[ebx], -SHELL_SPEED
    mov marioX, dx
    add marioX, 4
    jmp CC_KickAction
CC_KickRight:
    mov enemyVelX[ebx], SHELL_SPEED
    mov marioX, dx
    sub marioX, 4
CC_KickAction:
    add marioScore, 400
    mov eax, 600
    mov edx, 50
    call MakeSound
    jmp CC_nextEnemy

CC_stompLogic:
    mov marioVelY, -2
    lea ebx, enemyType
    add ebx, ecx
    cmp BYTE PTR [ebx], 1
    je CC_stompKoopa
    push ecx
    lea ebx, enemyActive
    add ebx, ecx
    mov BYTE PTR [ebx], 0
    pop ecx
    add marioScore, 100
    push eax
    push edx
    mov eax, esi
    mov dl, al
    mov eax, edi
    mov dh, al
    call Gotoxy
    mov al, ' '
    call WriteChar
    pop edx
    pop eax
    mov eax, 800
    mov edx, 80
    call MakeSound
    jmp CC_nextEnemy

CC_stompKoopa:
    lea ebx, enemyState
    add ebx, ecx
    mov BYTE PTR [ebx], 1
    mov ebx, ecx
    shl ebx, 1
    mov enemyVelX[ebx], 0
    add marioScore, 100
    mov eax, 800
    mov edx, 80
    call MakeSound
    jmp CC_nextEnemy

CC_nextEnemy:
    inc ecx
    jmp CC_enemyLoop
    
    ; Star Kills
CC_starKillEnemies:
    xor ecx, ecx
CC_starKillLoop:
    cmp ecx, MAX_ENEMIES
    jge CC_done
    lea ebx, enemyActive
    add ebx, ecx
    cmp BYTE PTR [ebx], 1
    jne CC_nextStarKill
    push ecx
    mov ebx, ecx
    shl ebx, 1
    movsx esi, enemyX[ebx]
    movsx edi, enemyY[ebx]
    pop ecx
    movsx eax, marioX
    sub eax, esi
    cmp eax, 0
    jge CC_starAbsX
    neg eax
CC_starAbsX:
    cmp eax, 2
    jg CC_nextStarKill
    movsx eax, marioY
    sub eax, edi
    cmp eax, 0
    jge CC_starAbsY
    neg eax
CC_starAbsY:
    cmp eax, 2
    jg CC_nextStarKill
    push ecx
    lea ebx, enemyActive
    add ebx, ecx
    mov BYTE PTR [ebx], 0
    pop ecx
    add marioScore, 200
    mov eax, 1200
    mov edx, 40
    call MakeSound
CC_nextStarKill:
    inc ecx
    jmp CC_starKillLoop
    
CC_done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
CheckCollisions ENDP
ApplyDamageToMario PROC
    ; Don't take damage if star power is active
    cmp marioPowerState, MARIO_STAR
    je ADM_exit
    
    ; Power state downgrade: Fire -> Super -> Small
    cmp marioPowerState, MARIO_FIRE
    je ADM_fireToSuper
    cmp marioPowerState, MARIO_SUPER
    je ADM_superToSmall
    
    ; Already small - lose a life
ADM_smallDeath:
    dec marioLives
    cmp marioLives, 0
    jg ADM_respawn
    mov gameState, STATE_GAME_OVER
    jmp ADM_exit
    
ADM_respawn:
    call EraseMario
    mov marioX, 10
    mov marioY, GROUND_LEVEL - 2
    mov marioOldX, 10
    mov marioOldY, GROUND_LEVEL - 2
    mov marioVelX, 0
    mov marioVelY, 0
    mov marioJumpCount, 0
    mov marioPowerState, MARIO_SMALL
    mov marioRetainState, MARIO_SMALL
    mov marioInvincible, 60
    mov eax, 200
    mov edx, 200
    call MakeSound
    jmp ADM_exit
    
ADM_fireToSuper:
    mov marioPowerState, MARIO_SUPER
    mov marioInvincible, 60
    mov eax, 300
    mov edx, 100
    call MakeSound
    jmp ADM_exit
    
ADM_superToSmall:
    mov marioPowerState, MARIO_SMALL
    mov marioInvincible, 60
    mov eax, 300
    mov edx, 100
    call MakeSound
    jmp ADM_exit
    
ADM_exit:
    ret
ApplyDamageToMario ENDP





DrawGround PROC
	pushad
	mov eax, white + (COLOR_GROUND * 16)
	call SetTextColor
	mov dh, GROUND_LEVEL
	mov ecx, SCREEN_WIDTH
	mov dl, 0
DG_Loop:
	push ecx
	call Gotoxy
	mov al, ground_char
	call WriteChar
	pop ecx
	inc dl
	loop DG_Loop
	popad
	ret
DrawGround ENDP

DrawLevel PROC
	pushad
	call Clrscr
	mov eax, white + (COLOR_GROUND * 16)
	call SetTextColor
	mov dh, GROUND_LEVEL
	mov ecx, SCREEN_WIDTH
	mov dl, 0
DL_DrawAllGround:
	push ecx
	call Gotoxy
	mov al, ground_char
	call WriteChar
	pop ecx
	inc dl
	loop DL_DrawAllGround
	mov ecx, 0
DL_PitLoop:
	cmp ecx, MAX_PITS
	jge DL_PitsDone
	lea ebx, pitActive
	add ebx, ecx
	cmp BYTE PTR [ebx], 1
	jne DL_NextPit
	mov eax, red + (black * 16)
	call SetTextColor
	mov ebx, ecx
	shl ebx, 1
	mov ax, pitX[ebx]
	mov dl, al
	mov dh, GROUND_LEVEL
	lea edi, pitWidth
	add edi, ecx
	movzx esi, BYTE PTR [edi]
DL_DrawPitMarkers:
	cmp esi, 0
	jle DL_NextPit
	call Gotoxy
	mov al, 'v'
	call WriteChar
	inc dl
	dec esi
	jmp DL_DrawPitMarkers
DL_NextPit:
	inc ecx
	jmp DL_PitLoop
DL_PitsDone:
	call DrawPipes      
	call DrawBlocks
	call DrawCoins
	call DrawClouds
    call DrawPowerups
	popad
	ret
DrawLevel ENDP

CheckIfInPit PROC
	push ebx
	push ecx
	push edx
	mov al, 0  
	mov ecx, 0
CIP_Loop:
	cmp ecx, MAX_PITS
	jge CIP_Done
	lea ebx, pitActive
	add ebx, ecx
	cmp BYTE PTR [ebx], 1
	jne CIP_Next
	mov ebx, ecx
	shl ebx, 1
	mov ax, pitX[ebx]
	cmp dl, al  
	jl CIP_Next
	lea ebx, pitWidth
	add ebx, ecx
	movzx bx, BYTE PTR [ebx]
	add ax, bx  
	cmp dl, al
	jge CIP_Next
	mov al, 1
	jmp CIP_Done
CIP_Next:
	inc ecx
	jmp CIP_Loop
CIP_Done:
	pop edx
	pop ecx
	pop ebx
	ret
CheckIfInPit ENDP
GameLoop PROC
    ; ===================================================================
    ; INITIALIZATION
    ; ===================================================================
    call Clrscr
    call DrawLevel
    call DrawPipes
    call DrawBlocks
    call DrawClouds
    call DrawCoins
    call DrawPowerups
    call DrawFlagpole
    
    mov al, currentLevel
    cmp al, 2
    jne GL_SkipLevel2InitialDraw
    
    call DrawMovingPlatforms
    call DrawElevatorPlatforms
    call DrawPiranhaPlants
    
GL_SkipLevel2InitialDraw:
    call DrawHUD

    ; ===================================================================
    ; MAIN GAME LOOP
    ; ===================================================================
gameMainLoop:
    cmp gameState, STATE_GAMEPLAY
    jne exitGameLoop
    
    call HandleInput
    call ErasePowerups
    
    ; Save old pos
    mov ax, marioX
    push ax
    mov ax, marioY
    push ax
    
    ; Updates
    call UpdatePhysics
    call UpdateEnemies
    call UpdatePowerups
    call UpdateFireballs          ; NEW
    
    mov al, currentLevel
    cmp al, 2
    jne GL_SkipLevel2Updates
    
    call UpdateMovingPlatforms
    call UpdateElevatorPlatforms
    call UpdatePiranhaPlants
    
GL_SkipLevel2Updates:
    call UpdateTimer
    
    ; Collisions
    call EraseEnemies
    call CheckCollisions
    call CheckFireballCollisions  ; NEW
    call CheckFlagpoleCollision
    
    ; Rendering
    pop bx
    pop cx
    mov ax, marioY
    cmp ax, bx
    jne GL_MarioMoved
    mov ax, marioX
    cmp ax, cx
    jne GL_MarioMoved
    jmp GL_DrawEnvironment
    
GL_MarioMoved:
    call EraseMario
    call DrawMario
    
GL_DrawEnvironment:
    call DrawBlocks
    call DrawEnemy
    call DrawPowerups
    call EraseFireballs           ; NEW
    call DrawFireballs            ; NEW
    
    ; --- FIX: Handle Level 2 Erase/Redraw ---
    mov al, currentLevel
    cmp al, 2
    jne GL_SkipLevel2Redraw
    
    call EraseMovingPlatforms
    call EraseElevatorPlatforms
    call ErasePiranhaPlants
    
    call DrawMovingPlatforms
    call DrawElevatorPlatforms
    call DrawPiranhaPlants
    
    ; FIX: Redraw Pipes here to restore any erased parts
    call DrawPipes
    ; -----------------------------------------------
    
GL_SkipLevel2Redraw:
    
    mov eax, 100
    call Delay
    jmp gameMainLoop
    
exitGameLoop:
    call SaveLevelProgress
    call SaveHighScore
    ret
GameLoop ENDP

END main