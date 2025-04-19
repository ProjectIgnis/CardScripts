--ロイヤルデモンズ・ライブアリーナ
--Royal Rebel's Arena
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.actcond)
	c:RegisterEffect(e1)
	--trap indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.indtg)
	e1:SetValue(s.indesval)
	c:RegisterEffect(e1)
end
function s.actcond(e,tp,eg,ep,ev,re,r,rp)
	 return Duel.GetMatchingGroupCountRush(Card.IsMonster,e:GetHandler():GetControler(),0,LOCATION_MZONE,nil)>=2
end
function s.indtg(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FIEND) and c:IsFaceup()
end
function s.indesval(e,re)
	return re:GetHandler():IsTrap()
end