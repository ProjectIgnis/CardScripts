--メタル化寄生生物－ルナタイト
local s,id=GetID()
function s.initial_effect(c)
	aux.AddUnionProcedure(c,nil,true)
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(aux.IsUnionState)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_SPELL)
end