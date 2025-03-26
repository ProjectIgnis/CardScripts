--黒衣竜アルビオン
--Albion the Shrouded Dragon
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Change name
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e1:SetValue(CARD_ALBAZ)
	c:RegisterEffect(e1)
	--Apply the appropriate effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_ALBAZ}
s.listed_series={SET_BRANDED}
function s.cfilter(c,e,tp)
	if not ((c:IsCode(CARD_ALBAZ) or (c:IsSetCard(SET_BRANDED) and c:IsSpellTrap())) and c:IsAbleToGraveAsCost()) then return false end
	local hc=e:GetHandler()
	if c:IsLocation(LOCATION_HAND) then
		return Duel.GetLocationCount(tp,LOCATION_MZONE,0)>0 and hc:IsCanBeSpecialSummoned(e,0,tp,false,false)
	else
		return hc:IsAbleToDeck() and (hc:IsLocation(LOCATION_GRAVE) or Duel.IsPlayerCanDraw(tp,1))
	end
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	local label=tc:IsLocation(LOCATION_DECK) and 1 or 0
	e:SetLabel(label)
	Duel.SendtoGrave(tc,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local label=e:GetLabel()
	if label==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	else
		local cat=CATEGORY_TODECK
		if c:IsLocation(LOCATION_HAND) then
			cat=cat+CATEGORY_DRAW
			Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
		end
		e:SetCategory(cat)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,tp,0)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local label=e:GetLabel()
	if label==0 and Duel.GetLocationCount(tp,LOCATION_MZONE,0)>0 then
		--Hand: Special Summon this card
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	else
		--Deck: Place this card on the bottom of the Deck
		local loc=c:GetLocation()
		if Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and c:IsLocation(LOCATION_DECK) and loc==LOCATION_HAND then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end