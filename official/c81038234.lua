--夢魔鏡の夢語らい
--Dream Mirror Dreamtelling
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--Your "Dream Mirror" monsters are shuffled into the deck instead of going to GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.reptg)
	e2:SetValue(LOCATION_DECKSHF)
	c:RegisterEffect(e2)
	--Place 1 "Dream Mirror of Joy" or "Dream Mirror of Terror" from banished/GY into field zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
	--Lists "Dream Mirror" archetype
s.listed_series={0x131}
	--Specificially lists "Dream Mirror of Joy" and "Dream Mirror of Terror"
s.listed_names={CARD_DREAM_MIRROR_JOY,CARD_DREAM_MIRROR_TERROR}

	--Check if a "Dream Mirror" is tributing itself as cost
function s.repfilter(c,tp,re)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsSetCard(0x131) and c:IsReason(REASON_COST)
		and c==re:GetHandler() and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp,re) end
	return true
end
	--Send this face-up card to GY as cost
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
	--Check for "Dream Mirror of Joy"/"Dream Mirror of Terror"
function s.filter(c,tp)
	return c:IsType(TYPE_FIELD) and c:IsCode(CARD_DREAM_MIRROR_JOY,CARD_DREAM_MIRROR_TERROR) and c:IsFaceup() and not c:IsForbidden()
end
	--Check for 1 monster that specifically lists "Dream Mirror of Joy"/"Dream Mirror of Terror"
function s.spfilter(c,e,tp,code)
	return aux.IsCodeListed(c,code) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil,tp) end
end
	--Place 1 "Dream Mirror of Joy" or "Dream Mirror of Terror" from banished/GY into field zone
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ag=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	if #ag>0 then
		local ac=ag:GetFirst()
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		Duel.MoveToField(ac,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		--Special summon 1 monster that specifically lists the placed card
		local code=ac:GetCode()
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp,code)
		if #g>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,1,nil):GetFirst()
			Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end