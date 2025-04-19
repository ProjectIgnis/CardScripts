--マジカル・ピジョン
--Magical Pigeon
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_DARK_MAGICIAN_GIRL,id+1}
function s.cfilter(c,p)
	return c:IsFaceup() and c:IsCode(CARD_DARK_MAGICIAN_GIRL)
		and c:IsAbleToHandAsCost() and Duel.GetMZoneCount(p,c)>1
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SendtoHand(g,nil,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		if e:GetLabel()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return false end
		e:SetLabel(0)
		return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) 
			and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,1,RACE_WINGEDBEAST,ATTRIBUTE_WIND)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,0,0,1,RACE_WINGEDBEAST,ATTRIBUTE_WIND) then
		for i=1,2 do
			local token=Duel.CreateToken(tp,id+1)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
		Duel.SpecialSummonComplete()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetOperation(s.op)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.spfilter(c,e,tp)
	return c:IsCode(CARD_DARK_MAGICIAN_GIRL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,id+1)
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	if #dg>0 and #sg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) and Duel.Destroy(dg,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		Duel.SpecialSummon(sg:Select(tp,1,1,nil),0,tp,tp,false,false,POS_FACEUP)
	end
end