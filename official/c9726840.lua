-- 閃刀起動－リンケージ
-- Sky Striker Mobilize - Linkage!
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Send 1 card to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
s.listed_series={0x1115}
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(Card.IsInMainMZone,tp,LOCATION_MZONE,0,1,nil)
end
function s.tgfilter(c,e,tp)
	return c:IsAbleToGrave() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function s.spfilter(c,e,tp,tc)
	return c:IsSetCard(0x1115) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,tc,c,0x60)>0
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler(),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.attfilter(c,att)
	return c:IsFaceup() and c:IsSetCard(0x1115) and c:IsAttribute(att)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,c,e,tp)
	if #g<1 or Duel.SendtoGrave(g,REASON_EFFECT)<1 or not g:GetFirst():IsLocation(LOCATION_GRAVE) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP,0x60) 
		and Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,ATTRIBUTE_DARK)
		and Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,ATTRIBUTE_LIGHT) then
		-- Gain ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- Cannot Special Summon non-"Sky Striker Ace" monsters from the Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x1115)
end