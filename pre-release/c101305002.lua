--混沌の魔王－スカル・デーモン
--Skull Archfiend of Chaos
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If this card is in your hand or GY: You can target 3 other cards in the GYs and/or face-up banishment, including a card that mentions "Ritual of Light and Darkness"; place them on the bottom of the Deck in any order, and if you do, Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.tdsptg)
	e1:SetOperation(s.tdspop)
	c:RegisterEffect(e1)
	--If this card is sent to the GY: You can send 1 Ritual Spell from your hand or Deck to the GY; add 1 Ritual Monster mentioned on that card from your Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_RITUAL_OF_LIGHT_AND_DARKNESS}
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.ListsCode,1,nil,CARD_RITUAL_OF_LIGHT_AND_DARKNESS)
end
function s.tdsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	local g=Duel.GetTargetGroup(aux.FaceupFilter(Card.IsAbleToDeck),tp,LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_GRAVE|LOCATION_REMOVED,c)
	if chk==0 then return #g>=3 and aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	local tg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,3,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.tdspop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 and Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and tg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK|LOCATION_EXTRA) then
		local tg_your,tg_opp=tg:Split(Card.IsControler,nil,tp)
		local your_count=tg_your:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
		local opp_count=tg_opp:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
		if your_count>=2 then
			Duel.SortDeckbottom(tp,tp,your_count)
		end
		if opp_count>=2 then
			Duel.SortDeckbottom(tp,1-tp,opp_count)
		end
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.thcostfilter(c,tp)
	return c:IsRitualSpell() and c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c)
end
function s.thfilter(c,rit_spell)
	return c:IsRitualMonster() and rit_spell:ListsCode(c:GetCode())and c:IsAbleToHand()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thcostfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=Duel.SelectMatchingCard(tp,s.thcostfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	Duel.SendtoGrave(sc,REASON_COST)
	e:SetLabelObject(sc)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabelObject())
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end