--鎖付き飛龍炎刃
--Salamandra with Chain
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Equip this card to a FIRE monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(aux.RemainFieldCost)
	e1:SetTarget(s.eqptg)
	e1:SetOperation(s.eqpop)
	c:RegisterEffect(e1)
	--Fusion Summon 1 FIRE Warrior or Dragon Fusion Monster shuffling materials from your hand, field, and/or GY
	local params = {fusfilter=s.fusmonfilter,
			matfilter=Card.IsAbleToDeck,
			extrafil=s.extramat,
			extraop=Fusion.ShuffleMaterial,
			extratg=s.extratg,
			stage2=s.stage2}
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(Fusion.SummonEffTG(params))
	e2:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e2)
end
function s.eqptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsAttribute(ATTRIBUTE_FIRE) end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_FIRE),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_FIRE),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.posfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsCanTurnSet()
end
function s.eqpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.Equip(tp,c,tc) then
		--Equipped monster gain 700 ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
		--Equip limit
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetValue(function(e,cc) return cc:IsAttribute(ATTRIBUTE_FIRE) end)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e2)
		--Change 1 Effect Monster on the field to face-down Defense Position
		local pg=Duel.GetMatchingGroup(s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if #pg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
			local tc=pg:Select(tp,1,1,nil)
			Duel.HintSelection(tc,true)
			Duel.BreakEffect()
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	else
		c:CancelToGrave(false)
	end
end
function s.fusmonfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR|RACE_DRAGON)
end
function s.extramat(e,tp,mg,sumtype)
	return Duel.GetMatchingGroup(aux.NecroValleyFilter(Fusion.IsMonsterFilter(Card.IsAbleToDeck)),tp,LOCATION_GRAVE,0,nil)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 then
		--Destroy it during the End Phase
		aux.DelayedOperation(tc,PHASE_END,id,e,tp,function(cc) Duel.Destroy(cc,REASON_EFFECT) end,nil,0,1,aux.Stringid(id,3))
	end
end