-- プライムキャット・ストライニャー
-- Praime Cat Straynya
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon procedure
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160016004,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT))
	--Face-up LIGHT monsters you control cannot be destroyed by your opponent's effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.tg)
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	--Atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTarget(s.tg)
	e2:SetValue(200)
	c:RegisterEffect(e2)
end
s.named_material={160016004}
function s.tg(e,c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsAttribute(ATTRIBUTE_LIGHT)
end