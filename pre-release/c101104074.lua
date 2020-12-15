--Ａ・Ɐ・ＲＲ
--Amaze Ɐttraction Rapid Racing
--Scripted by Eerie Code

local s,id=GetID()
function s.initial_effect(c)
	--From cards_specific_functions.lua
	aux.AddAttractionEquipProc(c)
	--Activate 1 of 2 effects, depending on equipped monster's controller.
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
function s.cond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local et=e:GetHandler():GetEquipTarget()
	if not et then return false end
	local yours=et:GetControler()==tp
	if chkc then return s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
	if chk==0 then
		if yours then
			return s.postg(e,tp,eg,ep,ev,re,r,rp,0)
		else
			return s.lvtg(e,tp,eg,ep,ev,re,r,rp,0)
		end
	end
	if yours then
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
	if ec and Duel.ChangePosition(ec,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)~=0
		and tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
	end
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetEquipTarget()
	if chk==0 then return tc and tc:HasLevel() and tc:IsCanChangePosition() end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,tc,1,0,0)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec and ec:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		ec:RegisterEffect(e1)
		if not ec:IsImmuneToEffect(e1) then
			Duel.ChangePosition(ec,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
		end
	end
end
