-- ターンバック・ショット
-- Turnback Shot
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and r==REASON_RULE
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(Card.IsAbleToHand),tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	--requirement
	--effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(Card.IsAbleToHand),tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		g=g:AddMaximumCheck()
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
