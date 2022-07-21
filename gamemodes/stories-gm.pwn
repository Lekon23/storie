main() {}

#include <a_samp>

#include <a_mysql>
#include <foreach>
#include <mxdate>
#include <sscanf2>
#include <streamer>
#include <dc_cmd>
#include <md5>
#include <fmt>


#pragma warning disable 				239
#pragma warning disable 				214
#pragma warning disable 				213


#define MYSQL_HOST							"localhost"			// "176.31.233.153"
#define MYSQL_USER							"root"				 	// "gs159087"			 
#define MYSQL_PASS							""						 	// "RJhDwPijDaCs"	 
#define MYSQL_NAME							"stories_mode" 	// "gs159087"			 

#define MAX_PLAYER_PASSWORD			40
#define MAX_FACTIONS						15
#define MAX_WEATHER							10
#define MAX_FACTION_NAME				35
#define MAX_ADV_LENGTH					50

#define SCM                     SendClientMessage
#define SCMf                    SendClientMessagef
#define SCMAll                  SendClientMessageToAll
#define SCMAllf                 SendClientMessageToAllf
#define SAM											SendAdminMessage
#define SPD											ShowPlayerDialog
#define SPDf                    ShowPlayerDialogf

#define DIALOG_LOGIN						1
#define DIALOG_REGISTER_PASS		2
#define DIALOG_REGISTER_GENDER	3
#define DIALOG_REGISTER_FROM		4
#define DIALOG_REGISTER_FRIEND	5
#define DIALOG_REGISTER_PROMO		6
#define DIALOG_REGISTER_CITY		7
#define DIALOG_WELCOME					8
#define DIALOG_GOBACK						9
#define DIALOG_WRONG						10
#define DIALOG_STATS						11
#define DIALOG_NICK							12
#define DIALOG_BAN							14
#define DIALOG_NEWBAN						15

#define DIALOG_ALOGIN						13
#define DIALOG_AHELP						16
#define DIALOG_PM								17
#define DIALOG_MLEADER					18
#define DIALOG_MLEADER_WARNING	19
#define DIALOG_MLEADER_REMOVE		20

#define DIALOG_LMENU						21
#define DIALOG_LMENU_NAME				22
#define DIALOG_LMENU_ADVERT			23
#define DIALOG_LMENU_RANKS			24
#define DIALOG_LMENU_RANKS_1		25
#define DIALOG_LMENU_RANKS_2		26
#define DIALOG_LMENU_RANKS_3		27
#define DIALOG_LMENU_RANKS_4		28

#define SYSCOLOR								0xF5DEB3FF // Hello
#define PURPLE									0xC2A2DBFF // /me, /do
#define GRAY										0xDDDDDDFF // Notifications
#define LIGHTGREEN							0x99CC00FF // Admin chat
#define RED											0xF5512FFF // Punish
#define YELLOW									0xE9DA00FF // AO

#define INFINITY_HEALTH					0x7F800000


new dbHandle;

enum playerInfo {
	pId,
	pName[MAX_PLAYER_NAME],
	pPassword[MAX_PLAYER_PASSWORD],
	pAdminLvl,
	pAdminPassword[6],
	pMoney,
	pBank,
	pDonate,
	pPhone[24],
	pExp,
	pLvl,
	pHours,
	pGender,
	pSkin,
	bool:pGame,
	Float:pLastPosX,
	Float:pLastPosY,
	Float:pLastPosZ,
	pLastInt,
	pLastVW,
	Float:pSpawnPosX,
	Float:pSpawnPosY,
	Float:pSpawnPosZ,
	Float:pSpawnDeg,
	pCity[10],
	pLastTime,
	pWarns,
	pRegIp[16],
	pLastIp[16],
	pReferal[MAX_PLAYER_NAME],
	pMail[50],
	pWanted,
	pVip,
	pFaction,
	pRank,
	pLeader,
	pJob,
	Float:pHp,
	Float:pArm,
}

enum factionInfo {
	fId,
	fName[MAX_FACTION_NAME],
	fLeader[MAX_PLAYER_NAME],
	fColor[20],
	fAdvert[MAX_ADV_LENGTH],
	fDeputyRank,
	fRanksNum,
	fRanks[200],
}

new allPlayers[MAX_PLAYERS][playerInfo];
new allFactions[MAX_FACTIONS][factionInfo];
new factionsRanks[MAX_FACTIONS][15][24];

new factions_list[MAX_FACTIONS+1][MAX_FACTION_NAME];

new ls_zone1, ls_zone2, ls_zone3, sf_zone1, sf_zone2, sf_zone3, sf_zone4, sf_zone5, lv_zone1, lv_zone2, lv_zone3, lv_zone4;

new Text:TdCity[3];
new Text:TdSkin[3];
new Text:TdLogo;

new spawn_cords[3][4] = {{1613.5215, -2328.9072, 13.5469, 88.7682}, 
												 {-1405.4496, -312.1926, 14.1484, 90.0},
												 {1679.0756, 1447.5276, 10.7746, 271.5015}};


new admins[7][50] = {"{C1C2C3}Игрок{ffffff}", 
										 "{00AEE4}Мл. Администратор{ffffff}", 
										 "{E6D700}Администратор{ffffff}", 
										 "{6666FF}Старший Администратор{ffffff}", 
										 "{019223}Зам. Гл. Администратора{ffffff}", 
										 "{019223}Главный Администор{ffffff}", 
										 "{fc0000}Основатель{ffffff}"};

new admins_ncolor[7][50] = {"Игрок", 
													  "Мл. Администратор", 
														"Администратор", 
														"Старший Администратор", 
														"Зам. Гл. Администратора",
														"Главный Администор", 
														"Основатель"};

new admin_passwords[6] = {57739, 36116, 51032, 36905, 69861, 88567};

new admin_zone[4] = {3, Float:-2638.82, Float:1407.33, Float:906.46}; // Jizzy

new job_list[3][20] = {"Безработный", "Грузчик", "Дальнобойщик"};

new weather_list[3][10] = {{10, 8, 2, 5, 5, 15, 2, 10, 5, 2}, 
													 {8, 10, 10, 15, 9, 9, 5, 5, 15, 8}, 
													 {25, 18, 5, 17, 10, 10, 19, 8, 8, 5}};

new weather_ls, weather_sf, weather_lv;


forward CheckPlayer(playerid);
forward CheckAdmin(playerid);
forward ProxDetector(Float:radi, playerid, string[],col);
forward SendAdminMessage(msg[], color);
forward KickWithDelay(playerid);
forward UpdateTime();
forward UpdateWather();
forward PayDay();
forward BanUser(playerid, type, btime, reason[]);
forward CheckBan(playerid);
forward UpdatePlayer(playerid);


public OnGameModeInit()
{
	SetGameModeText("Stories GM");
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	MySQLConnect();

	DisableInteriorEnterExits();
	ManualVehicleEngineAndLights();
	AllowInteriorWeapons(1);
	EnableStuntBonusForAll(0);
	ShowPlayerMarkers(0);
	SetNameTagDrawDistance(10.0);

	ls_zone1 = CreateDynamicRectangle(183, -3000, 3000, 464);
	ls_zone2 = CreateDynamicRectangle(-630, -353, 183, 464);
	ls_zone3 = CreateDynamicRectangle(-309, -1989, 184, -353);

	sf_zone1 = CreateDynamicRectangle(-3000, -3000, -1892, 2040);
	sf_zone2 = CreateDynamicRectangle(-1891, -3000, -1161, 1552);
	sf_zone3 = CreateDynamicRectangle(-1161, -3000, -622, 558);
	sf_zone4 = CreateDynamicRectangle(-622, -3000, -309, -353);
	sf_zone5 = CreateDynamicRectangle(-309, -3000, 179, -1989);

	lv_zone1 = CreateDynamicRectangle(-3000, 2040, 3000, 3000);
	lv_zone2 = CreateDynamicRectangle(-1161, 558, 3000, 2040);
	lv_zone3 = CreateDynamicRectangle(-619.0625, 464, 3000, 558);
	lv_zone4 = CreateDynamicRectangle(-1897, 1552, -1161, 2040);

	new h, m, s;

	gettime(h, m, s);

	SetWorldTime(h);
	SetWeather(3);

	weather_ls = weather_list[0][random(MAX_WEATHER)];
	weather_sf = weather_list[1][random(MAX_WEATHER)];
	weather_lv = weather_list[2][random(MAX_WEATHER)];

	SetTimer("UpdateTime", 1000*60, true);
	SetTimer("UpdateWather", 1000*60*20, true);

	GetFactionInfo();

	return 1;
}

public OnGameModeExit()
{
	foreach(Player, i) SavePlayer(i);

	mysql_close(dbHandle);

	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	if (!allPlayers[playerid][pGame]) {
		ClearChat(playerid);

		GetPlayerName(playerid, allPlayers[playerid][pName], MAX_PLAYER_NAME);
		CheckBan(playerid);

		if (CheckBan(playerid)) {
			if (CheckRoleplayName(playerid)) {
				TdLogo = TextDrawCreate(42.999996, 425.600006, "GTA-STORIES.RU");
				TextDrawLetterSize(TdLogo, 0.3, 1.3);
				TextDrawTextSize(TdLogo, 1280.000000, 1280.000000);
				TextDrawAlignment(TdLogo, 1);
				TextDrawColor(TdLogo, 0xBB0000FF);
				TextDrawSetShadow(TdLogo, 2);
				TextDrawSetOutline(TdLogo, 1);
				TextDrawBackgroundColor(TdLogo, 51);
				TextDrawFont(TdLogo, 2);
				TextDrawSetProportional(TdLogo, 1);

				TextDrawShowForPlayer(playerid, TdLogo);


				SCM(playerid, SYSCOLOR, "Добро пожаловать на Stories GTA, надеемся, что вы хорошо проведете время у нас!");

				SetPlayerPos(playerid, 0.0, 0.0, 0.0);
				SetPlayerCameraPos(playerid, 0.0, 0.0, 0.0);
				SetPlayerCameraLookAt(playerid, playerid, 0.0, 0.0, 0.0);

				TogglePlayerSpectating(playerid, 1);

				new queryString[250];

				format(queryString, sizeof(queryString), "SELECT * FROM `users` WHERE `name`='%s'", allPlayers[playerid][pName]);
				return mysql_tquery(dbHandle, queryString, "CheckPlayer", "i", playerid);
			}	
		}
	} 
	
	if (allPlayers[playerid][pGame]) {
		SetSpawnInfo(playerid, 0, allPlayers[playerid][pSkin], Float:allPlayers[playerid][pSpawnPosX], Float:allPlayers[playerid][pSpawnPosY], Float:allPlayers[playerid][pSpawnPosZ], 90.0, 0, 0, 0, 0, 0, 0);
		return SpawnPlayer(playerid);
	}

	return 1;
}

