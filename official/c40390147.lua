--輝光帝ギャラクシオン
--Starliege Lord Galaxion
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 4 "Photon" monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_PHOTON),4,2)
	--Special Summon 1 "Galaxy-Eyes Photon Dragon" from your hand or Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(Cost.Choice(
		{Cost.Detach(1),aux.Stringid(id,1),s.spcheck(LOCATION_HAND)},
		{Cost.Detach(2),aux.Stringid(id,2),s.spcheck(LOCATION_DECK)}
	))
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_PHOTON}
s.listed_names={CARD_GALAXYEYES_P_DRAGON}
function s.spfilter(c,e,tp)
	return c:IsCode(CARD_GALAXYEYES_P_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcheck(loc)
	return function(e,tp)
		return Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local loc=e:GetLabel()==1 and LOCATION_HAND or LOCATION_DECK
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local loc=e:GetLabel()==1 and LOCATION_HAND or LOCATION_DECK
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,loc,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
