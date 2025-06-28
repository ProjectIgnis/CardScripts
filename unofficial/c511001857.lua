--ラスト・トリック
--Last Trick
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 Spell Card your opponent activated to your hand instead of it going to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsSpellCard()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=re:GetHandler()
	if chk==0 then return ec:IsStatus(STATUS_LEAVE_CONFIRMED) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,ec,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
	if ec and not ec:IsStatus(STATUS_DESTROY_CONFIRMED) then
		ec:CancelToGrave()
		Duel.SendtoHand(ec,tp,REASON_EFFECT)
	end
end
