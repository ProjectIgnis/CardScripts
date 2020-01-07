--フォトン・デルタ・ウィング
local s,id=GetID()
function s.initial_effect(c)
	--cannot attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(s.con)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:GetCode()==id
end
function s.con(e)
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,e:GetHandler())
end
