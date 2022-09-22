--希花牙のアイリス
--Iris the Rare Shadow Flower
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Set from your GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e) return e:GetHandler():IsStatus(STATUS_SUMMON_TURN) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160011048,160011049}
function s.setfilter(c)
	return c:IsCode(160011048,160011049) and c:IsSSetable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g==0 or Duel.SSet(tp,g)==0 then return end
	Duel.DisableShuffleCheck()
	local g2=Duel.GetMatchingGroup(function(c)return c:GetSequence()<1 end,tp,LOCATION_DECK,0,nil)
	Duel.SendtoGrave(g2,REASON_EFFECT)
	local ct=Duel.GetOperatedGroup():GetFirst()
	if ct:IsType(TYPE_NORMAL) and ct:IsRace(RACE_PLANT) and ct:IsLevel(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g3=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g3>0 then
			Duel.HintSelection(g3)
			Duel.BreakEffect()
			Duel.SpecialSummon(g3,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end