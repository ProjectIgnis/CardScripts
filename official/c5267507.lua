--地縛神 スカーレッド・ノヴァ
--Earthbound Immortal Red Nova
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--There can only be 1 "Earthbound Immortal" monster on the field
	c:SetUniqueOnField(1,1,aux.FilterBoolFunction(Card.IsSetCard,SET_EARTHBOUND_IMMORTAL),LOCATION_MZONE)
	--Send 1 "Earthbound Immortal" monster or "Red Dragon Archfiend" from your hand or face-up Monster Zone to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetCost(Cost.SelfBanish)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_RED_DRAGON_ARCHFIEND,97489701} --"Red Nova Dragon"
s.listed_series={SET_EARTHBOUND,SET_EARTHBOUND_IMMORTAL}
function s.tgfilter(c)
	return (c:IsSetCard(SET_EARTHBOUND_IMMORTAL) or c:IsCode(CARD_RED_DRAGON_ARCHFIEND)) and c:IsMonster() and c:IsAbleToGrave()
		and (c:IsFaceup() or not c:IsOnField())
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.earthboundspfilter(c,e,tp)
	if not (c:IsSetCard(SET_EARTHBOUND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_DECK) then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	elseif c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)
	end
end
function s.rednovaspfilter(c,e,tp)
	return c:IsCode(97489701) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local gc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
	if gc and Duel.SendtoGrave(gc,REASON_EFFECT)>0 and gc:IsLocation(LOCATION_GRAVE) then
		local b1=Duel.IsExistingMatchingCard(s.earthboundspfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,e,tp)
		local b2=Duel.IsExistingMatchingCard(s.rednovaspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		if not ((b1 or b2) and Duel.SelectYesNo(tp,aux.Stringid(id,1))) then return end
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,2)},
			{b2,aux.Stringid(id,3)})
		if op==1 then
			--Special Summon 1 "Earthbound" monster from your Deck or Extra Deck
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.earthboundspfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.BreakEffect()
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		elseif op==2 then
			--Special Summon "Red Nova Dragon" from your Extra Deck
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sc=Duel.SelectMatchingCard(tp,s.rednovaspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
			if not sc then return end
			Duel.BreakEffect()
			if Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP) then
				sc:CompleteProcedure()
			end
		end
	end
end