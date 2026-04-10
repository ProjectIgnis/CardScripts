--召喚魔術－「剣」
--Invocation "Sword"
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon 1 Fusion Monster from your Extra Deck, using monsters you control. If Summoning an "Invoked" Fusion Monster this way, you can also return banished monsters to the GY as material
	local e1=Fusion.CreateSummonEff({
					handler=c,
					matfilter=Fusion.OnFieldMat,
					extrafil=s.fextra,
				})
	e1:SetCountLimit(1,{id,0})
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--During your Main Phase, if this card is in your GY: You can target 1 "Aleister" monster or "Invocation" in your GY; shuffle this card into the Deck, and if you do, add the targeted card to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_INVOKED,SET_ALEISTER}
s.listed_names={CARD_INVOCATION}
function s.checkmat(tp,sg,fc)
	return fc:IsSetCard(SET_INVOKED) or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup),tp,LOCATION_REMOVED,LOCATION_REMOVED,nil),s.checkmat
end
function s.thfilter(c)
	return ((c:IsSetCard(SET_ALEISTER) and c:IsMonster()) or c:IsCode(CARD_INVOCATION)) and c:IsAbleToHand()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and c:IsLocation(LOCATION_DECK)
		and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end