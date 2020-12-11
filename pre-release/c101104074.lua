--Ａ・Ɐ・ＲＲ
--Amaze Attraction Rapid Racing
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(aux.RemainFieldCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--action
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.cond)
	e2:SetTarget(s.tg)
	c:RegisterEffect(e2)
end
s.listed_series={0x25d}
function s.filter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x25d) or not c:IsControler(tp))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,tp) end
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) 
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) or not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	else
		c:CancelToGrave(false)
	end
end
function s.eqlimit(e,c)
	return c:GetControler()==e:GetHandlerPlayer() or e:GetHandler():GetEquipTarget()==c
end
function s.cond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local et=e:GetHandler():GetEquipTarget()
	local yours=et and et:GetControler()==tp
	if chkc then return s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
	if chk==0 then
		if et then
			return s.postg(e,tp,eg,ep,ev,re,r,rp,0)
		else
			return s.lvtg(e,tp,eg,ep,ev,re,r,rp,0)
		end
	end
	if et then
		e:SetCategory(CATEGORY_POSITION+CATEGORY_TODECK)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(s.posop)
		s.postg(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetCategory(CATEGORY_POSITION+CATEGORY_LVCHANGE)
		e:SetProperty(0)
		e:SetOperation(s.lvop)
		s.lvtg(e,tp,eg,ep,ev,re,r,rp,1)
	end
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return not chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	local tc=e:GetHandler():GetEquipTarget()
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil)
		and tc and tc:IsCanChangePosition() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,tc,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local ec=e:GetHandler():GetEquipTarget()
	if ec and ec:IsRelateToEffect(e) and Duel.ChangePosition(ec,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)~=0
		and tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
	end
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetEquipTarget()
	if chk==0 then return tc and tc:IsCanChangePosition() end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,tc,1,0,0)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if ec and ec:IsFaceup() and ec:UpdateLevel(1,RESET_PHASE+PHASE_END)~=0 then
		Duel.ChangePosition(ec,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
