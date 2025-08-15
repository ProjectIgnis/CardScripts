--Ｔ・Ｋ・Ｇ
--Tamabot King Golem
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	local e0=Fusion.AddProcMixN(c,true,true,CARD_TAMABOT,3)[1]
	e0:SetDescription(aux.Stringid(id,2))
	local e1=Fusion.AddProcMix(c,true,true,CARD_TAMABOT,s.ffilter)[1]
	e1:SetDescription(aux.Stringid(id,3))
	--Make 1 monster lose 600 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_TAMABOT}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsCode(CARD_TAMABOT) and c:IsHasEffect(160021007)
end
function s.tdfilter(c)
	return c:IsMonster() and c:IsCode(CARD_TAMABOT) and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNotMaximumModeSide,tp,LOCATION_MZONE,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.HintSelection(tg)
	if Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_COST)<1 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,Card.IsNotMaximumModeSide,tp,LOCATION_MZONE,0,1,3,nil)
	Duel.HintSelection(g)
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetDescription(3001)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_SET_AVAILABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESETS_STANDARD_PHASE_END,2)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
	if c:IsSummonPhaseMain() and c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_FUSION) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Recover(tp,2000,REASON_EFFECT)
	end
end