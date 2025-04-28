--Ｐ・Ｍ Ｒ－ブラウ
--Plasmatic Model Rising Blau
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Ritual
	c:EnableReviveLimit()
	--Cannot be destroyed by your opponent's effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.indtg)
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
end
function s.indtg(e,c)
	return c:IsFacedown() and c:IsSpellTrap()
end