--波導銃ミニ・マグロム
--Hydro Gun Mini Bluefin
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Increase self ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_TOHAND|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160002032}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_FISH),tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,RACE_FISH),tp,LOCATION_MZONE,0,nil)
	local ct=g:GetSum(Card.GetLevel)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,ct*100)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.spfilter(c,e,tp)
	return c:IsCode(160002032) and (c:IsAbleToHand() or (Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	-- Effect
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,RACE_FISH),tp,LOCATION_MZONE,0,nil)
	local ct=g:GetSum(Card.GetLevel)
	if c:IsRelateToEffect(e) and c:IsFaceup() and ct>0 then
		-- Gain ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
		e1:SetValue(ct*100)
		c:RegisterEffect(e1)
		if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
			if tc then
				aux.ToHandOrElse(tc,tp,
					function()
						return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
					end,
					function()
						Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
					end,
					aux.Stringid(id,2)
				)
			end
		end
	end
end

