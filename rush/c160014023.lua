--アビスレイヤー・リヴァイアナイト
--Abysslayer Leviaknight
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	--Cannot be destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.indcon)
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsRace(RACE_SEASERPENT) and c:IsLevelAbove(10)
end
function s.val(e,c)
	local tp=e:GetHandler():GetControler()
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_GRAVE,0,nil)
	return ct*500
end
function s.indcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_GRAVE,0,nil)>2 and Duel.IsTurnPlayer(1-tp)
end