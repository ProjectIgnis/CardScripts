--Crustacean Knight
--AlphaKretin
function c210310159.initial_effect(c)
	--ritual level
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_RITUAL_LEVEL)
	e1:SetCountLimit(1,210310159)
	e1:SetValue(c210310159.rlevel)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,210311159)
	e2:SetTarget(c210310159.thtg)
	e2:SetOperation(c210310159.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	c:RegisterEffect(e3)
end
function c210310159.rlevel(e,c)
	local lv=e:GetHandler():GetLevel()
	if c:IsAttribute(ATTRIBUTE_WATER) then
		local clv=c:GetLevel()
		return lv*65536+clv
	else return lv end
end
function c210310159.filter(c,mc)
	return c:GetType()&0x82==0x82 and c210310159.isfit(mc,c) and c:IsAbleToHand()
end
function c210310159.isfit(c,mc)
	return mc.fit_monster and c:IsCode(table.unpack(mc.fit_monster))
end
function c210310159.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:GetType()&0x81==0x81 and Duel.IsExistingMatchingCard(c210310159.filter,tp,LOCATION_DECK,0,1,nil,c) and c:IsAbleToHand()
end
function c210310159.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210310159.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function c210310159.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210310159.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,g)
			Duel.BreakEffect()
			local tg=Duel.SelectMatchingCard(tp,c210310159.filter,tp,LOCATION_DECK,0,1,1,nil,g:GetFirst())
			if tg:GetCount()>0 then
				Duel.SendtoHand(tg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tg)
			end
		end
	end
end