--浅すぎた墓穴
--The Shallow Grave
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCountRush(tp,0,LOCATION_MZONE)<=2 and Duel.IsExistingMatchingCard(Card.IsMonster,tp,0,LOCATION_GRAVE,1,nil)
end
function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,1-tp)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_GRAVE,1,nil,e,1-tp)
		and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=Duel.SelectMatchingCard(1-tp,s.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,1-tp)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
		end
	end
end