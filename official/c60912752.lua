--異次元の境界線
--D.D. Borderline
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--cannot bp
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BP)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.bpcon)
	c:RegisterEffect(e2)
end
function s.bpcon(e)
	return not Duel.IsExistingMatchingCard(Card.IsSpell,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end