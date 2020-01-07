--Magical Longicorn
local s,id=GetID()
function s.initial_effect(c)
	--disable and destroy
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAIN_ACTIVATING)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp or not re:IsActiveType(TYPE_SPELL) or not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not e:GetHandler():IsAttackPos() then return end
	Duel.NegateEffect(ev)
end
