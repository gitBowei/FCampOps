while ($true)
{
	# ScriptBy: Luiz Filipe - 23/04/2014 - lfbasantos@gmail.com / lfbasantos@hotmail.com
	$vCfg=1;
	$caminho="D:\opt\prog";
	$vFill="###############################################################";
	$vHead="#-01-02-03-04-05-06-07-08-09-10-11-12-13-14-15-16-17-18-19-20-#";
	$vSep="-";
	$vSea="~~";
	$vNav="XX";
	$vLetra="Z";
	$vEndLine="-#";	
	$vIni=$vIni+1;
	
	if ($vIni -eq 1 ) {	clear-host; };
	if ($vCfg -eq 1) { $vPc1 = 1; $vPc2 = 2 } else { $vPc1 = 2; $vPc2 = 1 };
	$vMp1=get-content $caminho\mapa1.txt;
	$vSeqMp1="";
	
	foreach ($i in $vMp1) 
			{ 
				$vCol=0;
				$vLn="Z";
				foreach ($vPos in $i.split("-")) 
					{
					if ($vPos.substring(0,1) -ne "#" -and $vCol -ne 21) 
							{ 
								$arrLinhas = "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O";
								if ($arrLinhas -contains $vPos) { $vLn = $vPos; }
								if ($vCol -ne 0) 
										{ 
											if ($vPos -eq "XX")
												{
													if ($vCol -lt 10) {$vSeqMp1=$vSeqMp1+$vLn+"0"+$vCol;};
													if ($vCol -gt 9) {$vSeqMp1=$vSeqMp1+$vLn+$vCol;};
												}
										};
							};
					$vCol = $vCol + 1;
					}
			};

	$vMp2=get-content $caminho\mapa2.txt;
	$vSeqMp2="";
	foreach ($i in $vMp2) 
			{ 
				$vCol=0;
				$vLn="Z";
				foreach ($vPos in $i.split("-")) 
					{
					if ($vPos.substring(0,1) -ne "#" -and $vCol -ne 21) 
							{ 
								$arrLinhas = "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O";
								if ($arrLinhas -contains $vPos) { $vLn = $vPos; }
								if ($vCol -ne 0) 
										{ 
											if ($vPos -eq "XX")
												{
													if ($vCol -lt 10) {$vSeqMp2=$vSeqMp2+$vLn+"0"+$vCol;};
													if ($vCol -gt 9) {$vSeqMp2=$vSeqMp2+$vLn+$vCol;};
												}
										};
							};
					$vCol = $vCol + 1;
					}
			};
	

	write-host "###############################################################";
	write-host "######     BATALHA NAVAL POWERSHELL  MODAFOKER           ######";
	write-host "###############################################################";
	write-host "#                                                             #";
	write-host "###############################################################";
	write-host "######                 MAPA DE NAVIOS                    ######";
	
	$vHitsPlayer1=get-content $caminho\Shot1.txt -erroraction silentlycontinue
	$vMissPlayer1=get-content $caminho\Fired1.txt -erroraction silentlycontinue
	$vHitsPlayer2=get-content $caminho\Shot2.txt -erroraction silentlycontinue	
	$vMissPlayer2=get-content $caminho\Fired2.txt -erroraction silentlycontinue
	
	for($vCont=1; $vCont -lt 18; $vCont++) {
		$vLetras="##ABCDEFGHIJKLMNO#";
		if ($vCont -eq 1) { write-host $vFill };
		if ($vCont -eq 2) { write-host $vHead };
		if ($vCont -gt 2) {
			$vLetra=$vLetras.substring($vCont-1,1);
			$vLinha=$vLetra;
			for($vCont2=1; $vCont2 -lt 21; $vCont2++) {
				if ($vCont2 -lt 10) {$vNum="0"+$vCont2;};
				if ($vCont2 -gt 9) {$vNum=$vCont2;};
				$vMark=$vLetra+$vNum;
				if ($vCfg -eq 1) { 
					if ($vSeqMp1 -match $vMark) { $vSea = "XX"; }; 
					if ($vHitsPlayer2 -match $vMark) {$vSea = "<>";};
					if ($vMissPlayer2 -match $vMark) {$vSea = "><";};
					} else {
					if ($vSeqMp2 -match $vMark) { $vSea = "XX"; };
					if ($vHitsPlayer1 -match $vMark ) { $vSea = "<>"; };
					if ($vMissPlayer1 -match $vMark ) { $vSea = "><"; };
				}
				$vLinha=$vLinha+$vSep+$vSea;
				$vSea = "~~";
			}
			$vLinha=$vLinha+$vEndLine;
			write-host $vLinha;
		}
	}
	write-host $vFill;

	write-host "#                                                             #";
	write-host "###############################################################";
	write-host "######                  FROTA ADVERSARIA                 ######";	
	for($vCont=1; $vCont -lt 18; $vCont++) {
		$vLetras="##ABCDEFGHIJKLMNO#";
		if ($vCont -eq 1) { write-host $vFill; };
		if ($vCont -eq 2) { write-host $vHead; };
		if ($vCont -gt 2) {
			$vLetra=$vLetras.substring($vCont-1,1);
			$vLinha=$vLetra;
			for($vCont2=1; $vCont2 -lt 21; $vCont2++) {
				if ($vCont2 -lt 10) {$vNum="0"+$vCont2;};
				if ($vCont2 -gt 9) {$vNum=$vCont2;};
				$vMark=$vLetra+$vNum;
				if ($vSeqShot -match $vMark) { $vSea = "XX"; };
				if ($vSeqFired -match $vMark) { $vSea = "@@"; };
				$vLinha=$vLinha+$vSep+$vSea;
				$vSea = "~~";
			}
			$vLinha=$vLinha+$vEndLine;
			write-host $vLinha;
		}
	}
	write-host $vFill;
	write-host "#                                                             #";
	write-host "###############################################################";

	
	if (get-content $caminho\winner1.txt -erroraction silentlycontinue)
	{
		write-host "## Jogador 1 Venceu. ##";
		break;
	} elseif (get-content $caminho\winner2.txt -erroraction silentlycontinue) {
		write-host " ## Jogador 2 Venceu. ##";
		break;
	}
	
	
	if (test-path $caminho\pc$vPc2.txt){
		write-host "Aguardando jogada...";
	}
	$vC=1;
	while (test-path $caminho\pc$vPc2.txt) {
		if ($vC -eq 50) { $vC = 1; write-host ".";};
		write-host -nonewline  ".";
		$vC=$vC+1;
		sleep 1;
		
	}

	write-host ".";
	write-output "1" > $caminho\pc$vPc1.txt;
	$vFlag=1;
	while ($vFlag -eq 1) {
	sleep 1;
			if (get-content $caminho\winner1.txt -erroraction silentlycontinue)
			{
				write-host "## Jogador 1 Venceu. ##";
				break;
			} elseif (get-content $caminho\winner2.txt -erroraction silentlycontinue) {
				write-host " ## Jogador 2 Venceu. ##";
				break;
			}
	$vAtk = read-host "[Digite posição de ataque(Ex.: E01)]";
	if ($vSeqFired -match $vAtk -or $vSeqShot -match $vAtk) { write-host "Tiro já registrado. Tente outra posição"; } else { $vFlag = 2 };
	}
	
	if ($vCfg -eq 1) {
		if ($vSeqMp2 -match $vAtk) {
			write-host "###############################################################";
			write-host "######             BOOOOOOOOOOOOOOMMMM !!!!!!            ######";
			write-host "###############################################################";
			#$vSeqMp2 = $vSeqMp2 -replace $vAtk, "";
			$vSeqShot = $vSeqShot+$vAtk;
			write-output $vSeqShot > $caminho\Shot1.txt;
			$vLenShot = get-content $caminho\Shot1.txt -erroraction silentlycontinue
				if ($vSeqMp2.length -eq $vLenShot.length ) 
					{
						write-host "## VOCÊ VENCEU ##";
						write-output "WINNER" > $caminho\winner1.txt
						remove-item $caminho\pc1.txt;
						break;
					};
			} else {
			$vSeqFired= $vSeqFired+$vAtk;
			write-output $vSeqFired > $caminho\Fired1.txt
			}
		} else {
			if ($vSeqMp1 -match $vAtk) {
			write-host "###############################################################";
			write-host "######             BOOOOOOOOOOOOOOMMMM !!!!!!            ######";
			write-host "###############################################################";	
			#$vSeqMp1 = $vSeqMp1 -replace $vAtk, "";
			$vSeqShot = $vSeqShot+$vAtk;
			write-output $vSeqShot > $caminho\Shot2.txt
			$vLenShot = get-content $caminho\Shot2.txt -erroraction silentlycontinue
				if ($vSeqMp1.length -eq $vLenShot.length) 
					{
						write-host "## VOCÊ VENCEU ##";
						write-output "WINNER" > $caminho\winner2.txt
						remove-item $caminho\pc2.txt;
					};
			} else {
			$vSeqFired= $vSeqFired+$vAtk;
			write-output $vSeqFired > $caminho\Fired2.txt
			}
		}
		
	remove-item $caminho\pc$vPc1.txt;
	sleep 1;
	clear-host;
}





example content of mapa1.txt (do not add this line)
###############################################################
#-01-02-03-04-05-06-07-08-09-10-11-12-13-14-15-16-17-18-19-20-#
A-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
B-~~-~~-~~-~~-~~-~~-~~-~~-XX-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
C-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
D-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
E-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
F-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
G-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-XX-~~-~~-~~-~~-~~-~~-~~-~~-#
H-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-XX-~~-~~-~~-~~-~~-~~-~~-~~-#
I-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
J-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
K-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
L-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
M-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
N-~~-~~-~~-~~-~~-~~-~~-XX-XX-XX-XX-XX-~~-~~-~~-~~-~~-~~-~~-~~-#
O-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
###############################################################


example content of mapa2.txt(do not add this line)
###############################################################
#-01-02-03-04-05-06-07-08-09-10-11-12-13-14-15-16-17-18-19-20-#
A-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
B-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
C-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
D-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
E-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
F-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
G-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
H-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
I-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
J-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
K-~~-~~-XX-~~-~~-~~-~~-XX-XX-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
L-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
M-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
N-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-XX-~~-~~-#
O-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-~~-#
###############################################################

