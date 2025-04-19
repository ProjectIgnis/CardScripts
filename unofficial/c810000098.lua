--Frightfur Factory (Anime)
--rescripted by Naim (to match the fusion summon procedure)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Fusion Summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(s.spcost)
	e2:SetTarget(Fusion.SummonEffTG(aux.FilterBoolFunction(Card.IsSetCard,SET_FRIGHTFUR)))
	e2:SetOperation(Fusion.SummonEffOP(aux.FilterBoolFunction(Card.IsSetCard,SET_FRIGHTFUR)))
	c:RegisterEffect(e2)
end
s.listed_series={0x46,0xad}
s.listed_names={CARD_POLYMERIZATION}
function s.cfilter(c)
	return (c:IsCode(CARD_POLYMERIZATION) or c:IsSetCard(SET_FUSION)) and c:IsAbleToRemoveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end