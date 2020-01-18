--Bronze Knights
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,500,500,1,RACE_WARRIOR,ATTRIBUTE_EARTH)
	end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=math.min(ft,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local cg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,ft,nil)
	local ct=#cg
	Duel.SendtoGrave(cg,REASON_COST+REASON_DISCARD)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,500,500,1,RACE_WARRIOR,ATTRIBUTE_EARTH) then
		for i=1,ct do
			local token=Duel.CreateToken(tp,id+1)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		end
		Duel.SpecialSummonComplete()
	end
end
