--御巫の誘い輪舞
--Mikanko Reflection Rondo
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	local e0=aux.AddEquipProcedure(c,1,nil,s.eqlimit)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	--Can only control 1 "Inviting Rondo of the Mikanko"
	c:SetUniqueOnField(1,0,id)
	--Gain control of the monster while you control a "Mikanko" monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_SET_CONTROL)
	e1:SetValue(function(e) return e:GetHandlerPlayer() end)
	e1:SetCondition(s.contcond)
	c:RegisterEffect(e1)
	--Equipped monster cannot activate its effect while under your control
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetCondition(s.actcond)
	c:RegisterEffect(e2)
	--Send the equiped monster to the GY
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MIKANKO}
function s.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c or e:GetHandlerPlayer()~=c:GetControler()
end
function s.contcond(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_MIKANKO),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.actcond(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec:GetControler()==e:GetHandlerPlayer()
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if ec and ec:IsLocation(LOCATION_MZONE) then
		Duel.SendtoGrave(ec,REASON_EFFECT)
	end
end