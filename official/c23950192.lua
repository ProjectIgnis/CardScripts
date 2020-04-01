--氷結界の術者
local s,id=GetID()
function s.initial_effect(c)
	--cannot attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.tg)
	e2:SetCondition(s.con)
	c:RegisterEffect(e2)
end
s.listed_series={0x2f}
function s.con(e)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x2f),e:GetHandler():GetControler(),LOCATION_MZONE,0,1,e:GetHandler())
end
function s.tg(e,c)
	return c:GetLevel()>=4
end
