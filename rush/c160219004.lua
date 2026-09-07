--ＹＸＺ－キャノン・ドラゴン
--YXZ-Cannon Dragon
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	c:EnableReviveLimit()
	local fusproc1=Fusion.AddProcMix(c,true,true,62651957,65622692,64500000)[1]
	fusproc1:SetDescription(aux.Stringid(160219003,0))
	local fusproc2=Fusion.AddProcMix(c,true,true,64500000,aux.FilterBoolFunctionEx(Card.IsHasEffect,160219005))[1]
	fusproc2:SetDescription(aux.Stringid(160219003,1))
	local fusproc3=Fusion.AddProcMix(c,true,true,65622692,aux.FilterBoolFunctionEx(Card.IsHasEffect,160219006))[1]
	fusproc3:SetDescription(aux.Stringid(160219003,2))
	local fusproc4=Fusion.AddProcMix(c,true,true,62651957,aux.FilterBoolFunctionEx(Card.IsHasEffect,160219007))[1]
	fusproc4:SetDescription(aux.Stringid(160219003,3))
	Fusion.AddUnionFusionProc(c)
	--Name becomes "XYZ-Dragon Cannon" in the Extra Deck
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetValue(91998119)
	c:RegisterEffect(e0)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonPhaseMain() and c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.filter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end