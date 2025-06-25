--クリティウスの牙
--The Fang of Critias
local s,id=GetID()
function s.initial_effect(c)
	--This card is also always treated as "Legendary Dragon Critias"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_CODE)
	e0:SetValue(10000060)
	c:RegisterEffect(e0)
	--Send 1 Trap from your hand or field to the GY, that is listed on a Fusion Monster that can only be Special Summoned with "The Fang of Critias" (if that card is Set, reveal it), then Special Summon that Fusion Monster from your Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={10000060,id} --"Legendary Dragon Critias"
function s.tgfilter(c,e,tp)
	return c:IsTrap() and c:IsAbleToGrave() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetCode())
end
function s.spfilter(c,e,tp,code)
	return c:IsType(TYPE_FUSION) and c.material_trap and code==c.material_trap and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local mc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,nil,e,tp):GetFirst()
	if mc and not mc:IsImmuneToEffect(e) then
		if mc:IsOnField() and mc:IsFacedown() then
			Duel.ConfirmCards(1-tp,mc)
		end
		if Duel.SendtoGrave(mc,REASON_EFFECT)==0 or not mc:IsLocation(LOCATION_GRAVE) then return end
		local code=mc:GetCode()
		if mc:IsPreviousLocation(LOCATION_ONFIELD) and mc:IsPreviousPosition(POS_FACEUP) then
			code=mc:GetPreviousCodeOnField()
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,code):GetFirst()
		if sc then
			Duel.BreakEffect()
			if Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)==0 then return end
			sc:CompleteProcedure()
		end
	end
end
