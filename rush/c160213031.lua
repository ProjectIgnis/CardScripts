--大剣竜駕ダイナ－ミクス［Ｌ］
--Dynamight Dino Dynamix [L]
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Name becomes "Dynamic Dino Dynamix [L]" in the hand
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_HAND)
	e0:SetValue(160203005)
	c:RegisterEffect(e0)
	--Send to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetRange(LOCATION_MZONE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetCondition(s.maxCon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	c:AddSideMaximumHandler(e1)
end
s.MaximumSide="Left"
function s.maxCon(e)
	return e:GetHandler():IsMaximumModeCenter()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(Card.IsAbleToHand),tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(Card.IsAbleToHand),tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		g=g:AddMaximumCheck()
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end