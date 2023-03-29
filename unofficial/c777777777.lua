--Rule of the Day
--At the start of each Draw Phase: Each player declares Spell or Trap Card. Add from the Worlds banlist 1 random card of that type to that player's hand. If the card is a Trap card, it can be Set instead, and it can be activated this turn.
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
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local f1=Duel.SelectOption(tp,71,72)
	if f1==0 then
		local num=Duel.GetRandomNumber(1,#ban_spell)
		local g1=Duel.CreateToken(tp,ban_spell[num])
		Duel.Hint(HINT_CARD,ep,g1:GetCode())
		Duel.SendtoHand(g1,tp,REASON_RULE)
	end
	if f1==1 then
		local num=Duel.GetRandomNumber(1,#ban_trap)
		local g2=Duel.CreateToken(tp,ban_trap[num])
		Duel.Hint(HINT_CARD,ep,g2:GetCode())
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			local f2=Duel.SelectOption(tp,1153,573)
			if f2==0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
				Duel.MoveToField(g2,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
			else
				Duel.SendtoHand(g2,tp,REASON_RULE)
			end
		else
			Duel.SendtoHand(g2,tp,REASON_RULE)
		end
	end
end

ban_spell={
7394770, --Brilliant Fusion
04031928, --Change of Heart
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
ban_trap={
03280747, --Sixth Sense
05851097, --Vanity's Emptiness
17178486, --Life Equalizer
27174286, --Return from the Different Dimension
28566710, --Last Turn
32723153, --Magical Explosion
57585212, --Self-Destruct Button
64697231, --Trap Dustshot
80604091, --Ultimate Offering
80604092, --Ultimate Offering
93016201, --Royal Oppression
61740673, --Imperial Order
23002292, --Red Reboot
21076084, --Trickstar Reincarnation
35316708, --Time Seal
43262273, --Appointer of the Red Lotus
}