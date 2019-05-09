--Paleozoic Byronia
--designed and scripted by Naim
function c210777058.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),2,nil,c210777058.matcheck)
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c210777058.efilter)
	c:RegisterEffect(e1)
	--reveal set, add to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(210777058,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c210777058.setcon)
	e2:SetCost(c210777058.setcost)
	e2:SetOperation(c210777058.setop)
	c:RegisterEffect(e2)
	--draw
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(210777058,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetCountLimit(1,210777058)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c210777058.drwcond)
	e3:SetTarget(c210777058.drwtg)
	e3:SetOperation(c210777058.drwop)
	c:RegisterEffect(e3)
end
function c210777058.matf(c)
	return c:IsRace(RACE_AQUA) and c:IsLevel(2)
end
function c210777058.matcheck(g,lc,tp)
	return g:IsExists(c210777058.matf,1,nil)
end
function c210777058.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER) and re:GetOwner()~=e:GetOwner()
end
function c210777058.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c210777058.rvfilter(c)
	return c:IsType(TYPE_TRAP) and not c:IsPublic()
end
function c210777058.filter2(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
function c210777058.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
	return Duel.IsExistingMatchingCard(c210777058.rvfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(c210777058.filter2,tp,LOCATION_REMOVED,0,1,nil)	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rev=Duel.SelectMatchingCard(tp,c210777058.rvfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,99,nil)
	Duel.ConfirmCards(1-tp,rev)
	Duel.ShuffleHand(tp)
	e:SetLabel(rev:GetCount())
end
function c210777058.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,c210777058.filter2,tp,LOCATION_REMOVED,0,1,e:GetLabel(),nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c210777058.seqcfilter(c,tp,lg)
	return c:IsRace(RACE_AQUA) and c:IsAttribute(ATTRIBUTE_WATER) and lg:IsContains(c)
end
function c210777058.drwcond(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(c210777058.seqcfilter,1,nil,tp,lg)
end
function c210777058.drwtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c210777058.tgyfilter(c)
	return c:IsSetCard(0xd4) and c:IsAbleToGrave()
end
function c210777058.drwop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.Draw(tp,1,REASON_EFFECT)
	if ct==0 then return end
	local dc=Duel.GetOperatedGroup():GetFirst()
	if dc:IsType(TYPE_TRAP) and Duel.IsExistingMatchingCard(c210777058.tgyfilter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(210777058,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		Duel.ConfirmCards(1-tp,dc)
		local g=Duel.SelectMatchingCard(tp,c210777058.tgyfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
		Duel.ShuffleHand(tp)
	end
end
