--サブテラーの継承
--Subterror Succession
--scripted by Logical Nonsense
local s,id=GetID()
function s.initial_effect(c)
	--Activate (Send monster to GY to add flip monster)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk) 
		or s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk) end
	if s.thtg1(e,tp,eg,ep,ev,re,r,rp,0) and s.thtg2(e,tp,eg,ep,ev,re,r,rp,0) then
		local opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
		if opt==0 then
			s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
		else
			s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
		end
		e:SetLabel(opt+1)
	elseif s.thtg1(e,tp,eg,ep,ev,re,r,rp,0) then
		Duel.SelectOption(tp,aux.Stringid(id,0))
		s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk) 
		e:SetLabel(1)
	else
		Duel.SelectOption(tp,aux.Stringid(id,1))
		s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
		e:SetLabel(2)
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		s.thop1(e,tp,eg,ep,ev,re,r,rp)
	elseif e:GetLabel()==2 then
		s.thop2(e,tp,eg,ep,ev,re,r,rp)
	end
end
--Check for monster from hand or field to send to GY
function s.tgfilter1(c,tp)
	local code = c:GetCode()
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() 
	and Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil,c,code)
end
--Check for flip monster
function s.thfilter1(c,tc,code)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_FLIP) and c:IsAbleToHand() and not c:IsCode(code)
	and c:GetOriginalAttribute()==tc:GetOriginalAttribute()
end
--Activation legality
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return 
		Duel.IsExistingMatchingCard(s.tgfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
--Performing the effect of adding to hand
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=Duel.SelectMatchingCard(tp,s.tgfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
	local tc=tg:GetFirst()
	if tc then
		local code = tc:GetCode()
		if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil,tc,code)
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
	if c:IsRelateToEffect(e) and c:IsSSetable(true) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.BreakEffect()
		c:CancelToGrave()
		Duel.ChangePosition(c,POS_FACEDOWN)
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end
--Check for monster from hand or field to send to GY
function s.tgfilter2(c,tp)
	return (c:IsLocation(LOCATION_HAND) and c:GetOriginalLevel()>0 or c:IsFaceup()) and c:IsType(TYPE_FLIP) and c:IsAbleToGrave() 
	and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil,c)
end
--Check for monster with same attribute but lower level
function s.thfilter2(c,tc)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and c:GetOriginalLevel()<tc:GetOriginalLevel() and c:GetOriginalAttribute()==tc:GetOriginalAttribute()
end
--Activation legality
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return 
		Duel.IsExistingMatchingCard(s.tgfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
	--Performing the effect of adding to hand
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=Duel.SelectMatchingCard(tp,s.tgfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
	local tc=tg:GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil,tc)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if c:IsRelateToEffect(e) and c:IsSSetable(true) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.BreakEffect()
		c:CancelToGrave()
		Duel.ChangePosition(c,POS_FACEDOWN)
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end
