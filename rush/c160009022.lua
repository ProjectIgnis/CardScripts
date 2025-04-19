--カジキ尖兵カジュー
--Swordfish Vanguard Gaju
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Gain LP
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e) return e:GetHandler():IsStatus(STATUS_SUMMON_TURN) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160007058,160007059,160007003}
function s.setfilter(c)
	return c:IsCode(160007058,160007059) and c:IsSSetable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.spfilter(c,e,tp)
	return c:IsCode(160007003) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g==0 or Duel.SSet(tp,g)==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,nil,e,tp)
	if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Group.Select(sg,tp,1,1,nil)
		if #sc==0 then return end
		Duel.BreakEffect()
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end