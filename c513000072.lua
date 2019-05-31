--Ｓｉｎ パラレルギア
local s,id=GetID()
function s.initial_effect(c)
	--self destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(s.descon)
	c:RegisterEffect(e2)
end
s.listed_names={27564031}
function s.descon(e)
	return not Duel.IsEnvironment(27564031)
end

