--焔魔神ベルシュドロス
--Blaze Fiend Overlords Beelucitaroth
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Maximum Procedure
	Maximum.AddProcedure(c,nil,s.filter1,s.filter2)
	c:AddMaximumAtkHandler()
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
	--level
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(6)
	e2:SetCondition(s.indcon)
	c:RegisterEffect(e2)
end
s.MaximumAttack=3000
s.listed_names={160205010,160205012}
function s.filter1(c)
	return c:IsCode(160205010)
end
function s.filter2(c)
	return c:IsCode(160205012)
end
function s.indcon(e)
	return e:GetHandler():IsMaximumMode()
end
function s.indval(e,re,rp)
	return re:IsTrapEffect() and aux.indoval(e,re,rp)
end