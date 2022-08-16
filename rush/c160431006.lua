--ヴォイドヴェルグ・レクイエム
--Voidvelgr Requiem
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	-- Increase self ATK
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.atkcost)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsAttribute,ATTRIBUTE_DARK),tp,LOCATION_MZONE,0,1,nil) end
	local ct=Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsAttribute,ATTRIBUTE_DARK),tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,ct*300)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	-- Effect
	local ct=Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsAttribute,ATTRIBUTE_DARK),tp,LOCATION_MZONE,0,nil)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and ct>0 then
		-- Gain ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetValue(ct*300)
		c:RegisterEffectRush(e1)
		if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),tp,0,LOCATION_MZONE,1,nil) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
			e2:SetValue(600)
			c:RegisterEffectRush(e2)
		end
	
	end
end
