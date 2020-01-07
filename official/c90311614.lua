--氷結界の水影
local s,id=GetID()
function s.initial_effect(c)
	--direct attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(s.dircon)
	c:RegisterEffect(e1)
end
function s.filter(c)
	local lv=c:GetLevel()
	return c:IsFaceup() and (lv==0 or c:GetLevel()>2)
end
function s.dircon(e)
	local tp=e:GetHandler():GetControler()
	return not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
