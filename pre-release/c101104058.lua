--アメイズメント・プレシャスパーク
--Amazement Precious Park
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Trap activate in set turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetCondition(s.actcon)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x25e))
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
	--set
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetCost(s.setcost)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
s.listed_series={0x25e}
function s.actcon(e)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.eqfilter(c,ec)
	return c:GetEquipGroup():IsContains(ec)
end
function s.setfilter(c,ec)
	return c:IsType(TYPE_TRAP) and c:IsSetCard(0x25e) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
		and not c:IsCode(ec:GetCode()) and c:IsSSetable(true)
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_TRAP) and c:IsSetCard(0x25e)
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
		and Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,c)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.setfilter(chkc,e:GetLabelObject()) end
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>-1 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local gc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_SZONE,0,1,1,nil,tp):GetFirst()
	e:SetLabelObject(gc)
	Duel.SendtoGrave(gc,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,gc)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsSSetable() then
		Duel.SSet(tp,tc)
	end
end
