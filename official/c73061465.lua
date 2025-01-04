--氷結界の封魔団
--Spellbreaker of the Ice Barrier
local s,id=GetID()
function s.initial_effect(c)
	--Apply activation restriction
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(aux.IceBarrierDiscardCost(s.cfilter,false))
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ICE_BARRIER}
function s.cfilter(c)
	return c:IsSetCard(SET_ICE_BARRIER) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	--Neither player can activate Spell Cards
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,1)
	e1:SetValue(s.tgval)
	e1:SetReset(RESETS_STANDARD_PHASE_END,3)
	c:RegisterEffect(e1)
end
function s.tgval(e,re,rp)
	return re:IsSpellEffect() and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end