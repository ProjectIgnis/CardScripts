--ファイナライズ・フェニックス
--Finalize Phoenix
--scripted by YoshiDuels & Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end 
function s.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>=2
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ft=Duel.GetMZoneCount(tp)
		if ft<=0 then return false end
		if ft>=2 then ft=2 end
		local og=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,0,LOCATION_MZONE,nil)
		local lvl=og:GetSum(Card.GetLevel)
		local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_PYRO)
		local tdg=g:Filter(Card.IsAbleToDeck,nil)
		local ssg=g:Filter(s.spfilter,nil,e,tp)
		return aux.SelectUnselectGroup(tdg,e,tp,4,4,s.rescon(lvl,ft,ssg),0)
	end
end
function s.rescon(lvl,ft,ssg)
	return function(sg,e,tp,mg)
		return ((ssg-sg):CheckWithSumEqual(Card.GetLevel,lvl,1,ft))
	end
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local ft=Duel.GetMZoneCount(tp)
	if ft<=0 then return false end
	if ft>=2 then ft=2 end
	local og=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,0,LOCATION_MZONE,nil)
	local lvl=og:GetSum(Card.GetLevel)
	local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_PYRO)
	local tdg=g:Filter(Card.IsAbleToDeckOrExtraAsCost,nil)
	local ssg=g:Filter(s.spfilter,nil,e,tp)
	local td=aux.SelectUnselectGroup(tdg,e,tp,4,4,s.rescon(lvl,ft,ssg),1,tp,HINTMSG_TODECK)
	Duel.HintSelection(td)
	if Duel.SendtoDeck(td,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=(ssg-td):SelectWithSumEqual(tp,Card.GetLevel,lvl,1,ft)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end