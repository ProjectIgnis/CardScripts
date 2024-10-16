--機動砦 マキシマム・ガジェット
--Maximum Gadget the Moving Fortress
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Maximum Procedure
	Maximum.AddProcedure(c,nil,s.filter1,s.filter2)
	c:AddMaximumAtkHandler()
	--Name becomes "Green Gadget" in the Graveyard
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetValue(41172955)
	c:RegisterEffect(e1)
	--pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetCondition(s.pcon)
	c:RegisterEffect(e2)
	--Cannot be destroyed by your opponent's effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.pcon)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
end
s.MaximumAttack=3000
s.listed_names={160019015,160019017}
function s.filter1(c)
	return c:IsCode(160019015)
end
function s.filter2(c)
	return c:IsCode(160019017)
end
function s.pcon(e)
	return e:GetHandler():IsMaximumMode()
end