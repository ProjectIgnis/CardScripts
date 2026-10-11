--予幻なき世界に託す約束
--Theorealize Ephemeral Lull
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Banish 1 "Medius" monster from your hand or face-up field; banish as many monsters on the field as possible that were Special Summoned from the Extra Deck, then you can Special Summon 1 "Artmage" monster from your GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(s.banishcost)
	e1:SetTarget(s.banishtg)
	e1:SetOperation(s.banishop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--If you have 3 or more different Monster Types on your field: You can banish this card from your GY; Special Summon 1 of your banished "Medius" monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil):GetBinClassCount(Card.GetRace)>=3
	end)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_series={SET_POWER_PATRON,SET_MEDIUS,SET_ARTMAGE}
function s.rvmfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsAbleToRemove()
end
function s.banishcostfilter(c)
	return c:IsSetCard(SET_MEDIUS) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.rvmfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
function s.banishcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.banishcostfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.banishcostfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.banishtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.rvmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.artmagespfilter(c,e,tp)
	return c:IsSetCard(SET_ARTMAGE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.banishop(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(s.rvmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 and rg:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.artmagespfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.artmagespfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.mediusspfilter(c,e,tp)
	return c:IsSetCard(SET_MEDIUS) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.mediusspfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.mediusspfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end