--星辰の刺毒
--Dragontail Sting
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Banish 1 monster and/or 1 Spell/Trap from your opponent's GY, then you can place 1 "Dragontail" card from your GY or banishment on the bottom of the Deck, except "Dragontail Sting", then draw 1 card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_DRAGONTAIL}
s.listed_names={id}
function s.rmfilter(c,e)
	return c:IsAbleToRemove() and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsMonster,nil)<=1 and sg:FilterCount(Card.IsSpellTrap,nil)<=1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_GRAVE,nil,e)
	local tg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_REMOVE)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tg,#tg,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
end
function s.tdfilter(c)
	return c:IsSetCard(SET_DRAGONTAIL) and c:IsFaceup() and c:IsAbleToDeck() and not c:IsCode(id)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 and Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
		if #g==0 then return end
		Duel.HintSelection(g)
		Duel.BreakEffect()
		if Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end