public OnPlayerConnect(playerid)
{
	ClearVars(playerid);
	SetPVarInt(playerid, "wrong_pass", 6);
	SetPlayerColor(playerid, 0);

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if (GetPVarInt(playerid, "plveh") != 0) {
		DestroyVehicle(GetPVarInt(playerid, "plveh"));
		SetPVarInt(playerid, "plveh", 0);
	}


	if (GetPVarInt(playerid, "recontarget") != -1) {
		new aid = GetPVarInt(playerid, "recontarget");

		TogglePlayerSpectating(aid, 0);
		SetPlayerVirtualWorld(aid, 0);
		SetPlayerInterior(aid, 0);

		GameTextForPlayer(aid, "PLAYER ~r~DISCONNECT", 1000, 5);

		SetPVarInt(aid, "recon", -1);
	}

	if (GetPVarInt(playerid, "recon") != -1) {
		new pid = GetPVarInt(playerid, "recon");

		SetPVarInt(pid, "recontarget", -1);
	}

	SavePlayer(playerid);
	ClearVars(playerid);

	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerSkin(playerid, allPlayers[playerid][pSkin]);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	GivePlayerMoney(playerid, 100);
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) 
{
	switch (dialogid) {
		case DIALOG_LOGIN: {
			if (!response) return SPD(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Авторизация", "Этот аккаунт уже зарегистрирован.\nЕсли вы являетесь его владельцем введите пароль ниже.\n\nЕсли вы введете неверный пароль более 5-ти раз ваш IP адрес будет заблокирован!", "Войти", "");
			if (strlen(inputtext) < 3) return SPD(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Авторизация", "Этот аккаунт уже зарегистрирован.\nЕсли вы являетесь его владельцем введите пароль ниже.\n\nЕсли вы введете неверный пароль более 5-ти раз ваш IP адрес будет заблокирован!", "Войти", "");
			if (GetPVarInt(playerid, "wrong_pass") <= 1) return BanUser(playerid, 1, 600, "Ввод неверного пароля более 5-ти раз.");
			if (!strcmp(allPlayers[playerid][pPassword], MD5_Hash(inputtext))) if (strlen(inputtext) > 3) return LoadPlayer(playerid);

			new msg[50];

			SetPVarInt(playerid, "wrong_pass", GetPVarInt(playerid, "wrong_pass") -1);
			format(msg, sizeof(msg), "Неверный пароль. Осталось попыток: %d", GetPVarInt(playerid, "wrong_pass"));
			SPD(playerid, DIALOG_WRONG, DIALOG_STYLE_MSGBOX, "Неверный пароль", msg, "Закрыть", "");
		}

		case DIALOG_REGISTER_PASS: {
			if (response) {
				if (strlen(inputtext) > 3) {
					if (strlen(inputtext) > 24) {
						SCM(playerid, GRAY, "Вы ввели слишком длинный пароль!");
						SPD(playerid, DIALOG_REGISTER_GENDER, DIALOG_STYLE_INPUT, "Регистрация", "Приветствуем вас на нашем проекте. Ваш ник свободен для регистрации.\n\nУкажите ниже пароль для аккаунта.", "Далее", "Выход");
					}

					strmid(allPlayers[playerid][pPassword], inputtext, 0, strlen(inputtext));

					SPD(playerid, DIALOG_REGISTER_GENDER, DIALOG_STYLE_MSGBOX, "Регистрация", "Для продолжения регистрации выберите пол для персонажа.", "Мужской", "Женский");

				} else {
					SCM(playerid, GRAY, "Вы ввели слишком короткий пароль!");
					SPD(playerid, DIALOG_REGISTER_GENDER, DIALOG_STYLE_INPUT, "Регистрация", "Приветствуем вас на нашем проекте. Ваш ник свободен для регистрации.\n\nУкажите ниже пароль для аккаунта.", "Далее", "Выход");
				}
			}
		}

		case DIALOG_REGISTER_GENDER: {
			if (response) {
				allPlayers[playerid][pGender] = 1;
				SPD(playerid, DIALOG_REGISTER_FROM, DIALOG_STYLE_LIST, "Откуда вы узнали о нашем проекте?", "Я не хочу говорить об этом вам\nРеклама ВКонтакте\nРеклама YouTube\nРеклама в мониторингах\nРеклама в других местах\nНашел сервер во вкладке hosted\nЯ здесь по совету друзей\nЭто не мой первый аккаунт\nМоего варианта нет в списке", "Выбрать", "");
			
			} else {
				allPlayers[playerid][pGender] = 1;
				SPD(playerid, DIALOG_REGISTER_FROM, DIALOG_STYLE_LIST, "Откуда вы узнали о нашем проекте?", "Я не хочу говорить об этом вам\nРеклама ВКонтакте\nРеклама YouTube\nРеклама в мониторингах\nРеклама в других местах\nНашел сервер во вкладке hosted\nЯ здесь по совету друзей\nЭто не мой первый аккаунт\nМоего варианта нет в списке", "Выбрать", "");
			} 
		}

		case DIALOG_REGISTER_FROM: {
			if (!response) {
				SPD(playerid, DIALOG_REGISTER_FROM, DIALOG_STYLE_LIST, "Откуда вы узнали о нашем проекте?", "Я не хочу говорить об этом вам\nРеклама ВКонтакте\nРеклама YouTube\nРеклама в мониторингах\nРеклама в других местах\nНашел сервер во вкладке hosted\nЯ здесь по совету друзей\nЭто не мой первый аккаунт\nМоего варианта нет в списке", "Выбрать", "");
			
			} else {
				SPD(playerid, DIALOG_REGISTER_FRIEND, DIALOG_STYLE_INPUT, "Укажите пригласившего игрока", "Здесь вы можете указать ник игрока, пригласившего вас на сервер. Когда вы отыграете 24 часа он получит 50.000$.", "Ввод", "Пропуск");
			}
		}

		case DIALOG_REGISTER_FRIEND: {
			strmid(allPlayers[playerid][pReferal], inputtext, 0, strlen(inputtext));

			if (response) SPD(playerid, DIALOG_REGISTER_PROMO, DIALOG_STYLE_INPUT, "Промокод", "Здесь вы можете ввести промокод от ютубера или с рекламной акции.", "Ввод", "Пропуск");
			else SPD(playerid, DIALOG_REGISTER_PROMO, DIALOG_STYLE_INPUT, "Промокод", "Здесь вы можете ввести промокод от ютубера или с рекламной акции.", "Ввод", "Пропуск");
		}

		case DIALOG_REGISTER_PROMO: {
			if (response) {
				// TODO система промокодов
			}

			CityChose(playerid);
		}

		case DIALOG_GOBACK: {
			if (response) {
				SetPlayerPos(playerid, Float:allPlayers[playerid][pLastPosX], Float:allPlayers[playerid][pLastPosY], Float:allPlayers[playerid][pLastPosZ]);
				SetPlayerVirtualWorld(playerid, allPlayers[playerid][pLastVW]);
				SetPlayerInterior(playerid, allPlayers[playerid][pLastInt]);
			}
		}

		case DIALOG_WRONG: {
			if (response || !response) SPD(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Авторизация", "Этот аккаунт уже зарегистрирован.\nЕсли вы являетесь его владельцем введите пароль ниже.\n\nЕсли вы введете неверный пароль более 5-ти раз ваш IP адрес будет заблокирован!", "Войти", "");
		}

		case DIALOG_ALOGIN: {
			if (!response) return 0;
			if (strlen(inputtext) < 3) return SPD(playerid, DIALOG_ALOGIN, DIALOG_STYLE_PASSWORD, "Авторизация в админку", "Добро пожаловать, введите свой админ-пароль ниже для получения\nправ администратора. Без ввода пароля вам будут недоступны\nфункции администратора.", "Войти", "");
			if (!strcmp(allPlayers[playerid][pAdminPassword], inputtext)) if (strlen(inputtext) > 3) {
				new msg[100];

				format(msg, sizeof(msg), "%s %s вошел в систему администрирования.", admins[allPlayers[playerid][pAdminLvl]], allPlayers[playerid][pName]);
				SetPVarInt(playerid, "aduty", 1);
				SCM(playerid, GRAY, "Вы подтвердили админ-права.");
				return SAM(msg, -1);
			}
		}

		case DIALOG_MLEADER: {
			new pid = GetPVarInt(playerid, "cand");

			if (allFactions[listitem][fLeader] != EOS) { 
				SetPVarInt(playerid, "cand_faction", listitem);

				return SPDf(playerid, DIALOG_MLEADER_WARNING, DIALOG_STYLE_MSGBOX, 
				"Пост лидера", "Заменить", "Отмена", "Пост лидера данной фракции занимает %s, вы хотите снять\nего и назначить %s?", 
				allFactions[listitem][fLeader], allPlayers[pid][pName]);
			}

			else MakeLeader(playerid, pid, listitem);
		}

		case DIALOG_MLEADER_WARNING: {
			if (response) {
				new pid = GetPVarInt(playerid, "cand");
				new fid = GetPVarInt(playerid, "cand_faction");

				MakeLeader(playerid, pid, fid);
			}
		}


		case DIALOG_LMENU: {
			if (response) {
				switch (listitem) {
					case 0: return SPDf(playerid, DIALOG_LMENU_NAME, DIALOG_STYLE_INPUT, "Название фракции", "Ввести", "Отмена", "\
					Текущее название фракции: %s\nЕсли вы хотите изменить название - введите ниже новое название фракции.", 
					factions_list[allPlayers[playerid][pFaction]]);

					case 1: return SPDf(playerid, DIALOG_LMENU_ADVERT, DIALOG_STYLE_INPUT, "Объявление фракции", "Ввести", "Отмена", "\
					Текущее объявление фракции: %s\nЕсли вы хотите изменить объявление - введите ниже новое объявление фракции.", 
					allFactions[allPlayers[playerid][pFaction]-1][fAdvert]);

					case 2: return SPDf(playerid, DIALOG_LMENU_RANKS, DIALOG_STYLE_LIST, "Управление рангами", "Изменить", "Закрыть", "\
					Количество рангов: %d\n\
					Ранг заместителя: %d\n\
					Управление названиями рангов\n", allFactions[allPlayers[playerid][pFaction]-1][fRanksNum],
					allFactions[allPlayers[playerid][pFaction]-1][fDeputyRank]);
				}
			}
		}

		case DIALOG_LMENU_NAME: {
			if (response) {
				if (strlen(inputtext) < 3) return SCM(playerid, GRAY, "Название фракции должно быть длиннее 3-х символов.");
				if (strlen(inputtext) > MAX_FACTION_NAME) return SCM(playerid, GRAY, "Название фракции не может быть длинее 36-ти сиволов.");

				strmid(factions_list[allPlayers[playerid][pFaction]], inputtext, 0, strlen(inputtext));
				strmid(allFactions[allPlayers[playerid][pFaction]-1][fName], inputtext, 0, strlen(inputtext));

				new queryString[250], msg[128];

				format(queryString, sizeof(queryString), "UPDATE `factions` SET `name` = '%s' WHERE `factions`.`id` = %d",
				inputtext, allPlayers[playerid][pFaction]);

				mysql_query(dbHandle, queryString, false);

				SCMf(playerid, YELLOW, "Вы изменили название фракции на %s.", inputtext);

				format(msg, sizeof(msg), "Лидер %s изменил название фракции на %s.", 
				allPlayers[playerid][pName], inputtext);

				return SAM(msg, YELLOW);
			}

			return SPD(playerid, DIALOG_LMENU, DIALOG_STYLE_LIST, "Панель лидера", "\
				Название фракции\n\
				Редактировать объявление\n\
				Управление рангами\n\
				Управление автопарком", "Изменить", "Закрыть");
		}

		case DIALOG_LMENU_ADVERT: {
			if (response) {
				if (strlen(inputtext) < 3) return SCM(playerid, GRAY, "Объявление фракции должно быть длиннее 3=х символов.");
				if (strlen(inputtext) > MAX_ADV_LENGTH) return SCM(playerid, GRAY, "Объявление фракции не может быть длинее 50-ти сиволов.");

				strmid(allFactions[allPlayers[playerid][pFaction]-1][fAdvert], inputtext, 0, strlen(inputtext));

				new queryString[250];

				format(queryString, sizeof(queryString), "UPDATE `factions` SET `advert` = '%s' WHERE `factions`.`id` = %d",
				inputtext, allPlayers[playerid][pFaction]);

				mysql_query(dbHandle, queryString, false);

				return SCM(playerid, YELLOW, "Вы изменили объявляение фракции фракции.");
			}

			return SPD(playerid, DIALOG_LMENU, DIALOG_STYLE_LIST, "Панель лидера", "\
				Название фракции\n\
				Редактировать объявление\n\
				Управление рангами\n\
				Управление автопарком", "Изменить", "Закрыть");
		}

		case DIALOG_LMENU_RANKS: {
			if (response) {
				new fid = allPlayers[playerid][pFaction]-1;

				switch(listitem) {
					case 0: return SPDf(playerid, DIALOG_LMENU_RANKS_1, DIALOG_STYLE_INPUT, "Количество рангов", "Ввести", "Отмена", "\
					Текущее количество рангов: %d\nЕсли вы хотите изменить количество - введите ниже новое количество рангов.", allFactions[fid][fRanksNum]);

					case 1: return SPDf(playerid, DIALOG_LMENU_RANKS_2, DIALOG_STYLE_INPUT, "Ранг заместителя", "Ввести", "Отмена", "\
					Текущий ранг заместителя: %d\nЕсли вы хотите изменить ранг - введите ниже новый ранг заместителя.", allFactions[fid][fDeputyRank]);

					case 2: {
						new ranks[200] = "";

						for (new i = 0; i < allFactions[fid][fRanksNum]; i++) {
							strcat(ranks, factionsRanks[fid][i]);
							strcat(ranks, "\n");
						}

						SPD(playerid, DIALOG_LMENU_RANKS_3, DIALOG_STYLE_LIST, "Изменение названий рангов", ranks, "Изменить", "Закрыть");
					}
				}
			} else return SPD(playerid, DIALOG_LMENU, DIALOG_STYLE_LIST, "Панель лидера", "\
				Название фракции\n\
				Редактировать объявление\n\
				Управление рангами\n\
				Управление автопарком", "Изменить", "Закрыть");
		}

		case DIALOG_LMENU_RANKS_1: {
			if (response) {
				if (strval(inputtext) < 1) return SCM(playerid, GRAY, "Количество рангов фракции должно быть больше одного."); 
				if (strval(inputtext) > 15) return SCM(playerid, GRAY, "Количество рангов фракции должно быть меньше 15-ти."); 

				new fid = allPlayers[playerid][pFaction]-1;

				allFactions[fid][fRanksNum] = strval(inputtext);

				if (allFactions[fid][fDeputyRank] > strval(inputtext)) allFactions[fid][fDeputyRank] = strval(inputtext);
			
				new queryString[250];

				format(queryString, sizeof(queryString), "UPDATE `factions` SET `ranks_num` = %d WHERE `factions`.`id` = %d", strval(inputtext), fid+1);
				mysql_query(dbHandle, queryString, false);

				SCMf(playerid, YELLOW, "Вы установили количество рангов во фракции: %d.", allFactions[fid][fRanksNum]);
			}

			return SPDf(playerid, DIALOG_LMENU_RANKS, DIALOG_STYLE_LIST, "Управление рангами", "Изменить", "Закрыть", "\
				Количество рангов: %d\n\
				Ранг заместителя: %d\n\
				Управление названиями рангов\n", allFactions[allPlayers[playerid][pFaction]-1][fRanksNum],
				allFactions[allPlayers[playerid][pFaction]-1][fDeputyRank]);
		}

		case DIALOG_LMENU_RANKS_2: {
			if (response) {
				if (strval(inputtext) < 1) return SCM(playerid, GRAY, "Ранг заместителя не может быть меньше одного."); 
				if (strval(inputtext) > 15) return SCM(playerid, GRAY, "Ранг заместителя не может быть больше 15-ти."); 

				new fid = allPlayers[playerid][pFaction]-1;
				
				if (strval(inputtext) >= allFactions[fid][fRanksNum]) return SCM(playerid, GRAY, "Ранг заместителя не может быть больше количеста рангов.");

				allFactions[fid][fDeputyRank] = strval(inputtext);

				new queryString[250];

				format(queryString, sizeof(queryString), "UPDATE `factions` SET `deputy_rank` = %d WHERE `factions`.`id` = %d", strval(inputtext), fid+1);
				mysql_query(dbHandle, queryString, false);

				SCMf(playerid, YELLOW, "Вы установили ранг заместителя: %d.", allFactions[fid][fDeputyRank]);
			}

			return SPDf(playerid, DIALOG_LMENU_RANKS, DIALOG_STYLE_LIST, "Управление рангами", "Изменить", "Закрыть", "\
				Количество рангов: %d\n\
				Ранг заместителя: %d\n\
				Управление названиями рангов\n", allFactions[allPlayers[playerid][pFaction]-1][fRanksNum],
				allFactions[allPlayers[playerid][pFaction]-1][fDeputyRank]);
		}

		case DIALOG_LMENU_RANKS_3: {
			if (response) {
				new fid = allPlayers[playerid][pFaction]-1;

				for (new i = 0; i < allFactions[fid][fRanksNum]; i++) {
					if (listitem == i) {
						SPDf(playerid, DIALOG_LMENU_RANKS_4, DIALOG_STYLE_INPUT, "Управление рангом", "Ввести", "Отмена", "\
						Текущий ранг: %s\nЕсли вы хотите изменить ранг - введите ниже новое название ранга.", factionsRanks[fid][i]);
						SetPVarInt(playerid, "rank_num", i);
					}
				}
			} else SPDf(playerid, DIALOG_LMENU_RANKS, DIALOG_STYLE_LIST, "Управление рангами", "Изменить", "Закрыть", "\
				Количество рангов: %d\n\
				Ранг заместителя: %d\n\
				Управление названиями рангов\n", allFactions[allPlayers[playerid][pFaction]-1][fRanksNum],
				allFactions[allPlayers[playerid][pFaction]-1][fDeputyRank]);
		}

		case DIALOG_LMENU_RANKS_4: {
			new fid = allPlayers[playerid][pFaction]-1;
			new ranks[200], queryString[250+200];

			if (response) {
				if (strlen(inputtext) < 2) return SCM(playerid, GRAY, "Название ранга должно быть более 2-х символов."); 
				if (strlen(inputtext) > 24) return SCM(playerid, GRAY, "Название ранга должно быть меньше 25-ти символов.");

				new rank = GetPVarInt(playerid, "rank_num");

				strmid(factionsRanks[fid][rank], inputtext, 0, strlen(inputtext));

				for (new i = 0; i < 14; i++) {
					strcat(ranks, factionsRanks[fid][i]);
					strcat(ranks, ",");
				}

				format(queryString, sizeof(queryString), "UPDATE `factions` SET `ranks` = '%s' WHERE `factions`.`id` = %d", ranks, fid+1);
				mysql_query(dbHandle, queryString, false);

				SCMf(playerid, YELLOW, "Вы установили название ранга %d: %s.", rank+1, inputtext);
			}

			ranks = "";

			for (new i = 0; i < allFactions[fid][fRanksNum]; i++) {
				strcat(ranks, factionsRanks[fid][i]);
				strcat(ranks, "\n");
			}

			return SPD(playerid, DIALOG_LMENU_RANKS_3, DIALOG_STYLE_LIST, "Изменение названий рангов", ranks, "Изменить", "Закрыть");
		}
	}

	return 1;
}

public OnPlayerText(playerid, text[]) 
{
	if(GetPVarInt(playerid, "flood") > gettime()) {
		SendClientMessage(playerid, GRAY, "Не флудите!");
		return 0;
	}

	new str[128];

	if (allPlayers[playerid][pGender]) format(str, sizeof(str), "%s сказал: %s", allPlayers[playerid][pName], text);
	else format(str, sizeof(str), "%s сказала: %s", allPlayers[playerid][pName], text);

	ProxDetector(10.0, playerid, str, -1);
	SetPlayerChatBubble(playerid, text, -1, 7.0, 10000);

	SetPVarInt(playerid, "flood", gettime()+2);

	return 0;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid) 
{
	if (clickedid == TdCity[1]) {
		if (GetPVarInt(playerid, "city") < 3) SetPVarInt(playerid, "city", GetPVarInt(playerid, "city")+1);
		else SetPVarInt(playerid, "city", 1);
	}

	if (clickedid == TdCity[2]) {
		CancelSelectTextDraw(playerid);

		TextDrawHideForPlayer(playerid, TdCity[0]);
		TextDrawHideForPlayer(playerid, TdCity[1]);
		TextDrawHideForPlayer(playerid, TdCity[2]);

		if (GetPVarInt(playerid, "city") == 1) {
			allPlayers[playerid][pSpawnPosX] = Float:spawn_cords[GetPVarInt(playerid, "city")-1][0];
			allPlayers[playerid][pSpawnPosY] = Float:spawn_cords[GetPVarInt(playerid, "city")-1][1];
			allPlayers[playerid][pSpawnPosZ] = Float:spawn_cords[GetPVarInt(playerid, "city")-1][2];
			allPlayers[playerid][pSpawnDeg] = Float:spawn_cords[GetPVarInt(playerid, "city")-1][3];
			
			format(allPlayers[playerid][pCity], 10, "%s", "ls");
		}

		if (GetPVarInt(playerid, "city") == 2) {
			allPlayers[playerid][pSpawnPosX] = Float:spawn_cords[GetPVarInt(playerid, "city")-1][0];
			allPlayers[playerid][pSpawnPosY] = Float:spawn_cords[GetPVarInt(playerid, "city")-1][1];
			allPlayers[playerid][pSpawnPosZ] = Float:spawn_cords[GetPVarInt(playerid, "city")-1][2];
			allPlayers[playerid][pSpawnDeg] = Float:spawn_cords[GetPVarInt(playerid, "city")-1][3];

			format(allPlayers[playerid][pCity], 10, "%s", "sf");
		}

		if (GetPVarInt(playerid, "city") == 3) {
			allPlayers[playerid][pSpawnPosX] = Float:spawn_cords[GetPVarInt(playerid, "city")-1][0];
			allPlayers[playerid][pSpawnPosY] = Float:spawn_cords[GetPVarInt(playerid, "city")-1][1];
			allPlayers[playerid][pSpawnPosZ] = Float:spawn_cords[GetPVarInt(playerid, "city")-1][2];
			allPlayers[playerid][pSpawnDeg] = Float:spawn_cords[GetPVarInt(playerid, "city")-1][3];

			format(allPlayers[playerid][pCity], 10, "%s", "lv");
		}

		SkinChose(playerid);
	}

	if (clickedid == TdCity[0]) {
		if (GetPVarInt(playerid, "city") > 1) SetPVarInt(playerid, "city", GetPVarInt(playerid, "city")-1);
		else SetPVarInt(playerid, "city", 3);
	}

	if (clickedid == TdCity[0] || clickedid == TdCity[1]) {
		if (GetPVarInt(playerid, "city") == 1) {
			SetPlayerCameraPos(playerid, 1997.0424, -1299.7795, 93.8176);
			SetPlayerCameraLookAt(playerid, 1997.0424, -1299.7795, 93.8176);	
		}

		if (GetPVarInt(playerid, "city") == 2) {
			SetPlayerCameraPos(playerid, -2238.1655, 611.9241, 121.3173);
			SetPlayerCameraLookAt(playerid, -2238.1655, 611.9241, 121.3173);	
		}

		if (GetPVarInt(playerid, "city") == 3) {
			SetPlayerCameraPos(playerid, 2250.4556, 2339.5042, 58.8163);
			SetPlayerCameraLookAt(playerid, 2250.4556, 2339.5042, 58.8163);
		}
	}


	if (clickedid == TdSkin[1]) {
		if (GetPVarInt(playerid, "skin") < 8) SetPVarInt(playerid, "skin", GetPVarInt(playerid, "skin")+1);
		else SetPVarInt(playerid, "skin", 1);
	}

	if (clickedid == TdSkin[2]) {
		CancelSelectTextDraw(playerid);

		TextDrawHideForPlayer(playerid, TdSkin[0]);
		TextDrawHideForPlayer(playerid, TdSkin[1]);
		TextDrawHideForPlayer(playerid, TdSkin[2]);

		CreatePlayer(playerid);
	}

	if (clickedid == TdSkin[0]) {
		if (GetPVarInt(playerid, "skin") > 1) SetPVarInt(playerid, "skin", GetPVarInt(playerid, "skin")-1);
		else SetPVarInt(playerid, "skin", 8);
	}

	if (clickedid == TdSkin[0] || clickedid == TdSkin[1]) {
		new sa = GetPVarInt(playerid, "sa");
		DestroyActor(sa);

		if (allPlayers[playerid][pGender]) {
			if (GetPVarInt(playerid, "skin") == 1) { sa = CreateActor(18, 257.5, -41.6, 1002.02, 90); allPlayers[playerid][pSkin] = 18; }
			if (GetPVarInt(playerid, "skin") == 2) { sa = CreateActor(23, 257.5, -41.6, 1002.02, 90); allPlayers[playerid][pSkin] = 23; }
			if (GetPVarInt(playerid, "skin") == 3) { sa = CreateActor(188, 257.5, -41.6, 1002.02, 90); allPlayers[playerid][pSkin] = 188; }
			if (GetPVarInt(playerid, "skin") == 4) { sa = CreateActor(3, 257.5, -41.6, 1002.02, 90); allPlayers[playerid][pSkin] = 3; }
			if (GetPVarInt(playerid, "skin") == 5) { sa = CreateActor(35, 257.5, -41.6, 1002.02, 90); allPlayers[playerid][pSkin] = 35; }
			if (GetPVarInt(playerid, "skin") == 6) { sa = CreateActor(21, 257.5, -41.6, 1002.02, 90); allPlayers[playerid][pSkin] = 21; }
			if (GetPVarInt(playerid, "skin") == 7) { sa = CreateActor(30, 257.5, -41.6, 1002.02, 90); allPlayers[playerid][pSkin] = 30; }
			if (GetPVarInt(playerid, "skin") == 8) { sa = CreateActor(29, 257.5, -41.6, 1002.02, 90); allPlayers[playerid][pSkin] = 29; }
		}

		if (!allPlayers[playerid][pGender]) {
			if (GetPVarInt(playerid, "skin") == 1) { sa = CreateActor(56, 257.5, -41.6, 1002.02, 90); allPlayers[playerid][pSkin] = 18; }
			if (GetPVarInt(playerid, "skin") == 2) { sa = CreateActor(55, 257.5, -41.6, 1002.02, 90); allPlayers[playerid][pSkin] = 23; }
			if (GetPVarInt(playerid, "skin") == 3) { sa = CreateActor(41, 257.5, -41.6, 1002.02, 90); allPlayers[playerid][pSkin] = 188; }
			if (GetPVarInt(playerid, "skin") == 4) { sa = CreateActor(9, 257.5, -41.6, 1002.02, 90); allPlayers[playerid][pSkin] = 3; }
			if (GetPVarInt(playerid, "skin") == 5) { sa = CreateActor(11, 257.5, -41.6, 1002.02, 90); allPlayers[playerid][pSkin] = 35; }
			if (GetPVarInt(playerid, "skin") == 6) { sa = CreateActor(93, 257.5, -41.6, 1002.02, 90); allPlayers[playerid][pSkin] = 21; }
			if (GetPVarInt(playerid, "skin") == 7) { sa = CreateActor(151, 257.5, -41.6, 1002.02, 90); allPlayers[playerid][pSkin] = 30; }
			if (GetPVarInt(playerid, "skin") == 8) { sa = CreateActor(13, 257.5, -41.6, 1002.02, 90); allPlayers[playerid][pSkin] = 29; }
		}

		SetActorVirtualWorld(sa, 2147483645);
		SetPVarInt(playerid, "sa", sa);
	}

	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(GetPVarInt(playerid, "AFK") > 0) return SetPVarInt(playerid, "AFK", 0);

	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate) 
{
	if (oldstate == PLAYER_STATE_DRIVER) {
		if (GetPVarInt(playerid, "plveh") != 0) {
			DestroyVehicle(GetPVarInt(playerid, "plveh"));
			SetPVarInt(playerid, "plveh", 0);
		}
	}

	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) 
{
	if (newkeys == 1) SwitchEngine(playerid); // ctrl
	if (newkeys == 512) SwitchLight(playerid); // 2
	if (newkeys == 2048) SwitchBonnet(playerid); // Num 8
	if (newkeys == 4096) SwitchBoot(playerid); // Num 2

	if (newkeys == KEY_SECONDARY_ATTACK) {
		if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK) {
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		}
	}

	return 1;
}

public OnPlayerEnterDynamicArea(playerid, areaid) {
	if (areaid == ls_zone1 || areaid == ls_zone2 || areaid == ls_zone3) {
		SetPVarInt(playerid, "location", 1);
		SetPlayerWeather(playerid, weather_ls);
	} 

	if (areaid == sf_zone1 || areaid == sf_zone2 || areaid == sf_zone3 ||
	areaid == sf_zone4 || areaid == sf_zone5) {
		SetPVarInt(playerid, "location", 2);
		SetPlayerWeather(playerid, weather_sf);
	}

	if (areaid == lv_zone1 || areaid == lv_zone2 || areaid == lv_zone3 || areaid == lv_zone4) {
		SetPVarInt(playerid, "location", 3);
		SetPlayerWeather(playerid, weather_lv);
	}

	return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ) 
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 0) {
			if (GetPVarInt(playerid, "aduty")) {
				new veh = GetPlayerVehicleID(playerid);

				if (veh > 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) SetVehiclePos(veh, Float:fX, Float:fY, Float:fZ);
				else SetPlayerPos(playerid, Float:fX, Float:fY, Float:fZ);

				SCM(playerid, GRAY, "Вы телепортировались по метке.");
			}
		}
	}

	return 1;
}


