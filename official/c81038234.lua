--夢魔鏡の夢語らい
--Dream Mirror Recap
--Logical Nonsense
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	c:RegisterEffect(e1)
	--Your "Dream Mirror" monsters are shuffled into the Deck instead of being sent to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(e,c) return c:IsSetCard(SET_DREAM_MIRROR) and c:IsReason(REASON_COST) and c:GetReasonEffect():GetHandler()==c end)
	e2:SetValue(LOCATION_DECKSHF)
	c:RegisterEffect(e2)
	--Place 1 "Dream Mirror of Joy" or "Dream Mirror of Terror" face-up in your Field Zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCondition(function() return Duel.IsMainPhase() end)
	e3:SetCost(s.plcost)
	e3:SetTarget(s.pltg)
	e3:SetOperation(s.plop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_DREAM_MIRROR}
s.listed_names={CARD_DREAM_MIRROR_JOY,CARD_DREAM_MIRROR_TERROR}
function s.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and c:IsStatus(STATUS_EFFECT_ENABLED) end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.plfilter(c)
	return c:IsFieldSpell() and c:IsCode(CARD_DREAM_MIRROR_JOY,CARD_DREAM_MIRROR_TERROR) and c:IsFaceup() and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spfilter(c,e,tp,code)
	return c:ListsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local plc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_REMOVED|LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if not plc then return end
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if fc then
		Duel.SendtoGrave(fc,REASON_RULE)
		Duel.BreakEffect()
	end
	if not Duel.MoveToField(plc,tp,tp,LOCATION_FZONE,POS_FACEUP,true) or Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	local code=plc:GetCode()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp,code)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil):GetFirst()
		Duel.BreakEffect()
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end