--世壊同心
--The Worlds as One
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 monster from the GY or return monsters and summon from the Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_VISAS_STARFROST}
s.listed_series={SET_VISAS}
function s.gyspfilter(c,e,tp)
	return s.statsfilter(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.statsfilter(c)
	return c:IsAttack(1500) and c:IsDefense(2100)
end
function s.tdfilter(c)
	return c:IsFaceup() and c:IsAbleToDeck()
		and (c:IsCode(CARD_VISAS_STARFROST) or s.statsfilter(c))
end
function s.synchfilter(c,e,tp,zonecheck)
	return c:IsSetCard(SET_VISAS) and c:IsType(TYPE_SYNCHRO)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and (zonecheck or Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetLocationCountFromEx(tp,tp,sg,TYPE_SYNCHRO)>0 and sg:IsExists(s.cfilter,1,nil,sg)
end
function s.cfilter(c,sg)
	return c:IsCode(CARD_VISAS_STARFROST) and sg:FilterCount(s.statsfilter,c)==4
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.gyspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	local b2=#g>=5 and Duel.IsExistingMatchingCard(s.synchfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,true)
		and aux.SelectUnselectGroup(g,e,tp,5,5,s.rescon,0)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.spop)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	elseif op==2 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.synchop)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,5,tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.gyspfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.synchop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	if #g<5 then return end
	local rg=aux.SelectUnselectGroup(g,e,tp,5,5,s.rescon,1,tp,HINTMSG_TODECK)
	if #rg~=5 then return end
	Duel.HintSelection(rg,true)
	if Duel.SendtoDeck(rg,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)==5
		and Duel.IsExistingMatchingCard(s.synchfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,false) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.synchfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,false):GetFirst()
		if sc then
			Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end