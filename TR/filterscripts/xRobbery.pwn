#include <a_samp>
#include <a_mysql>
#include <zcmd>
#include <sscanf2>
#include <YSI\y_iterate>

#define		SQL_HOST			"localhost"
#define		SQL_USER			"root"
#define		SQL_PASSWORD		""
#define		SQL_DBNAME			"xfr_testdb"

#define MAX_SAFE 			50		// Oluþturulabilecek en fazla kasa sayýsý
#define SAFE_COOLDOWN_TIME 	5		// Kasanýn tekrar soyulabilmesi için beklenecek süre (dk)
#define ROB_MAX 			30000 	// Kasadan çalýnabilecek en fazla para
#define ROB_MIN 			10000 	// Kasadan çalýnabilecek en az para 

enum safe_data 
{
	safe_Obj,
	safe_BosObj,
	safe_Timer,
	safe_Sure,
	Text3D:safe_Label,
	Float:safe_Pos[4],
	
	safe_Progress,
	safe_Durum
}

new 
	xSafe[MAX_SAFE][safe_data],
	Iterator:xSafes<MAX_SAFE>,
	MySQL:mysqlB,

	PlayerText:xRob_TD[MAX_PLAYERS][8],
	Float:pTmpPos[MAX_PLAYERS][4]
;

