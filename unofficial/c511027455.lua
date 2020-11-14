--Edge Imp Frightfuloid (anime)
--Scripted By Sever666
local s,id=GetID()
function s.initial_effect(c)
	--code
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ADD_SETCODE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e3:SetValue(0xad)
	c:RegisterEffect(e3)
end
