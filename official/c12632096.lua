--超銀河眼の光波龍
--Neo Galaxy-Eyes Cipher Dragon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon Procedure
	Xyz.AddProcedure(c,nil,9,3)
	--Take control of the opponent's monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.ctcon)
	e1:SetCost(s.ctcost)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
end
s.listed_series={SET_CIPHER}
s.listed_names={id}
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,SET_CIPHER)
end
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rt=math.min(Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsAbleToChangeControler),tp,0,LOCATION_MZONE,nil),Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL),c:GetOverlayCount(),3)
	if chk==0 then return rt>0 and c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	local ct=c:RemoveOverlayCard(tp,1,rt,REASON_COST)
	e:SetLabel(ct)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Other monsters cannot attack directly
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetLabel(c:GetFieldID())
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Take control of the opponent's monsters
	local ct=math.min(e:GetLabel(),Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsAbleToChangeControler),tp,0,LOCATION_MZONE,ct,ct,nil)
	Duel.GetControl(g,tp,PHASE_END,1)
	local og=Duel.GetOperatedGroup()
	if #og==0 then return end
	for tc in og:Iter() do
		---Negate their effects
		tc:NegateEffects(c,RESET_PHASE|PHASE_END)
		--Their ATK's become 4500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(4500)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		--Their names become "Neo Galaxy-Eyes Cipher Dragon"
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_CODE)
		e2:SetValue(id)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e2)
	end
end
function s.atktg(e,c)
	return e:GetLabel()~=c:GetFieldID()
end