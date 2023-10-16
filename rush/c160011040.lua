--ギャラクティカ・サイフォス
--Galactica Xiphos
local s,id=GetID()
function s.initial_effect(c)
	--Equip
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit,nil,nil,nil,s.condition)
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	--Additional ATK if it is "Galactica Oblivion"
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	e2:SetCondition(s.condition2)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_GALACTICA_OBLIVION}
function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_GALAXY) and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.value(e,c)
	local tp=e:GetHandlerPlayer()
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsType,TYPE_NORMAL),tp,LOCATION_MZONE,0,nil)*300
end
function s.filter(c)
	return (c:IsLevel(7) or c:IsLevel(8)) and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil)
end
function s.condition2(e)
	local c=e:GetHandler():GetEquipTarget()
	return c:IsCode(CARD_GALACTICA_OBLIVION)
end