--Ｕ．Ａ．ロッカールーム
--U.A. Locker Room
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Add setcode
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x107)
	c:RegisterEffect(e0)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_RECOVER+CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
s.listed_series={0x107}
function s.thfilter(c)
	return c:IsAbleToHand() and c:IsType(TYPE_MONSTER) and (c:IsSetCard(0x107) or c:IsSetCard(0xb2)) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOHAND)
	Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function s.tdfilter(c)
	return  c:IsAbleToDeck() and c:IsType(TYPE_MONSTER) and not c:IsPublic() and (c:IsSetCard(0x107) or c:IsSetCard(0xb2))
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)==1 then
		if Duel.Recover(tp,500,REASON_EFFECT)==500 then
			if Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsPlayerCanDraw(tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
				local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_HAND,0,1,99,nil)
				if #g>0 then
					Duel.ConfirmCards(1-tp,g)
					local ct=Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
					Duel.ShuffleDeck(tp)
					Duel.BreakEffect()
					Duel.Draw(tp,ct,REASON_EFFECT)
				end
			end
		end
	end
end
