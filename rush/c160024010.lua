--冥跡のアミール
--Emir of the Monumenthes
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
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
	--Atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.target)
	e2:SetValue(500)
	c:RegisterEffect(e2)
end
function s.indtg(e,c)
	return c:IsSpellTrap() or c==e:GetHandler()
end
function s.target(e,c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH)
end