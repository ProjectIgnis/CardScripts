--JP name
--GMX 55th Experiment Report
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon 1 Dinosaur Fusion Monster from your Extra Deck using monsters from your hand or field. If your opponent controls a monster, you can also use 1 "GMX" monster in your Deck as material
	local e1=Fusion.CreateSummonEff({
			handler=c,
			fusfilter=function(c) return c:IsRace(RACE_DINOSAUR) end,
			extrafil=s.fextra,
			extratg=s.extratg
		})
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--During your Main Phase: You can banish this card from your GY; excavate the top cards of your Deck until you excavate a "GMX" card, add that "GMX" card to your hand, also shuffle the rest into the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.excavtg)
	e2:SetOperation(s.excavop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GMX}
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.deckmatfilter(c)
	return c:IsSetCard(SET_GMX) and c:IsMonster() and c:IsAbleToGrave()
end
function s.fextra(e,tp,mg)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 then
		local eg=Duel.GetMatchingGroup(s.deckmatfilter,tp,LOCATION_DECK,0,nil)
		if #eg>0 then
			return eg,s.fcheck
		end
	end
	return nil
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
	return c:IsSetCard(SET_GMX) and c:IsAbleToHand()
end
function s.excavtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.excavop(e,tp,eg,ep,ev,re,r,rp)
	local deck_count=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if deck_count>0 then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		if #g==0 then
			Duel.ConfirmDecktop(tp,deck_count)
			local excav_g=Duel.GetDecktopGroup(tp,deck_count)
			Duel.RaiseEvent(excav_g,EVENT_CUSTOM+101304092,e,REASON_EFFECT,tp,tp,deck_count)
		else
			local sc=g:GetMaxGroup(Card.GetSequence):GetFirst()
			local sc_seq=sc:GetSequence()
			local excav_count=deck_count-sc_seq
			Duel.ConfirmDecktop(tp,excav_count)
			local excav_g=Duel.GetDecktopGroup(tp,excav_count)
			Duel.RaiseEvent(excav_g,EVENT_CUSTOM+101304092,e,REASON_EFFECT,tp,tp,excav_count)
			if Duel.SendtoHand(sc,nil,REASON_EFFECT) then
				Duel.ConfirmCards(1-tp,sc)
				Duel.ShuffleHand(tp)
			end
		end
	end
	Duel.ShuffleDeck(tp)
end