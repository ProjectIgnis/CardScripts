--儀式の供物
local s,id=GetID()
function s.initial_effect(c)
	--ritual level
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_RITUAL_LEVEL)
	e1:SetValue(s.rlevel)
	c:RegisterEffect(e1)
end
function s.rlevel(e,c)
	local lv=e:GetHandler():GetLevel()
	if c:IsAttribute(ATTRIBUTE_DARK) then
		local clv=c:GetLevel()
		return lv*65536+clv
	else return lv end
end
