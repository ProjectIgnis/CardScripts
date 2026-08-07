--刻印の調停者
--Engraver of the Mark
local s,id=GetID()
function s.initial_effect(c)
	--When your opponent activates a card or effect by declaring exactly 1 card name (Quick Effect): You can send this card from your hand to the GY; declare 1 other card name.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.declcon)
	e1:SetCost(Cost.SelfToGrave)
	e1:SetOperation(s.declop)
	c:RegisterEffect(e1)
	--Once per turn (Quick Effect): You can target 1 face-up card on the field; destroy it during the End Phase of the next turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.declcon(e,tp,eg,ep,ev,re,r,rp)
	local ac=re:GetChainData(ev).announced_card
	return rp==1-tp and ac and (type(ac)=="number" or #ac==1)
end
function s.declop(e,tp,eg,ep,ev,re,r,rp)
	local rcd=re:GetChainData(ev)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	if rcd.announce_filter then
		local announce_filter=type(rcd.announce_filter)=="function"
			and rcd.announce_filter(e,tp,eg,ep,ev,re,r,rp)
			or rcd.announce_filter
		--can't exclude the announced name since we can't guarantee there'll be a declarable name left,
		--and having a card declaration prompt with no valid options leads to a soft lock
		rcd.announced_card=Duel.AnnounceCard(tp,announce_filter)
	else
		rcd.announced_card=Duel.AnnounceCard(tp,~DF.IsCode(rcd.announced_card))
	end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local turn_count=Duel.GetTurnCount()
		--Destroy it during the End Phase of the next turn
		aux.DelayedOperation(tc,PHASE_END,id,e,tp,
			function(ag)
				Duel.Hint(HINT_CARD,0,id)
				Duel.Destroy(ag,REASON_EFFECT)
			end,
			function() return Duel.GetTurnCount()==turn_count+1 end,
			nil,2,aux.Stringid(id,2)
		)
	end
end
