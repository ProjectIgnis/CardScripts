--Japanese name
--Mantman the Ultrahuman
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be Tributed, or be destroyed by battle, while face-up on the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	c:RegisterEffect(e3)
	--Special Summon this card from your hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,id)
	e4:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsOwner,tp),tp,0,LOCATION_ONFIELD,1,nil) end)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	--Place this card on the bottom of the Deck, then you can return 1 face-up card on the field you own to your hand
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(function(e) return e:GetHandler():IsStatus(STATUS_SUMMON_TURN|STATUS_SPSUMMON_TURN) end)
	e5:SetTarget(s.tdtg)
	e5:SetOperation(s.tdop)
	c:RegisterEffect(e5)
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
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_EITHER,LOCATION_ONFIELD)
end
function s.rthfilter(c,tp)
	return c:IsOwner(tp) and c:IsFaceup() and c:IsAbleToHand()
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and c:IsLocation(LOCATION_DECK|LOCATION_EXTRA)
		and Duel.IsExistingMatchingCard(s.rthfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g=Duel.SelectMatchingCard(tp,s.rthfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.BreakEffect()
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end