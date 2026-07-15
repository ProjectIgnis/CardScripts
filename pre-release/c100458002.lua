--セネトの啓示者－アメンホテプ
--Sennet Prophet - Amenhotep
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: You can send it to the GY; show up to 2 Normal Monster Cards from your hand, Deck, face-up field, and/or GY, then Set that many "Sennet" Traps from your Deck
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_SET)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,{id,0})
	e1a:SetCost(Cost.SelfToGrave)
	e1a:SetTarget(s.settg)
	e1a:SetOperation(s.setop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--You can banish this card from your GY, then target up to 3 Normal Monsters in your GY; shuffle them into the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SENNET}
local LOCATIONS_HAND_DECK_ONFIELD_GRAVE=LOCATION_HAND|LOCATION_DECK|LOCATION_ONFIELD|LOCATION_GRAVE
function s.showfilter(c)
	return c:IsOriginalType(TYPE_NORMAL) and (c:IsFaceup() or not c:IsOnField())
end
function s.setfilter(c)
	return c:IsSetCard(SET_SENNET) and c:IsTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.showfilter,tp,LOCATIONS_HAND_DECK_ONFIELD_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local show_group=Duel.GetMatchingGroup(s.showfilter,tp,LOCATIONS_HAND_DECK_ONFIELD_GRAVE,0,nil)
	if #show_group==0 then return end
	local set_group=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	if #set_group==0 then return end
	local szone_count=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local max_count=math.min(2,szone_count,#show_group,#set_group)
	if max_count==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rg=Duel.SelectMatchingCard(tp,s.showfilter,tp,LOCATIONS_HAND_DECK_ONFIELD_GRAVE,0,1,max_count,nil)
	if #rg==0 then return end
	local confirm_group,hintselection_group=rg:Split(Card.IsLocation,nil,LOCATION_HAND|LOCATION_DECK)
	if #hintselection_group>0 then
		Duel.HintSelection(hintselection_group)
	end
	if #confirm_group>0 then
		Duel.ConfirmCards(1-tp,confirm_group)
		if confirm_group:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
			Duel.ShuffleHand(tp)
		end
		if confirm_group:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
			Duel.ShuffleDeck(tp)
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,#rg,#rg,nil)
	if #sg==#rg then
		Duel.BreakEffect()
		Duel.SSet(tp,sg)
	end
end
function s.tdfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end