public OnFilterScriptInit()
{
	print("[xRobbery MySql] Veri tabanina baglaniliyor...");

	mysqlB = mysql_connect(SQL_HOST, SQL_USER, SQL_PASSWORD, SQL_DBNAME); 
	mysql_log(ALL); 
	if (mysql_errno(mysqlB) == 0) print("[xRobbery MySql] Veri tabanina baglanti basarili!");
	else print("[xRobbery MySql] Baglanti Basarisiz!\n\n[!!! xRobbery Yüklenemedi !!!]\n\n");
	
	mysql_query(mysqlB, "CREATE TABLE IF NOT EXISTS `xRob_Safes` (\
	  `ID` int(11) NOT NULL,\
	  `X` float NOT NULL default '0',\
	  `Y` float NOT NULL default '0',\
	  `Z` float NOT NULL default '0',\
	  `A` float NOT NULL default '0',\
		PRIMARY KEY  (`ID`),\
		UNIQUE KEY `ID_2` (`ID`),\
		KEY `ID` (`ID`)\
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	
	mysql_tquery(mysqlB, "SELECT * FROM `xRob_Safes`", "LoadxSafes");
	return 1;
}

public OnPlayerConnect(playerid)
{
	ApplyAnimation(playerid, "BOMBER", "null", 0.0, false, false, false, false, 0, false); // Animasyonun çalýþmama bug'ýný önlemek için ekledim.
	ApplyAnimation(playerid, "ROB_BANK", "null", 0.0, false, false, false, false, 0, false);
	
	SetPVarInt(playerid, "pSafeID", -1);
	
	xRob_TD[playerid][0] = CreatePlayerTextDraw(playerid, 191.141998, 212.749984, "box");
	PlayerTextDrawLetterSize(playerid, xRob_TD[playerid][0], 0.000000, 10.983894);
	PlayerTextDrawTextSize(playerid, xRob_TD[playerid][0], 438.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, xRob_TD[playerid][0], 1);
	PlayerTextDrawColor(playerid, xRob_TD[playerid][0], -1);
	PlayerTextDrawUseBox(playerid, xRob_TD[playerid][0], 1);
	PlayerTextDrawBoxColor(playerid, xRob_TD[playerid][0], 50);
	PlayerTextDrawSetShadow(playerid, xRob_TD[playerid][0], 0);
	PlayerTextDrawSetOutline(playerid, xRob_TD[playerid][0], 0);
	PlayerTextDrawBackgroundColor(playerid, xRob_TD[playerid][0], 255);
	PlayerTextDrawFont(playerid, xRob_TD[playerid][0], 1);
	PlayerTextDrawSetProportional(playerid, xRob_TD[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, xRob_TD[playerid][0], 0);

	xRob_TD[playerid][1] = CreatePlayerTextDraw(playerid, 193.953109, 198.750030, "Kasa Soygunu");
	PlayerTextDrawLetterSize(playerid, xRob_TD[playerid][1], 0.457159, 1.903331);
	PlayerTextDrawAlignment(playerid, xRob_TD[playerid][1], 1);
	PlayerTextDrawColor(playerid, xRob_TD[playerid][1], -1378294017);
	PlayerTextDrawSetShadow(playerid, xRob_TD[playerid][1], 0);
	PlayerTextDrawSetOutline(playerid, xRob_TD[playerid][1], 1);
	PlayerTextDrawBackgroundColor(playerid, xRob_TD[playerid][1], 255);
	PlayerTextDrawFont(playerid, xRob_TD[playerid][1], 0);
	PlayerTextDrawSetProportional(playerid, xRob_TD[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, xRob_TD[playerid][1], 0);

	xRob_TD[playerid][2] = CreatePlayerTextDraw(playerid, 202.386459, 230.833358, "Kasa aciliyor...");
	PlayerTextDrawLetterSize(playerid, xRob_TD[playerid][2], 0.288491, 1.378332);
	PlayerTextDrawAlignment(playerid, xRob_TD[playerid][2], 1);
	PlayerTextDrawColor(playerid, xRob_TD[playerid][2], -5963521);
	PlayerTextDrawSetShadow(playerid, xRob_TD[playerid][2], 1);
	PlayerTextDrawSetOutline(playerid, xRob_TD[playerid][2], 0);
	PlayerTextDrawBackgroundColor(playerid, xRob_TD[playerid][2], 255);
	PlayerTextDrawFont(playerid, xRob_TD[playerid][2], 1);
	PlayerTextDrawSetProportional(playerid, xRob_TD[playerid][2], 1);
	PlayerTextDrawSetShadow(playerid, xRob_TD[playerid][2], 1);

	xRob_TD[playerid][3] = CreatePlayerTextDraw(playerid, 202.386520, 253.000000, "box");
	PlayerTextDrawLetterSize(playerid, xRob_TD[playerid][3], 0.000000, 0.676428);
	PlayerTextDrawTextSize(playerid, xRob_TD[playerid][3], 427.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, xRob_TD[playerid][3], 1);
	PlayerTextDrawColor(playerid, xRob_TD[playerid][3], -1);
	PlayerTextDrawUseBox(playerid, xRob_TD[playerid][3], 1);
	PlayerTextDrawBoxColor(playerid, xRob_TD[playerid][3], 100);
	PlayerTextDrawSetShadow(playerid, xRob_TD[playerid][3], 0);
	PlayerTextDrawSetOutline(playerid, xRob_TD[playerid][3], 0);
	PlayerTextDrawBackgroundColor(playerid, xRob_TD[playerid][3], 255);
	PlayerTextDrawFont(playerid, xRob_TD[playerid][3], 1);
	PlayerTextDrawSetProportional(playerid, xRob_TD[playerid][3], 1);
	PlayerTextDrawSetShadow(playerid, xRob_TD[playerid][3], 0);

	xRob_TD[playerid][4] = CreatePlayerTextDraw(playerid, 201.449447, 250.666656, "IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII");
	PlayerTextDrawLetterSize(playerid, xRob_TD[playerid][4], 0.410775, 1.098333);
	PlayerTextDrawAlignment(playerid, xRob_TD[playerid][4], 1);
	PlayerTextDrawColor(playerid, xRob_TD[playerid][4], -5963521);
	PlayerTextDrawSetShadow(playerid, xRob_TD[playerid][4], 0);
	PlayerTextDrawSetOutline(playerid, xRob_TD[playerid][4], 0);
	PlayerTextDrawBackgroundColor(playerid, xRob_TD[playerid][4], 255);
	PlayerTextDrawFont(playerid, xRob_TD[playerid][4], 1);
	PlayerTextDrawSetProportional(playerid, xRob_TD[playerid][4], 1);
	PlayerTextDrawSetShadow(playerid, xRob_TD[playerid][4], 0);

	xRob_TD[playerid][5] = CreatePlayerTextDraw(playerid, 202.386489, 274.583312, "box");
	PlayerTextDrawLetterSize(playerid, xRob_TD[playerid][5], 0.000000, 2.925331);
	PlayerTextDrawTextSize(playerid, xRob_TD[playerid][5], 429.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, xRob_TD[playerid][5], 1);
	PlayerTextDrawColor(playerid, xRob_TD[playerid][5], 150);
	PlayerTextDrawUseBox(playerid, xRob_TD[playerid][5], 1);
	PlayerTextDrawBoxColor(playerid, xRob_TD[playerid][5], 100);
	PlayerTextDrawSetShadow(playerid, xRob_TD[playerid][5], 0);
	PlayerTextDrawSetOutline(playerid, xRob_TD[playerid][5], 0);
	PlayerTextDrawBackgroundColor(playerid, xRob_TD[playerid][5], 255);
	PlayerTextDrawFont(playerid, xRob_TD[playerid][5], 1);
	PlayerTextDrawSetProportional(playerid, xRob_TD[playerid][5], 1);
	PlayerTextDrawSetShadow(playerid, xRob_TD[playerid][5], 0);

	xRob_TD[playerid][6] = CreatePlayerTextDraw(playerid, 205.666137, 275.749877, "~g~~h~Kasayi basariyla actiniz!~n~~y~~h~Calinan para: ~g~$123");
	PlayerTextDrawLetterSize(playerid, xRob_TD[playerid][6], 0.227115, 1.162497);
	PlayerTextDrawAlignment(playerid, xRob_TD[playerid][6], 1);
	PlayerTextDrawColor(playerid, xRob_TD[playerid][6], -1);
	PlayerTextDrawSetShadow(playerid, xRob_TD[playerid][6], 0);
	PlayerTextDrawSetOutline(playerid, xRob_TD[playerid][6], 1);
	PlayerTextDrawBackgroundColor(playerid, xRob_TD[playerid][6], 255);
	PlayerTextDrawFont(playerid, xRob_TD[playerid][6], 1);
	PlayerTextDrawSetProportional(playerid, xRob_TD[playerid][6], 1);
	PlayerTextDrawSetShadow(playerid, xRob_TD[playerid][6], 0);

	xRob_TD[playerid][7] = CreatePlayerTextDraw(playerid, 302.650115, 303.750061, "Soygunu iptal etmek icin LSHIFT tusuna basin.");
	PlayerTextDrawLetterSize(playerid, xRob_TD[playerid][7], 0.178388, 0.946666);
	PlayerTextDrawAlignment(playerid, xRob_TD[playerid][7], 1);
	PlayerTextDrawColor(playerid, xRob_TD[playerid][7], -2139062017);
	PlayerTextDrawSetShadow(playerid, xRob_TD[playerid][7], 1);
	PlayerTextDrawSetOutline(playerid, xRob_TD[playerid][7], 0);
	PlayerTextDrawBackgroundColor(playerid, xRob_TD[playerid][7], 255);
	PlayerTextDrawFont(playerid, xRob_TD[playerid][7], 1);
	PlayerTextDrawSetProportional(playerid, xRob_TD[playerid][7], 1);
	PlayerTextDrawSetShadow(playerid, xRob_TD[playerid][7], 1);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	new sid = GetPVarInt(playerid, "pSafeID");
	if(sid != -1) safeCooldown(playerid, sid);
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys == KEY_JUMP)
	{
		if(GetPVarInt(playerid, "pSafeID") != -1)
		{
			new sid = GetPVarInt(playerid, "pSafeID");
			KillTimer(xSafe[sid][safe_Timer]);
			new str[128];
			PlayerTextDrawSetString(playerid, xRob_TD[playerid][2], "~r~~h~Soygun iptal edildi!");
			PlayerTextDrawShow(playerid, xRob_TD[playerid][2]);
			format(str, sizeof(str), "~g~~h~Soygunu iptal ettiniz!~n~~y~~h~Calinan para: ~g~$%d", GetPVarInt(playerid, "robbedMoney"));
			PlayerTextDrawSetString(playerid, xRob_TD[playerid][6], str);
			PlayerTextDrawShow(playerid, xRob_TD[playerid][6]);
			PlayerTextDrawHide(playerid, xRob_TD[playerid][7]);
			GivePlayerMoney(playerid, GetPVarInt(playerid, "robbedMoney"));
			xSafe[sid][safe_Timer] = SetTimerEx("safeCooldown", 3000, false, "ud", playerid, sid);
			SetPVarInt(playerid, "pSafeID", -1);
			DeletePVar(playerid, "rob_Money");
			DeletePVar(playerid, "robbedMoney");
			ClearAnimations(playerid);
			TogglePlayerControllable(playerid, 1);
		}
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(GetPVarInt(playerid, "pSafeID") != -1)
	{
		new sid = GetPVarInt(playerid, "pSafeID");
		KillTimer(xSafe[sid][safe_Timer]);
		new str[128];
		PlayerTextDrawSetString(playerid, xRob_TD[playerid][2], "~r~~h~Kasa soyulamadi!");
		PlayerTextDrawShow(playerid, xRob_TD[playerid][2]);
		format(str, sizeof(str), "~g~~h~Oldugunuz icin soygun iptal edildi!~n~~y~~h~Calinan para: ~g~$%d", GetPVarInt(playerid, "robbedMoney"));
		PlayerTextDrawSetString(playerid, xRob_TD[playerid][6], str);
		PlayerTextDrawShow(playerid, xRob_TD[playerid][6]);
		PlayerTextDrawHide(playerid, xRob_TD[playerid][7]);
		GivePlayerMoney(playerid, GetPVarInt(playerid, "robbedMoney"));
		xSafe[sid][safe_Timer] = SetTimerEx("safeCooldown", 3000, false, "ud", playerid, sid);
		SetPVarInt(playerid, "pSafeID", -1);
		DeletePVar(playerid, "rob_Money");
		DeletePVar(playerid, "robbedMoney");
		ClearAnimations(playerid);
		TogglePlayerControllable(playerid, 1);
	}
}

public OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
	switch(GetPVarInt(playerid, "safeMode"))
	{
		case 1:
		{
			if(response == EDIT_RESPONSE_FINAL)
			{
				DestroyObject(GetPVarInt(playerid, "tmp_safe"));
				DeletePVar(playerid, "tmp_safe");
				DeletePVar(playerid, "safeMode");
				new sid = CreatexSafe(fX, fY, fZ, fRotZ);
				new str[128];
				format(str, sizeof(str), "{00FF00}[!] {ECB021}%d {FFFB93}ID'li kasa baþarýyla eklendi!", sid);
				SendClientMessage(playerid, -1, str);
			}
			else if(response == EDIT_RESPONSE_CANCEL)
			{
				DestroyObject(GetPVarInt(playerid, "tmp_safe"));
				DeletePVar(playerid, "tmp_safe");
				DeletePVar(playerid, "safeMode");
				SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Kasa eklemeyi iptal ettiniz.");
			}
		}
		case 2:
		{
			new sid = GetPVarInt(playerid, "tmp_safe");
			if(response == EDIT_RESPONSE_FINAL)
			{
				xSafe[sid][safe_Pos][0] = fX;
				xSafe[sid][safe_Pos][1] = fY;
				xSafe[sid][safe_Pos][2] = fZ;
				xSafe[sid][safe_Pos][3] = fRotZ;
				if(xSafe[sid][safe_Durum] == 3)
				{
					Delete3DTextLabel(xSafe[sid][safe_Label]);
					xSafe[sid][safe_Label] = Create3DTextLabel(" ", -1, xSafe[sid][safe_Pos][0], xSafe[sid][safe_Pos][1], xSafe[sid][safe_Pos][2]+1, 100, 0);
				}				
				DeletePVar(playerid, "tmp_safe");
				DeletePVar(playerid, "safeMode");
				SavexSafe(sid);
				new str[128];
				format(str, sizeof(str), "{00FF00}[!] {ECB021}%d {FFFB93}ID'li kasa baþarýyla düzenlendi!", sid);
				SendClientMessage(playerid, -1, str);
			}
			else if(response == EDIT_RESPONSE_CANCEL)
			{
				DeletePVar(playerid, "tmp_safe");
				DeletePVar(playerid, "safeMode");
				SetObjectPos(xSafe[sid][safe_Obj], xSafe[sid][safe_Pos][0], xSafe[sid][safe_Pos][1], xSafe[sid][safe_Pos][2]);
				SetObjectRot(xSafe[sid][safe_Obj], 0.0, 0.0, xSafe[sid][safe_Pos][3]);
				SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Kasa düzenlemeyi iptal ettiniz.");
			}
		}
	}
	return 1;
}

CMD:soy(playerid, params[])
{
	new sid = GetNearestSafeID(playerid);
	if(sid == -1) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Kasa bulunamadý!");
	if(xSafe[sid][safe_Durum] == 3) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Bu kasa yakýn zamanda soyulmuþ! Tekrar soymak için bir süre beklemelisiniz.");
	if(xSafe[sid][safe_Durum] != 0) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Bu kasa þu an zaten soyuluyor!");
	
	SetPlayerLookAt(playerid, xSafe[sid][safe_Pos][0], xSafe[sid][safe_Pos][1]);
	SetCameraBehindPlayer(playerid);
	TogglePlayerControllable(playerid, 0);
	xSafe[sid][safe_Progress] = 0;
	xSafe[sid][safe_Timer] = SetTimerEx("safeCrackProgress", 100, true, "ud", playerid, sid);
	xSafe[sid][safe_Durum] = 1;
	SetPVarInt(playerid, "pSafeID", sid);
	PlayerTextDrawSetString(playerid, xRob_TD[playerid][2], "Kasa aciliyor...");
	PlayerTextDrawSetString(playerid, xRob_TD[playerid][6], "Kasa acilmaya calisiliyor...");
	PlayerTextDrawSetString(playerid, xRob_TD[playerid][4], " ");
	for(new i; i<8; i++) PlayerTextDrawShow(playerid, xRob_TD[playerid][i]);
	ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_LOOP", 4.1, true, false, false, false, 0, false);
	return 1;
}

CMD:kasaolustur(playerid, params[])
{
	if(GetPVarInt(playerid, "safeMode") != 0) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Zaten bir kasa düzenliyorsunuz!");
	new Float:pos[3];
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	GetXYInFrontOfPlayer(playerid, pos[0], pos[1], 1);
	SetPVarInt(playerid, "tmp_safe", CreateObject(2332, pos[0], pos[1], pos[2], 0.0, 0.0, 0, 100));
	SetPVarInt(playerid, "safeMode", 1); // 1: oluþturma 2: düzenleme
	EditObject(playerid, GetPVarInt(playerid, "tmp_safe"));
	return 1;
}

CMD:kasaduzenle(playerid, params[])
{
	if(GetPVarInt(playerid, "safeMode") != 0) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Zaten bir kasa düzenliyorsunuz!");
	new sid;
	if(sscanf(params, "d", sid)) return SendClientMessage(playerid, -1, "{F0AE0F}KULLANIM: {FFFB93}/kasaduzenle {ECB021}[Kasa ID]");
	if(!Iter_Contains(xSafes, sid)) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Bu ID'de kasa bulunamadý!");
	SetPVarInt(playerid, "tmp_safe", sid);
	SetPVarInt(playerid, "safeMode", 2);
	pTmpPos[playerid][0] = xSafe[sid][safe_Pos][0];
	pTmpPos[playerid][1] = xSafe[sid][safe_Pos][1];
	pTmpPos[playerid][2] = xSafe[sid][safe_Pos][2];
	pTmpPos[playerid][3] = xSafe[sid][safe_Pos][3];
	EditObject(playerid, xSafe[sid][safe_Obj]);
	SendClientMessage(playerid, -1, "{00FF00}[!] {FFFB93}Kasayý düzenlemeye baþladýnýz!");
	return 1;
}

CMD:kasasil(playerid, params[])
{
	new sid;
	if(sscanf(params, "d", sid)) return SendClientMessage(playerid, -1, "{F0AE0F}KULLANIM: {FFFB93}/kasasil {ECB021}[Kasa ID]");
	if(!Iter_Contains(xSafes, sid)) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Bu ID'de kasa bulunamadý!");
	Iter_Remove(xSafes, sid);
	if(xSafe[sid][safe_Durum] == 3) Delete3DTextLabel(xSafe[sid][safe_Label]);
	DestroyObject(xSafe[sid][safe_Obj]);
	KillTimer(xSafe[sid][safe_Timer]);
	new str[128];
	format(str, sizeof(str), "DELETE FROM `xrob_safes` WHERE `ID`=%d", sid);
	mysql_query(mysqlB, str);
	format(str, sizeof(str), "{00FF00}[!] {ECB021}%d {FFFB93}ID'li kasayý baþarýyla sildiniz!", sid);
	SendClientMessage(playerid, -1, str);
	return 1;
}

forward safeCrackProgress(playerid, safeid);
public safeCrackProgress(playerid, safeid)
{
	xSafe[safeid][safe_Progress]++;
	new str[56];
	for(new i; i<xSafe[safeid][safe_Progress] / 2; i++) format(str, sizeof(str), "%sI", str);
	PlayerTextDrawSetString(playerid, xRob_TD[playerid][4], str);
	PlayerTextDrawShow(playerid, xRob_TD[playerid][4]);
	
	if(xSafe[safeid][safe_Progress] >= 100)
	{
		KillTimer(xSafe[safeid][safe_Timer]);
		DestroyObject(xSafe[safeid][safe_Obj]);
		xSafe[safeid][safe_BosObj] = CreateObject(1829, xSafe[safeid][safe_Pos][0], xSafe[safeid][safe_Pos][1], xSafe[safeid][safe_Pos][2], 0.0, 0.0, xSafe[safeid][safe_Pos][3]);
		PlayerTextDrawSetString(playerid, xRob_TD[playerid][2], "Kasa acildi! Kasa soyuluyor...");
		PlayerTextDrawShow(playerid, xRob_TD[playerid][2]);
		PlayerTextDrawSetString(playerid, xRob_TD[playerid][6], "~g~~h~Kasayi basariyla actiniz!~n~~y~~h~Calinan para: ~g~$0");
		PlayerTextDrawShow(playerid, xRob_TD[playerid][6]);
		PlayerTextDrawSetString(playerid, xRob_TD[playerid][4], " ");
		PlayerTextDrawShow(playerid, xRob_TD[playerid][4]);
		SetPVarInt(playerid, "rob_Money", random((ROB_MAX - ROB_MIN)) + ROB_MIN);
		ApplyAnimation(playerid, "ROB_BANK", "CAT_SAFE_ROB", 4.1, true, false, false, false, 0, false);
		xSafe[safeid][safe_Durum] = 2;
		xSafe[safeid][safe_Progress] = 0;
		xSafe[safeid][safe_Timer] = SetTimerEx("safeRobProgress", 100, true, "ud", playerid, safeid);
	}
	return 1;
}

forward safeRobProgress(playerid, safeid);
public safeRobProgress(playerid, safeid)
{
	xSafe[safeid][safe_Progress]++;
	new str[128];
	for(new i; i<xSafe[safeid][safe_Progress] / 2; i++) format(str, sizeof(str), "%sI", str);
	PlayerTextDrawSetString(playerid, xRob_TD[playerid][4], str);
	PlayerTextDrawShow(playerid, xRob_TD[playerid][4]);
	
	format(str, sizeof(str), "~g~~h~Kasayi basariyla actiniz!~n~~y~~h~Calinan para: ~g~$%d", (GetPVarInt(playerid, "rob_Money") * xSafe[safeid][safe_Progress]) / 100);
	PlayerTextDrawSetString(playerid, xRob_TD[playerid][6], str);
	PlayerTextDrawShow(playerid, xRob_TD[playerid][6]);
	SetPVarInt(playerid, "robbedMoney", (GetPVarInt(playerid, "rob_Money") * xSafe[safeid][safe_Progress]) / 100);
	
	if(xSafe[safeid][safe_Progress] >= 100)
	{
		KillTimer(xSafe[safeid][safe_Timer]);
		PlayerTextDrawSetString(playerid, xRob_TD[playerid][2], "Kasa soyuldu!");
		PlayerTextDrawShow(playerid, xRob_TD[playerid][2]);
		format(str, sizeof(str), "~g~~h~Kasayi basariyla soydunuz!~n~~y~~h~Calinan para: ~g~$%d", GetPVarInt(playerid, "rob_Money"));
		PlayerTextDrawSetString(playerid, xRob_TD[playerid][6], str);
		PlayerTextDrawShow(playerid, xRob_TD[playerid][6]);
		PlayerTextDrawHide(playerid, xRob_TD[playerid][7]);
		GivePlayerMoney(playerid, GetPVarInt(playerid, "rob_Money"));
		xSafe[safeid][safe_Timer] = SetTimerEx("safeCooldown", 3000, false, "ud", playerid, safeid);
		SetPVarInt(playerid, "pSafeID", -1);
		DeletePVar(playerid, "rob_Money");
		DeletePVar(playerid, "robbedMoney");
		ClearAnimations(playerid);
		TogglePlayerControllable(playerid, 1);
	}
	return 1;
}

forward safeCooldown(playerid, safeid);
public safeCooldown(playerid, safeid)
{
	if(IsPlayerConnected(playerid)) for(new i; i<8; i++) PlayerTextDrawHide(playerid, xRob_TD[playerid][i]);
	if(xSafe[safeid][safe_Durum] == 1) return xSafe[safeid][safe_Durum] = 0;
	new str[128];
	xSafe[safeid][safe_Sure] = SAFE_COOLDOWN_TIME * 60;
	xSafe[safeid][safe_Durum] = 3;
	format(str, sizeof(str), "Bu kasa soyuldu!\nTekrar soymak için beklenecek süre: {F0AE0F}%s", TimeConvert(xSafe[safeid][safe_Sure]));
	xSafe[safeid][safe_Label] = Create3DTextLabel(str, -1, xSafe[safeid][safe_Pos][0], xSafe[safeid][safe_Pos][1], xSafe[safeid][safe_Pos][2]+1, 100, 0);
	xSafe[safeid][safe_Timer] = SetTimerEx("safe_SureAzalt", 1000, true, "d", safeid);
	return 1;
}

forward safe_SureAzalt(safeid);
public safe_SureAzalt(safeid)
{
	xSafe[safeid][safe_Sure]--;
	new str[128];
	format(str, sizeof(str), "Bu kasa soyuldu!\nTekrar soymak için beklenecek süre: {F0AE0F}%s", TimeConvert(xSafe[safeid][safe_Sure]));
	Update3DTextLabelText(xSafe[safeid][safe_Label], -1, str);
	
	if(xSafe[safeid][safe_Sure] <= 0)
	{
		Delete3DTextLabel(xSafe[safeid][safe_Label]);
		DestroyObject(xSafe[safeid][safe_BosObj]);
		xSafe[safeid][safe_Obj] = CreateObject(2332, xSafe[safeid][safe_Pos][0], xSafe[safeid][safe_Pos][1], xSafe[safeid][safe_Pos][2], 0.0, 0.0, xSafe[safeid][safe_Pos][3]);
		xSafe[safeid][safe_Durum] = 0;
	}
	return 1;
}

SavexSafe(safeid)
{
	new query[128];
	
	mysql_format(mysqlB, query, sizeof(query), "UPDATE `xRob_Safes` SET X=%f, Y=%f, Z=%f, A=%f WHERE ID=%d",
	xSafe[safeid][safe_Pos][0], xSafe[safeid][safe_Pos][1], xSafe[safeid][safe_Pos][2], xSafe[safeid][safe_Pos][3], safeid);
	mysql_query(mysqlB, query);
	return 1;
}

forward LoadxSafes();
public LoadxSafes()
{
	new rows = cache_num_rows();
	new id, loaded;
 	if(rows)
  	{
		while(loaded < rows)
		{
  			cache_get_value_name_int(loaded, "ID", id);
		    cache_get_value_name_float(loaded, "X", xSafe[id][safe_Pos][0]);
		    cache_get_value_name_float(loaded, "Y", xSafe[id][safe_Pos][1]);
		    cache_get_value_name_float(loaded, "Z", xSafe[id][safe_Pos][2]);
		    cache_get_value_name_float(loaded, "A", xSafe[id][safe_Pos][3]);

			xSafe[id][safe_Obj] = CreateObject(2332, xSafe[id][safe_Pos][0], xSafe[id][safe_Pos][1], xSafe[id][safe_Pos][2], 0.0, 0.0, xSafe[id][safe_Pos][3]);
			
			Iter_Add(xSafes, id);
			loaded++;
		}
	}
	printf("[xRobbery] %d kasa yuklendi.", loaded);
	return 1;
}

stock CreatexSafe(Float:x, Float:y, Float:z, Float:a)
{
	new id = Iter_Free(xSafes);
	xSafe[id][safe_Obj] = CreateObject(2332, x, y, z, 0.0, 0.0, a);
	xSafe[id][safe_Pos][0] = x;
	xSafe[id][safe_Pos][1] = y;
	xSafe[id][safe_Pos][2] = z;
	xSafe[id][safe_Pos][3] = a;
	
	new query[256];
	format(query, sizeof(query),"INSERT INTO `xRob_Safes` (`ID`,`X`,`Y`,`Z`,`A`) VALUES ('%d','%f','%f','%f','%f')",
	id, x, y, z, a);
	mysql_query(mysqlB, query);
	Iter_Add(xSafes, id);
	return id;
}

stock GetNearestSafeID(playerid)
{
	new Float:pos[2];
	foreach(new i : xSafes)
	{
		GetXYInFrontOfSafe(i, pos[0], pos[1], 0.7);
		if(IsPlayerInRangeOfPoint(playerid, 1, pos[0], pos[1], xSafe[i][safe_Pos][2])) return i;
	}
	return -1;
}

stock GetXYInFrontOfSafe(safeid, &Float:x, &Float:y, Float:distance)
{
	new Float:a;

	x = xSafe[safeid][safe_Pos][0];
	y = xSafe[safeid][safe_Pos][1];
	a = xSafe[safeid][safe_Pos][3];
	a += 180;

	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}

stock GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
	// Created by Y_Less

	new Float:a;

	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);

	if (GetPlayerVehicleID(playerid)) {
	    GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}

	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}

