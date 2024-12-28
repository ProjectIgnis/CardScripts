--機動砦 マキシマム・ガジェット［Ｒ］
--Maximum Gadget the Moving Fortress [R]
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Name becomes "Red Gadget" in the Graveyard
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetValue(86445415)
	c:RegisterEffect(e1)
	--Increase ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.cost)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	c:AddSideMaximumHandler(e2)
end
s.MaximumSide="Right"
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,2) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.DiscardDeck(tp,2,REASON_COST)<1 then return end
	--Effect
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(400)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
end