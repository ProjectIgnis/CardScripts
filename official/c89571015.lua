--ストームサイファー
local s,id=GetID()
function s.initial_effect(c)
	--cannot attack directly
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e1)
	--cannot attack emz
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetValue(s.atlimit)
	c:RegisterEffect(e2)
	--immune
	local e3=e1:Clone()
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetValue(s.immval)
	c:RegisterEffect(e3)
	--indes
	local e4=e2:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	c:RegisterEffect(e4)
end
function s.atlimit(e,c)
	return c:GetSequence()>4
end
function s.immval(e,te)
	local tc=te:GetHandler()
	if not (tc:IsLocation(LOCATION_MZONE) or tc:IsPreviousLocation(LOCATION_MZONE)) then return end
	if tc:IsLocation(LOCATION_MZONE) then
		return te:IsActiveType(TYPE_MONSTER) and te:IsActivated() and tc:GetSequence()>4
	elseif tc:IsPreviousLocation(LOCATION_MZONE) then
		return te:IsActiveType(TYPE_MONSTER) and te:IsActivated() and tc:GetPreviousSequence()>4
	end
end
