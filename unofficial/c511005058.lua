--Muscle Gardna
--original script by Shad3
local s,id=GetID()
function s.initial_effect(c)
	--Cannot attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetCondition(s.cd)
	c:RegisterEffect(e1)
end
function s.cd(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>1
end