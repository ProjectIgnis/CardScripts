--デーモンの諧謔
--Archfiend Playtime
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 Level 7 or lower "Archfiend" monster from your hand or Deck, or if you have a face-up "Archfiend" Ritual Monster in your Extra Deck, you can Special Summon 1 "Royal Archfiend", 1 "Duke Archfiend", and/or 1 "Highness Archfiend" from your hand and/or Deck instead
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ARCHFIEND}
s.listed_names={58769832,85154941,11248645} --"Royal Archfiend", "Duke Archfiend", "Highness Archfiend"
function s.spfilter(c,e,tp,ex_chk)
	return ((c:IsLevelBelow(7) and c:IsSetCard(SET_ARCHFIEND)) or (ex_chk and c:IsCode(58769832,85154941,11248645)))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.archritfilter(c)
	return c:IsSetCard(SET_ARCHFIEND) and c:IsRitualMonster() and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ex_chk=Duel.IsExistingMatchingCard(s.archritfilter,tp,LOCATION_EXTRA,0,1,nil)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp,ex_chk)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.rescon(ex_chk)
	return function(sg,e,tp,mg)
		return #sg==1 or (ex_chk and #sg<=3 and sg:FilterCount(Card.IsCode,nil,58769832,85154941,11248645)==#sg and sg:GetClassCount(Card.GetCode)==#sg)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local ex_chk=Duel.IsExistingMatchingCard(s.archritfilter,tp,LOCATION_EXTRA,0,1,nil)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,e,tp,ex_chk)
	if #g==0 then return end
	if not ex_chk then
		ft=1
	else
		ft=math.min(ft,3)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	end
	local rescon=s.rescon(ex_chk)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,rescon,1,tp,HINTMSG_SPSUMMON,rescon)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end