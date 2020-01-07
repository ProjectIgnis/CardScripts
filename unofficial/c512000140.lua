--Percy's Hunting Ground
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate	
	local e1=Effect.CreateEffect(c)	
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetRange(LOCATION_HAND+LOCATION_DECK)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--Cannot leave the field due to effects.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetTargetRange(LOCATION_FZONE,LOCATION_FZONE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetValue(s.filter)
	Duel.RegisterEffect(e2,0)
	--prevents activating/setting new fields
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SSET)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.setlimit)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(1,0)
	e4:SetValue(s.actlimit)
	c:RegisterEffect(e4)
	--add spell/set trap from the banlist
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(1040,9))
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_FZONE,LOCATION_FZONE)
	e5:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetCountLimit(1)
	e5:SetCondition(s.cond1)
	e5:SetTarget(s.target1)
	e5:SetOperation(s.oper1)
	c:RegisterEffect(e5)
end
ban_spell={
23314220,
63166095,
23171610,
98338152,
47325505,
04031928,
11110587,
13035077,
17375316,
18144506,
18144507,
19613556,
23557835,
27770341,
34906152,
35059553,
41482598,
42703248,
42829885,
44763025,
45986603,
31423101,
46060017,
46411259,
46448938,
55144522,
57953380,
60682203,
67169062,
67616300,
69243953,
70828912,
74191942,
79571449,
85602018,
94220427,
54447022,
02295440,
08949584,
14087893,
14733538,
15854426,
22842126,
23701465,
27970830,
32807846,
33782437,
43040603,
45305419,
48130397,
52340444,
53129443,
12580477,
53208660,
54631665,
58577036,
66957584,
7394770,
71344451,
75500286,
67723438,
70368879,
72405967,
72892473,
73468603,
73628505,
74845897,
75500286,
81439173,
81674782,
83764718,
83764719,
91623717,
93600443,
95308449,
97211663,
99330325,
73915051,
71650854
}
ban_trap={
21076084,
35125879,
82732705,
73599290,
30241314,
17078030,
84749824,
41420027,
36468556,
53936268,
40605147,
03280747,
05851097,
17178486,
27174286,
28566710,
32723153,
35316708,
57585212,
64697231,
80604091,
80604092,
93016201,
}
function s.op(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
end
function s.filter(e,te,c)
	if not te then return false end
	local tc=te:GetOwner()
	return (te:IsActiveType(TYPE_MONSTER) and c~=tc
		or (te:IsHasCategory(CATEGORY_TOHAND+CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_TODECK+CATEGORY_RELEASE+CATEGORY_TOGRAVE+CATEGORY_FUSION_SUMMON)
		and te:IsActiveType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER)))
end
function s.setlimit(e,c,tp)
	return c:IsType(TYPE_FIELD)
end
function s.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_FIELD) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.cond1(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	e:SetCategory(CATEGORY_TOHAND)
	Duel.SetOperationInfo(tp,0,CATEGORY_TOHAND,nil,1,tp,nil)
end
function s.oper1(e,tp,eg,ep,ev,re,r,rp)
	local f1=Duel.SelectOption(tp,aux.Stringid(1040,10),aux.Stringid(1040,11))
	if f1==0 then
		local num=Duel.GetRandomNumber(1,#ban_spell)
		add_spell_id=ban_spell[num]
		g1=Duel.CreateToken(tp,add_spell_id)
		Duel.SendtoHand(g1,tp,REASON_RULE)
	end
	if f1==1 then 
		local num=Duel.GetRandomNumber(1,#ban_trap)
		add_trap_id=ban_trap[num]
		g2=Duel.CreateToken(tp,add_trap_id)
			if Duel.CheckLocation(tp,LOCATION_SZONE,nil) then
				local f2=Duel.SelectOption(tp,aux.Stringid(1040,12),aux.Stringid(1040,13))
					if f2==0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
					Duel.MoveToField(g2,tp,tp,LOCATION_SZONE,POS_FACEDOWN,true)
					else Duel.SendtoHand(g2,tp,REASON_RULE)	end
			else
				Duel.SendtoHand(g2,tp,REASON_RULE)
			end
	end
end
