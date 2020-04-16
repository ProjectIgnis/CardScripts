--Anime Archtype
if not AnimeArchetype then
	AnimeArchetype = {}

	-- Alligator
	-- アリゲーター
	-- Graydle Alligator/Spawn Alligator/Toon Alligator/Lion Alligator
	AnimeArchetype.OCGAlligator={
		39984786,4611269,59383041,66451379
	}
	function Card.IsAlligator(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x502,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGAlligator))
	end

	-- Angel (archetype) list to update
	-- 天使
	-- てんし
	-- Injection Fairy Lily/Machine Angel Ritual/Machine Angel Absolute Ritual
	-- Mechquipped Angineer/Ghostrick Angel of Mischief/Doma The Angel of Silence
	-- Angel of Zera/Winged Egg of New Life/Archlord Kristya
	-- Archlord Zerato/Rosaria, the Stately Fallen Angel/Harvest Angel of Wisdom/
	-- Soul of the Pure/Graceful Dice/Fairy's Hand Mirror
	-- Graceful Tear/Graceful Charity/Numinous Healer
	-- Cherubini, Black Angel of the Burning Abyss
	-- Fallen Angel of Roses/Muse-A/Queen Angel of Roses
	AnimeArchetype.OCGAngel={
		79575620,39996157,15914410,53334641,16972957,42216237,
		42418084,18378582,59509952,81146288,85399281,47852924,
		74137509,17653779,9032529,79571449,2130625,49674183,
		69992868,96470883,11398951
	}
	function Card.IsAngel(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x154a,sc,sumtype,playerid) or c:IsSetCard(0xef,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGAngel))
	end

	-- Anti アンチ 
	-- Dystopia the Despondent/Delta Crow - Anti Reverse/Anti-Alian
	function Card.IsAnti(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x503,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,52085072,59839761,43583400)
	end

	-- Assassin アサシン
	-- Ansatsu/Dark Hunter/Night Assailant
	-- Night Papilloperative/Gravekeeper's Assailant/Photon Papilloperative
	-- Raiden, Hand of the Lightsworn
	AnimeArchetype.OCGAssassin={
		48365709,19357125,16226786,
		2191144,25262697,28150174,
		77558536
	}
	function Card.IsAssassin(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x504,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGAssassin))
	end

	-- Astral アストラル
	-- Astral Barrier/Astral Barrier
	function Card.IsAstral(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x505,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,37053871,45950291)
	end

	-- Atlandis アトランタル
	-- Number C6: Chronomaly Chaos Atlandis/Number 6: Chronomaly Atlandis
	function Card.IsAtlandis(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x506,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,9161357,6387204)
	end

	-- Barian (archetype) バリアン
	-- CXyz Barian Hope/ Number 71: Rebarian Shark
	function Card.IsBarian(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		if c:IsBarians(fbool) or c:IsBattleguard(fbool) then return true end
		return c:IsSetCard(0x509,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,67926903,59479050)
	end

	-- Barian's バリアンズ
	-- Rank-Up-Magic Barian's Force, Rank-Up-Magic Limited Barian's Force
	function Card.IsBarians(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x1509,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,47660516,92365601)
	end

	-- Battleguard バーバリアン
	AnimeArchetype.OCGBattleguard={
		-- Battleguard King, Lava Battleguard, Swamp Battleguard
		-- Battleguard Howling, Battleguard Rage
		39389320,20394040,40453765,78621186,42233477
	}
	function Card.IsBattleguard(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x2509,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGBattleguard))
	end

	-- Blackwing Tamer 
	-- ＢＦＴ
	-- ブラックフェザーテイマー
	-- Blackwing Tamer - Obsidian Hawk Joe
	function Card.IsBlackwingTamer(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x2033,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,81983656)
	end

	-- Butterfly
	-- 蝶
	-- ちょう
	-- Blazewing Butterfly/Flower Cardian Boardefly/Flower Cardian Peony with Butterfly
	-- Butterfly Dagger - Elma
	AnimeArchetype.OCGButterfly={
		16984449,69243953,57261568,3966653
	}
	function Card.IsButterfly(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		if c:IsPhantomButterfly(fbool) then return true end
		return c:IsSetCard(0x50c,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGButterfly))
	end

	-- Phantom Butterfly
	-- 幻蝶
	-- げんちょう
	-- Butterspy Protection
	AnimeArchetype.OCGPhantomButterfly={
		63630268
	}
	function Card.IsPhantomButterfly(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x150c,sc,sumtype,playerid) or c:IsSetCard(0x6a,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGPhantomButterfly))
	end

	-- C (archetype)
	-- Ｃ 
	-- カオス 
	-- is "C" or Cxyz or Cnumber
	function Card.IsC(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x1048,sc,sumtype,playerid) or c:IsSetCard(0x1073,sc,sumtype,playerid) or c:IsSetCard(0x568,sc,sumtype,playerid)
	end

	-- Cat キャット (list to update)
	-- Cat Shark/Nekogal #2/Mimicat
	-- Fluffal Cat/Crystal Beast Amethyst Cat/Majespecter Cat - Nekomata
	-- Magicat/Catnipped Kitty/Lunalight Cat Dancer
	-- Lunalight Blue Cat/Rescue Cat/Lock Cat
	-- Number 28/Watch Cat
	AnimeArchetype.OCGCat={
		84224627,43352213,88032456,2729285,32933942,5506791,
		25531465,96501677,51777272,11439455,14878871,52346240,
		54191698,70975131
	}
	function Card.IsCat(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x50e,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGCat))
	end

	-- Celestial 
	-- 天輪
	-- てんりん
	-- Celestial Double Star Shaman/Guiding Light
	function Card.IsCelestial(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x254a,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,69865139,25472513)
	end

	-- Champion 
	-- 王者
	-- おうじゃ
	-- Champion's Vigilance
	function Card.IsChampion(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x152f,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,82382815)
	end
	-- Clear クリアー
	-- Clear Vice Dragon/Clear World
	function Card.IsClear(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x510,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,97811903,82044279,33900648)
	end

	-- Comics Hero 
	-- ＣＨ
	-- コミックヒーロー
	-- CXyz Comics Hero Legend Arthur/Comics Hero King Arthur
	function Card.IsComicsHero(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x511,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,77631175,13030280)
	end

	-- Cubic Seed 
	-- 方界胤
	-- ほうかいいん 
	-- Vijam the cubic seed
	function Card.IsCubicSeed(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x10e3,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,CARD_VIJAM)
	end

	-- Dart ダーツ
	-- Fire Darts
	function Card.IsDart(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x513,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,43061293)
	end

	-- Dice (archetype) ダイス 
	-- Speedroid Red-Eyed Dice/Speedroid Tri-Eyed Dice/Dice Armadillo
	-- Dice Try!/Dice Jar/Dice Roll Battle
	-- Dice Re-Roll
	AnimeArchetype.OCGDice={
		16725505,27660735,69893315,59905358,3549275,88482761,
		83241722
	}
	function Card.IsDice(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x514,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGDice))
	end
	-- Dog ドッグ 
	-- Assault Dog/Mad Dog of Darkness/Ancient Gear Hunting Hound
	-- Performapal Bubblebowwow/Alien Dog/Guard Dog
	-- Kozmo DOG Fighter/Skull Dog Marron/Wind-Up Dog
	-- Chain Dog/Nin-Ken Dog/Watch Dog
	-- Fluffal Dog/Flamvell Firedog/Wroughtweiler
	-- Magidog/Mecha-Dog Marron
	AnimeArchetype.OCGDog={
		72714226,79182538,42878636,34379489,15475415,57346400,
		29491334,86652646,12076263,96930127,11987744,86889202,
		39246582,23297235,6480253,47929865,94667532
	}
	function Card.IsDog(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x516,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGDog))
	end

	-- Doll ドール
	-- Aqua Madoor/Tribute Doll/Malice Doll of Demise
	-- Neo Aqua Madoor/Rogue Doll/Lightray Madoor
	-- Gimmick Puppet Dreary Doll/Gimmick Puppet Magnet Doll
	AnimeArchetype.OCGDoll={
		72657739,91939608,85639257,2903036,49563947,82579942,
		92418590,39806198
	}
	function Card.IsDoll(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x517,sc,sumtype,playerid) or c:IsSetCard(0x9d,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGDoll))
	end


	-- Drone
	-- ドローン
	--Star Drawing/Doron/SPYRAL GEAR - Drone
	AnimeArchetype.OCGDrone={
		24610207,756652,4474060
	}
	function Card.IsDrone(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x581,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGDrone))
	end


	-- Druid ドルイド 
	-- Secret Sect Druid Wid/Secret Sect Druid Dru/Aurkus, Lightsworn Druid
	AnimeArchetype.OCGDruid={
		24062258,97064649,7183277
	}
	function Card.IsDruid(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x8c,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGDruid))
	end

	-- Dyson ダイソン 
	-- Number C9: Chaos Dyson Sphere/Number 9: Dyson Sphere
	function Card.IsDyson(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x519,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,1992816,32559361)
	end

	-- Earth (archetype) (to do)
	-- 地
	AnimeArchetype.OCGEarth={
		42685062,76052811,71564150,77827521,75375465,70595331,94773007,45042329,22082163,37970940,82140600,
		78783370,99426834,32360466,66500065,24294108,28120197,62966332,67494157,46372010,48934760,88696724,
		59820352,67105242,29934351,60866277,54407825,66788016,53778229,46181000,14258627,67113830,61468779,
		15545291,60229110,90502999,33970665,35762283,12247206,54109233,9628664,79109599,95993388,54976796,
		3136426,64681263,97612389,86016245,91020571,58601383,97204936,63465535,4587638,38296564,60627999,
		79569173,97169186,26381750,70156997,20590784,77428945,54762426,46918794,95220856,2084239,77754944
	}
	function Card.IsEarth(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		if c:IsEarthbound(fbool) or c:IsHell(fbool) then return true end
		return c:IsSetCard(0x51a,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGEarth))
	end

	-- Earthbound (list to update)
	-- 地縛
	-- じばく 
	-- Earthbound Revival/Roar of the Earthbound/Earthbound Whirlwind
	-- Earthbound Linewalker/Call of the Earthbound
	AnimeArchetype.OCGEarthbound={
		64187086,56339050,96907086,67987302,65743242
	}
	function Card.IsEarthbound(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x151a,sc,sumtype,playerid) or c:IsSetCard(0x21,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGEarthbound))
	end

	-- Elf エルフ 
	-- Ghost Fairy Elfobia/Wing Egg Elf/Elf's Light
	-- Ancient Elf/ Kozmoll Dark Lady/Shining Elf/
	-- Mystical Fairy Elfuria/Prediction Princess Petalelf/Dancing Elf
	-- Dark Elf /Gemini Elf/Toon Gemini Elf/ Flelf
	-- Blackwing - Elphin the Raven/Mystical Elf/Gift of The Mystical Elf
	AnimeArchetype.OCGElf={
		44663232,98582704,39897277,93221206,97170107,85239662,
		68625727,59983499,21417692,69140098,42386471,61807040,
		11613567,15025844,98299011
	}
	function Card.IsElf(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x51b,sc,sumtype,playerid) or c:IsSetCard(0xe4,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGElf))
	end

	-- Emissary of Darkness 
	-- 冥府の使者
	-- めいふのししゃ
	-- Gorz the Emissary of Darkness/Emissary of Darkness Token
	function Card.IsEmissaryOfDarkness(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x51c,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,44330098,44330099)
	end

	-- Fairy (archetype) フェアリー
	-- Ancient Fairy Dragon/CXyz Dark Fairy Cheer Girl/Nekogal #1
	-- Dancing Fairy/Fairy Archer/Fairy Cheer Girl
	-- Fairy Tail - Luna/Fairy Tail - Snow/Fairy Tail - Rella
	-- Fairy Tail - Sleeper/Fairy Dragon/Little Fairy
	-- Woodland Sprite
	AnimeArchetype.OCGFairy={
		25862681,23454876,1761063,90925163,48742406,51960178,
		86937530,55623480,52022648,42921475,20315854,45939611,
		6979239
	}
	function Card.IsFairy(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x51d,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGFairy))
	end

	-- Forest (archetype) 
	-- 森
	-- もり 
	-- Ancient Forest/Witch of the Black Forest/Naturia Forest
	-- Forest/Yellow Baboon, Archer of the Forest/Murmur of the Forest
	-- Wood Remains/Wodan the Resident of the Forest/Alpacaribou, Mystical Beast of the Forest
	-- Valerifawn, Mystical Beast of the Forest/Kalantosa, Mystical Beast of the Forest/Uniflora, Mystical Beast of the Forest
	-- Eco, Mystical Spirit of the Forest/Green Baboon, Defender of the Forest
	AnimeArchetype.OCGForest={
		77797992,87624166,14015067,4192696,87430998,46668237,60398723,37322745,36318200,24096499,78010363,42883273,65303664,17733394
	}
	function Card.IsForest(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x51f,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGForest))
	end

	-- Fossil (not finished) 
	-- 化石
	-- かせき
	-- Release from Stone/Fossil Dig/Fossil Excavation
	AnimeArchetype.OCGFossil={
		
	}
	function Card.IsFossil(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x512,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGFossil))
	end

	-- Gem-Knight Lady ジェムナイトレディ 
	-- Gem-Knight Lady Brilliant Diamond/Gem-Knight Lady Lapis Lazuli
	function Card.IsGemKnightLady(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x3047,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,47611119,19355597)
	end

	-- Gorgonic
	-- ゴルゴニック 
	-- Gorgonic Gargoyle/Gorgonic Guardian/Gorgonic Ghoul
	-- Gorgonic Cerberus/Gorgonic Golem
	AnimeArchetype.OCGGorgonic={
		64379261,84401683,98637386,37168514,90764875
	}
	function Card.IsGorgonic(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x522,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGGorgonic))
	end
	-- Goyo ゴヨウ 
	-- Brotherhood of the Fire Fist - Coyote/Goyo Emperor/Goyo Guardian
	-- Goyo King/Goyo Chaser/Goyo Defender
	-- Goyo Predator
	AnimeArchetype.OCGGoyo={
		49785720,59255742,7391448,84305651,63364266,58901502,
		98637386
	}
	function Card.IsGoyo(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x523,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGGoyo))
	end

	-- Granel
	-- グランエル
	function Card.IsGranel(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x524,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,2137678,4545683)
	end

	-- Hand (archetype) ハンド
	-- Ice Hand/Ancient Gear Fist/Performapal Sleight Hand Magician
	-- Number C106: Giant Red Hand/Koa'ki Meiru Powerhand/Comic Hand
	-- Kaminote Blow/The Judgement Hand/Number 106: Giant Hand
	-- Phantom Hand/Fire Hand/Prominence Hand
	-- Magic Hand/Rocket Hand/Hundred Eyes Dragon
	-- Left-Hand Shark/Right-Hand Shark

	AnimeArchetype.OCGHand={
		95929069,40830387,20403123,55888045,19642889,33453260,
		97570038,28003512,63746411,40555959,68535320,21414674,
		22530212,13317419,95453143,47840168,11845050
	}
	function Card.IsHand(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x527,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGHand))
	end

	-- Heavy Industry 
	-- 重機
	-- じゅうき 
	-- Digvorzhak, King of Heavy Industry/Heavy Freight Train Derricrane/Jumbo Drill
	AnimeArchetype.OCGHeavyIndustry={
		42851643,29515122,13647631
	}
	function Card.IsHeavyIndustry(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x529,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGHeavyIndustry))
	end

	-- Hell 
	-- 地獄
	-- ヘル 
	-- Hundred-Footed Horror/Chthonian Soldier/Mefist the Infernal General
	AnimeArchetype.OCGHell={
		36029076,46820049,50916353
	}
	function Card.IsHell(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x567,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGHell))
	end

	-- Heraldic 
	-- 紋章
	-- もんしょう
	-- Number 18: Heraldry Patriarch/Number 8: Heraldic King Genom-Heritage/Medallion of the Ice Barrier

	-- Heraldic
	function Card.IsHeraldic(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x566,sc,sumtype,playerid) or c:IsSetCard(0x76,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,23649496,47387961)
	end


	-- Hunder サンダー 
	-- Ally of Justice Thunder Armor/Evilswarm Thunderbird/Elemental HERO Thunder Giant
	-- Mahunder/Pahunder/Brohunder
	-- Sishunder/Phantom Beast Thunder-Pegasus/Gouki Thunder Ogre/
	-- Thunder End Dragon/Thunder Kid/Thunder Crash/
	-- Thunder Short/ Thunder Sea Horse/Thunder Dragon/
	-- Raigeki Break/Raigeki Bottle/Raigeki
	-- Thunder Unicorn/Twin-Headed Thunder Dragon/D/D/D Gust King Alexander / 
	-- D/D/D Gust High King Alexander / Number 91: Thunder Spark Dragon/ Black Thunder
	-- Blizzard Thunderbird/Blue Thunder T-45 Mega Thunderball/
	-- Thunder King, the Lightningstrike Kaiju
	AnimeArchetype.OCGHunder={
		71438011,78663366,21524779,84530620,27217742,57019473,
		34961968,15510988,69196160,20264508,48049769,31786629,
		52833089,50920465,14089428,21817254,48770333,61204971,
		30010480,698785,77506119,54752875,6766208,987311,
		84417082,4178474,11741041,12580477
	}
	function Card.IsHunder(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x565,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGHunder))
	end

	-- Inu 犬
	-- Mad Dog of Darkness/Ancient Gear Hunting Hound/Caninetaur
	-- Skull Dog Marron/Nin-Ken Dog/Watch Dog
	-- Zombowwow/Doomdog Octhros/Outstanding Dog Marron
	-- Mecha-Dog Marron/Yokotuner
	AnimeArchetype.OCGInu={
		79182538,42878636,91754175,
		86652646,11987744,86889202,
		27971137,58616392,11548522,
		94667532,27750191
	}
	function Card.IsInu(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x52a,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGInu))
	end

	-- Ivy アイヴィ 
	-- Wall of Ivy/Ivy Shackles/Ivy Token
	AnimeArchetype.OCGIvy={
		30069398,14730606,30069399
	}
	function Card.IsIvy(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x52b,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGIvy))
	end

	-- Jester ジェスター 
	-- Majester Paladin, the Ascending Dracoslayer/Jester Confit/Jester Lord
	AnimeArchetype.OCGJester={
		72992744,8487449,88722973,
	}
	function Card.IsJester(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x52c,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGJester))
	end

	-- Jutte ジュッテ
	-- Jutte Fighter
	function Card.IsJutte(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x52d,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,60410769)
	end

	-- King (not finished) 
	-- 王
	-- おう
	-- Brron, Mad King of Dark World/The Furious Sea King/Zeman the Ape King
	-- Hot Red Dragon Archfiend King Calamity/Royal Decree
	-- Royal Decree/Royal Decree/Royal Writ of Taxation
	-- Royal Oppression/Imperial Order/Imperial Iron Wall
	-- Royal Prison/Royal Tribute/Pharaoh's Treasure
	-- Pharaonic Protector/Temple of the Kings/Necrovalley
	-- Curse of Royal/King Tiger Wanghu/King's Consonance
	-- King's Consonance/Protector of the Throne/Invader of the Throne
	-- Guardian of the Throne Room/Trial of the Princesses
	-- Royal Keeper/Trap of the Imperial Tomb/Royal Magical Library
	-- Brotherhood of the Fire Fist - Tiger King/Gash the Dust Lord
	-- Number C65: King Overfiend/The Twin Kings, Founders of the Empire/Machine King
	-- Machine King - 3000 B.C./Machine King Prototype/Magical King Moonstar
	-- Barbaroid, the Ultimate Battle Machine/Unformed Void/Amorphactor Pain, the Imagination Dracoverlord
	-- Phantom King Hydride/Gazelle the King of Mythical Beasts/Queen of Autumn Leaves
	-- Ice Queen/Pumpking the King of Ghosts/Lich Lord, King of the Underworld
	-- King Pyron/Demise, King of Armageddon
	-- Dark King of the Abyss/Abyssal Kingshark/Machine Lord Ür
	-- Alector, Sovereign of Birds/Beast King Barbaros/Leo, the Keeper of the Sacred Tree
	-- Sacred Noble Knight of King Artorigus/Endymion, the Master Magician/Digvorzhak, King of Heavy Industry
	-- Beast Machine King Barbaros Ür/Queen's Bodyguard/Queen's Bodyguard
	-- Queen's Pawn/Skull Archfiend of Lightning/Emperor of the Land and Sea
	-- Artorigus, King of the Noble Knights/Gwenhwyfar, Queen of Noble Arms/Hieratic Dragon King of Atum
	-- Absolute King Back Jack/Big Eye/Superancient Deepsea King Coelacanth
	-- Super Quantal Mech King Great Magnus/Princess of Tsurugi
	-- Shinato, King of a Higher Plane/Dark Highlander/Celestial Wolf Lord, Blue Sirius
	-- D/D/D Destiny King Zero Laplace
	-- D/D/D Oblivion King Abyss Ragnarok
	-- D/D/D Chaos King Apocalypse
	-- D/D/D Dragonbane King Beowulf
	-- D/D/D Doom King Armageddon
	-- D/D/D Gust High King Executive Alexander
	-- D/D/D Oracle King d'Arc
	-- D/D/D Cursed King Siegfried
	-- D/D/D Supreme King Kaiser
	-- D/D/D Duo-Dawn King Kali Yuga
	-- D/D/D Marksman King Tell
	-- D/D/D Superdoom King Purplish Armageddon
	-- D/D/D Wave King Caesar
	-- D/D/D Wave Oblivion King Caesar Ragnarok
	-- D/D/D Wave High King Executive Caesar
	-- D/D/D Dragon King Pendragon
	-- D/D/D Rebel King Leonidas
	-- D/D/D Stone King Darius
	-- D/D/D Flame King Genghis
	-- D/D/D Flame High King Executive Genghis
	-- D/D/D Gust King Alexander
	-- Vennominon the King of Poisonous Snakes/Number 8: Heraldic King Genom-Heritage/Rise to Full Height
	-- King of the Swamp/Beastking of the Swamps/Imperial Tombs of Necrovalley
	-- Coach King Giantrainer/Coach Captain Bearman

	-- archtype:Fire King/Supreme King/Monarch (spell/trap)/Dracoverlord
	AnimeArchetype.OCGKing={
		60990740,13662809,44223284,17573739,89832901,41925941,78651105,19028307,99426834,16768387,6214884,67136033,
		2926176,21686473,47198668,56619314,74069667,92536468,73360025,53375573,53982768,72426662,29424328,11250655,
		68400115,40732515,57274196,45425051,10833828,18710707,30646525,19012345,5818798,22910685,47879985,19748583,
		64514622,14462257,30459350,61740673,90434657,3056267,20438745,83986578,79109599,24590232,55818463,46700124,
		70406920,89222931,96938777,21223277,54702678,34408491,96381979,32995007,30741334,44852429,8463720,15939229,
		74583607,987311,71612253,82956492,51497409,3758046,75326861,70583986,29515122,28290705,27337596,62242678,
		35058857,CARD_NECROVALLEY,47387961,6901008,18891691,63571750,89959682,43791861,51371017,82213171,10071456,29155212,
		4179849,71411377,5901497,58477767,19254117,33950246,51452091,16509093,93016201,26586849,56058888,72405967,
		86742443,86327225,61370518,88307361,29762407,80955168,72709014,24857466,52589809,5309481,10613952,84025439,
		38180759,22858242
	}
	function Card.IsKing(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		if c:IsChampion(fbool) then return true end
		return c:IsSetCard(0x52f,sc,sumtype,playerid) or c:IsSetCard(0xf8,sc,sumtype,playerid) or c:IsSetCard(0x81,sc,sumtype,playerid) or c:IsSetCard(0xda,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGKing))
	end

	-- Knight (not finished) ナイト 
	-- Arcana Knight Joker/Dark Titan of Terror/Ancient Gear Knight
	-- Arma Knight/Arcanite Magician/ Arcanite Magician/Assault Mode
	-- D.D. Unicorn Knight/Insect Knight/Infernity Knight
	-- Evilswarm Nightmare/Serpent Night Dragon/Elemental HERO Neos Knight
	-- Airknight Parshath/Alien Ammonite/Ojama Knight
	-- Chronomaly Gordian Knot/Number C101: Silent Honor DARK/Kagemucha Knight
	-- Ganbara Knight/King's Knight/Gimmick Puppet Twilight Joker
	-- Gimmick Puppet Nightmare/Galaxy Knight/King's Knight
	-- Quick-Span Knight/Mirage Knight/Koa'ki Meiru Urnight
	-- Cockroach Knight/Dark Flare Knight/Copy Knight
	-- Command Knight/Ghostrick Night/Cipher Mirror Knight
	-- Succubus Knight/Big Belly Knight/Shine Knight
	-- Shadowknight Archfiend/Doomcaliber Knight/Night Express Knight
	-- Jade Knight/Jack's Knight/Jutte Fighter
	-- Skull Knight #2/Zubaba Knight/Divine Knight Ishzark
	-- Wind-Up Knight/Tasuke Knight/Tatakawa Knight
	-- Gaia Knight, the Force of Earth/XX-Saber Fulhelmknight/XX-Saber Boggart Knight
	-- D/D Nighthowl/Toy Knight/Dragunity Knight - Vajrayana
	-- Dragunity Knight - Gae Dearg/Dragunity Knight - Gae Bulg/Dragunity Knight - Trident
	-- Dragunity Knight - Barcha/Dragonic Knight/Night Assailant
	-- Night's End Sorcerer/Paladin of Photon Dragon/Paladin of Dark Dragon
	-- Paladin of White Dragon/Night Beam/Knight Day Grepher
	-- Night Dragolich/Night Papilloperative/Nightmare Scorpion
	-- Theban Nightmare/Nightmare Archfiends/Nightmare Horse
	-- Reaper on the Nightmare/Night Lizard/Twilight Rose Knight
	-- Number 101: Silent Honor ARK/Number 47: Nightmare Shark/
	-- Supreme Arcanite Magician/Valkyrian Knight/Royal Knight of the Ice Barrier
	-- Vivid Knight/Pixie Knight/Familiar Knight
	-- Paladin of the Cursed Dragon/Dark Magician Knight/Blade Knight
	-- Penguin Knight/Nightmare Penguin/Seiyaryu/Avenging Knight Parshath
	-- Dragon Master Knight/Mermaid Knight/Midnight Fiend
	-- Super Roboyarou,Red-Eyes Metal Knight Gearfried

	-- TellarKnight/Igknight/Gem-Knight
	AnimeArchetype.OCGKnight={
		24435369,83678433,1412158,85651167,89494469,39303359,36151751,14553285,95291684,35052053,
		71341529,66516792,18036057,652362,72837335,19353570,24291651,64788463,92821268,55204071,
		35950025,11287364,49217579,30936186,33413638,21843307,10375182,85827713,58383100,62873545,
		55291359,32696942,86952477,9603356,78700060,51126152,44364207,90876561,60410769,15653824,
		97896503,57902462,80538728,86039057,18444902,78422252,5998840,48210156,1826676,38109772,
		16226786,36107810,85346853,71408082,73398797,89882100,15767889,88724332,88643173,51838385,
		42956963,59290628,78402798,6150044,31924889,359563,72926163,40391316,12744567,97204936,
		21249921,34116027,900787,80159717,25682811,2191144,85684223,48739166,2986553,31320433,
		99348756,66661678,52575195,35429292,89731911,68670547,50725996,39507162,36039163,81306586,
		6740720,69514125
	}
	function Card.IsKnight(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x530,sc,sumtype,playerid) or c:IsSetCard(0x1047,sc,sumtype,playerid) or c:IsSetCard(0x9c,sc,sumtype,playerid) or c:IsSetCard(0xc8,sc,sumtype,playerid) 
				or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGKnight))
	end

	-- Koala コアラ 
	AnimeArchetype.OCGKoala={
		-- Big Koala, Des Koala, Vampire Koala, Sea Koala, Koalo-Koala, Tree Otter
		42129512,69579761,1371589,87685879,7243511,71759912,
	}
	function Card.IsKoala(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x531,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGKoala))
	end

	-- Lamp ランプ 
	-- Performapal Trump Witch/Performapal Trump Girl/Mech Mole Zombie
	-- F.A. Circuit Grand Prix/Ancient Lamp/Mystic Lamp
	-- Lord of the Lamp/ La Jinn the Mystical Genie of the Lamp
	AnimeArchetype.OCGLamp={
		54912977,97590747,98049915, 39838559,99510761,91584698,
		id02073,63545455
	}
	function Card.IsLamp(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x532,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGLamp))
	end

	-- Landstar ランドスター 
	-- Comrade Swordsman of Landstar/Swordsman of Landstar
	function Card.IsLandstar(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x533,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,3573512,83602069)
	end

	-- Line Monster ラインモンスター 
	-- Number 72: Shogi Rook/Shogi Knight/Shogi Lance
	AnimeArchetype.OCGLineMonster={
		32476434,41493640,75253697
	}
	function Card.IsLineMonster(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x564,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGLineMonster))
	end

	-- Magnet 
	-- 磁石
	-- マグネット
	function Card.IsMagnet(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x534,sc,sumtype,playerid) or c:IsSetCard(0x2066,sc,sumtype,playerid)
	end

	-- Mantis カマキリ
	-- Empress Mantis
	AnimeArchetype.OCGMantis={
		58818411
	}
	function Card.IsMantis(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x535,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGMantis))
	end

	-- Melodious Songstress 
	-- 幻奏の歌姫
	-- げんそうのうたひめ
	-- Soprano the Melodious Songstress/Solo the Melodious Songstress
	function Card.IsMelodiousSongtress(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x209b,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,14763299,62895219)
	end

	-- Motor モーター 
	-- Fiendish Engine Ω
	function Card.IsMotor(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x537,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,82556058)
	end

	-- Neko 猫
	-- Dark Cat with White Tail/Kinka-byo/Black Cat-astrophe
	-- Ghostrick Nekomusume/Watch Cat/A Cat of Ill Omen/
	-- Lunalight Cat Dancer/Lunalight Blue Cat/Quantum Cat
	AnimeArchetype.OCGNeko={
		8634636,45452224,67381587,24101897,70975131,24140059,
		51777272,11439455,87772572
	}
	function Card.IsNeko(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x538,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGNeko))
	end

	-- Number 39: Utopia (archetype)  
	-- Ｎｏ．３９ 希望皇ホープ
	-- ナンバーズ３９ きぼうおうホープ 
	-- Number S39: Utopia the Lightning/Number S39: Utopia Prime/Number 39: Utopia
	-- Number 39: Utopia Roots
	AnimeArchetype.OCGN39Utopia={
		56832966,86532744,84013237,
		84124261
	}
	function Card.IsN39Utopia(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		if Card.IsCN39UtopiaRay(c,sc,sumtype,playerid) then return true end
		return c:IsSetCard(0x539,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGN39Utopia))
	end

	-- Number C39: Utopia (archetype) 
	-- ＣＮｏ．３９ 希望皇ホープレイ 
	-- カオスナンバーズ３９ きぼうおうホープレイ 
	-- Number C39: Utopia Ray/Number C39: Utopia Ray Victory/Number C39: Utopia Ray V
	AnimeArchetype.OCGCN39UtopiaRay={
		56840427,87911394,66970002
	}
	function Card.IsCN39UtopiaRay(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x1539,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGCN39UtopiaRay))
	end
	-- Number S 
	-- ＳＮｏ.
	-- シャイニングナンバーズ 
	-- Number S39: Utopia the Lightning/Number S39: Utopia the Lightning/Number S0: Utopic ZEXAL
	AnimeArchetype.OCGNumberS={
		52653092,56832966,86532744
	}
	function Card.IsNumberS(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x2048,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGNumberS))
	end

	-- Numeron ヌメロン 
	-- Number 100: Numeron Dragon
	-- Rank-Up-Magic Numeron Force
	-- Rank-Down-Magic Numeron Fall
	AnimeArchetype.OCGNumeron={
		57314798,48333324,71345905
	}
	function Card.IsNumeron(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x53a,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGNumeron))
	end

	-- Papillon パピヨン
	-- Moonlit Papillon
	function Card.IsPapillon(c,sc,sumtype,playerid) 
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x53c,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,16366944)
	end

	-- Parasite パラサイト
	-- Graydle Parasite/Fusion Parasite
	function Card.IsParasite(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x53d,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,49966595,6205579)
	end

	-- Pixie (not finished) 
	-- 妖精
	-- ようせい
	-- Ghost Fairy Elfobia/Fairy of the Fountain/Prickle Fairy
	-- Dreamsprite/Mystical Fairy Elfuria/Star Grail Fairy Ries
	-- Super Quantal Fairy Alphan/Rose Fairy/Fairy King Albverdich
	-- Fairy King Truesdale/Fairy Knight Ingunar/Fairy's Gift/
	-- Fairy Wind/Ancient Pixie Dragon
	AnimeArchetype.OCGPixie={
		44663232,81563416,91559748,8687195,85239662,21893603,
		90925163,58753372,44125452,42921475,52022648,55623480,
		86937530,45425051,28290705,19684740,68401546,73507661,
		4179255
	}
	function Card.IsPixie(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x53e,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGPixie))
	end

	-- Priestess 
	-- 巫女
	-- みこ
	-- Priestess with Eyes of Blue/Maiden of the Aqua/Winda, Priestess of Gusto
	-- Time Maiden/Star Grail-Bearing Priestess/Ariel, Priestess of the Nekroz/
	-- Gravekeeper's Priestess
	AnimeArchetype.OCGPriestess={
		95511642,56827051,3381441,27107590,36734924,54455435,
		17214465
	}
	function Card.IsPriestess(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x53f,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGPriestess))
	end

	-- Puppet パペット
	-- Puppet Master/Junk Puppet/Puppet Ritual
	-- Puppet King/Puppet Plant
	AnimeArchetype.OCGPuppet={
		67968069,3167573,41442341,51119924,1969506
	}
	function Card.IsPuppet(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x540,sc,sumtype,playerid) or c:IsSetCard(0x83,sc,sumtype,playerid) or c:IsSetCard(0x152c,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGPuppet))
	end

	-- Raccoon (not finished) 狸
	-- Baby Raccoon Tantan/Baby Raccoon Ponpoko/Turtle Raccoon
	-- Number 64: Ronin Raccoon Sandayu/Kagemusha Raccoon Token
	AnimeArchetype.OCGRacoon={
		92729410,28118128,39972130,39972129,17441953
	}
	function Card.IsRaccoon(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x542,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGRacoon))
	end

	-- Red (archetype) レッド	 Last updated by 16th Apr 2020
	-- Sub-archetype: Red-Eyes/Red Dragon Archfiend
	-- U.A. Dreadnought Dunker/Vampire Red Baron/Xtra HERO Dread Decimator/Eternal Dread
	-- Ojama Red/Number C106: Giant Red Hand/Construction Train Signal Red/The Wicked Dreadroot
	-- Red Carpet/Red Cocoon/Red Supernova Dragon/Red Nova Dragon
	-- Red Familiar/Red Rain/Red Screen/SPYRAL GEAR - Big Red
	-- Noble Knight Medraut/Dark Red Enchanter/Super Quantum Red Layer/Destiny HERO - Dreadmaster
	-- Destiny HERO - Dread Servant/Dread Dragon/Number 27: Dreadnought Dreadnoid/Red Warg
	-- Akakieisu/Red Gadget/Red Gardna/Opticlops
	-- Red Sprinter/Red Supremacy/Red Duston/Tyhone #2
	-- Crimson Ninja/Red Nova/Red Medicine/Red Mirror
	-- Red Rising Dragon/Red Resonator/Red Reboot/Emergeroid Call
	-- Red Rose Dragon/Red Wyvern/Lord of the Red/Hundred Eyes Dragon
	AnimeArchetype.OCGRed={
		71279983,6917479,63813056,35787450,
		37132349,55888045,34475451,62180201,
		41197012,2542230,99585850,97489701,
		8372133,5376159,18634367,30979619,
		59057152,45462639,59975920,40591390,
		36625827,51925772,8387138,45313993,
		38035986,86445415,72318602,14531242,
		14886469,50584941,61019812,56789759,
		14618326,21142671,38199696,8706701,
		66141736,40975574,23002292,70628672,
		26118970,76547525,19025379,95453143
	}
	function Card.IsRed(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x543,sc,sumtype,playerid)
			or c:IsSetCard(0x3b,sc,sumtype,playerid)
			or c:IsSetCard(0x1045,sc,sumtype,playerid)
			or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGRed))
	end

	-- Seal 
	-- 封じ
	-- ふうじ
	-- Mask of Restrict/Block Attack/Stop Defense
	-- Anti-Spell Fragrance
	AnimeArchetype.OCGSeal={
		63102017,29549364,25880422,58921041,
	}
	function Card.IsSeal(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x545,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGSeal))
	end

	-- Shaman シャーマン 
	-- Elemental HERO Necroid Shaman/Sylvan Sagequoia/The Legendary Fisherman
	-- The Legendary Fisherman III/The Legendary Fisherman II/Lumina, Twilightsworn Shaman
	-- Neo Flamvell Shaman
	AnimeArchetype.OCGShaman={
		81003500,10530913,3643300,44968687,19801646,56166150,
		39761138
	}
	function Card.IsShaman(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x546,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGShaman))
	end

	-- Shark (archetype)シャーク 
	-- Eagle Shark/Hyper-Ancient Shark Megalodon/Number C32: Shark Drake Veiss
	-- Shark Caesar/Cat Shark/Gazer Shark
	-- Cyber Shark/Shark Stickers/Shark Cruiser
	-- Shark Fortress/Sharkraken/Abyssal Kingshark
	-- Scrap Shark/Spear Shark/Saber Shark
	-- Submersible Carrier Aero Shark/Brandish Mecha Shark Cannon/Wind-Up Shark
	-- Double Fin Shark/Double Shark/Corroding Shark
	-- Depth Shark/Number 37: Hope Woven Dragon Spider Shark/Number 32: Shark Drake
	-- Number 71: Rebarian Shark/Number 47: Nightmare Shark/Hammer Shark
	-- Bahamut Shark/Panther Shark/Mermaid Shark
	-- Metabo-Shark/Left-Hand Shark/Right-Hand Shark
	AnimeArchetype.OCGShark={
		7500772,10532969,49221191,14306092,84224627,23536866,
		32393580,20838380,20358953,50449881,71923655,44223284,
		69155991,70655556,63193879,5014629,51227866,25484449,
		64319467,17643265,34290067,37798171,37279508,65676461,
		59479050,31320433,17201174,440556,70101178,87047161,
		37792478,47840168,11845050
	}
	function Card.IsShark(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x547,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGShark))
	end

	-- Shining (not finished) シャイニング
	-- Elemental HERO The Shining/Elemental HERO Shining Phoenix Enforcer/Elemental HERO Shining Flare Wingman
	-- Leeching the Light/SZW - Fenrir Sword/Shining Hope Road
	-- Radiant Mirror Force/Number 104: Masquerade/Blue-Eyes Shining Dragon

	-- Number S
	AnimeArchetype.OCGShining={
		22061412,88820235,25366484,62829077,53347303,90263923,12927849,21481146,2061963
	}
	function Card.IsShining(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		if c:IsNumberS(fbool) then return true end
		return c:IsSetCard(0x548,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGShining))
	end

	-- Skiel
	-- スキエル
	function Card.IsSkiel(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x549,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,31930787,75733063)
	end

	-- Sky (not finished) 
	-- 天
	-- てん
	-- Fire Formation - Tenki/Fire Formation - Tenken/Fire Formation - Tensu
	-- Fire Formation - Tensen/Slifer the Sky Dragon/Injection Fairy Lily
	-- Number C9: Chaos Dyson Sphere/Crow Goblin/Absorbing Kid from the Sky
	-- Earthshattering Event/Great Long Nose/Phantasm Spiral Assault
	-- Cyber Angel Idaten/Cyber Angel Benten/Balance of Judgment
	-- Grand Horn of Heaven/Horn of Heaven/Black Horn of Heaven
	-- A Wild Monster Appears!/Gaia Drake, the Universal Force/Needle Ceiling
	-- Unification/Tenkabito Shien/Ascension Sky Dragon
	-- The Fountain in the Sky/Sky Iris/Zeradias, Herald of Heaven
	-- The Sanctuary in the Sky/Cards from the Sky/Goblin Fan
	-- Dark Highlander/Sky Galloping Gaia the Dragon Champion/Lullaby of Obedience
	-- Beginning of Heaven and Earth/Ehther the Heavenly Monarch/Edea the Heavenly Squire
	-- Divine Wrath/Convulsion of Nature/Sky Scourge Invicil
	-- Sky Scourge Enrise/Sky Scourge Norleras/Tenmataitei
	-- Noble Arms of Destiny/Card of Sanctity/Celestial Wolf Lord, Blue Sirius
	-- Number 9: Dyson Sphere/Number 44: Sky Pegasus/Blustering Winds
	-- Blackwing - Jetstream the Blue Sky/Blackwing - Hillen the Tengu-wind/
	-- Ancient Brain/World of Prophecy/Reborn Tengu/Rose Bell of Revelation

	-- Nordic Ascendant/Skyscraper
	AnimeArchetype.OCGSky={
		49771608,42431843,67443336,32360466,50323155,3072808,87390067,22346472,42664989,54977057,62966332,77998771,
		77235086,3629090,49010598,54407825,95457011,96570609,92223641,4149689,1637760,39238953,38411870,7452945,
		97795930,10028593,86327225,27813661,11458071,48453776,74841885,10000020,41589166,90122655,95352218,23587624,
		29146185,37910722,32995007,75326861,58601383,1992816,80764541,23085002,32559361,2519690,12171659,80196387
	}
	function Card.IsSky(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		if c:IsCelestial(fbool) or c:IsAngel(fbool) then return true end
		return c:IsSetCard(0x54a,sc,sumtype,playerid) or c:IsSetCard(0xf6,sc,sumtype,playerid) or c:IsSetCard(0x3042,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGSky))
	end

	-- Slime スライム 
	-- Slime Toad/Graydle Slime/Graydle Slime Jr.
	-- Jam Breeding Machine/Slime token/Change Slime
	-- Jam Defender/D/D Swirl Slime/D/D Necro Slime
	-- Humanoid Slime/Magical Reflect Slime/Metal Reflect Slime
	-- Revival Jam
	AnimeArchetype.OCGSlime={
		31709826,46821314,3918345,26905245,5600127,45206713,
		72291412,21770261
	}
	function Card.IsSlime(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x54b,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGSlime))
	end

	-- Sphere スフィア 
	-- Abyss-sphere/Vylon Sphere/Number C9: Chaos Dyson Sphere
	-- The Atmosphere/Sphere of Chaos/Blast Sphere
	-- Daigusto Sphreez/Darkness Neosphere/Troposphere
	-- Transforming Sphere/Number 9: Dyson Sphere/Heliosphere Dragon
	-- Thought Ruler Archfiend/The Winged Dragon of Ra - Sphere Mode
	AnimeArchetype.OCGSphere={
		60202749,75886890,32559361,14466224,82693042,26302522,
		29552709,60417395,72144675,66094973,1992816,51043053,
		70780151,10000080
	}
	function Card.IsSphere(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x54c,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGSphere))
	end

	--- Spirit (archetype) 
	--- 精霊 
	--- スピリット
	--- Blue-Eyes Spirit Dragon
	function Card.IsSpirit(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return (c:IsSetCard(0x54e,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,CARD_BLUEEYES_SPIRIT))
	end

	-- Starship スターシップ
	-- Starship Spy Plane
	-- Number 42: Galaxy Tomahawk
	function Card.IsStarship(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x54f,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,15458892,10389142)
	end

	-- Statue スタチュー
	-- Tiki Curse/Guardian Statue/Tiki Soul
	-- Dragon Statue
	AnimeArchetype.OCGStatue={
		75209824,3129635,49514333,9197735
	}
	function Card.IsStatue(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x550,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGStatue))
	end

	-- Stone (list to do)
	-- 岩石 
	-- がんせき
	-- Boulder Tortoise/Giant Soldier of Stone/Rock Spirit/Sentry Soldier of Stone
	AnimeArchetype.OCGStone={
		9540040,13039848,82818645,57354389
	}
	function Card.IsStone(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x551,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGStone))
	end

	-- Superheavy
	-- 超重
	-- ちょうじゅう 

	-- Tachyon タキオン
	AnimeArchetype.OCGTachyon={
		-- Tachyon Transmigrassion, Tachyon Chaos Hole
		8038143,59650656
	}
	function Card.IsTachyon(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		if c:IsTachyonDragon(fbool) then return true end
		return c:IsSetCard(0x555,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGTachyon))
	end

	-- Tachyon Dragon 
	-- 時空竜
	-- タキオン・ドラゴン
	AnimeArchetype.OCGTachyonDragon={
		-- N107, CN107
		88177324,68396121
	}
	function Card.IsTachyonDragon(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x1555,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGTachyonDragon))
	end

	-- Toy トイ
	-- Performapal Parrotrio/Stoic Challenge/Toy Knight/
	-- Divine Knight Ishzark/Toy Vendor/Toy Magician/
	-- Light Laser


	AnimeArchetype.OCGToy={
		56675280,37364101,1826676,57902462,70245411,58132856,
		11471117
	}
	function Card.IsToy(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x559,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGToy))
	end

	-- Toy (ARC-V archetype) トーイ
	function Card.IsToyArcV(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x55a,sc,sumtype,playerid) or c:IsSetCard(0xad,sc,sumtype,playerid) 
	end

	--V (GX Archetype)
	AnimeArchetype.OCGV={
		97574404,62017867,96746083,51638941,21208154,62180201,57793869,88581108,58859575,84243274
		--LV, Vision HERO
	}
	function Card.IsV(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		if c:Is_V_(fbool) then return true end
		return c:IsSetCard(0x55a,sc,sumtype,playerid) or c:IsSetCard(0x41,sc,sumtype,playerid) or c:IsSetCard(0x5008,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGV))
	end

	-- V (Zexal archetype)
	-- V
	-- ブイ

	-- Number C39: Utopia Ray V/V Salamander/V－LAN Hydra/V-LAN Token
	function Card.Is_V_(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x155a,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,33725002,66970002,13536606,13536607)
	end

	--W
	-- Arcana Force XXI - The World/VW-Tiger Catapult/VWXYZ-Dragon Catapult Cannon
	-- Malefic Claw Stream/Malefic World/Earthbound Immortal Wiraqocha Rasca/
	-- W Nebula Meteorite/Ride of the Valkyries
	AnimeArchetype.OCGW={
		23846921,41181774,27564031,90075978,96300057,58859575,
		84243274,65687442
		--Windwitch/ ZW
	}

	function Card.IsW(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x56b,sc,sumtype,playerid) or c:IsSetCard(0xf0,sc,sumtype,playerid) or c:IsSetCard(0x7e,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGW))
	end

	-- White ホワイト
	-- Great White/Cyberse Whitehat/Malefic Blue-Eyes White Dragon
	-- The All-Seeing White Tiger/Deep-Eyes White Dragon/ Paladin of White Dragon/ 
	-- Naturia White Oak/White Night Dragon/Blue-Eyes Alternative White Dragon/
	-- Blue-Eyes White Dragon/ The White Stone of Ancients/The White Stone of Legend/
	-- White Aura Dolphin/White Aura Biphamet/White Aura Whale/

	-- White Aura Monokeros/ White Salvation/White Magical Hat/
	-- White Stingray/White Duston/White Dolphin/
	-- White Night Queen/White ninja/White Howling/
	-- White Hole/White-Horned Dragon / White Potan
	-- White Moray/Lunalight White Rabbit
	-- White Mirror
	AnimeArchetype.OCGWhite={
		13429800,46104361,9433350,
		32269855,22804410,73398797,
		24644634,79473793,38517737,
		CARD_BLUEEYES_W_DRAGON,71039903,79814787,
		78229193,89907227,5614808,
		63731062,63509474,15150365,
		49930315,3557275,92409659,
		20193924,1571945,62487836,
		43487744,73891874,98024118,
		84812868,32825095,84335863,
		19885332
	}
	function Card.IsWhite(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x55d,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGWhite))
	end

	-- Wisel
	-- ワイゼル
	-- Meklord Emperor Wisel/Meklord Army of Wisel
	function Card.IsWisel(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x560,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,68140974,39648965)
	end

	--X
	AnimeArchetype.OCGX={
		18000338,69831560,5861892,61156777,55410871,87526784,98535702,21598948,71525232,5257687,37745919,81823360,81913510,
		46008667,40253382,11264180,3868277,58258899,48605591,12181376,93130021,62651957,86559484,30562585,28912357,19891310,
		84243274,2111707,91998119,99724761
		--CXyz, X-Saber
	}

	function Card.IsX(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x56c,sc,sumtype,playerid) or c:IsSetCard(0x1073,sc,sumtype,playerid) or c:IsSetCard(0x100d,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGX))
	end

	--Y
	AnimeArchetype.OCGY={
		23915499,76895648,56111151,3912064,911883,14731897,65622692,81332143,84243274,2111707,91998119,25119460
		--PSYFrame
	}

	function Card.IsY(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x56d,sc,sumtype,playerid) or c:IsSetCard(0xc1,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGY))
	end


	-- Yomi 黄泉
	-- Treeborn Frog
	-- Yomi Ship
	AnimeArchetype.OCGYomi={
		12538374,51534754
	}
	function Card.IsYomi(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x563,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,12538374,51534754)
	end

	-- Yubel (archetype) ユベル
	AnimeArchetype.OCGYubel={
		-- Yubel, Yubel terror, Yubel nighmare
		78371393,4779091,31764700
	}
	function Card.IsYubel(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x561,sc,sumtype,playerid)  or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGYubel))
	end

	--Z
	AnimeArchetype.OCGZ={
		50319138,95027497,29389368,64500000,62499965,30562585,51865604,65172015,40854197,27134689,84243274,91998119,99724761,25119460
		--ZW -
	}

	function Card.IsZ(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x56e,sc,sumtype,playerid) or c:IsSetCard(0x7e,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGZ))
	end

	-- ∞ (Infinity)
	-- ∞
	-- インフィニティ
	-- Meklord Astro Mekanikle/Meklord Emperor Granel/Meklord Emperor Skiel/
	-- Meklord Emperor Wisel
	AnimeArchetype.OCGInfinity={
		63468625,4545683,31930787,68140974
	}
	function Card.IsInfinity(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x562,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGInfinity))
	end


	-- Monarch
	-- 帝
	-- てい
	-- Mobius the Frost Monarch/Strike of the Monarchs/The First Monarch
	-- Caius the Shadow Monarch/Granmarg the Mega Monarch/Escalation of the Monarchs
	-- March of the Monarchs/Pantheism of the Monarchs/Erebus the Underworld Monarch
	-- Mobius the Mega Monarch/Thestalos the Firestorm Monarch/The Monarchs Awaken
	-- Tenacity of the Monarchs/The Monarchs Erupt/Zaborg the Thunder Monarch
	-- The Prime Monarch/Kuraz the Light Monarch/Granmarg the Rock Monarch
	-- Return of the Monarchs/Angmarl the Fiendish Monarch/Thestalos the Mega Monarch
	-- Raiza the Mega Monarch/Raiza the Storm Monarch/The Monarchs Stormforth
	-- Domain of the True Monarchs/Delg the Dark Monarch/Caius the Mega Monarch
	-- Zaborg the Mega Monarch/Ehther the Heavenly Monarch/Frost Blast of the Monarchs
	-- Edea the Heavenly Squire/Eidos the Underworld Squire/Tenmataitei
	-- Emperor of the Land and Sea/Garum the Storm Vassal/Mithra the Thunder Vassal
	-- Escher the Frost Vassal/Lucius the Shadow Vassal/Berlineth the Firestorm Vassal
	-- Landrobe the Rock Vassal/Bujintei Kagutsuchi/Indiora Doom Volt the Cubic Emperor
	-- Meklord Emperor Granel/Meklord Emperor Skiel/Meklord Emperor Wisel
	-- Boon of the Meklord Emperor/The Great Emperor Penguin/Shark Caesar
	-- Empress Judge/Starliege Lord Galaxion/Geira Guile the Cubic King
	-- Royal Firestorm Guards/Empress Mantis/Bujintei Tsukuyomi
	-- Vulcan Dragni the Cubic King/Bujintei Susanowo/Mausoleum of the Emperor
	-- Odin, Father of the Aesir/Cyber Angel Natasha/Chaos Emperor Dragon - Envoy of the End
	-- Amazoness Empress/Vampire Kingdom/Susa Soldier/Musician King
	AnimeArchetype.OCGMonarch={
	4929256,5795980,8522996,9748752,15545291,18235309,
	9870120,22842126,23064604,23689697,26205777,26822796,
	33609262,48716527,51945556,54241725,57666212,60229110,
	61466310,65612386,69230391,69327790,73125233,79844764,
	84171830,85718645,87288189,87602890,96570609,99940363,
	95457011,59463312,90122655,11250655,22382087,22404675,
	24326617,58786132,59808784,95993388,1855932,3775068,
	4545683,31930787,68140974,12986778,6836211,14306092,
	15237615,40390147,40392714,54040221,58818411,73289035,
	75840616,77387463,80921533,93483212,99427357,82301904,
	04591250,62188962,40473581,56907389
	}
	function Card.IsMonarch(c,sc,sumtype,playerid)
		sumtype=sumtype or 0
		playerid=playerid or PLAYER_NONE
		return c:IsSetCard(0x571,sc,sumtype,playerid) or c:IsSetCard(0xbe,sc,sumtype,playerid) or c:IsSummonCode(sc,sumtype,playerid,table.unpack(AnimeArchetype.OCGMonarch))
	end

end
