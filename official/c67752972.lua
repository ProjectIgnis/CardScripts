--エレキュウキ
--Wattkyuki
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon Procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_WATT),1,1,Synchro.NonTunerEx(Card.IsRace,RACE_THUNDER),1,99)
	--Can attack directly
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	--Shuffle monsters from the GY and field into the Deck and Special Summon 1 "Watt" Synchro Monster from your Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spsynccon)
	e2:SetTarget(s.spsynctg)
	e2:SetOperation(s.spsyncop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_WATT}
s.listed_names={id}
function s.spsynccon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.GetAttackTarget()==nil
end
function s.gyfilter(c)
	return c:IsSetCard(SET_WATT) and c:IsType(TYPE_TUNER) and c:IsAbleToDeck()
end
function s.mzfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER) and not c:IsType(TYPE_TUNER) and c:IsAbleToDeck()
end
function s.spfilter(c,e,tp,matg)
	return c:IsSetCard(SET_WATT) and c:IsType(TYPE_SYNCHRO) and not c:IsCode(id)
		and Duel.GetLocationCountFromEx(tp,tp,matg,c)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)==1
		and sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==1
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,sg)
end
function s.spsynctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE,0,nil)
	local g2=Duel.GetMatchingGroup(s.mzfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g1>0 and #g2>0
		and aux.SelectUnselectGroup(g1+g2,e,tp,2,2,s.rescon,0) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_MZONE|LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spsyncop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE,0,nil)
	local g2=Duel.GetMatchingGroup(s.mzfilter,tp,LOCATION_MZONE,0,nil)
	if #g1<1 or #g2<1 then return end
	local rg=aux.SelectUnselectGroup(g1+g2,e,tp,2,2,s.rescon,1,tp,HINTMSG_TODECK)
	if #rg~=2 then return end
	Duel.HintSelection(rg,true)
	if Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and Duel.GetOperatedGroup():IsExists(Card.IsLocation,1,nil,LOCATION_DECK|LOCATION_EXTRA) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
		if sc then
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end