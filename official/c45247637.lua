--薔薇の刻印
--Mark of the Rose
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,1,aux.CheckStealEquip,s.eqlimit,s.cost,s.target)
	--control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.ccon)
	e2:SetOperation(s.cop1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetOperation(s.cop2)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_SET_CONTROL)
	e4:SetValue(s.ctval)
	c:RegisterEffect(e4)
	e2:SetLabelObject(e4)
	e3:SetLabelObject(e4)
end
function s.costfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToRemove()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,tc)
	e:SetCategory(CATEGORY_CONTROL+CATEGORY_EQUIP)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
end
function s.eqlimit(e,c)
	return e:GetHandlerPlayer()~=c:GetControler() or e:GetHandler():GetEquipTarget()==c
end
function s.ccon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function s.cop1(e,tp,eg,ep,ev,re,r,rp)
	local ce=e:GetLabelObject()
	if ce then ce:SetValue(tp) end
end
function s.cop2(e,tp,eg,ep,ev,re,r,rp)
	local ce=e:GetLabelObject()
	if ce then ce:SetValue(1-tp) end
end
function s.ctval(e,c)
	return e:GetHandlerPlayer()
end
