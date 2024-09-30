--トランザム・アサルトライナック
--Transamu Assault Rainac
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,CARD_TRANSAMU_RAINAC,1,s.ffilter,1)
	--Reduce Level
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.named_material={CARD_TRANSAMU_RAINAC}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsType(TYPE_EFFECT,fc,sumtype,tp) and c:IsRace(RACE_GALAXY,fc,sumtype,tp) and not c:IsLevel(7)
end
function s.condition(e,tp,eg,ep,ev,re,r,r,rp)
	return e:GetHandler():IsLevelAbove(4)
end
function s.filter(c)
	return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,2,nil) end
end
function s.checkfilter(c)
	return c:IsLocation(LOCATION_DECK) and c:IsCode(160402024)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	if #g==0 then return end
	Duel.HintSelection(g)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)==0 then return end
	--Effect
	local c=e:GetHandler()
	--decrease level by 3
	c:UpdateLevel(-3,RESETS_STANDARD_PHASE_END,c)
	if g:FilterCount(s.checkfilter,nil)>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3208)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		e1:SetValue(DOUBLE_DAMAGE)
		c:RegisterEffect(e1)
	end
end