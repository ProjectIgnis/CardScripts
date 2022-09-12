--聖なる守り手
--Mysterious Guard
local s,id=GetID()
function s.initial_effect(c)
	--Return to the top of the Deck or Deck & hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tgfilter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e) and (c:IsAbleToDeck() or c:IsAbleToHand())
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsAbleToDeck,1,nil) and sg:IsExists(Card.IsAbleToHand,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return true end
	e:SetLabel(0)
	local dhg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	local b1=dhg:FilterCount(Card.IsAbleToDeck,nil)>0
	local b2=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_WARRIOR),tp,LOCATION_MZONE,0,1,nil) and aux.SelectUnselectGroup(dhg,e,tp,2,2,s.rescon,0)
	if not (b1 or b2) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	local tg=Group.CreateGroup()
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		tg=dhg:FilterSelect(tp,Card.IsAbleToDeck,1,1,nil)
	elseif op==2 then
		tg=aux.SelectUnselectGroup(dhg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,1,0,0)
	end
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then return end
	if op==1 then
		local tc=Duel.GetFirstTarget()
		if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	elseif op==2 then
		local tg=Duel.GetTargetCards(e):Match(Card.IsFaceup,nil)
		if #tg==0 then return end
		local dc=tg:GetFirst()
		if #tg>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			dc=tg:FilterSelect(tp,s.selfilter,1,1,nil,tg):GetFirst()
			if not dc then return end
			Duel.HintSelection(dc,true)
		end
		tg=tg-dc
		if Duel.SendtoDeck(dc,nil,SEQ_DECKTOP,REASON_EFFECT)>0 and dc:IsLocation(LOCATION_DECK) and #tg>0
			and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_WARRIOR),tp,LOCATION_MZONE,0,1,nil) then
			Duel.BreakEffect()
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
		end
	end
end
function s.selfilter(c,g)
	return c:IsAbleToDeck() and g:IsExists(Card.IsAbleToHand,1,c)
end