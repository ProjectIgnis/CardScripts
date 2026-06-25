--JP name
--GMX Suppression Squad
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If this card is in your hand and you control a "GMX" monster or a Dinosaur monster: You can Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--You can target 1 face-up monster on the field; excavate the top cards of your Deck until you excavate a Dinosaur monster, send that Dinosaur monster to the GY, and if you do, the targeted monster becomes a Dinosaur monster (until the end of this turn), also shuffle the rest into the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.excavtg)
	e2:SetOperation(s.excavop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GMX}
function s.spconfilter(c)
	return (c:IsSetCard(SET_GMX) or c:IsRace(RACE_DINOSAUR)) and c:IsFaceup()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.tgfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToGrave()
end
function s.excavtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and not c:IsRace(RACE_DINOSAUR) and c:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(aux.NOT(Card.IsRace),RACE_DINOSAUR),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,aux.FaceupFilter(aux.NOT(Card.IsRace),RACE_DINOSAUR),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.excavop(e,tp,eg,ep,ev,re,r,rp)
	local deck_count=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if deck_count>0 then
		local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
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
			local tc=Duel.GetFirstTarget()
			if Duel.SendtoGrave(sc,REASON_EFFECT|REASON_EXCAVATE) and sc:IsLocation(LOCATION_GRAVE) and tc:IsRelateToEffect(e)
				and tc:IsFaceup() and not tc:IsRace(RACE_DINOSAUR) then
				--The targeted monster becomes a Dinosaur monster (until the end of this turn)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_COPY_INHERIT)
				e1:SetCode(EFFECT_CHANGE_RACE)
				e1:SetValue(RACE_DINOSAUR)
				e1:SetReset(RESETS_STANDARD_PHASE_END)
				tc:RegisterEffect(e1)
			end
		end
	end
	Duel.ShuffleDeck(tp)
end