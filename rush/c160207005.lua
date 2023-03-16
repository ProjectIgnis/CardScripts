--超魔輝獣マグナム・オーバーロード
--Supreme Beast Magnum Overlord
Duel.LoadCardScript("c160428002.lua")
local s,id=GetID()
function s.initial_effect(c)
	Maximum.AddProcedure(c,nil,s.filter1,s.filter2)
	--Cannot be destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.indcon)
	e1:SetValue(s.indval)
	c:RegisterEffect(e1)
	c:AddCenterToSideEffectHandler(e1)
	c:AddMaximumAtkHandler()
end
s.MaximumAttack=3500
function s.filter1(c)
	return c:IsCode(160428001)
end
function s.filter2(c)
	return c:IsCode(160428003)
end
function s.indcon(e)
	--maximum mode check to do
	return e:GetHandler():IsMaximumMode()
end
function s.indval(e,re,rp)
	return re:IsActiveType(TYPE_TRAP) and aux.indoval(e,re,rp)
end