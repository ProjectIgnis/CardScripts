--暗黒恐獣
--Black Tyranno
local s,id=GetID()
function s.initial_effect(c)
	--direct attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(s.dircon)
	c:RegisterEffect(e1)
end
function s.dircon(e)
	local tp=e:GetHandler():GetControler()
	return Duel.GetFieldGroupCount(tp,0,LOCATION_SZONE)==0
		and not Duel.IsExistingMatchingCard(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil)
end