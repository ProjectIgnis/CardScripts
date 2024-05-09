--Ｘ・Ｙ・Ｚコンバイン
--XYZ Combine
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Special Summon 1 "X-Head Cannon", "Y-Dragon Head", or "Z-Metal Tank" from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_REMOVE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.dspcon)
	e1:SetTarget(s.dsptg)
	e1:SetOperation(s.dspop)
	c:RegisterEffect(e1)
	--Special Summon up to 2 of your banished "X-Head Cannon", "Y-Dragon Head", or "Z-Metal Tank"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.rmspcost)
	e2:SetTarget(s.rmsptg)
	e2:SetOperation(s.rmspop)
	c:RegisterEffect(e2)
end
s.listed_card_types={TYPE_UNION}
s.listed_names={62651957,65622692,64500000} --"X-Head Cannon", "Y-Dragon Head", "Z-Metal Tank"
function s.dspconfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
		and c:IsType(TYPE_UNION) and c:IsFaceup() and c:IsPreviousControler(tp)
		and ((((c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousTypeOnField()&TYPE_UNION>0
		and c:GetPreviousAttributeOnField()&ATTRIBUTE_LIGHT>0 and c:GetPreviousRaceOnField()&RACE_MACHINE>0)
		or c:IsPreviousLocation(LOCATION_SZONE)) and c:IsPreviousPosition(POS_FACEUP))
		or not c:IsPreviousLocation(LOCATION_ONFIELD))
end
function s.dspcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.dspconfilter,1,nil,tp)
end
function s.spfilter(c,e,tp)
	return c:IsCode(62651957,65622692,64500000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.dsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.dspop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.rmspcostfilter(c,tp)
	return c:IsType(TYPE_FUSION) and c:IsFaceup() and c:IsAbleToExtraAsCost() and Duel.GetMZoneCount(tp,c)>0
end
function s.rmspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmspcostfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.rmspcostfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.rmsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(s.spfilter,Card.IsFaceup),tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.rmspop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<1 then return end
	local g=Duel.GetMatchingGroup(aux.AND(s.spfilter,Card.IsFaceup),tp,LOCATION_REMOVED,0,nil,e,tp)
	if #g==0 then return end
	ft=math.min(2,ft)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end