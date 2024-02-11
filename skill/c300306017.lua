--No One Suspects the Dark Scorpion Gang!
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,2,false,s.flipcon,s.flipop,1)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabelObject(e)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_names={76922029}
s.listed_series={SET_DARK_SCORPION}
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetRange(0x5f)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsCode(76922029) or (c:IsMonster() and c:IsSetCard(SET_DARK_SCORPION)) end)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetRange(0x5f)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(e,c) return c:IsCode(76922029) or (c:IsMonster() and c:IsSetCard(SET_DARK_SCORPION)) end)
	e2:SetCondition(s.rdcon)
	e2:SetValue(400)
	Duel.RegisterEffect(e2,tp)
	--Cannot Summon/Set monsters, except "Don Zaloog" and "Dark Scorpion" monsters)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SUMMON)
	e3:SetRange(0x5f)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(function(e,c) return not ((c:IsMonster() and c:IsSetCard(SET_DARK_SCORPION)) or c:IsCode(76922029)) end)
	Duel.RegisterEffect(e3,tp)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e4,tp)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e5,tp)
	local e6=e3:Clone()
	e6:SetCode(EFFECT_CANNOT_MSET)
	Duel.RegisterEffect(e6,tp)
end
--Direct Attack Functions
function s.rdcon(e)
	local c=Duel.GetAttacker()
	return c and c:GetControler()==e:GetHandlerPlayer() and Duel.GetAttackTarget()==nil
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)>0
end
--Special Summon Functions
function s.cfilter(c,e,tp)
	return c:IsDiscardable() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c,e,tp)
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsSetCard(SET_DARK_SCORPION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,c:GetCode(),e,tp)
end
function s.spfilter2(c,e,tp,code)
	return c:IsMonster() and c:IsSetCard(SET_DARK_SCORPION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--SpSummon Condition
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,76922029),tp,LOCATION_MZONE,0,1,nil)
	and Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
end
--SpSummon Operation
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	--OPD Register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Special Summon 2 "Dark Scorpion" monsters with different names (1 each from hand and Deck)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	if Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD,nil,e,tp)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
		if #g>1 then
			local sg1=g:FilterSelect(tp,Card.IsLocation,1,1,nil,LOCATION_HAND)
			local sg2=g:Filter(aux.NOT(Card.IsCode),nil,sg1:GetFirst():GetCode()):FilterSelect(tp,Card.IsLocation,1,1,nil,LOCATION_DECK)
			sg1:Merge(sg2)
			Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
