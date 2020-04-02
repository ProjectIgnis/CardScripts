--六花深々
--Rikka Tranquility
--scripted by Naim, updated by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
end
s.listed_series={0x141}
function s.spfilter1(c,e,tp,check)
	return c:IsSetCard(0x141) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and (check==0 or Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,c,e,tp))
end
function s.spfilter2(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,0)
	local b=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,1)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and (a or b) end
	if b and Duel.CheckReleaseGroupCost(tp,Card.IsRace,1,false,nil,nil,RACE_PLANT)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local g=Duel.SelectReleaseGroupCost(tp,Card.IsRace,1,1,false,nil,nil,RACE_PLANT)
		Duel.Release(g,REASON_COST)
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,e:GetLabel()+1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,e:GetLabel())
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or e:GetLabel()==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g2>0 then
			Duel.BreakEffect() 
			Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
