--Fossil Hammer
local s,id=GetID()
function s.initial_effect(c)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
function s.filter2(c,e,tp)
	return Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,c:GetLevel()-1)
end
function s.spfilter(c,e,tp,lv)
	return c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,1-tp,false,false,POS_FACEUP_ATTACK) 
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetLevel)
	if chk==0 then return #g>0 and tg and tg:IsExists(s.filter2,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,#tg,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetLevel)
	if #g==0 or not tg then return end
	if Duel.Destroy(tg,REASON_EFFECT)>0 and tg:IsExists(s.filter2,1,nil,e,tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg2=Duel.SelectMatchingCard(1-tp,aux.NecroValleyFilter(s.spfilter),tp,0,LOCATION_GRAVE,1,1,nil,e,tp,g:GetFirst():GetLevel()-1)
		if #sg2>0 then
			Duel.HintSelection(sg2)
			Duel.SpecialSummon(sg2,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK)
		end
	end
end
