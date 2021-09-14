-- 奇装天鎧
-- Unbelievarmor
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
function s.thcostfilter(c)
	return c:IsLevelAbove(7) and c:IsAbleToDeckOrExtraAsCost()
end
function s.thfilter(c)
	return c:IsMonster() and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
function s.thcostrescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetRace)==#sg and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,sg)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local cg=Duel.GetMatchingGroup(s.thcostfilter,tp,LOCATION_GRAVE,0,nil)
		return aux.SelectUnselectGroup(cg,e,tp,3,3,s.thcostrescon,0)
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Requirement
	local g=Duel.GetMatchingGroup(s.thcostfilter,tp,LOCATION_GRAVE,0,nil)
	local cg=aux.SelectUnselectGroup(g,e,tp,3,3,s.thcostrescon,1,tp,HINTMSG_TODECK)
	local ct=0
	if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==1 then
		ct=Duel.SendtoDeck(cg,nil,SEQ_DECKBOTTOM,REASON_COST)
		Duel.SortDeckbottom(tp,tp,#cg)
	else
		ct=Duel.SendtoDeck(cg,nil,SEQ_DECKTOP,REASON_COST)
		Duel.SortDecktop(tp,tp,#cg)
	end
	if ct~=3 then return end
	-- Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local hg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #hg>0 and Duel.SendtoHand(hg,nil,REASON_EFFECT)>0 
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) 
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		local ag=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
		if #ag>0 then
			Duel.BreakEffect()
			Duel.HintSelection(ag)
			-- Reduce ATK
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-1500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			ag:GetFirst():RegisterEffectRush(e1)
		end
	end
end