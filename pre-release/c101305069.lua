--雷盟－オルタネータ
--Blitzclique - Alternator
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Monsters your opponent controls lose 300 ATK/DEF for each Thunder monster you control
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetRange(LOCATION_SZONE)
	e1a:SetTargetRange(0,LOCATION_MZONE)
	e1a:SetValue(function(e,c) return -300*Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsRace,RACE_THUNDER),e:GetHandlerPlayer(),LOCATION_MZONE,0,nil) end)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)
	--You can shuffle 1 other "Blitzclique" card from your hand or face-up field into the Deck; add 1 Thunder monster with a different name from your Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetCost(s.thunderthcost)
	e2:SetTarget(s.thunderthtg)
	e2:SetOperation(s.thunderthop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
	--You can banish this card from your GY; add 1 "Blitzclique" Spell or "Kowloon, Citadel of the Sky" from your Deck to your hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.blitzthtg)
	e3:SetOperation(s.blitzthop)
	e3:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e3)
end
s.listed_names={101305050} --"Kowloon, Citadel of the Sky"
s.listed_series={SET_BLITZCLIQUE}
function s.thunderthcostfilter(c,tp)
	return c:IsSetCard(SET_BLITZCLIQUE) and c:IsAbleToDeckAsCost() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		and Duel.IsExistingMatchingCard(s.thunderthfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
function s.thunderthfilter(c,code)
	return c:IsRace(RACE_THUNDER) and not c:IsCode(code) and c:IsAbleToHand()
end
function s.thunderthcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.thunderthcostfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sc=Duel.SelectMatchingCard(tp,s.thunderthcostfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,c,tp):GetFirst()
	if sc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,sc)
	else
		Duel.HintSelection(sc)
	end
	Duel.SendtoDeck(sc,nil,SEQ_DECKSHUFFLE,REASON_COST)
	e:SetLabel(sc:GetCode())
end
function s.thunderthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thunderthop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thunderthfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.blitzthfilter(c)
	return ((c:IsSetCard(SET_BLITZCLIQUE) and c:IsSpell()) or c:IsCode(101305050)) and c:IsAbleToHand()
end
function s.blitzthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.blitzthfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.blitzthop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.blitzthfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end