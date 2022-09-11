--ネオスペーシア・ウェーブ
--Neospace Wave
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x1f}
function s.filter(c)
	return c:IsSetCard(0x1f) and c:IsMonster()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	local neoct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_DECK,0,nil)
	return neoct>ct
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local ct=#mg
	local ft=Duel.GetMZoneCount(tp,mg)
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if chk==0 then return ct>0 and ft>=ct and mg:FilterCount(Card.IsAbleToGrave,nil)==ct and #sg>=ct end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,mg,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,ct,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	if Duel.SendtoGrave(mg,REASON_EFFECT)>0 then
		local ct=#Duel.GetOperatedGroup()
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		if ct>0 and ft>=ct and #sg>=ct then
			local spg=sg:RandomSelect(tp,ct)
			Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