TimeConvert(time) { // Forum.sa-mp 'The_Gangstas'tan alýntýdýr.
    new minutes;
    new seconds;
    new string[128];
    if(time > 59){
        minutes = floatround(time/60);
        seconds = floatround(time - minutes*60);
        if(seconds>9)format(string,sizeof(string),"%d:%d",minutes,seconds);
        else format(string,sizeof(string),"%d:0%d",minutes,seconds);
    }
    else{
        seconds = floatround(time);
        if(seconds>9)format(string,sizeof(string),"0:%d",seconds);
        else format(string,sizeof(string),"0:0%d",seconds);
    }
    return string;
}

stock SetPlayerLookAt(playerid, Float:X, Float:Y) // Forum.sa-mp 'Write'dan aýntýdýr.
{
	new Float:Px, Float:Py, Float: Pa;
	GetPlayerPos(playerid, Px, Py, Pa);
	Pa = floatabs(atan((Y-Py)/(X-Px)));
	if (X <= Px && Y >= Py) Pa = floatsub(180, Pa);
	else if (X < Px && Y < Py) Pa = floatadd(Pa, 180);
	else if (X >= Px && Y <= Py) Pa = floatsub(360.0, Pa);
	Pa = floatsub(Pa, 90.0);
	if (Pa >= 360.0) Pa = floatsub(Pa, 360.0);
	SetPlayerFacingAngle(playerid, Pa);
}


/*
Kiler:

xSafe[sid][safe_BosObj][0] = CreateObject(19618, xSafe[sid][safe_Pos][0], xSafe[sid][safe_Pos][1], xSafe[sid][safe_Pos][2], 0.0, 0.0, xSafe[sid][safe_Pos][3]);
xSafe[sid][safe_BosObj][1] = CreateObject(19619, xSafe[sid][safe_Pos][0]-0.35, xSafe[sid][safe_Pos][1]+0.35, xSafe[sid][safe_Pos][2], 0.0, 0.0, xSafe[sid][safe_Pos][3]);
xSafe[sid][safe_ParaObj] = CreateObject(2005, xSafe[sid][safe_Pos][0], xSafe[sid][safe_Pos][1], xSafe[sid][safe_Pos][2], 0.0, 0.0, xSafe[sid][safe_Pos][3]);
MoveObject(xSafe[sid][safe_BosObj][1], xSafe[sid][safe_Pos][0]-0.2, xSafe[sid][safe_Pos][1]+0.45, xSafe[sid][safe_Pos][2], 1.0, 0.0, 0.0, xSafe[sid][safe_Pos][3]+250);
*/