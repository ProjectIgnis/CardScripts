--ロードアームズ－ソードブレイカー
--Road Arms - Sword Breaker
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit,nil,nil,nil,s.condition)
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	--Cannot be destroyed by the opponent's trap effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
end
s.listed_names={id,CARD_SEVENS_ROAD_MAGICIAN}
function s.eqfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_SEVENS_ROAD_MAGICIAN) and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.filter(c)
	return c:IsFaceup() and c:IsEquipSpell() and c:GetEquipTarget()
end
function s.value(e,c)
	return Duel.GetMatchingGroupCountRush(s.filter,e:GetHandlerPlayer(),LOCATION_SZONE,LOCATION_SZONE,nil)*1000
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,id),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.efilter(e,te)
	return te:IsTrapEffect() and te:GetOwnerPlayer()~=e:GetOwnerPlayer()
end