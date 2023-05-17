--覇王龍の奇跡
--Miracle of the Supreme King
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(function(_,tp) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_ZARC),tp,LOCATION_ONFIELD,0,1,nil) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_ZARC}
s.listed_series={SET_ODD_EYES}
function s.desfilter(c,e,tp)
	return c:IsFaceup() and c:IsCode(CARD_ZARC)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function s.spfilter(c,e,tp,ec)
	if not ((c:IsSetCard(SET_ODD_EYES) and c:IsType(TYPE_PENDULUM)) or (c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCode(CARD_ZARC))) then return false end
	if not c:IsCanBeSpecialSummoned(e,0,tp,true,false) then return false end
	if c:IsLocation(LOCATION_DECK) then
		return Duel.GetMZoneCount(tp,ec)>0
	else
		return Duel.GetLocationCountFromEx(tp,tp,ec,c)>0
	end
end
function s.pcfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.setfilter(c)
	return c:IsQuickPlaySpell() and c:IsSSetable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp)
	local b2=not Duel.HasFlagEffect(tp,id+100) and Duel.CheckPendulumZones(tp) 
		and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_EXTRA,0,1,nil)
	local b3=not Duel.HasFlagEffect(tp,id+200) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCode,CARD_ZARC),tp,LOCATION_ONFIELD,0,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,LOCATION_ONFIELD)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
	elseif sel==2 then
		e:SetCategory(0)
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1)
	elseif sel==3 then
		e:SetCategory(0)
		Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Destroy 1 "Supreme King Z-ARC" you control
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
		if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,e,tp)
			if #sg>0 then
				Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
			end
		end
	elseif op==2 then
		--Place 1 face-up Pendulum Monster from your Extra Deck in your Pendulum Zone
		if not Duel.CheckPendulumZones(tp) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sc=Duel.SelectMatchingCard(tp,s.pcfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
		if sc then
			Duel.MoveToField(sc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	elseif op==3 then
		--Set 1 Quick-Play Spell directly from your Deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SSet(tp,g)
		end
	end
end