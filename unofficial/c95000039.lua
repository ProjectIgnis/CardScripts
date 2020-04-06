--Metaion, the Timelord Token
local s,id=GetID()
function s.initial_effect(c)
	c:SetStatus(STATUS_NO_LEVEL,true)
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e1)
end
