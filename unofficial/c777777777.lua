--Rule of the Day: Forbidden Acquisition
--At the start of each Draw Phase, each player is shown 3 random banned cards from the Worlds Forbidden/Limited list.
--They select one and apply the following, depending on what it is:
--Spell: Add it to their hand
--Trap: either add it to their hand OR set it, instead. It can be activated this turn.
--Monster: Add it to their hand (or to their Extra Deck, if it cannot be placed in the hand)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCountLimit(1)
	e1:SetOperation(s.operation)
	Duel.RegisterEffect(e1,0)
	local e2=e1:Clone()
	Duel.RegisterEffect(e2,1)
end

local banned_cards={
21044178, --Abyss Dweller
62320425, --Agido the Ancient Sentry
91869203, --Amazoness Archer
4280258, --Apollousa, Bow of the Goddess
4280259, --Apollousa, Bow of the Goddess
43262273, --Appointer of the Red Lotus
20292186, --Artifact Scythe
440556, --Bahamut Shark
84815190, --Baronne de Fleur
73356503, --Barrier Statue of the Stormwinds
27552504, --Beatrice, Lady of the Eternal
9929398, --Blackwing - Gofu the Vague Shadow
94689206, --Block Dragon
27548199, --Borreload Savage Dragon
1041278, --Branded Expulsion
69243953, --Butterfly Dagger - Elma
11384280, --Cannon Soldier
14702066, --Cannon Soldier MK-2
57953380, --Card of Safe Return
95727991, --Catapult Turtle
3040496, --Chaos Ruler, the Chaotic Magical Dragon
60682203, --Cold Wave
17375316, --Confiscation
50588353, --Crystron Halqifibrax
98095162, --Curious, the Lightsworn Dominion
69015963, --Cyber-Stein
15341821, --Dandylion
44763025, --Delinquent Duo
23557835, --Dimension Fusion
31423101, --Divine Sword - Phoenix Blade
8903700, --Djinn Releaser of Rituals
51858306, --Eclipse Wyvern
17412721, --Elder Entity Norden
55623480, --Fairy Tail - Snow
78706415, --Fiber Jar
93369354, --Fishborg Blaster
42703248, --Giant Trunade
55204071, --Gimmick Puppet Nightmare
79571449, --Graceful Charity
75732622, --Grinder Golem
59537380, --Guardragon Agarpain
86148577, --Guardragon Elpy
19613556, --Heavy Storm
24094258, --Heavymetalfoes Electrumite
62242678, --Hot Red Dragon Archfiend King Calamity
61740673, --Imperial Order
59934749, --Isolde, Two Tales of the Noble Knights
41855169, --Jowgen the Spiritualist
35059553, --Kaiser Colosseum
48626373, --Kashtira Arise-Heart
32909498, --Kashtira Fenrir
25926710, --Kelbek the Ancient Vanguard
11398059, --King of the Feral Imps
39064822, --Knightmare Goblin
65330383, --Knightmare Gryphon
3679218, --Knightmare Mermaid
28566710, --Last Turn
85602018, --Last Will
34086406, --Lavalval Chain
57421866, --Level Eater
17178486, --Life Equalizer
30342076, --Link Decoder
85243784, --Linkross
4423206, --M-X-Saber Invoker
32723153, --Magical Explosion
34206604, --Magical Scientist
34906152, --Mass Driver
23434538, --Maxx "C"
44097050, --Mecha Phantom Beast Auroradon
46411259, --Metamorphosis
96782886, --Mind Master
41482598, --Mirage of Nightmare
71818935, --Moon of the Closed Heaven
76375976, --Mystic Mine
54719828, --Number 16: Shock Master
10389142, --Number 42: Galaxy Tomahawk
35772782, --Number 67: Pair-a-Dice Smasher
63504681, --Number 86: Heroic Champion - Rhongomyniad
95474755, --Number 89: Diablosis the Mind Hacker
58820923, --Number 95: Galaxy-Eyes Dark Matter Dragon
52653092, --Number S0: Utopic ZEXAL
89023486, --Original Sinful Spoils - Snake-Eye
34945480, --Outer Entity Azathot
74191942, --Painful Choice
23558733, --Phoenixian Cluster Amaryllis
55144522, --Pot of Greed
25725326, --Prank-Kids Meow-Meow-Mu
70369116, --Predaplant Verte Anaconda
70828912, --Premature Burial
23002292, --Red Reboot
27174286, --Return from the Different Dimension
1357146, --Ronintoadin
93016201, --Royal Oppression
91258852, --SPYRAL Master Plan
57585212, --Self-Destruct Button
72330894, --Simorgh, Bird of Sovereignty
3280747, --Sixth Sense
63789924, --Smoke Grenade of the Thief
54447022, --Soul Charge
59859086, --Splash Mage
27381364, --Spright Elf
20663556, --Substitoad
23516703, --Summon Limit
33918636, --Superheavy Samurai Scarecrow
77679716, --Superheavy Samurai Soulbreaker Armor
43387895, --Supreme King Dragon Starving Venom
92731385, --Tearlaments Kitkallos
63101919, --Tempest Magician
42829885, --The Forceful Sentry
88071625, --The Tyrant Neptune
90809975, --Toadally Awesome
79875176, --Toon Cannon Soldier
22593417, --Topologic Gumblar Dragon
64697231, --Trap Dustshoot
88581108, --True King of All Calamities
80604091, --Ultimate Offering
80604092, --Ultimate Offering
83152482, --Union Carrier
5851097, --Vanity's Emptiness
44910027, --Victory Dragon
81122844, --Wind-Up Carrier Zenmaity
16923472, --Wind-up Hunter
85115440, --Zoodiac Broadbull
11110587, --That Grass Looks Greener
17375316, --Confiscation
19613556, --Heavy Storm
23557835, --Dimension Fusion
34906152, --Mass Driver
35059553, --Kaiser Colloseum
41482598, --Mirage of Nightmare
42703248, --Giant Trunade
42829885, --The Forceful Sentry
44763025, --Deliquent Duo
45986603, --Snatch Steal
31423101, --Divine Sword - Phoenix Blade
46411259, --Metamorphosis
55144522, --Pot of greed
57953380, --Card of Safe Return
60682203, --Cold Wave
67616300, --Chicken Game
69243953, --Butterfly Dagger - Elma
70828912, --Premature Burial
74191942, --Painful Choice
79571449, --Graceful Charity
85602018, --Last Will
54447022, --Soul Charge
63789924, --Smoke Grenade of the Thief
76375976, --Mystic Mine
46060017, --Zoodiac Barrage
59750328, --Card of Demise
24224830, --Called by the Grave
18144506, --Harpie's Feather Duster
93946239, --Into the Void
24940422, --Sekka’s Light
02295440, --One for One
14733538, --Draco Face-off
15854426, --Divine Wind of the Mist Valley
23701465, --Primal Seed
27970830, --Gateway of the Six
32807846, --Reinforcement of the Army
33782437, --One Day of Peace
52340444, --Sky Striker Mecha - Hornet Drones
24010609, --Sky Striker Mecha Modules - Multirole
58577036, --Reasoning
66957584, --Infernity Launcher
13035077, --Dragonic Diagram
71344451, --Slash Draw
75500286, --Gold Sarcophagus
70368879, --Upstart Goblin
72892473, --Card Destruction
73468603, --Set Rotation
73628505, --Terraforming
81439173, --Foolish Burial
83764718, --Monster Reborn
83764719, --Monster Reborn
91623717, --Chain Strike
93600443, --Mask Change 2
95308449, --Final Countdown
71650854, --Magical Mid-Breaker Field
1845204, --Instant Fusion
37520316, --Mind Control
01984618, --Nadir Servant
63166095, --Sky Striker Mobilize - Engage!
65681983, --Crossout Designator
43040603, --Monster Gate
52947044, --Fusion Destiny
36637374, --Branded Opening
77103950, --Primeval Planet Perlereino
15443125, --Spright Starter
28126717, --Floowandereeze and the Magnificent Map
46448938, --Spellbook of Judgment
04031928, --Change of Heart
71832012, --Prime Planet Paraisos
44362883, --Branded Fusion
48130397, --Super Polymerization
31434645, --Cursed Eldland
67723438, --Emergency Teleport
84211599, --Pot of Prosperity
57103969, --Fire Formation - Tenki
35261759, --Pot of Desires
14532163, --Lightning Storm
03285551, --Rite of Aramesir
35726888, --Foolish Burial Goods
12580477, --Raigeki
35371948, --Trickstar Light Stage
}
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local cards={}
	for i=1,3 do
		local num=Duel.GetRandomNumber(1,#banned_cards)
		table.insert(cards,banned_cards[num])
	end
	local code=Duel.SelectCardsFromCodes(tp,1,1,false,false,cards)
	local card=Duel.CreateToken(tp,code)
	Duel.Hint(HINT_CARD,1-ep,card:GetCode())
	if card:IsSpell() or card:IsMonster() then
		Duel.SendtoHand(card,tp,REASON_RULE)
	elseif card:IsTrap() then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			local f2=Duel.SelectOption(tp,1153,573) --Add to hand/Set it to the field
			if f2==0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
				Duel.MoveToField(card,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
			else
				Duel.SendtoHand(card,tp,REASON_RULE)
			end
		else
			Duel.SendtoHand(card,tp,REASON_RULE)
		end
	end
end
