--精霊術師 ドリアード
--Elemental Mistress Doriado (GOAT)
--Effect applies in hand/GY as well
--Effect never applies if its attribute is changed by another effect
--Effect cannot be negated because it is also a condition
--scripted by senpaizuri
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Attribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetRange(0x16)
	e1:SetCondition(s.condition)
	e1:SetValue(0xf)
	c:RegisterEffect(e1)
end
function s.condition(e)
	local eff=e:GetHandler():IsHasEffect(EFFECT_CHANGE_ATTRIBUTE)
	if not eff then return true end
	local eval=eff:GetValue()
	local val=(type(eval)=='function' and eval(eff,e:GetHandler())) or eval
	return e:GetHandler():GetOriginalAttribute()&val~=0
end
