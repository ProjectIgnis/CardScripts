--メタル化寄生生物－ソルタイト
--Metallizing Parasite - Soltite
local s,id=GetID()
function s.initial_effect(c)
	aux.AddUnionProcedure(c,nil,true)
	--Equip effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCondition(aux.IsUnionState)
	e1:SetValue(s.efilter1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetCondition(aux.IsUnionState)
	e2:SetValue(s.efilter2)
	c:RegisterEffect(e2)
end
function s.efilter1(e,re,rp)
	return rp==1-e:GetHandlerPlayer() and re:IsMonsterEffect()
end
function s.efilter2(e,te)
	return te:GetHandlerPlayer()~=e:GetHandlerPlayer() and te:IsMonsterEffect()
end