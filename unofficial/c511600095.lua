--デストーイ・チェンジ・オブ・メモリー
--Frightfur Change of Memory
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Frightfur"/"Fluffal"/"Edge Imp" Pendulum monster from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_FRIGHTFUR,SET_FLUFFAL,SET_EDGE_IMP}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not (re and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) or e==re then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or #g~=1 then return false end
	return g:GetFirst():IsControler(tp) and g:GetFirst():IsLocation(LOCATION_MZONE)
end
function s.spfilter(c,e,tp)
	return (c:IsSetCard(SET_FRIGHTFUR) or c:IsSetCard(SET_FLUFFAL) or c:IsSetCard(SET_EDGE_IMP)) and c:IsType(TYPE_PENDULUM)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_DECK) and s.spfilter(chkc,e,tp) end
	if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		Duel.ChangeTargetCard(ev,Group.FromCards(tc))
	end
end