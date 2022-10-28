--終焔魔神ディスペラシオン［Ｌ］
--Doomblaze Fiend Overlord Despairacion [L]
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.indval)
	c:RegisterEffect(e1)
	c:AddSideMaximumHandler(e1)
	local e2=e1:Clone()
	e2:SetCondition(s.maxCon)
	e2:SetValue(s.indval2)
	c:RegisterEffect(e2)
	c:AddSideMaximumHandler(e2)
end
s.MaximumSide="Left"
function s.indval(e,re,rp)
	return re:IsActiveType(TYPE_TRAP) and aux.indoval(e,re,rp)
end
function s.maxCon(e)
	return e:GetHandler():IsMaximumMode()
end
function s.indval2(e,re,rp)
	return re:IsActiveType(TYPE_SPELL) and aux.indoval(e,re,rp)
end