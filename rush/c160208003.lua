--ハーピィ三姉妹［Ｒ］
--Harpie Lady Sisters [R]
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Name becomes "Harpie Ladies"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_GRAVE|LOCATION_MZONE)
	e1:SetValue(160208002)
	c:RegisterEffect(e1)
	c:AddSideMaximumHandler(e1)
	--Cannot be destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2)
	c:AddSideMaximumHandler(e2)
	--Extra attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e3:SetCondition(s.indcon)
	e3:SetValue(2)
	c:RegisterEffect(e3)
	c:AddSideMaximumHandler(e3)
end
s.MaximumSide="Right"
function s.indval(e,re,rp)
	return re:IsMonsterEffect() and aux.indoval(e,re,rp)
end
function s.indcon(e)
	return e:GetHandler():IsMaximumMode()
end