// ==========================================================================================================================
// CUSTOM
// ==========================================================================================================================


stock MySQLConnect() 
{
	dbHandle = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASS, MYSQL_NAME);

	if (mysql_errno() != 0) print("don't connect to database");

	else {
		print("Connect to database");

		mysql_set_charset("cp1251");
		mysql_query(dbHandle, "SET NAMES cp1251;", false);
		mysql_query(dbHandle, "SET SESSION character_set_server='utf8';", false);
	}

	return 1;
}

stock ClearVars(playerid)
{
	allPlayers[playerid][pId] = 0;
	allPlayers[playerid][pName] = EOS;
	allPlayers[playerid][pPassword] = EOS;
	allPlayers[playerid][pAdminLvl] = 0;
	allPlayers[playerid][pAdminPassword] = EOS;
	allPlayers[playerid][pMoney] = 0;
	allPlayers[playerid][pBank] = 0;
	allPlayers[playerid][pDonate] = 0;
	allPlayers[playerid][pPhone] = EOS;
	allPlayers[playerid][pExp] = 0;
	allPlayers[playerid][pLvl] = 0;
	allPlayers[playerid][pGender] = 0;
	allPlayers[playerid][pSkin] = 0;
	allPlayers[playerid][pGame] = false;
	allPlayers[playerid][pLastPosX] = 0.0;
	allPlayers[playerid][pLastPosY] = 0.0;
	allPlayers[playerid][pLastPosZ] = 0.0;
	allPlayers[playerid][pLastInt] = 0;
	allPlayers[playerid][pLastVW] = 0;
	allPlayers[playerid][pSpawnPosX] = 0.0;
	allPlayers[playerid][pSpawnPosY] = 0.0;
	allPlayers[playerid][pSpawnPosZ] = 0.0;
	allPlayers[playerid][pSpawnDeg] = 0.0;
	allPlayers[playerid][pCity] = EOS;
	allPlayers[playerid][pLastTime] = 0;
	allPlayers[playerid][pHours] = 0;
	allPlayers[playerid][pWarns] = 0;
	allPlayers[playerid][pRegIp] = EOS;
	allPlayers[playerid][pLastIp] = EOS;
	allPlayers[playerid][pReferal] = EOS;
	allPlayers[playerid][pMail] = EOS;
	allPlayers[playerid][pWanted] = 0;
	allPlayers[playerid][pVip] = 0;
	allPlayers[playerid][pFaction] = 0;
	allPlayers[playerid][pRank] = 0;
	allPlayers[playerid][pLeader] = 0;
	allPlayers[playerid][pJob] = 0;
	allPlayers[playerid][pHp] = 0.0;
	allPlayers[playerid][pArm] = 0.0;
	
	return 1;
}

stock CityChose(playerid) 
{
	TdCity[0] = TextDrawCreate(250, 415, "<<<");
	TextDrawLetterSize(TdCity[0], 0.449999, 1.600000);
	TextDrawTextSize(TdCity[0], 288.666656, 17.007406);
	TextDrawAlignment(TdCity[0], 1);
	TextDrawColor(TdCity[0], -1);
	TextDrawUseBox(TdCity[0], true);
	TextDrawBoxColor(TdCity[0], 1);
	TextDrawSetShadow(TdCity[0], 0);
	TextDrawSetOutline(TdCity[0], 1);
	TextDrawBackgroundColor(TdCity[0], 51);
	TextDrawFont(TdCity[0], 1);
	TextDrawSetProportional(TdCity[0], 1);
	TextDrawSetSelectable(TdCity[0], true);

	TdCity[1] = TextDrawCreate(358, 415, ">>>");
	TextDrawLetterSize(TdCity[1], 0.449999, 1.600000);
	TextDrawTextSize(TdCity[1], 374.666809, 22.814817);
	TextDrawAlignment(TdCity[1], 1);
	TextDrawColor(TdCity[1], -1);
	TextDrawUseBox(TdCity[1], true);
	TextDrawBoxColor(TdCity[1], 1);
	TextDrawSetShadow(TdCity[1], 0);
	TextDrawSetOutline(TdCity[1], 1);
	TextDrawBackgroundColor(TdCity[1], 51);
	TextDrawFont(TdCity[1], 1);
	TextDrawSetProportional(TdCity[1], 1);
	TextDrawSetSelectable(TdCity[1], true);

	TdCity[2] = TextDrawCreate(318.666748, 415, "‹‘ЂPAЏ’"); // ВЫБРАТЬ
	TextDrawLetterSize(TdCity[2], 0.449999, 1.600000);
	TextDrawTextSize(TdCity[2], 1951.665039, 47.288852);
	TextDrawAlignment(TdCity[2], 2);
	TextDrawColor(TdCity[2], -1);
	TextDrawUseBox(TdCity[2], true);
	TextDrawBoxColor(TdCity[2], 1);
	TextDrawSetShadow(TdCity[2], 0);
	TextDrawSetOutline(TdCity[2], 1);
	TextDrawBackgroundColor(TdCity[2], 51);
	TextDrawFont(TdCity[2], 1);
	TextDrawSetProportional(TdCity[2], 1);
	TextDrawSetSelectable(TdCity[2], true);


	TextDrawShowForPlayer(playerid, TdCity[0]);
	TextDrawShowForPlayer(playerid, TdCity[1]);
	TextDrawShowForPlayer(playerid, TdCity[2]);

	SelectTextDraw(playerid, 0xFFFFFFFF);

	SetPVarInt(playerid, "city", 1);

	SetPlayerCameraPos(playerid, 1997.0424, -1299.7795, 93.8176);
	SetPlayerCameraLookAt(playerid, 1997.0424, -1299.7795, 93.8176);	

	SPD(playerid, DIALOG_REGISTER_CITY, DIALOG_STYLE_MSGBOX, "Stories GTA", "В штате Сан-Андреас есть три города, выберите гроод для проживания из списка.", "Закрыть", "");

	return 1;
}

