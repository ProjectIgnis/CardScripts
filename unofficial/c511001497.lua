--ガーディアン・シールド
--Guardian Shield
local s,id=GetID()
function s.initial_effect(c)
	--Equip procedure: Equip only to a "Guardian" monster
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,SET_GUARDIAN))
	--Equipped monster gains 300 DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	--If a "Guardian" monster you control would be destroyed by battle, destroy this card instead
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.reptg)
	e2:SetValue(function(e,c) return s.repfilter(c,e:GetHandlerPlayer()) end)
	e2:SetOperation(function(e) Duel.Destroy(e:GetHandler(),REASON_EFFECT|REASON_REPLACE) end)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GUARDIAN}
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_GUARDIAN) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsReason(REASON_BATTLE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and c 
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	return Duel.SelectYesNo(tp,aux.Stringid(id,0))
end