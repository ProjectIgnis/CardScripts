--Ａ・Ɐ・ＣＣ
--Amaze Ɐttraction Cyclone Coaster
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
	if chkc then return s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
	local et=e:GetHandler():GetEquipTarget()
	if not et then return false end
	local yours=et:GetControler()==tp
	if chk==0 then
		if yours then
			return s.gytg(e,tp,eg,ep,ev,re,r,rp,0)
		else
			return s.thtg(e,tp,eg,ep,ev,re,r,rp,0)
		end
	end
	if yours then
		e:SetCategory(CATEGORY_TOGRAVE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(s.gyop)
		s.gytg(e,tp,eg,ep,ev,re,r,rp,1)
		e:SetHintTiming(0,TIMING_END_PHASE)
	else
		e:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetProperty(0)
		e:SetOperation(s.thop)
		s.thtg(e,tp,eg,ep,ev,re,r,rp,1)
		e:SetHintTiming(0,TIMING_END_PHASE)
	end
end
function s.gyfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.gyfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.gyfilter,tp,0,LOCATION_ONFIELD,1,nil) and e:GetHandler():IsAbleToGrave() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.gyfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc and tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) then
		local g=Group.FromCards(c,tc)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function s.thfilter(c)
	return c:IsSetCard(0x25d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) and e:GetHandler():IsAbleToGrave() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		Duel.ConfirmCards(1-tp,g)
		if c:IsRelateToEffect(e) then
			Duel.SendtoGrave(c,REASON_EFFECT)
		end
	end
end