stock SkinChose(playerid) 
{
	TdSkin[0] = TextDrawCreate(250, 415, "<<<");
	TextDrawLetterSize(TdSkin[0], 0.449999, 1.600000);
	TextDrawTextSize(TdSkin[0], 288.666656, 17.007406);
	TextDrawAlignment(TdSkin[0], 1);
	TextDrawColor(TdSkin[0], -1);
	TextDrawUseBox(TdSkin[0], true);
	TextDrawBoxColor(TdSkin[0], 1);
	TextDrawSetShadow(TdSkin[0], 0);
	TextDrawSetOutline(TdSkin[0], 1);
	TextDrawBackgroundColor(TdSkin[0], 51);
	TextDrawFont(TdSkin[0], 1);
	TextDrawSetProportional(TdSkin[0], 1);
	TextDrawSetSelectable(TdSkin[0], true);

	TdSkin[1] = TextDrawCreate(358, 415, ">>>");
	TextDrawLetterSize(TdSkin[1], 0.449999, 1.600000);
	TextDrawTextSize(TdSkin[1], 374.666809, 22.814817);
	TextDrawAlignment(TdSkin[1], 1);
	TextDrawColor(TdSkin[1], -1);
	TextDrawUseBox(TdSkin[1], true);
	TextDrawBoxColor(TdSkin[1], 1);
	TextDrawSetShadow(TdSkin[1], 0);
	TextDrawSetOutline(TdSkin[1], 1);
	TextDrawBackgroundColor(TdSkin[1], 51);
	TextDrawFont(TdSkin[1], 1);
	TextDrawSetProportional(TdSkin[1], 1);
	TextDrawSetSelectable(TdSkin[1], true);

	TdSkin[2] = TextDrawCreate(318.666748, 415, "‹‘ЂPAЏ’"); // ВЫБРАТЬ
	TextDrawLetterSize(TdSkin[2], 0.449999, 1.600000);
	TextDrawTextSize(TdSkin[2], 1951.665039, 47.288852);
	TextDrawAlignment(TdSkin[2], 2);
	TextDrawColor(TdSkin[2], -1);
	TextDrawUseBox(TdSkin[2], true);
	TextDrawBoxColor(TdSkin[2], 1);
	TextDrawSetShadow(TdSkin[2], 0);
	TextDrawSetOutline(TdSkin[2], 1);
	TextDrawBackgroundColor(TdSkin[2], 51);
	TextDrawFont(TdSkin[2], 1);
	TextDrawSetProportional(TdSkin[2], 1);
	TextDrawSetSelectable(TdSkin[2], true);


	TextDrawShowForPlayer(playerid, TdSkin[0]);
	TextDrawShowForPlayer(playerid, TdSkin[1]);
	TextDrawShowForPlayer(playerid, TdSkin[2]);

	SelectTextDraw(playerid, 0xFFFFFFFF);


	SetPlayerCameraPos(playerid, 255, -41.65, 1002.5);
	SetPlayerCameraLookAt(playerid, 255, -41.65, 1002.5);	

	new sa;

	if (allPlayers[playerid][pGender]) sa = CreateActor(18, 257.5, -41.6, 1002.02, 90);
	if (!allPlayers[playerid][pGender]) sa = CreateActor(56, 257.5, -41.6, 1002.02, 90);

	SetActorVirtualWorld(sa, 2147483645);

	SetPVarInt(playerid, "skin", 1);
	SetPVarInt(playerid, "sa", sa);
	
	SetPlayerInterior(playerid, 14);
	SetPlayerVirtualWorld(playerid, 2147483645);

	// int etc

	return 1;
}

stock CreatePlayer(playerid) 
{
	new queryString[1000];

	GetPlayerIp(playerid, allPlayers[playerid][pLastIp], 16);

	strmid(allPlayers[playerid][pPassword], MD5_Hash(allPlayers[playerid][pPassword]), 0, strlen(MD5_Hash(allPlayers[playerid][pPassword])));

	format(queryString, sizeof(queryString), "\
	INSERT INTO `users` (`id`, `name`, `password`, `admin`, `admin_pass`, `money`, `bank`, `donate`, `phone`, `exp`, `lvl`, `hours`, \
	`gender`, `skin`, `lastPosX`, `lastPosY`, `lastPosZ`, `lastVW`, `lastInt`, `spawnPosX`, `spawnPosY`, `spawnPosZ`, `spawnDegree`, \
	`city`, `last_time`, `warns`, `regip`, `lastip`, `referal`, `mail`, `wanted`, `vip`, `faction`, `rank`, `leader`, `job`, `hp`, `arm`) \
	VALUES (NULL, '%s', '%s', '0', '', '0', '-1', '0', '', '0', '1', '0', '%d', '%d', '0.0', '0.0', '0.0', '0', '0', '%f', '%f', '%f', '%f', \
	'%s', '0', '0', '%s', '%s', '%s', 'test@mail.ru', '0', '0', '0', '0', '0', '0', '100.0', '0')",
	allPlayers[playerid][pName], allPlayers[playerid][pPassword], allPlayers[playerid][pGender], allPlayers[playerid][pSkin],
	allPlayers[playerid][pSpawnPosX], allPlayers[playerid][pSpawnPosY], allPlayers[playerid][pSpawnPosZ], allPlayers[playerid][pSpawnDeg], 
	allPlayers[playerid][pCity], allPlayers[playerid][pLastIp], allPlayers[playerid][pLastIp], allPlayers[playerid][pReferal]);

	mysql_query(dbHandle, queryString, false);

	LoadPlayer(playerid);
	SPD(playerid, DIALOG_WELCOME, DIALOG_STYLE_MSGBOX, "Stories GTA", "Добро пожаловать, надеемся, что вы хорошо проведете время на нашем проекте!", "Закрыть", "");

	return 1;
}

stock LoadPlayer(playerid) 
{
	new queryString[500];

	format(queryString, sizeof(queryString), "SELECT * FROM `users` WHERE `name` = '%s'", allPlayers[playerid][pName]);
	mysql_query(dbHandle, queryString, true);

	allPlayers[playerid][pGame] = true;

	cache_get_value_name_int(0, "id", allPlayers[playerid][pId]);
	cache_get_value_name_int(0, "admin", allPlayers[playerid][pAdminLvl]);
	cache_get_value_name(0, "admin_pass", allPlayers[playerid][pAdminPassword]);
	cache_get_value_name_int(0, "money", allPlayers[playerid][pMoney]);
	cache_get_value_name_int(0, "exp", allPlayers[playerid][pExp]);
	cache_get_value_name_int(0, "lvl", allPlayers[playerid][pLvl]);
	cache_get_value_name_int(0, "gender",	allPlayers[playerid][pGender]);
	cache_get_value_name_int(0, "skin", allPlayers[playerid][pSkin]);
	cache_get_value_name_float(0, "lastPosX", allPlayers[playerid][pLastPosX]);
	cache_get_value_name_float(0, "lastPosY", allPlayers[playerid][pLastPosY]);
	cache_get_value_name_float(0, "lastPosZ", allPlayers[playerid][pLastPosZ]);
	cache_get_value_name_int(0, "lastVW",	allPlayers[playerid][pLastVW]);
	cache_get_value_name_int(0, "lastInt", allPlayers[playerid][pLastInt]);
	cache_get_value_name_float(0, "spawnPosX", allPlayers[playerid][pSpawnPosX]);
	cache_get_value_name_float(0, "spawnPosY", allPlayers[playerid][pSpawnPosY]);
	cache_get_value_name_float(0, "spawnPosZ", allPlayers[playerid][pSpawnPosZ]);
	cache_get_value_name_float(0, "spawnDegree", allPlayers[playerid][pSpawnDeg]);
	cache_get_value_name(0, "city", allPlayers[playerid][pCity]);
	cache_get_value_name_int(0, "last_time", allPlayers[playerid][pLastTime]);
	cache_get_value_name_int(0, "bank", allPlayers[playerid][pBank]);
	cache_get_value_name_int(0, "donate", allPlayers[playerid][pDonate]);
	cache_get_value_name(0, "phone", allPlayers[playerid][pPhone]);
	cache_get_value_name_int(0, "hours", allPlayers[playerid][pHours]);
	cache_get_value_name_int(0, "warns", allPlayers[playerid][pWarns]);
	cache_get_value_name(0, "regip", allPlayers[playerid][pRegIp]);
	cache_get_value_name(0, "referal", allPlayers[playerid][pReferal]);
	cache_get_value_name(0, "mail", allPlayers[playerid][pMail]);
	cache_get_value_name_int(0, "wanted", allPlayers[playerid][pWanted]);
	cache_get_value_name_int(0, "vip", allPlayers[playerid][pVip]);
	cache_get_value_name_int(0, "faction", allPlayers[playerid][pFaction]);
	cache_get_value_name_int(0, "rank",	allPlayers[playerid][pRank]);
	cache_get_value_name_int(0, "leader",	allPlayers[playerid][pLeader]);
	cache_get_value_name_int(0, "job",	allPlayers[playerid][pJob]);
	cache_get_value_name_float(0, "hp", allPlayers[playerid][pHp]);
	cache_get_value_name_float(0, "arm", allPlayers[playerid][pArm]);

	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, allPlayers[playerid][pMoney]);
	SetPlayerScore(playerid, allPlayers[playerid][pLvl]);
	SetPlayerSkin(playerid, allPlayers[playerid][pSkin]);
	SetPlayerHealth(playerid, allPlayers[playerid][pHp]);
	SetPlayerArmour(playerid, allPlayers[playerid][pArm]);

	SetSpawnInfo(playerid, 0, allPlayers[playerid][pSkin], Float:allPlayers[playerid][pSpawnPosX], Float:allPlayers[playerid][pSpawnPosY], Float:allPlayers[playerid][pSpawnPosZ], Float:allPlayers[playerid][pSpawnDeg], 0, 0, 0, 0, 0, 0);

	TogglePlayerSpectating(playerid, 0);

	GetPlayerIp(playerid, allPlayers[playerid][pLastIp], 16);
	format(queryString, sizeof(queryString), "UPDATE `users` SET `lastip` = '%s' WHERE `users`.`id` = %d", allPlayers[playerid][pLastIp], allPlayers[playerid][pId]);
	mysql_query(dbHandle, queryString, false);

	format(queryString, sizeof(queryString), "SELECT * FROM `factions` WHERE `factions`.`leader` = '%s'", allPlayers[playerid][pName]);
	mysql_query(dbHandle, queryString, true);

	new rows;
	cache_get_row_count(rows);

	if (allPlayers[playerid][pLeader]) {
		if (!rows) {
			allPlayers[playerid][pFaction] = 0;
			allPlayers[playerid][pRank] = 0;
			allPlayers[playerid][pLeader] = 0;

			format(queryString, sizeof(queryString), "UPDATE `users` SET `rank` = 0, `faction` = 0, `leader` = 0  WHERE `users`.`id` = %d", 
			allPlayers[playerid][pId]);

			mysql_query(dbHandle, queryString, false);

			SCM(playerid, GRAY, "Вы были сняты с поста лидера.");
		}
	}

	if (allPlayers[playerid][pFaction]) {
		if (allPlayers[playerid][pRank] > allFactions[allPlayers[playerid][pFaction]-1][fRanksNum]) {
			new equality = allPlayers[playerid][pRank] - allFactions[allPlayers[playerid][pFaction]-1][fRanksNum];
			allPlayers[playerid][pRank] = allPlayers[playerid][pRank]-equality;

			format(queryString, sizeof(queryString), "UPDATE `users` SET `rank` = %d  WHERE `users`.`id` = %d", 
			allPlayers[playerid][pRank], allPlayers[playerid][pId]);

			mysql_query(dbHandle, queryString, false);
		}
	}

	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);
	SpawnPlayer(playerid);

	// ADMIN FUNCS

	if (allPlayers[playerid][pAdminLvl] > 0) SetPVarInt(playerid, "aduty", 0);
	if (allPlayers[playerid][pAdminLvl] > 0) SetPVarInt(playerid, "agm", 0);
	SetPVarInt(playerid, "recon", -1);
	SetPVarInt(playerid, "recontarget", -1);
	SetPVarInt(playerid, "plveh", 0);
	SetPVarInt(playerid, "flood", gettime());

	SetTimerEx("UpdatePlayer", 1000, true, "d", playerid);

	SetPlayerColor(playerid, -1);

	if (gettime()-allPlayers[playerid][pLastTime] <= 900) {
		SPD(playerid, DIALOG_GOBACK, DIALOG_STYLE_MSGBOX, "Stories GTA", "Вы хотите вернутся на место выхода?", "Да", "Нет");
	}

	return 1;
}

stock SavePlayer(playerid) 	
{
	if (allPlayers[playerid][pGame]) {
		new queryString[1000];

		GetPlayerPos(playerid, allPlayers[playerid][pLastPosX], allPlayers[playerid][pLastPosY], allPlayers[playerid][pLastPosZ]);
		GetPlayerSkin(allPlayers[playerid][pSkin]);

		if (GetPVarInt(playerid, "agm") == 1)	allPlayers[playerid][pHp] = 100.0;
		else GetPlayerHealth(playerid, Float:allPlayers[playerid][pHp]);

		GetPlayerArmour(playerid, Float:allPlayers[playerid][pArm]);
		allPlayers[playerid][pMoney] = GetPlayerMoney(playerid);
		allPlayers[playerid][pLvl] = GetPlayerScore(playerid);
		allPlayers[playerid][pLastTime] = gettime();
		allPlayers[playerid][pLastVW]	= GetPlayerVirtualWorld(playerid);
		allPlayers[playerid][pLastInt] = GetPlayerInterior(playerid);

		format(queryString, sizeof(queryString), "UPDATE `users` SET `name` = '%s', \
		`money` = '%d', `bank` = '%d', `donate` = '%d',`phone` = '%s', `exp` = '%d', `lvl` = '%d', `hours` = '%d', `gender` = '%d', \
		`skin` = '%d', `lastPosX` = '%f', `lastPosY` = '%f', `lastPosZ` = '%f', `lastVW` = '%d', `lastInt` = '%d', `spawnPosX` = '%f', \
		`spawnPosY` = '%f', `spawnPosZ` = '%f', `spawnDegree` = '%f',`city` = '%s', `last_time` = '%d', `warns` = '%d',\
		`mail` = '%s', `wanted` = '%d', `vip` = '%d', `faction` = '%d', `rank` = '%d', `leader` = '%d', `job` = '%d', `hp` = '%f', `arm` = '%f' \
		WHERE `users`.`id` = %d", allPlayers[playerid][pName], allPlayers[playerid][pMoney], allPlayers[playerid][pBank], allPlayers[playerid][pDonate], 
		allPlayers[playerid][pPhone], allPlayers[playerid][pExp], allPlayers[playerid][pLvl], allPlayers[playerid][pHours], 
		allPlayers[playerid][pGender], allPlayers[playerid][pSkin], allPlayers[playerid][pLastPosX], allPlayers[playerid][pLastPosY], 
		allPlayers[playerid][pLastPosZ], allPlayers[playerid][pLastVW], allPlayers[playerid][pLastInt], allPlayers[playerid][pSpawnPosX], 
		allPlayers[playerid][pSpawnPosY], allPlayers[playerid][pSpawnPosZ], allPlayers[playerid][pSpawnDeg], allPlayers[playerid][pCity], 
		allPlayers[playerid][pLastTime], allPlayers[playerid][pWarns], allPlayers[playerid][pMail], 
		allPlayers[playerid][pWanted], allPlayers[playerid][pVip], allPlayers[playerid][pFaction], allPlayers[playerid][pRank], 
		allPlayers[playerid][pLeader], allPlayers[playerid][pJob], allPlayers[playerid][pHp], allPlayers[playerid][pArm], allPlayers[playerid][pId]);

		mysql_query(dbHandle, queryString, false);
	}

	return 1;
}

stock GetFactionInfo() 
{
	new rows;
	factions_list[0] = "Нет организации";

	mysql_query(dbHandle, "SELECT * FROM `factions`", true);

	cache_get_row_count(rows);

	if (rows > 0) {
		for (new idx = 0; idx < rows; idx++) {
			cache_get_value_name_int(idx, "id", allFactions[idx][fId]);
			cache_get_value_name(idx, "name", allFactions[idx][fName]);
			cache_get_value_name(idx, "leader", allFactions[idx][fLeader]);
			cache_get_value_name(idx, "color", allFactions[idx][fColor]);
			cache_get_value_name(idx, "advert", allFactions[idx][fAdvert]);
			cache_get_value_name_int(idx, "deputy_rank", allFactions[idx][fDeputyRank]);
			cache_get_value_name_int(idx, "ranks_num", allFactions[idx][fRanksNum]);
			cache_get_value_name(idx, "ranks", allFactions[idx][fRanks]);

			strmid(factions_list[allFactions[idx][fId]], allFactions[idx][fName], 0, strlen(allFactions[idx][fName]));

			sscanf(allFactions[idx][fRanks], "p<,>s[24]s[24]s[24]s[24]s[24]s[24]s[24]s[24]s[24]s[24]s[24]s[24]s[24]s[24]s[24]", 
			factionsRanks[idx][0], factionsRanks[idx][1], factionsRanks[idx][2], factionsRanks[idx][3], factionsRanks[idx][4],
			factionsRanks[idx][5], factionsRanks[idx][6], factionsRanks[idx][7], factionsRanks[idx][8], factionsRanks[idx][9],
			factionsRanks[idx][10], factionsRanks[idx][11], factionsRanks[idx][12], factionsRanks[idx][13], factionsRanks[idx][14]);
		}
	}
}

