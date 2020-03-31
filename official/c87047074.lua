--甲虫装機の魔弓 ゼクトアロー
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,0x56))
	--Atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	--chain limit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(s.chcon)
	e4:SetOperation(s.chop)
	c:RegisterEffect(e4)
end
s.listed_series={0x56}
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()==e:GetHandler():GetEquipTarget()
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
	return ep==tp
end
