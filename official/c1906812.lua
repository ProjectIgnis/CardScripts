--灰燼竜バスタード
--Sprind the Irondash Dragon
--scripted by Logical Nonsense
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Fusion Materials: "Fallen of Albaz" + 1 Effect Monster Special Summoned this turn
	Fusion.AddProcMix(c,true,true,CARD_ALBAZ,aux.FilterBoolFunctionEx(s.filter))
	--Move this card you control to another of your Main Monster Zones, then you can destroy all other face-up cards in this card's column
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.seqtg)
	e1:SetOperation(s.seqop)
	c:RegisterEffect(e1)
	--Register the fact it was sent to GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SPRINGANS}
s.listed_names={CARD_ALBAZ}
function s.filter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_EFFECT) and c:IsStatus(STATUS_SPSUMMON_TURN)
end
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
end
function s.seqop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local seq=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	if seq then
		Duel.MoveSequence(c,math.log(seq,2))
		local dg=c:GetColumnGroup():Filter(Card.IsFaceup,c,nil)
		if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Add to your hand, or Special Summon, 1 "Springans" monster or 1 "Fallen of Albaz" from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
end
function s.thfilter(c,e,tp,ft)
	return c:IsMonster() and (c:IsSetCard(SET_SPRINGANS) or c:IsCode(CARD_ALBAZ))
		and (c:IsAbleToHand() or (c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft):GetFirst()
	if tc then
		aux.ToHandOrElse(tc,tp,function(c)
			return tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and ft>0 end,
		function(c)
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end,
		aux.Stringid(id,3))
	end
end