stock ClearChat(playerid) 
{
	for (new i = 0; i < 100; i++) {
		SCM(playerid, -1, " ");
	}

	return 1;
}

stock SwitchEngine(playerid) 
{
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
		new vehid = GetPlayerVehicleID(playerid);
		new engine, lights, alarm, doors, bonnet, boot, objective;

		GetVehicleParamsEx(vehid, engine, lights, alarm, doors, bonnet, boot, objective);
		
		if (engine == VEHICLE_PARAMS_ON) SetVehicleParamsEx(vehid, VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective);
		if (engine == VEHICLE_PARAMS_OFF) SetVehicleParamsEx(vehid, VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective);
	}

	return 1;
}

stock SwitchLight(playerid) 
{
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
		new vehid = GetPlayerVehicleID(playerid);
		new engine, lights, alarm, doors, bonnet, boot, objective;

		GetVehicleParamsEx(vehid, engine, lights, alarm, doors, bonnet, boot, objective);
		
		if (lights == VEHICLE_PARAMS_ON) SetVehicleParamsEx(vehid, engine, VEHICLE_PARAMS_OFF, alarm, doors, bonnet, boot, objective);
		if (lights == VEHICLE_PARAMS_OFF) SetVehicleParamsEx(vehid, engine, VEHICLE_PARAMS_ON, alarm, doors, bonnet, boot, objective);
	}

	return 1;
}

stock SwitchBonnet(playerid) 
{
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
		new vehid = GetPlayerVehicleID(playerid);
		new engine, lights, alarm, doors, bonnet, boot, objective;

		GetVehicleParamsEx(vehid, engine, lights, alarm, doors, bonnet, boot, objective);
		
		if (bonnet == VEHICLE_PARAMS_ON) SetVehicleParamsEx(vehid, engine, lights, alarm, doors, VEHICLE_PARAMS_OFF, boot, objective);
		if (bonnet == VEHICLE_PARAMS_OFF) SetVehicleParamsEx(vehid, engine, lights, alarm, doors, VEHICLE_PARAMS_ON, boot, objective);
	}

	return 1;
}

stock SwitchBoot(playerid) 
{
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
		new vehid = GetPlayerVehicleID(playerid);
		new engine, lights, alarm, doors, bonnet, boot, objective;

		GetVehicleParamsEx(vehid, engine, lights, alarm, doors, bonnet, boot, objective);
		
		if (boot == VEHICLE_PARAMS_ON) SetVehicleParamsEx(vehid, engine, lights, alarm, doors, bonnet, VEHICLE_PARAMS_OFF, objective);
		if (boot == VEHICLE_PARAMS_OFF) SetVehicleParamsEx(vehid, engine, lights, alarm, doors, bonnet, VEHICLE_PARAMS_ON, objective);
	}

	return 1;
}

public CheckPlayer(playerid) 
{
	new rows;

	cache_get_row_count(rows);

	if (rows) {
		SPD(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Авторизация", "Этот аккаунт уже зарегистрирован.\nЕсли вы являетесь его владельцем введите пароль ниже.\n\nЕсли вы введете неверный пароль более 5-ти раз ваш IP адрес будет заблокирован!", "Войти", "");
		cache_get_value_name(0, "password", allPlayers[playerid][pPassword], MAX_PLAYER_PASSWORD);

	} else {
		SPD(playerid, DIALOG_REGISTER_PASS, DIALOG_STYLE_INPUT, "Регистрация", "Приветствуем вас на нашем проекте. Ваш ник свободен для регистрации.\n\nУкажите ниже пароль для аккаунта.", "Далее", "Выход");
	}

	return 1;
}


// ==========================================================================================================================
// COMMANDS
// ==========================================================================================================================


CMD:stats(playerid, params[]) 
{
	if (allPlayers[playerid][pGame]) {
		new msg[1000], gender[10], phone[24], bank[24], city[13];

		if (allPlayers[playerid][pGender]) gender = "Мужской";
		if (!allPlayers[playerid][pGender]) gender = "Женский";

		if (allPlayers[playerid][pBank] == -1) bank = "Нет счета";
		if (allPlayers[playerid][pBank] > 0) format(bank, sizeof(bank), "%d$", allPlayers[playerid][pBank]);

		if (allPlayers[playerid][pPhone] == EOS) phone = "Не имеется";
		if (allPlayers[playerid][pPhone] != EOS) strmid(phone, allPlayers[playerid][pPhone], 0, strlen(allPlayers[playerid][pPhone]));

		if (!strcmp(allPlayers[playerid][pCity], "ls")) city = "Los Santos";
		if (!strcmp(allPlayers[playerid][pCity], "sf")) city = "San Fiero";
		if (!strcmp(allPlayers[playerid][pCity], "lv")) city = "Las Venturas";

		format(msg, sizeof(msg), "\
		Состояние счета:                        %d S coins\n\n\
		UID: %d\n\
		Имя: %s\n\
		Пол: %s\n\
		Уровень: %d\n\
		Очки опыта: %d\n\
		Часы в игре: %d\n\n\
		Деньги на руках: %d$\n\
		Деньги в банке: %s\n\n\
		Номер телефона: %s \n\n\
		Работа: %s \n\n\
		Фракция: %s \n\
		Ранг: %s(%d)\n\n\
		Город проживания: %s \n\n\
		Уровень розыска: %d \n\
		Предупреждения: %d \n", 
		allPlayers[playerid][pDonate], allPlayers[playerid][pId], allPlayers[playerid][pName], gender, 
		allPlayers[playerid][pLvl], allPlayers[playerid][pExp], allPlayers[playerid][pHours], allPlayers[playerid][pMoney], 
		bank, phone, job_list[allPlayers[playerid][pJob]], factions_list[allPlayers[playerid][pFaction]], 
		factionsRanks[allPlayers[playerid][pFaction]-1][allPlayers[playerid][pRank]-1], allPlayers[playerid][pRank],
		city, allPlayers[playerid][pWanted], allPlayers[playerid][pWarns]);

		SPD(playerid, DIALOG_STATS, DIALOG_STYLE_MSGBOX, "Игровая статистика", msg, "Закрыть", "");
	}

	return 1;
}

CMD:me(playerid, params[]) 
{
	if (allPlayers[playerid][pGame]) {
		if(GetPVarInt(playerid, "flood") > gettime()) {
			SendClientMessage(playerid, GRAY, "Не флудите!");
			return 0;
		}

		new action[100];
		if(sscanf(params, "s[100]", action)) return SCM(playerid, GRAY, "Используйте: /me [действие]");

		new msg[120];

		format(msg, sizeof(msg), "%s %s", allPlayers[playerid][pName], action);
		ProxDetector(10.0, playerid, msg, PURPLE);

		SetPVarInt(playerid, "flood", gettime()+2);
	}

	return 1;
}

CMD:do(playerid, params[]) 
{
	if (allPlayers[playerid][pGame]) {
		if(GetPVarInt(playerid, "flood") > gettime()) {
			SendClientMessage(playerid, GRAY, "Не флудите!");
			return 0;
		}

		new action[100];

		if(sscanf(params, "s[100]", action)) return SCM(playerid, GRAY, "Используйте: /do [описание]");

		new msg[100+MAX_PLAYER_NAME];

		format(msg, sizeof(msg), "%s ((%s))", action, allPlayers[playerid][pName]);
		ProxDetector(10.0, playerid, msg, PURPLE);

		SetPVarInt(playerid, "flood", gettime()+2);
	}

	return 1;
}

CMD:b(playerid, params[]) 
{
	if (allPlayers[playerid][pGame]) {
		if(GetPVarInt(playerid, "flood") > gettime()) {
			SendClientMessage(playerid, GRAY, "Не флудите!");
			return 0;
		}

		new message[100];

		if(sscanf(params, "s[100]", message)) return SCM(playerid, GRAY, "Используйте: /b, /n [сообщение]");

		new msg[100+MAX_PLAYER_NAME];

		format(msg, sizeof(msg), "(( %s: %s ))", allPlayers[playerid][pName], message);
		ProxDetector(10.0, playerid, msg, GRAY);

		SetPVarInt(playerid, "flood", gettime()+2);
	}

	return 1;
}

CMD:eng(playerid, params[]) return SwitchEngine(playerid);
CMD:li(playerid, params[]) return SwitchLight(playerid);
CMD:bonnet(playerid, params[]) return SwitchBonnet(playerid);
CMD:boot(playerid, params[]) return SwitchBoot(playerid);

CMD:mm(playerid, params[]) 
{
	return 1;
}


ALTX:b("/n");
ALTX:mm("/mn");

// ==========================================================================================================================
// LEADER COMMANDS
// ==========================================================================================================================



// ==========================================================================================================================
// FACTION COMMANDS
// ==========================================================================================================================

CMD:lmenu(playerid, params[])
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pLeader]) {
			return SPD(playerid, DIALOG_LMENU, DIALOG_STYLE_LIST, "Панель лидера", "\
				Название фракции\n\
				Редактировать объявление\n\
				Управление рангами\n\
				Управление автопарком", "Изменить", "Закрыть");

		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");		
	}

	return 1;
}


// ==========================================================================================================================
// ADMIN COMMANDS
// ==========================================================================================================================

CMD:alogin(playerid, params[]) 
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 0) {
			new duty = GetPVarInt(playerid, "aduty");
			new msg[100];

			if (duty) {
				format(msg, sizeof(msg), "%s вышел из системы администрирования.", allPlayers[playerid][pName]);
				SetPVarInt(playerid, "aduty", 0);
				SAM(msg, -1);
			}

			if (!duty) {
				new queryString[60];

				format(queryString, sizeof(queryString), "SELECT `admin_pass` from `users` WHERE `id`='%d'", allPlayers[playerid][pId]);
				mysql_tquery(dbHandle, queryString, "CheckAdmin", "i", playerid);
			}
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");		
	}

	return 1;
}

CMD:a(playerid, params[]) 
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 0) {
			if (GetPVarInt(playerid, "aduty")) {
				new message[100];

				if(sscanf(params, "s[100]", message)) return SCM(playerid, GRAY, "Используйте: /a [сообщение]");
				
				new msg[120];

				format(msg, sizeof(msg), "[A] %s: %s", allPlayers[playerid][pName], message);

				SAM(msg, LIGHTGREEN);

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:ahelp(playerid, params[])
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 0) {
			if (GetPVarInt(playerid, "aduty")) {
				new alvl;

				if (sscanf(params, "i", alvl)) return SCM(playerid, GRAY, "Используйте: /ahelp [уровень админки]");

				if (alvl == 1 && allPlayers[playerid][pAdminLvl] > 0) {
					return SPD(playerid, DIALOG_AHELP, DIALOG_STYLE_MSGBOX, "Админ помощь", 
					"Доступные комманды:\n\n\
					/alogin - вход в систему администрирования\n\
					/a - чат администрации\n\
					/ahelp - админ помощь\n\
					/admins - список администрации\n\
					/agm - godmode для администрации\n\
					/heal - вылечить игрока\n\
					/sethp - установить уровень здоровья\n\
					/re - режим слежки за игроком\n\
					/reoff - выйти из слежки за игроком\n\
					/spplayer - заспавнить игрока\n\
					/freeze - заморозить игрока\n\
					/unfreeze - разморозить игрока\n\
					/fix - починить авто\n\
					/flip - поставить транспорт на колеса\n\
					/plveh - создание временного транспорта\n\
					/pm - написать сообщение игроку\n\
					/goto - телепортироватся к игроку\n\
					/gethere - телепортировать игрока к себе\n\
					/tpl - меню для телепортации\n\
					/slap - подкинуть игрока в верх\n\n\
					Так-же достпно встроенное тп по метке.", "Закрыть", "");
				}

				if (alvl == 2 && allPlayers[playerid][pAdminLvl] > 1) {
					return SPD(playerid, DIALOG_AHELP, DIALOG_STYLE_MSGBOX, "Админ помощь", 
					"Доступные комманды:\n\n\
					/setskin - выдать скин (временный)\n\
					/az - телепортировать игрока в админ-зону\n\
					/jetapck /jp - выдать себе джетпак\n\
					/kick - кикнуть игрока с сервера\n\nКоманды предыдуших уровней.", "Закрыть", "");
				}

				if (alvl == 3 && allPlayers[playerid][pAdminLvl] > 2) {
					return SPD(playerid, DIALOG_AHELP, DIALOG_STYLE_MSGBOX, "Админ помощь", 
					"Доступные комманды:\n\n\
					/getip - проверить IP адреса игрока\n\
					/ban - заблокировать аккаунт игрока\n\
					/banip - заблокировать IP адрес игрока\n\nКоманды предыдуших уровней.", "Закрыть", "");
				}

				if (alvl == 4 && allPlayers[playerid][pAdminLvl] > 3) {
					return SPD(playerid, DIALOG_AHELP, DIALOG_STYLE_MSGBOX, "Админ помощь", 
					"Доступные комманды:\n\n\
					/ao - глобальный чат сервера\n\
					/setskin - выдать скин (постоянный)\n\
					/setname - установить имя игроку\n\
					/banoff - заблокировать игрока не в сети\n\
					/unban - разблокировать игрока\n\
					/unbanip - разблокировать IP адрес игрока\n\nКоманды предыдуших уровней.", "Закрыть", "");
				}

				if (alvl == 5 && allPlayers[playerid][pAdminLvl] > 4) {
					return SPD(playerid, DIALOG_AHELP, DIALOG_STYLE_MSGBOX, "Админ помощь", 
					"Доступные комманды:\n\n\
					/makeadmin - поставить/снять администратора (1-3lvl)\n\nКоманды предыдуших уровней.", "Закрыть", "");
				}

				if (alvl == 6 && allPlayers[playerid][pAdminLvl] > 5) {
					return SPD(playerid, DIALOG_AHELP, DIALOG_STYLE_MSGBOX, "Админ помощь", 
					"Доступные комманды:\n\n\
					/makeadmin - поставить/снять администратора (1-6lvl)\n\nКоманды предыдуших уровней.", "Закрыть", "");
				}

				if (alvl < 0 || alvl > 6) return SCM(playerid, GRAY, "Такого уровня не существует.");
				else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		}
	}
	return 1;
}

