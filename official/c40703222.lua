--増殖
--Multiply

local s,id=GetID()
function s.initial_effect(c)
	--Special summon as many tokens as possible to your field
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
end
s.listed_names={40640057}

function s.cfilter(c,ft,tp)
	return c:IsFaceup() and c:IsCode(40640057) and (ft>0 or (c:GetSequence()<5 and c:IsControler(tp))) and (c:IsFaceup() or c:IsControler(tp))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,ft,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,ft,tp)
	Duel.Release(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		e:SetLabel(0)
		return Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,300,200,1,RACE_FIEND,ATTRIBUTE_DARK)
	end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,300,200,1,RACE_FIEND,ATTRIBUTE_DARK) then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	for i=1,ft do
		local token=Duel.CreateToken(tp,id+1)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		--Cannot be tributed for a tribute summon
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3304)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
end