--超カバーカーニバル
--Super Hippo Carnival
local s,id=GetID()
function s.initial_effect(c)
	--Special summon 1 "Performapal Hip Hippo" from hand, deck, or GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
end
s.listed_names={41440148,TOKEN_HIPPO}
function s.filter(c,e,tp)
	return c:IsCode(41440148) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<=0 or (Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and ft>1) then return end
		if Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_HIPPO,0,TYPES_TOKEN,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH)
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local c=e:GetHandler()
			for i=1,ft do
				local token=Duel.CreateToken(tp,id+i)
				Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
				--Cannot be tributed
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(3303)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UNRELEASABLE_SUM)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				token:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
				token:RegisterEffect(e2)
				--Cannot special summon from extra deck while you control this token
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_FIELD)
				e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e3:SetRange(LOCATION_MZONE)
				e3:SetAbsoluteRange(tp,1,0)
				e3:SetTarget(s.splimit)
				e3:SetReset(RESET_EVENT|RESETS_STANDARD)
				token:RegisterEffect(e3)
				--Clock Lizard check
				local e4=aux.createContinuousLizardCheck(e:GetHandler(),LOCATION_MZONE)
				e4:SetReset(RESET_EVENT|RESETS_STANDARD)
				token:RegisterEffect(e4,true)
			end
			Duel.SpecialSummonComplete()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
			e1:SetTargetRange(0,LOCATION_MZONE)
			e1:SetValue(s.atlimit)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end
function s.atlimit(e,c)
	return not c:IsCode(TOKEN_HIPPO)
end