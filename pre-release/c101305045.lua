--混沌のマジック・ボックス
--Mystic Box of Chaos
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--When your opponent activates a card or effect that targets another card(s) you control: Return 1 of those cards you control to the hand (if face-down, reveal it briefly to check), and if you do, destroy 1 card on the field, then you can Special Summon 1 monster that mentions "Ritual of Light and Darkness" from your hand, with a different name than the returned card, ignoring its Summoning conditions
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.thdescon)
	e1:SetTarget(s.thdestg)
	e1:SetOperation(s.thdesop)
	c:RegisterEffect(e1)
	--If this card in its owner's possession is destroyed by an opponent's card: You can Special Summon 1 Ritual Monster that mentions "Ritual of Light and Darkness" from your hand or Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp and e:GetHandler():IsPreviousControler(tp) end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_RITUAL_OF_LIGHT_AND_DARKNESS}
function s.thdesconfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField() and c:IsAbleToHand()
end
function s.thdescon(e,tp,eg,ep,ev,re,r,rp)
	if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(s.thdesconfilter,1,e:GetHandler(),tp)
end
function s.thdestg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.thconfilter(c,re,tp)
	return c:IsRelateToEffect(re) and c:IsControler(tp)
end
function s.handspfilter(c,e,tp,code)
	return c:IsMonster() and c:ListsCode(CARD_RITUAL_OF_LIGHT_AND_DARKNESS) and not c:IsCode(code)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.thdesop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):Filter(s.thconfilter,nil,re,tp)
	if #tg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local sc=tg:FilterSelect(tp,Card.IsAbleToHand,1,1,nil):GetFirst()
	if not sc then return end
	if sc:IsFaceup() then
		Duel.HintSelection(sc)
	else
		Duel.ConfirmCards(1-tp,sc)
	end
	if Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_HAND) then
		Duel.ShuffleHand(sc:GetControler())
		local c=e:GetHandler()
		local exc=c:IsRelateToEffect(e) and c or nil
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,exc)
		if #g==0 then return end
		Duel.HintSelection(g)
		local code=sc:GetCode()
		if Duel.Destroy(g,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.handspfilter,tp,LOCATION_HAND,0,1,nil,e,tp,code)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.handspfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,code)
			if #sg>0 then
				Duel.BreakEffect()
				Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
			end
		end
	end
end
function s.ritualspfilter(c,e,tp)
	return c:IsRitualMonster() and c:ListsCode(CARD_RITUAL_OF_LIGHT_AND_DARKNESS) and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.ritualspfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.ritualspfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,true,POS_FACEUP)
	end
end