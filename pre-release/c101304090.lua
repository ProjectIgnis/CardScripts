--JP name
--GMX Partner Selandea
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--You can reveal this card in your hand; Special Summon 1 "GMX" monster or 1 Dinosaur monster from your hand, also you can only attack directly with "GMX" monsters for the rest of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(s.handsptg)
	e1:SetOperation(s.handspop)
	c:RegisterEffect(e1)
	--If this card is Special Summoned by a monster effect: You can Special Summon 1 Level 4 or lower "GMX" or Dinosaur monster from your hand, GY, or banishment in Defense Position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return re and re:IsMonsterEffect() end)
	e2:SetTarget(s.handgybansptg)
	e2:SetOperation(s.handgybanspop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GMX}
function s.gmxdinospfilter(c,e,tp,pos)
	return (c:IsSetCard(SET_GMX) or c:IsRace(RACE_DINOSAUR)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.handsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.gmxdinospfilter,tp,LOCATION_HAND,0,1,nil,e,tp,POS_FACEUP) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.handspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.gmxdinospfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,POS_FACEUP)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	local c=e:GetHandler()
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,2))
	--You can only attack directly with "GMX" monsters for the rest of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return not c:IsSetCard(SET_GMX) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.handgybanspfilter(c,e,tp)
	return c:IsLevelBelow(4) and s.gmxdinospfilter(c,e,tp,POS_FACEUP_DEFENSE) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function s.handgybansptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.handgybanspfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.handgybanspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.handgybanspfilter),tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end