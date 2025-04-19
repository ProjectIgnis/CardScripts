--ネオスペーシア・ウェーブ
--Neospace Wave
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NEO_SPACIAN}
function s.nsfilter(c)
	return c:IsSetCard(SET_NEO_SPACIAN) and c:IsMonster()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(s.nsfilter,tp,LOCATION_DECK,0,nil)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_NEO_SPACIAN) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local ct=#mg
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if chk==0 then return ct>0 and Duel.GetMZoneCount(tp,mg)>=ct and mg:FilterCount(Card.IsAbleToGrave,nil)==ct and #sg>=ct
		and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,mg,ct,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,ct,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	if #g==0 or Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end
	local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	local ct=#og
	if ct==0 or (ct>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<ct then return end
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if #sg>=ct then
		local spg=sg:RandomSelect(tp,ct)
		Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
	end
end