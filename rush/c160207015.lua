--深淵竜神アビス・ポセイドラ［Ｒ］
--Abyssal Dragon Lord Abyss Poseidra [R]
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--cannot mset
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_MSET)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	c:AddSideMaximumHandler(e1)
	--cannot sset
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SSET)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.condition2)
	e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_HAND) end)
	c:RegisterEffect(e2)
	c:AddSideMaximumHandler(e2)
end
s.MaximumSide="Right"
function s.condition(e)
	return not Duel.IsExistingMatchingCard(Card.IsMonster,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
function s.condition2(e)
	return e:GetHandler():IsMaximumMode() and Duel.IsExistingMatchingCard(Card.IsFacedown,e:GetHandlerPlayer(),0,LOCATION_SZONE,1,nil) and s.condition(e)
end