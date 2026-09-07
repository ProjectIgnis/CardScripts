--スリー・スライス
--Tri-Slice
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.fishfilter(c)
	return c:IsRace(RACE_FISH) and c:HasLevel() and c:IsLevel(6,9,12)
end
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
function s.rescon(lv)
	return function(sg,e,tp,mg)
		return sg:GetClassCount(Card.GetCode)==1 and (not lv or sg:IsExists(Card.IsLevel,1,nil,lv))
	end
end
function s.costfulfillment(c,e,tp,sumg)
	local lv=c:GetLevel()//3 
	return Duel.GetMZoneCount(tp,c)>=3 and aux.SelectUnselectGroup(sumg,e,tp,3,3,s.rescon(lv),0)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		if e:GetLabel()~=1 then return false end 
		e:SetLabel(0) 
		local costg=Duel.GetReleaseGroup(tp):Filter(s.fishfilter,nil)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 
			or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) 
			or #costg==0
			or not costg:IsExists(Card.IsLevel,1,nil,6,9,12) then 
			return false
		end
		local sumg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		if #sumg<3 then return false end
		return costg:IsExists(s.costfulfillment,1,nil,e,tp,sumg)
	end
	local costg=Duel.GetReleaseGroup(tp):Filter(s.fishfilter,nil)
	local sumg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local rg=costg:FilterSelect(tp,s.costfulfillment,1,1,nil,e,tp,sumg)
	local lv=rg:GetFirst():GetLevel()/3
	Duel.Release(rg,REASON_COST)
	Duel.SetTargetParam(lv)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local sumg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp):Filter(Card.IsLevel,nil,lv)
	if #sumg>=3 then
		local sg=aux.SelectUnselectGroup(sumg,e,tp,3,3,s.rescon(lv),1,tp,HINTMSG_SPSUMMON)
		for sc in sg:Iter() do
			Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
			sc:NegateEffects(e:GetHandler())
		end
	end
	Duel.SpecialSummonComplete()
end
