--破壊剣－マスターブレード
--Master Destruction Sword
--Scripted by Eerie Code
function c120401012.initial_effect(c)
	aux.AddEquipProcedure(c,nil,c120401012.filter)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c120401012.distg)
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
end
function c120401012.filter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_LINK)
end
function c120401012.distg(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end