--深淵の神獣ディス・パテル
--Bystial Dis Pater
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsRace,RACE_DRAGON),1,99)
	--Special Summon 1 banished LIGHT or DARK monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Shuffle 1 banished card into the Deck, and destroy or negate a monster's effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsMonsterEffect()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsAbleToDeck() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tc,1,0,0)
	local rc=re:GetHandler()
	if tc:GetOwner()==tp and rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
	elseif tc:GetOwner()==1-tp then
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_DECK|LOCATION_EXTRA)) then return end
	if tc:GetOwner()==tp and re:GetHandler():IsRelateToEffect(re) then
		Duel.BreakEffect()
		Duel.Destroy(eg,REASON_EFFECT)
	elseif tc:GetOwner()==1-tp then
		Duel.BreakEffect()
		Duel.NegateEffect(ev)
	end
end