CMD:ao(playerid, params[]) 
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 3) {
			if (GetPVarInt(playerid, "aduty")) {
				new message[100];

				if(sscanf(params, "s[100]", message)) return SCM(playerid, GRAY, "Используйте: /ao [сообщение]");
				
				SCMAllf(YELLOW, "%s %s: %s", admins_ncolor[allPlayers[playerid][pAdminLvl]], allPlayers[playerid][pName], message);

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:admins(playerid, params[]) 
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl]) {
			if (GetPVarInt(playerid, "aduty")) {
				new a_count = 0;

				foreach(Player, i) if(allPlayers[i][pAdminLvl] > 0) a_count++;

				SCMf(playerid, GRAY, "Администрация онлайн: (в сети: %d)", a_count);

				foreach(Player, i)
				{
					if(allPlayers[i][pAdminLvl] > 0)
					{
						new aduty[35];

						if (GetPVarInt(i, "aduty") == 1) aduty = "{02b514}Авторизован{ffffff}";
						if (GetPVarInt(i, "aduty") == 0) aduty = "{bababa}Не авторизован{ffffff}";

						SCMf(playerid, -1, "%s[%d] - [%d lvl] - %s", allPlayers[i][pName], i, allPlayers[i][pAdminLvl], aduty);
					}
				}

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:az(playerid, params[])
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 1) {
			if (GetPVarInt(playerid, "aduty")) {
				new pid;

				if (sscanf(params, "D(-9805423957)", pid)) return SCM(playerid, GRAY, "Используйте: /az [id игрока]");
				if (pid == -9805423957) {
					SetPlayerVirtualWorld(playerid, 2147483646);
					SetPlayerInterior(playerid, admin_zone[0]);
					SetPlayerPos(playerid, Float:admin_zone[1]+0.5, Float:admin_zone[2], Float:admin_zone[3]);

					return 1;
				}

				if (pid < 0 || pid > 1000) return SCM(playerid, GRAY, "Вы ввели неверный id игрока");
				if (GetPVarInt(pid, "recon") != -1) return SCM(playerid, GRAY, "Игрок находится в реконе.");

				SetPlayerVirtualWorld(playerid, 2147483646);
				SetPlayerInterior(playerid, admin_zone[0]);
				SetPlayerPos(playerid, Float:admin_zone[1], Float:admin_zone[2], Float:admin_zone[3]);

				SetPlayerVirtualWorld(pid, 2147483646);
				SetPlayerInterior(pid, admin_zone[0]);
				SetPlayerPos(pid, Float:admin_zone[1], Float:admin_zone[2], Float:admin_zone[3]);

				return SCMf(pid, GRAY, "Вы были телепортированы Администратором %s в админ-зону.", allPlayers[playerid][pName]);

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	} 

	return 1;
}

CMD:agm(playerid, params[]) 
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 0) {
			if (GetPVarInt(playerid, "aduty")) {
				if (GetPVarInt(playerid, "agm")) {
					SetPlayerHealth(playerid, 100.0);
					GameTextForPlayer(playerid, "AGM ~r~OFF", 600, 5);
					SetPVarInt(playerid, "agm", 0);
				} else {
					SetPlayerHealth(playerid, INFINITY_HEALTH);
					GameTextForPlayer(playerid, "AGM ~g~ON", 600, 5);
					SetPVarInt(playerid, "agm", 1);
				}
			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:flip(playerid, params[])
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 0) {
			if (GetPVarInt(playerid, "aduty")) {
				new vid;

				if (sscanf(params, "i", vid)) return SCM(playerid, GRAY, "Используйте: /flip [id транспорта]");
				if (!GetVehicleModel(vid)) return SCM(playerid, GRAY, "Транспорта с таким id не существует.");

				new Float:x, Float:y, Float:z;
				new Float:angle;

				GetVehiclePos(vid, x, y, z);
				GetVehicleZAngle(vid, angle);
				SetVehiclePos(vid, x, y, z + 1.5);
				SetVehicleZAngle(vid, angle);
				RepairVehicle(vid);

				return SCM(playerid, GRAY, "Транспорт поставлен на колёса.");	

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1; 
}

CMD:fix(playerid, params[])
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 0) {
			if (GetPVarInt(playerid, "aduty")) {
				new vid;

				if (sscanf(params, "i", vid)) return SCM(playerid, GRAY, "Используйте: /fix [id транспорта]");
				if (!GetVehicleModel(vid)) return SCM(playerid, GRAY, "Транспорта с таким id не существует.");

				RepairVehicle(vid); 

				return SCM(playerid, GRAY, "Транспорт починен.");

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}
	
	return 1;
}

CMD:re(playerid, params[])
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 0) {
			if (GetPVarInt(playerid, "aduty")) {
				new pid;

				if(sscanf(params, "i", pid)) return SCM(playerid, -1, "Введите: /re [id игрока]");
				if (allPlayers[playerid][pName] == allPlayers[pid][pName]) return SCM(playerid, GRAY, "Вы не можете следить сами за собой.");
				if(!allPlayers[pid][pGame]) return SCM(playerid, GRAY, "Вы ввели неверный ID игрока.");

				SetPlayerInterior(playerid, GetPlayerInterior(pid));
				SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(pid));
				TogglePlayerSpectating(playerid, 1);

				if(GetPlayerVehicleID(pid)) PlayerSpectateVehicle(playerid, GetPlayerVehicleID(pid));
				else PlayerSpectatePlayer(playerid, pid);

				SetPVarInt(pid, "recontarget", playerid);
				SetPVarInt(playerid, "recon", pid);

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:reoff(playerid, params[]) 
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 0) {
			if (GetPVarInt(playerid, "aduty")) {
				if (GetPVarInt(playerid, "recon") >= 0) {
					SetPVarInt(GetPVarInt(playerid, "recon"), "recontarget", -1);
					SetPVarInt(playerid, "recon", -1);

					TogglePlayerSpectating(playerid, 0);
					SetPlayerPos(playerid, Float:allPlayers[playerid][pSpawnPosX], Float:allPlayers[playerid][pSpawnPosY], Float:allPlayers[playerid][pSpawnPosZ]);
					SetPlayerVirtualWorld(playerid, 0);
					SetPlayerInterior(playerid, 0);
				}
			}
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");

	return 1;
}

