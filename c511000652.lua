--Picador Fiend
local s,id=GetID()
function s.initial_effect(c)
	--direct atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(s.dircon)
	c:RegisterEffect(e1)
end
s.listed_names={511000017}
function s.dircon(e)
	return Duel.IsEnvironment(511000017)
end
