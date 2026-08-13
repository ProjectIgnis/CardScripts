--眠らない街の『レイズ・ムーン』
--"Raise Moon" the City that Never Sleeps
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--The first time each Level 7 "Raise Moon" monster you control would be destroyed by card effect each turn, it is not destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c)
		return c:IsLevel(7) and c:IsSetCard(SET_RAISE_MOON)
	end)
	e1:SetValue(function(e,re,r,rp)
		return r&REASON_EFFECT==REASON_EFFECT and 1 or 0
	end)
	c:RegisterEffect(e1)
	--Once per turn, during the End Phase: Shuffle all "Raise Moon" cards in your GY and banishment into the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	--Once per turn: You can activate 1 of these effects;
	--● Place 1 card from your hand on the top or bottom of the Deck, then draw 1 card
	--● If you control a Spellcaster "Raise Moon" Xyz Monster: You can draw 1 card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.efftg)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_RAISE_MOON}
function s.tdfilter(c)
	return c:IsSetCard(SET_RAISE_MOON) and c:IsAbleToDeck() and c:IsFaceup()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function s.drconfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsSetCard(SET_RAISE_MOON) and c:IsXyzMonster() and c:IsFaceup()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	--● Place 1 card from your hand on the top or bottom of the Deck, then draw 1 card
	local option_1=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsPlayerCanDraw(tp)
	--● If you control a Spellcaster "Raise Moon" Xyz Monster: You can draw 1 card
	local option_2=Duel.IsExistingMatchingCard(s.drconfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,1)
	if chk==0 then return option_1 or option_2 end
	local choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,2)},
		{option_2,aux.Stringid(id,3)})
	e:GetChainData().choice=choice
	if choice==1 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,1,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	elseif choice==2 then
		e:SetCategory(CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local choice=e:GetChainData().choice
	if choice==1 then
		--● Place 1 card from your hand on the top or bottom of the Deck, then draw 1 card
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sc=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
		if not sc then return end
		local seq_op=0
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 then
			seq_op=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
		end
		if Duel.SendtoDeck(sc,nil,seq_op,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_DECK)
			and Duel.IsPlayerCanDraw(tp) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	elseif choice==2 then
		--● If you control a Spellcaster "Raise Moon" Xyz Monster: You can draw 1 card
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end