--Ａ・Ɐ・ＲＲ
--Amaze Ɐttraction Rapid Racing
--Scripted by Eerie Code

local s,id=GetID()
function s.initial_effect(c)
	--From cards_specific_functions.lua
	aux.AddAttractionEquipProc(c)
	--You: Target 1 card in your opponent's GY; change the equipped monster's battle position, and if you do, shuffle that target into the Deck.
	--Your opponent: Increase the equipped monster's Level by 1 (until the end of this turn), and if you do, change its battle position.
	local e2=aux.MakeAttractionBinaryEquipChkOp(c,id,
		{CATEGORY_POSITION+CATEGORY_TODECK,EFFECT_FLAG_CARD_TARGET,s.postg,s.posop,{0,0}},
		{CATEGORY_POSITION+CATEGORY_LVCHANGE,nil,s.lvtg,s.lvop,{0,0}},
		s.postg)
	c:RegisterEffect(e2)
end
s.listed_series={0x25d}
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