CMD:plveh(playerid, params[]) 
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 0) {
			if (GetPVarInt(playerid, "aduty")) {
				new pid, vm, color1, color2;

				if(sscanf(params, "iiD(1)D(1)", pid, vm, color1, color2)) return SCM(playerid, GRAY, "Используйте: /plveh [id игрока] [модель авто] [цвет1] [цвет2]");
				if (!allPlayers[pid][pGame]) return SCM(playerid, GRAY, "Вы ввели неверный ID игрока.");
				if (GetPlayerVehicleID(playerid) && playerid == pid) return SCM(playerid, GRAY, "Вы не можете использовать эту комманду, находясь в транспорте.");
				if (GetPlayerVehicleID(pid)) return SCM(playerid, GRAY, "Вы не можете использовать эту комманду, когда игрок в транспорте.");
				if (GetPVarInt(pid, "recon") != -1) return SCM(playerid, GRAY, "Игрок находится в реконе.");
				if (vm < 400 || vm > 610) return SCM(playerid, GRAY, "Вы ввели неверный ID транспорта.");
				if (color1 < 0 || color1 > 255) color1 = 1;
				if (color2 < 0 || color2 > 255) color2 = 1;

				new Float:x, Float:y, Float:z, Float:r;
				new engine, lights, alarm, doors, bonnet, boot, objective;

				GetPlayerPos(pid, Float:x, Float:y, Float:z);
				GetPlayerFacingAngle(pid, Float:r);

				new veh = CreateVehicle(vm, Float:x, Float:y, Float:z, Float:r, color1, color2, 0, 0);

				GetVehicleParamsEx(veh, engine, lights, alarm, doors, bonnet, boot, objective);
				SetVehicleParamsEx(veh, VEHICLE_PARAMS_ON, VEHICLE_PARAMS_ON, alarm, doors, VEHICLE_PARAMS_OFF, VEHICLE_PARAMS_OFF, objective);
			
				PutPlayerInVehicle(pid, veh, 0);

				SetPVarInt(pid, "plveh", veh);
			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:pm(playerid, params[])
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 0) {
			if (GetPVarInt(playerid, "aduty")) {
				new pid, type, msg[128];

				if (sscanf(params, "iDs[128]", pid, type, msg)) return SCM(playerid, GRAY, "Используйте: /pm [id игрока] [0/1 сообщение/диалог] [сообщение]");
				if(!allPlayers[pid][pGame]) return SCM(playerid, GRAY, "Вы ввели неверный ID игрока.");

				if (type == 0) SCMf(pid, YELLOW, "(( Администратор %s: %s ))", allPlayers[playerid][pName], msg);
				if (type == 1) SPDf(playerid, DIALOG_PM, DIALOG_STYLE_MSGBOX, "Сообщение от Администрации", "Закрыть", "", "Администратор %s написал вам: %s", 
				allPlayers[playerid][pName], msg);

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:setskin(playerid, params[]) 
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 1) {
			if (GetPVarInt(playerid, "aduty")) {
				new pid, sid, st;

				if (sscanf(params, "iiD(0)", pid, sid, st)) return SCM(playerid, GRAY, "Используйте: /setskin [id игрока] [id скина] [0/1 временный/постоянный]");
				if (!allPlayers[pid][pGame]) return SCM(playerid, GRAY, "Вы ввели неверный ID игрока.");
				if (sid < 0 || sid > 311) return SCM(playerid, GRAY, "Вы ввели неверный ID скина.");

				new amsg[100];

				if (st == 0) {
					SetPlayerSkin(pid, sid);

					format(amsg, sizeof(amsg), "Администратор %s выдал временный скин игроку %s.", allPlayers[playerid][pName], allPlayers[pid][pName]);

					SCMf(pid, GRAY, "%s %s выдал вам временный скин.", admins_ncolor[allPlayers[playerid][pAdminLvl]], allPlayers[playerid][pName]);
					SAM(amsg, GRAY);
				}

				if (st == 1) {
					if (allPlayers[playerid][pAdminLvl] > 3) {
						new queryString[250];

						allPlayers[pid][pSkin] = sid;
						SetPlayerSkin(pid, sid);

						format(queryString, sizeof(queryString), "UPDATE `users` SET `skin` = '%d' WHERE `users`.`id` = %d", sid, allPlayers[pid][pId]);
						mysql_query(dbHandle, queryString, false);

						format(amsg, sizeof(amsg), "Администратор %s выдал постоянный скин игроку %s.", allPlayers[playerid][pName], allPlayers[pid][pName]);

						SCMf(pid, GRAY, "%s %s выдал вам постоянный скин.", admins_ncolor[allPlayers[playerid][pAdminLvl]], allPlayers[playerid][pName]);
						SAM(amsg, GRAY);
					} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
				}
			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:setname(playerid, params[]) 
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 3) {
			if (GetPVarInt(playerid, "aduty")) {
				new pid, rows, name[24], queryString[100];

				if (sscanf(params, "is[24]", pid, name)) return SCM(playerid, GRAY, "Используйте: /setname [id игрока] [имя]");

				format(queryString, sizeof(queryString), "SELECT * FROM `users` WHERE `name`='%s'", name);
				mysql_query(dbHandle, queryString, true);

				cache_get_row_count(rows);

				if (!rows) {
					new amsg[100];

					format(amsg, sizeof(amsg), "Администратор %s изменил имя игроку %s на %s.", allPlayers[playerid][pName], allPlayers[pid][pName], name);

					strmid(allPlayers[pid][pName], name, 0, strlen(name));
					SetPlayerName(pid, name);

					format(queryString, sizeof(queryString), "UPDATE `users` SET `name` = '%s' WHERE `users`.`id` = %d", name, allPlayers[pid][pId]);
					mysql_query(dbHandle, queryString, false);

					SCMf(pid, YELLOW, "Администратор %s изменил вам имя на %s.", allPlayers[playerid][pName], name);
					SAM(amsg, YELLOW);

				} else return SCM(playerid, GRAY, "Игрок с таким именем уже существует.");
			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:sethp(playerid, params[])
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl]) {
			if (GetPVarInt(playerid, "aduty")) {
				new pid, Float:health;
				new msg[128];

				if (sscanf(params, "if", pid, health)) return SCM(playerid, GRAY, "Используйте: /sethp [id игрока] [количество здоровья]");
				if (!allPlayers[pid][pGame]) return SCM(playerid, GRAY, "Вы ввели неверный ID игрока.");
				if (GetPVarInt(pid, "recon") != -1) return SCM(playerid, GRAY, "Игрок находится в реконе.");

				SetPlayerHealth(pid, Float:health);
				SCMf(pid, GRAY, "Администратор %s установил вам уровень здоровья: %f", allPlayers[playerid][pName], health);

				format(msg, sizeof(msg), "Администратор %s установил уровень здоровья: %f игроку %s.", 
				allPlayers[playerid][pName], health, allPlayers[pid][pName]);

				SAM(msg, GRAY);
			}
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");

	return 1;
}

CMD:heal(playerid, params[])
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl]) {
			if (GetPVarInt(playerid, "aduty")) {
				new pid;
				new msg[128];

				if (sscanf(params, "i", pid)) return SCM(playerid, GRAY, "Используйте: /sethp [id игрока]");
				if (!allPlayers[pid][pGame]) return SCM(playerid, GRAY, "Вы ввели неверный ID игрока.");

				SetPlayerHealth(pid, Float:100.0);
				SCMf(pid, GRAY, "Вас вылечил Администратор %s.", allPlayers[playerid][pName]);

				format(msg, sizeof(msg), "Администратор %s вылечил игрока %s.", allPlayers[playerid][pName], allPlayers[pid][pName]);
				SAM(msg, GRAY);
			}
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");

	return 1;
}

CMD:goto(playerid, params[]) 
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 0) {
			if (GetPVarInt(playerid, "aduty")) {
				new pid;

				if (sscanf(params, "i", pid)) return SCM(playerid, GRAY, "Используйте: /goto [id игрока]");
				if (!allPlayers[pid][pGame]) return SCM(playerid, GRAY, "Вы ввели неверный ID игрока.");
				if (GetPVarInt(pid, "recon") != -1) return SCM(playerid, GRAY, "Игрок находится в реконе.");

				new Float:x, Float:y, Float:z, Float:r, vw;
				
				GetPlayerPos(pid, Float:x, Float:y, Float:z);
				GetPlayerFacingAngle(pid, Float:r);
				vw = GetPlayerVirtualWorld(pid);

				SetPlayerVirtualWorld(playerid, vw);
				SetPlayerPos(playerid, Float:x+0.1, Float:y, Float:z);
				SetPlayerFacingAngle(playerid, Float:r);

				return SCMf(playerid, GRAY, "Вы телепортировались к игроку %s.", allPlayers[pid][pName]);

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:gethere(playerid, params[]) 
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 0) {
			if (GetPVarInt(playerid, "aduty")) {
				new pid;

				if (sscanf(params, "i", pid)) return SCM(playerid, GRAY, "Используйте: /gethere [id игрока]");
				if (!allPlayers[pid][pGame]) return SCM(playerid, GRAY, "Вы ввели неверный ID игрока.");
				if (GetPVarInt(pid, "recon") != -1) return SCM(playerid, GRAY, "Игрок находится в реконе.");

				new Float:x, Float:y, Float:z, Float:r, vw;
				
				GetPlayerPos(playerid, Float:x, Float:y, Float:z);
				GetPlayerFacingAngle(playerid, Float:r);
				vw = GetPlayerVirtualWorld(playerid);

				SetPlayerVirtualWorld(pid, vw);
				SetPlayerPos(pid, Float:x+0.1, Float:y, Float:z);
				SetPlayerFacingAngle(pid, Float:r);

				SCMf(pid, GRAY, "Вас телепортировал к себе администратор %s.", allPlayers[playerid][pName]);
				return SCMf(playerid, GRAY, "Вы телепортировали к себе игрока %s.", allPlayers[pid][pName]);

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:tpl(playerid, params[])
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 0) {
			if (GetPVarInt(playerid, "aduty")) {
				return 1; // заменить на вывод меню gps где вместо постановления метки идет тп
			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:slap(playerid, params[]) 
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 0) {
			if (GetPVarInt(playerid, "aduty")) {
				new pid, st;

				if (sscanf(params, "ii", pid, st)) return SCM(playerid, GRAY, "Используйте: /slap [id игрока] [0/1 вниз/вверх]");
				if (!allPlayers[pid][pGame]) return SCM(playerid, GRAY, "Вы ввели неверный ID игрока.");
				if (GetPVarInt(pid, "recon") != -1) return SCM(playerid, GRAY, "Игрок находится в реконе.");

				new Float:x, Float:y, Float:z;
				new amsg[100];

				GetPlayerPos(pid, Float:x, Float:y, Float:z);

				if (st == 1) {
					SetPlayerPos(pid, Float:x, Float:y, Float:z+5);
					SCMf(pid, GRAY, "Администратор %s подкинул вас наверх.", allPlayers[playerid][pName]);
				}

				if (st == 0) {
					SetPlayerPos(pid, Float:x, Float:y, Float:z-5);
					SCMf(pid, GRAY, "Администратор %s подкинул вас вниз.", allPlayers[playerid][pName]);
				}

				format(amsg, sizeof(amsg), "Администратор %s дал поджопник игроку %s.", allPlayers[playerid][pName], allPlayers[pid][pName]);
				return SAM(amsg, GRAY);

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:freeze(playerid, params[])
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 0) {
			if (GetPVarInt(playerid, "aduty")) {
				new pid, msg[128];

				if (sscanf(params, "i", pid)) return SCM(playerid, GRAY, "Используйте: /freeze [id игрока]");
				if (!allPlayers[pid][pGame]) return SCM(playerid, GRAY, "Вы ввели неверный ID игрока.");
				if (GetPVarInt(pid, "recon") != -1) return SCM(playerid, GRAY, "Игрок находится в реконе.");

				TogglePlayerControllable(pid, 0);

				SCMf(pid, YELLOW, "Вас заморозил Администратор %s.", allPlayers[playerid][pName]);

				format(msg, sizeof(msg), "Администратор %s заморозил игрока %s.", allPlayers[playerid][pName], allPlayers[pid][pName]);
				return SAM(msg, YELLOW);

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:unfreeze(playerid, params[])
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 0) {
			if (GetPVarInt(playerid, "aduty")) {
				new pid, msg[128];

				if (sscanf(params, "i", pid)) return SCM(playerid, GRAY, "Используйте: /unfreeze [id игрока]");
				if (!allPlayers[pid][pGame]) return SCM(playerid, GRAY, "Вы ввели неверный ID игрока.");
				if (GetPVarInt(pid, "recon") != -1) return SCM(playerid, GRAY, "Игрок находится в реконе.");

				TogglePlayerControllable(pid, 1);

				SCMf(pid, YELLOW, "Вас разморозил Администратор %s.", allPlayers[playerid][pName]);

				format(msg, sizeof(msg), "Администратор %s разморозил игрока %s.", allPlayers[playerid][pName], allPlayers[pid][pName]);
				return SAM(msg, YELLOW);

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:getip(playerid,params[])
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 2) {
			if (GetPVarInt(playerid, "aduty")) {
				new pid, msg[128];

				if (sscanf(params, "i", pid)) return SCM(playerid, GRAY, "Используйте: /getip [id игрока]");
				if (!allPlayers[pid][pGame]) return SCM(playerid, GRAY, "Вы ввели неверный ID игрока.");

				format(msg, sizeof(msg), "Администратор %s проверил IP адрес игрока %s.", allPlayers[playerid][pName], allPlayers[pid][pName]);
				SAM(msg, GRAY);

				return SCMf(playerid, GRAY, "Reg IP: %s Last IP: %s", allPlayers[pid][pRegIp], allPlayers[pid][pLastIp]);

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:jetpack(playerid, params[])
{
  if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 1) {
			if (GetPVarInt(playerid, "aduty")) {
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
				GameTextForPlayer(playerid, "JETPACK ON", 600, 5);
			}
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");

  return 1;
} 

CMD:spplayer(playerid, params[])
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 0) {
			if (GetPVarInt(playerid, "aduty")) {
				new pid;

				if (sscanf(params, "i", pid)) return SCM(playerid, GRAY, "Используйте: /spplayer [id игрока]");
				if (!allPlayers[pid][pGame]) return SCM(playerid, GRAY, "Вы ввели неверный ID игрока.");
				if (GetPVarInt(pid, "recon") != -1) return SCM(playerid, GRAY, "Игрок находится в реконе.");

				SetPlayerInterior(pid, 0);
				SetPlayerVirtualWorld(pid, 0);
				SetPlayerPos(pid, Float:allPlayers[pid][pSpawnPosX], Float:allPlayers[pid][pSpawnPosY], Float:allPlayers[pid][pSpawnPosZ]);

				SCMf(pid, GRAY, "Вас заспавнил Администратор %s", allPlayers[playerid][pName]);

				new msg[128];
				format(msg, sizeof(msg), "Администратор %s заспавнил игрока %s.", allPlayers[playerid][pName], allPlayers[pid][pName]);
				return SAM(msg, GRAY);

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:kick(playerid, params[])
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 1) {
			if (GetPVarInt(playerid, "aduty")) {
				new pid, reason[40];

				if (sscanf(params, "is[40]", pid, reason)) return SCM(playerid, GRAY, "Используйте: /kick [id игрока] [причина]");
				if (!allPlayers[pid][pGame]) return SCM(playerid, GRAY, "Вы ввели неверный ID игрока.");

				SCMf(pid, GRAY, "Вы были кикнуты администратором %s.", allPlayers[playerid][pName]);
				SCMAllf(RED, "Администратор %s кикнул игрока %s. Причина: %s",
				allPlayers[playerid][pName], allPlayers[pid][pName], reason);

				SetTimerEx("KickWithDelay", 100, false, "i", pid);

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:ban(playerid, params[])
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 2) {
			if (GetPVarInt(playerid, "aduty")) {
				new pid, days, reason[40];

				if (sscanf(params, "iis[40]", pid, days, reason)) return SCM(playerid, GRAY, "Используйте: /ban [id игрока] [дни] [причина]");
				if (!allPlayers[pid][pGame]) return SCM(playerid, GRAY, "Вы ввели неверный ID игрока.");
				if (days < 0 || days > 2999) return SCM(playerid, GRAY, "Вы ввели неверное количество дней.");

				new queryString[250+40];

				format(queryString, sizeof(queryString), "\
				INSERT INTO `bans` (`id`, `type`, `ban_date`, `ban_time`, `ban_ip`, `ban_nickname`, `ban_reason`) \
				VALUES (NULL, '0', '%d', '%d', '-', '%s', '%s')", 
				gettime(), days*86400, allPlayers[pid][pName], reason);

				mysql_query(dbHandle, queryString, false);

				SPDf(pid, DIALOG_NEWBAN, DIALOG_STYLE_MSGBOX, "Блокировка", "Закрыть", "", "Вы были заблокированны администратором %s.\n\
				Если вы не согласны с действиями администратора - вы можете\nподать жалобу на форум.", allPlayers[playerid][pName]);

				SCMAllf(RED, "Администратор %s забанил игрока %s на %d дней. Причина: %s",
				allPlayers[playerid][pName], allPlayers[pid][pName], days, reason);


				SetTimerEx("KickWithDelay", 50, false, "i", pid);

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:banoff(playerid, params[]) 
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 3) {
			if (GetPVarInt(playerid, "aduty")) {
				new name[24], days, reason[40];

				if (sscanf(params, "s[24]ds[40]", name, days, reason)) return SCM(playerid, GRAY, "Используйте: /banoff [имя игрока] [дни] [причина]");
				if (days < 0 || days > 2999) return SCM(playerid, GRAY, "Вы ввели неверное количество дней.");

				new queryString[250+40];

				format(queryString, sizeof(queryString), "SELECT * FROM `users` WHERE `name`='%s'", name);
				mysql_query(dbHandle, queryString, true);

				new rows;
				cache_get_row_count(rows);

				if (rows) {
					//можно проверить не админ ли это

					format(queryString, sizeof(queryString), "\
					INSERT INTO `bans` (`id`, `type`, `ban_date`, `ban_time`, `ban_ip`, `ban_nickname`, `ban_reason`) \
					VALUES (NULL, '0', '%d', '%d', '-', '%s', '%s')", 
					gettime(), days*86400, name, reason);

					mysql_query(dbHandle, queryString, false);

					SCMAllf(RED, "Администратор %s в офлайне забанил игрока %s на %d дней. Причина: %s",
					allPlayers[playerid][pName], name, days, reason);

				} else return SCM(playerid, GRAY, "Игрок с этим никнеймом не найден.");
			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:banip(playerid, params[])
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 2) {
			if (GetPVarInt(playerid, "aduty")) {
				new pid, days, reason[40];

				if (sscanf(params, "iis[40]", pid, days, reason)) return SCM(playerid, GRAY, "Используйте: /banip [id игрока] [дни] [причина]");
				if (!allPlayers[pid][pGame]) return SCM(playerid, GRAY, "Вы ввели неверный ID игрока.");
				if (days < 0 || days > 2999) return SCM(playerid, GRAY, "Вы ввели неверное количество дней.");

				new queryString[250+40], ip[16];

				GetPlayerIp(pid, ip, 16);

				format(queryString, sizeof(queryString), "\
				INSERT INTO `bans` (`id`, `type`, `ban_date`, `ban_time`, `ban_ip`, `ban_nickname`, `ban_reason`) \
				VALUES (NULL, '1', '%d', '%d', '%s', '%s', '%s')", 
				gettime(), days*86400, ip, allPlayers[pid][pName], reason);

				mysql_query(dbHandle, queryString, false);
				

				SPDf(pid, DIALOG_NEWBAN, DIALOG_STYLE_MSGBOX, "Блокировка", "Закрыть", "", "Ваш IP адрес заблокированны администратором %s.\n\
				Если вы не согласны с действиями администратора - вы можете\nподать жалобу на форум.", allPlayers[playerid][pName]);

				SCMAllf(RED, "Администратор %s забанил по IP игрока %s на %d дней. Причина: %s",
				allPlayers[playerid][pName], allPlayers[pid][pName], days, reason);


				SetTimerEx("KickWithDelay", 50, false, "i", pid);

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:unban(playerid, params[])
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 3) {
			if (GetPVarInt(playerid, "aduty")) {
				new name[24], queryString[128], rows;

				if (sscanf(params, "s[24]", name)) return SCM(playerid, GRAY, "Используйте: /unban [имя игрока]");

				format(queryString, sizeof(queryString), "SELECT * FROM `users` WHERE `name`='%s'", name);
				mysql_query(dbHandle, queryString, true);

				cache_get_row_count(rows);

				if (rows) {
					format(queryString, sizeof(queryString), "SELECT * FROM `bans` WHERE `bans`.`ban_nickname` = '%s'", name);
					mysql_query(dbHandle, queryString, true);

					cache_get_row_count(rows);

					if (rows) {
						format(queryString, sizeof(queryString), "DELETE FROM `bans` WHERE `bans`.`ban_nickname` = '%s'", name);
						mysql_query(dbHandle, queryString, false);

						SCMAllf(RED, "Администратор %s разблокировал игрока %s.", allPlayers[playerid][pName], name);

					} else return SCM(playerid, GRAY, "Заблокированный игрок с таким именем не найден.");
				} else return SCM(playerid, GRAY, "Игрок с таким именем не найден.");
			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:unbanip(playerid, params[])
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 3) {
			if (GetPVarInt(playerid, "aduty")) {
				new ip[24], queryString[128], rows;

				if (sscanf(params, "s[16]", ip)) return SCM(playerid, GRAY, "Используйте: /unbanip [IP адресс]");

				format(queryString, sizeof(queryString), "SELECT * FROM `users` WHERE `ip`='%s'", ip);
				mysql_query(dbHandle, queryString, true);

				cache_get_row_count(rows);

				if (rows) {
					format(queryString, sizeof(queryString), "DELETE FROM `bans` WHERE `bans`.`ban_ip` = '%s'", ip);
					mysql_query(dbHandle, queryString, false);

					SCMf(playerid, GRAY, "Вы разблокировали IP адрес %s", ip);
				}
			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:makeleader(playerid, params[])
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 4) {
			if (GetPVarInt(playerid, "aduty")) {
				new pid;

				if (sscanf(params, "i", pid)) return SCM(playerid, GRAY, "Используйте: /makeleader [id игрока]");
				if (!allPlayers[pid][pGame]) return SCM(playerid, GRAY, "Вы ввели неверный ID игрока.");

				SetPVarInt(playerid, "cand", pid);

				SPDf(playerid, DIALOG_MLEADER, DIALOG_STYLE_LIST, "Выбор фракции", "Выбрать", "", "\
				%s\n\
				%s\n\
				%s\n\
				%s\n\
				%s\n\
				%s\n\
				%s\n\
				%s\n\
				%s\n\
				%s\n\
				%s\n\
				%s\n\
				%s\n\
				%s\n\
				%s\n", allFactions[0][fName], allFactions[1][fName], allFactions[2][fName], allFactions[3][fName], allFactions[4][fName],
				allFactions[5][fName], allFactions[6][fName], allFactions[7][fName], allFactions[8][fName], allFactions[9][fName],
				allFactions[10][fName], allFactions[11][fName], allFactions[12][fName], allFactions[13][fName], allFactions[14][fName]);

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:rmleader(playerid, params[]) 
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 4) {
			if (GetPVarInt(playerid, "aduty")) {
				new name[24], queryString[250], rows;

				if (sscanf(params, "s[24]", name)) return SCM(playerid, GRAY, "Используйте: /rmleader [имя игрока]");
				
				format(queryString, sizeof(queryString), "SELECT * FROM `users` WHERE `name`='%s'", name);
				mysql_query(dbHandle, queryString, true);
				cache_get_row_count(rows);

				if (rows) {
					format(queryString, sizeof(queryString), "SELECT * FROM `factions` WHERE `factions`.`leader`='%s'", name);
					mysql_query(dbHandle, queryString, true);
					cache_get_row_count(rows);

					if (rows) {
						new msg[128], fname[MAX_FACTION_NAME];

						foreach(Player, i)
						{
							if(!strcmp(allPlayers[i][pName], name))
							{
								allPlayers[i][pFaction] = 0;
								allPlayers[i][pRank] = 0;
								allPlayers[i][pLeader] = 0;

								SCMf(playerid, YELLOW, "Вы были сняты с должности лидера Администратором %s.", allPlayers[playerid][pName]);
							}
						}

						format(queryString, sizeof(queryString), "UPDATE `factions` SET `leader` = '' WHERE `factions`.`leader` = '%s'", name);
						mysql_query(dbHandle, queryString, false);

						cache_get_value_name(0, "name", fname);

						format(msg, sizeof(msg), "Администратор %s снял %s с должности лидера %s.",
						allPlayers[playerid][pName], name, fname);

						SAM(msg, YELLOW);
					} else return SCM(playerid, GRAY, "Лидер с таким именем не найден.");

				} else return SCM(playerid, GRAY, "Игрок с таким именем не найден.");

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

CMD:makeadmin(playerid, params[]) 
{
	if (allPlayers[playerid][pGame]) {
		if (allPlayers[playerid][pAdminLvl] > 4) {
			if (GetPVarInt(playerid, "aduty")) {
				new pid, alvl;

				if (sscanf(params, "ii", pid, alvl)) return SCM(playerid, GRAY, "Используйте: /makeadmin [id игрока] [уровень админки]");
				if (!allPlayers[pid][pGame]) return SCM(playerid, GRAY, "Вы ввели неверный ID игрока.");
				if (alvl > 6) return SCM(playerid, GRAY, "Максимальный уровень администратора: 6.");

				new msg[128], queryString[100];

				if (alvl == 0) {
					if (allPlayers[pid][pAdminLvl] > 4 && allPlayers[playerid][pAdminLvl] < 6) return SCM(playerid, GRAY, "Вы не можете снимать Главную Администрацию.");
					if (allPlayers[pid][pAdminLvl] == 0) return SCM(playerid, GRAY, "Игрок не является администратором.");
 
					format(msg, sizeof(msg), "Администратор %s установил %s уровень администратора %d (Был: %d)", 
					allPlayers[playerid][pName], allPlayers[pid][pName], alvl, allPlayers[pid][pAdminLvl]);

					allPlayers[pid][pAdminLvl] = 0;
					allPlayers[pid][pAdminPassword] = EOS;

					format(queryString, sizeof(queryString), "UPDATE `users` SET `admin` = '%d', `admin_pass` = '%s' WHERE `users`.`id` = %d", 
					allPlayers[pid][pAdminLvl], allPlayers[pid][pAdminPassword], allPlayers[pid][pId]);
					mysql_query(dbHandle, queryString, false);

					SendClientMessage(pid, GRAY, "Вы были сняты с должности администратора.");
					SetTimerEx("KickWithDelay", 100, false, "i", pid);

					return SAM(msg, GRAY);
				}

				if (alvl > 3) {
					if (allPlayers[playerid][pAdminLvl] > 5) {
						format(msg, sizeof(msg), "Администратор %s установил %s уровень администратора %d (Был: %d)", 
						allPlayers[playerid][pName], allPlayers[pid][pName], alvl, allPlayers[pid][pAdminLvl]);

						allPlayers[pid][pAdminLvl] = alvl;
						valstr(allPlayers[pid][pAdminPassword],  admin_passwords[allPlayers[pid][pAdminLvl]-1]);

						format(queryString, sizeof(queryString), "UPDATE `users` SET `admin` = '%d', `admin_pass` = '%s' WHERE `users`.`id` = %d", 
						allPlayers[pid][pAdminLvl], allPlayers[pid][pAdminPassword], allPlayers[pid][pId]);
						mysql_query(dbHandle, queryString, false);

						SetPVarInt(pid, "aduty", 0);
						return SAM(msg, GRAY);
					} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
				}

				format(msg, sizeof(msg), "Администратор %s установил %s уровень администратора %d (Был: %d)", 
				allPlayers[playerid][pName], allPlayers[pid][pName], alvl, allPlayers[pid][pAdminLvl]);

				allPlayers[pid][pAdminLvl] = alvl;
				valstr(allPlayers[pid][pAdminPassword],  admin_passwords[allPlayers[pid][pAdminLvl]-1]);

				format(queryString, sizeof(queryString), "UPDATE `users` SET `admin` = '%d', `admin_pass` = '%s' WHERE `users`.`id` = %d", 
				allPlayers[pid][pAdminLvl], allPlayers[pid][pAdminPassword], allPlayers[pid][pId]);
				mysql_query(dbHandle, queryString, false);

				SetPVarInt(pid, "aduty", 0);
				return SAM(msg, GRAY);

			} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
		} else return SCM(playerid, GRAY, "Вы не имеете доступа к этой комманде.");
	}

	return 1;
}

ALTX:jetpack("/jp");

// ==========================================================================================================================
// TECH SECTION
// ==========================================================================================================================


public CheckAdmin(playerid) 
{
	SPD(playerid, DIALOG_ALOGIN, DIALOG_STYLE_PASSWORD, "Авторизация в админку", "Добро пожаловать, введите свой админ-пароль ниже для получения\nправ администратора. Без ввода пароля вам будут недоступны\nфункции администратора.", "Войти", "");
	cache_get_value_name(0, "admin_pass", allPlayers[playerid][pAdminPassword], MAX_PLAYER_PASSWORD);

	return 1;
}

public SendAdminMessage(msg[], color) 
{
	foreach(Player, i)
	{
	  if(allPlayers[i][pAdminLvl] > 0)
		{
	    if (GetPVarInt(i, "aduty")) {
				SCM(i, color, msg);
			}
	  }
	}

	return 1;
}

public ProxDetector(Float:radi, playerid, string[],col)
{
    if(IsPlayerConnected(playerid))
    {
        new Float:posx, Float:posy, Float:posz;
        new Float:oldposx, Float:oldposy, Float:oldposz;
        new Float:tempposx, Float:tempposy, Float:tempposz;
        GetPlayerPos(playerid, oldposx, oldposy, oldposz);
        for(new i = 0; i < MAX_PLAYERS; i++)
        {
            if(IsPlayerConnected(i) && (GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i)))
            {
                GetPlayerPos(i, posx, posy, posz);
                tempposx = (oldposx -posx);
                tempposy = (oldposy -posy);
                tempposz = (oldposz -posz);
                if (((tempposx < radi/16) && (tempposx > -radi/16)) && ((tempposy < radi/16) && (tempposy > -radi/16)) && ((tempposz < radi/16) && (tempposz > -radi/16))) // If the player is within 16 meters
                {
                    SCM(i, col, string);
                }
                else if (((tempposx < radi/8) && (tempposx > -radi/8)) && ((tempposy < radi/8) && (tempposy > -radi/8)) && ((tempposz < radi/8) && (tempposz > -radi/8))) // within 8 meters
                {
                    SCM(i, col, string);
                }
                else if (((tempposx < radi/4) && (tempposx > -radi/4)) && ((tempposy < radi/4) && (tempposy > -radi/4)) && ((tempposz < radi/4) && (tempposz > -radi/4))) //4 meters
                {
                    SCM(i, col, string);
                }
                else if (((tempposx < radi/2) && (tempposx > -radi/2)) && ((tempposy < radi/2) && (tempposy > -radi/2)) && ((tempposz < radi/2) && (tempposz > -radi/2))) //2 meters
                {
                    SCM(i, col, string);
                }
                else if (((tempposx < radi) && (tempposx > -radi)) && ((tempposy < radi) && (tempposy > -radi)) && ((tempposz < radi) && (tempposz > -radi))) //1 meter
                {
                    SCM(i, col, string);
                }
            }
            else
            {
                SCM(i, col, string);
            }
        }
    }

    return 1;
}

public KickWithDelay(playerid) return Kick(playerid);

stock CheckRoleplayName(playerid)
{
	new plname[MAX_PLAYER_NAME];
	GetPlayerName(playerid, plname, MAX_PLAYER_NAME);

	for(new i=0;i<strlen(plname);i++)
	{
		if( !((plname[i]>='a'&&plname[i]<='z') || (plname[i]>='A'&&plname[i]<='Z') || plname[i]=='_'))
		{
			SPD(playerid, DIALOG_NICK, DIALOG_STYLE_MSGBOX, "Формат имени", "Ваше имя не соотвествует Roleplay формату.\nСделайте ник по шаблону Name_Surname или Name_McSurname.", "Закрыть", "");
			SetTimerEx("KickWithDelay", 50, false, "i", playerid);
			return 0;
		}
	}
	new d = strfind(plname, "_");
	if( d==-1 ) {
		SPD(playerid, DIALOG_NICK, DIALOG_STYLE_MSGBOX, "Формат имени", "Ваше имя не соотвествует Roleplay формату.\nСделайте ник по шаблону Name_Surname или Name_McSurname.", "Закрыть", "");
		SetTimerEx("KickWithDelay", 50, false, "i", playerid);
		return 0;
	}
	if(strfind(plname, "_", false, d+1) != -1) {
		SPD(playerid, DIALOG_NICK, DIALOG_STYLE_MSGBOX, "Формат имени", "Ваше имя не соотвествует Roleplay формату.\nСделайте ник по шаблону Name_Surname или Name_McSurname.", "Закрыть", "");
		SetTimerEx("KickWithDelay", 50, false, "i", playerid);
		return 0;
	}
	new name[10];
	strmid(name, plname, 0, d, sizeof name);
	new surname[10];
	strmid(surname, plname, d+1, strlen(plname), sizeof surname);
	if(strlen(name)<3 || strlen(name)>9) {
		SPD(playerid, DIALOG_NICK, DIALOG_STYLE_MSGBOX, "Формат имени", "Ваше имя не соотвествует Roleplay формату.\nСделайте ник по шаблону Name_Surname или Name_McSurname.", "Закрыть", "");
		SetTimerEx("KickWithDelay", 50, false, "i", playerid);
		return 0;
	}
	if(strlen(surname)<3 || strlen(surname)>9) {
		SPD(playerid, DIALOG_NICK, DIALOG_STYLE_MSGBOX, "Формат имени", "Ваше имя не соотвествует Roleplay формату.\nСделайте ник по шаблону Name_Surname или Name_McSurname.", "Закрыть", "");
		SetTimerEx("KickWithDelay", 50, false, "i", playerid);
		return 0;
	}
	if(!(name[0]>='A' && name[0]<='Z')) {
		SPD(playerid, DIALOG_NICK, DIALOG_STYLE_MSGBOX, "Формат имени", "Ваше имя не соотвествует Roleplay формату.\nСделайте ник по шаблону Name_Surname или Name_McSurname.", "Закрыть", "");
		SetTimerEx("KickWithDelay", 50, false, "i", playerid);
		return 0;
	}
	if(!(surname[0]>='A' && surname[0]<='Z')) {
		SPD(playerid, DIALOG_NICK, DIALOG_STYLE_MSGBOX, "Формат имени", "Ваше имя не соотвествует Roleplay формату.\nСделайте ник по шаблону Name_Surname или Name_McSurname.", "Закрыть", "");
		SetTimerEx("KickWithDelay", 50, false, "i", playerid);
		return 0;
	}
	for(new i=1;i<strlen(name);i++)
	{
		if(!(name[i]>='a'&&name[i]<='z')) {
			SPD(playerid, DIALOG_NICK, DIALOG_STYLE_MSGBOX, "Формат имени", "Ваше имя не соотвествует Roleplay формату.\nСделайте ник по шаблону Name_Surname или Name_McSurname.", "Закрыть", "");
			SetTimerEx("KickWithDelay", 50, false, "i", playerid);
			return 0;
		}
	}
	for(new i=1;i<strlen(surname);i++)
	{
		if(!(surname[i]>='a'&&surname[i]<='z')) {
			SPD(playerid, DIALOG_NICK, DIALOG_STYLE_MSGBOX, "Формат имени", "Ваше имя не соотвествует Roleplay формату.\nСделайте ник по шаблону Name_Surname или Name_McSurname.", "Закрыть", "");
			SetTimerEx("KickWithDelay", 50, false, "i", playerid);
			return 0;
		}
	}

	return 1;
}

public UpdateTime() 
{
	new h, m, s;

	gettime(h, m, s);

	if (m == 0) {
		SetWorldTime(h);
		PayDay();
	}

	return 1;
}

public PayDay() 
{
	foreach(Player, i)
	{
		// TODO: сделать подсчет уровней
		if (allPlayers[i][pGame]) {
			allPlayers[i][pExp] += 1;
			allPlayers[i][pHours] += 1;
		}
	}
	
	return 1;
}

public UpdateWather() 
{
	weather_ls = weather_list[0][random(MAX_WEATHER)];
	weather_sf = weather_list[1][random(MAX_WEATHER)];
	weather_lv = weather_list[2][random(MAX_WEATHER)];

	foreach(Player, i)
	{
		if (GetPVarInt(i, "location") == 1) SetPlayerWeather(i, weather_ls); 
		if (GetPVarInt(i, "location") == 2) SetPlayerWeather(i, weather_sf); 
		if (GetPVarInt(i, "location") == 3) SetPlayerWeather(i, weather_lv); 
	}

	return 1;
}

public BanUser(playerid, type, btime, reason[]) 
{
	new now = gettime();
	new ip[16], queryString[256+MAX_PLAYER_NAME];

	GetPlayerIp(playerid, ip, 16);

	format(queryString, sizeof(queryString), 
	"INSERT INTO `bans` (`id`, `type`, `ban_date`, `ban_time`, `ban_ip`, `ban_nickname`, `ban_reason`) \
	VALUES (NULL, '%d', '%d', '%d', '%s', '%s', '%s')", 
	type, now, btime, ip, allPlayers[playerid][pName], reason);

	mysql_query(dbHandle, queryString, false);

	SetTimerEx("KickWithDelay", 50, false, "i", playerid);

	return 1;
}

public CheckBan(playerid) 
{
	new ip[16], queryString[128+MAX_PLAYER_NAME], rows;

	GetPlayerIp(playerid, ip, 16);

	format(queryString, sizeof(queryString), 
	"SELECT * FROM `bans` WHERE `ban_nickname` = '%s' OR `ban_ip` = '%s'", 
	allPlayers[playerid][pName], ip);

	mysql_query(dbHandle, queryString, true);

	cache_get_row_count(rows);

	if (rows) {
		new type, bdate, btime, bantime[128], banip[16], name[MAX_PLAYER_NAME], reason[128];

		cache_get_value_name_int(0, "type", type);
		cache_get_value_name_int(0, "ban_date", bdate);
		cache_get_value_name_int(0, "ban_time", btime);
		cache_get_value_name(0, "ban_ip", banip);
		cache_get_value_name(0, "ban_nickname", name);
		cache_get_value_name(0, "ban_reason", reason);

		if (gettime() > bdate+btime && btime != -1) return 1;

		if (btime == -1) bantime = "Безсрочно";
		if (btime != -1) bantime = date("%dd.%mm.%yyyy в %hh:%ii", bdate+btime);

		if (type == 0) {
			SPDf(playerid, DIALOG_BAN, DIALOG_STYLE_MSGBOX, "Блокировка", "Выйти", "", "\
			Ваш игровой аккаунт был заблокирован.\n\n\
			Заблокированный аккаунт: %s\n\
			Причина блокировки: %s\n\
			Дата блокировки: %s\n\
			Дата разблокировки: %s\n\n\
			Если вы не согласны с решением администрации - вы \n\
			можете написать жалобу на форум.\
			",allPlayers[playerid][pName], reason, date("%dd.%mm.%yyyy %hh:%ii", bdate), bantime);
		}

		if (type == 1 && strcmp(ip, banip)) {
			if (!strcmp(allPlayers[playerid][pName], name)) {
				SPDf(playerid, DIALOG_BAN, DIALOG_STYLE_MSGBOX, "Блокировка", "Выйти", "", "\
				Ваш игровой аккаунт был заблокирован.\n\n\
				Заблокированный аккаунт: %s\n\
				Причина блокировки: %s\n\
				Дата блокировки: %s\n\
				Дата разблокировки: %s\n\n\
				Если вы не согласны с решением администрации - вы \n\
				можете написать жалобу на форум.\
				",allPlayers[playerid][pName], reason, date("%dd.%mm.%yyyy %hh:%ii", bdate), bantime);
			}
		}

		if (type == 1) {
			SPDf(playerid, DIALOG_BAN, DIALOG_STYLE_MSGBOX, "Блокировка", "Выйти", "", "\
			Ваш IP адрес был заблокирован.\n\n\
			Заблокированный IP адрес: %s\n\
			Причина блокировки: %s\n\
			Дата блокировки: %s\n\
			Дата разблокировки: %s\n\n\
			Если вы не согласны с решением администрации - вы \n\
			можете написать жалобу на форум.\
			",banip, reason, date("%dd.%mm.%yyyy %hh:%ii", bdate), bantime);
		}

		SetTimerEx("KickWithDelay", 50, false, "i", playerid);
		return 0;
	}

	return 1;
}

public UpdatePlayer(playerid)
{
	SetPVarInt(playerid, "AFK", GetPVarInt(playerid, "AFK")+1);

	if (GetPVarInt(playerid, "AFK") > 1) {
		new stroka[20];
		format(stroka, 20, "AFK: %d секунд", GetPVarInt(playerid, "AFK"));
		SetPlayerChatBubble(playerid, stroka, -1, 20.0, 1100);
	}

	return 1;
}

stock MakeLeader(playerid, pid, fid) 
{
	new queryString[250], msg[128];

	strmid(allFactions[fid][fLeader], allPlayers[pid][pName], 0, strlen(allPlayers[pid][pName]));


	format(queryString, sizeof(queryString), "SELECT * FROM `factions` WHERE `factions`.`leader` = '%s'",
	allPlayers[pid][pName]);
	mysql_query(dbHandle, queryString, true);

	new rows;
	cache_get_row_count(rows);

	if (rows > 0) {
		format(queryString, sizeof(queryString), "UPDATE `factions` SET `leader` = '' WHERE `factions`.`leader` = '%s'", allPlayers[pid][pName]);
		mysql_query(dbHandle, queryString, false);

		SPD(playerid, DIALOG_MLEADER_REMOVE, DIALOG_STYLE_MSGBOX, "Предупреждение", "Данный человек уже является лидером.\n\
		При постановлении он автоматически был снят с предыдущих постов.", "Закрыть", "");
	}

	format(queryString, sizeof(queryString), "UPDATE `factions` SET `leader` = '%s' WHERE `factions`.`id` = %d",
	allPlayers[pid][pName], allFactions[fid][fId]);
	mysql_query(dbHandle, queryString, false);

	format(queryString, sizeof(queryString), "UPDATE `users` SET `faction` = '%d', `rank` = '%d', `leader` = '1' WHERE `users`.`id` = %d",
	allFactions[fid][fId], allFactions[fid][fRanksNum], allPlayers[playerid][pId]);
	mysql_query(dbHandle, queryString, false);


	format(msg, sizeof(msg), "Администратор %s назначил %s на пост лидера %s.", 
	allPlayers[playerid][pName], allPlayers[pid][pName], factions_list[allFactions[fid][fId]]);

	allPlayers[playerid][pFaction] = allFactions[fid][fId];
	allPlayers[playerid][pRank] = allFactions[fid][fRanksNum];
	allPlayers[playerid][pLeader] = 1;


	SAM(msg, YELLOW);

	return SCMf(pid, YELLOW, "Администратор %s назначил вас на пост лидера %s!", allPlayers[playerid][pName], factions_list[allFactions[fid][fId]]);
}