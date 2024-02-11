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
	--If it is a Spell Card add it to the hand
	if f1==0 then
		local num=Duel.GetRandomNumber(1,#ban_spell)
		local gencard=Duel.CreateToken(tp,ban_spell[num])
		Duel.Hint(HINT_CARD,1-ep,gencard:GetCode())
		Duel.SendtoHand(gencard,tp,REASON_RULE)
	end
	--If it is a Trap card, either add it to the hand or Set it
	if f1==1 then
		local num=Duel.GetRandomNumber(1,#ban_trap)
		local g2=Duel.CreateToken(tp,ban_trap[num])
		Duel.Hint(HINT_CARD,ep,g2:GetCode())
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			local f2=Duel.SelectOption(tp,1153,573) --Add to hand/Set it to the field
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
69243953, --Butterfly Dagger - Elma
57953380, --Card of Safe Return
67616300, --Chicken Game
60682203, --Cold Wave
17375316, --Confiscation
44763025, --Deliquent Duo
23557835, --Dimension Fusion
31423101, --Divine Sword - Phoenix Blade
42703248, --Giant Trunade
79571449, --Graceful Charity
19613556, --Heavy Storm
35059553, --Kaiser Colloseum
85602018, --Last Will
34906152, --Mass Driver
41482598, --Mirage of Nightmare
76375976, --Mystic Mine
74191942, --Painful Choice
55144522, --Pot of greed
70828912, --Premature Burial
63789924, --Smoke Grenade of the Thief
45986603, --Snatch Steal
54447022, --Soul Charge
11110587, --That Grass Looks Greener
42829885, --The Forceful Sentry
24224830, --Called by the Grave
72892473, --Card Destruction
59750328, --Card of Demise
91623717, --Chain Strike
4031928, --Change of Heart
99266988, --Chaos Space
65681983, --Crossout Designator
95308449, --Final Countdown
81439173, --Foolish Burial
75500286, --Gold Sarcophagus
18144506, --Harpie's Feather Duster
1845204, --Instant Fusion
93946239, --Into the Void
71650854, --Magical Mid-Breaker Field
43040603, --Monster Gate
83764718, --Monster Reborn
83764719, --Monster Reborn
33782437, --One Day of Peace
2295440, --One for One
84211599, --Pot of Prosperity
55584558, --Purrely Delicious Memory
21347668, --Purrely Sleepy Memory
58577036, --Reasoning
32807846, --Reinforcement of the Army
24940422, --Sekka's Light
71344451, --Slash Draw
73628505, --Terraforming
67723438, --Emergency Teleport
35726888, --Foolish Burial Goods
14532163, --Lightning Storm
35261759, --Pot of Desires
12580477, --Raigeki
3285551, --Rite of Aramesir
48130397, --Super Polymerization
}
ban_trap={
43262273, --Appointer of the Red Lotus
53334471, --Gozen Match
61740673, --Imperial Order
28566710, --Last Turn
17178486, --Life Equalizer
32723153, --Magical Explosion
23002292, --Red Reboot
27174286, --Return from the Different Dimension
90846359, --Rivalry of Warlords
93016201, --Royal Oppression
57585212, --Self-Destruct Button
03280747, --Sixth Sense
82732705, --Skill Drain
24207889, --There Can Be Only One
35316708, --Time Seal
64697231, --Trap Dustshot
21076084, --Trickstar Reincarnation
80604091, --Ultimate Offering
80604092, --Ultimate Offering
05851097, --Vanity's Emptiness
}
