--大鎧竜駕ダイナ－ミクス［Ｒ］
--Dynamail Dino Dynamix [R]
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Name becomes "Dynamic Dino Dynamix [R]" in the hand
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_HAND)
	e0:SetValue(160203007)
	c:RegisterEffect(e0)
	--Destruction immunity
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	c:AddSideMaximumHandler(e1)
end
s.MaximumSide="Right"
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,160015057)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,2) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,2,REASON_COST)<1 then return end
	--Effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3060)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetValue(function(e,te)return te:GetOwnerPlayer()~=e:GetOwnerPlayer()end)
	e1:SetReset(RESETS_STANDARD_PHASE_END,2)
	c:RegisterEffect(e1)
	c:AddCenterToSideEffectHandler(e1)
end
