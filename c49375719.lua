--サイバー・チュチュ
local s,id=GetID()
function s.initial_effect(c)
	--direct attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(s.dacon)
	c:RegisterEffect(e1)
end
function s.filter(c,atk)
	return c:IsFacedown() or c:GetAttack()<=atk
end
function s.dacon(e)
	return not Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack())
end
