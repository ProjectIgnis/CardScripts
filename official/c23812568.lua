--アディショナル・ミラー・レベル７
--Additional Mirror Level 7
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 2 monsters with the same name from the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={id}
function s.confilter(c,tp)
	return c:IsLevel(7) and c:IsFaceup() and c:IsControler(tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.confilter,1,nil,tp)
end
function s.costfilter(c)
	return c:IsCode(id) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND|LOCATION_DECK,0,2,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND|LOCATION_DECK,0,2,2,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tgfilter(c,e,tp,eg)
	return eg:IsContains(c) and c:IsLevel(7) and c:IsFaceup()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp,c:GetCode())
end
function s.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,e,tp,eg) end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and ft>=2
		and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,eg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,eg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,1,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		--Can only Special Summon from the Extra Deck once
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetCondition(s.spcon)
		e1:SetOperation(s.spop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	--Special Summon 2 monsters with the same name and take damage equal to the combined ATK
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,2,2,nil,e,tp,tc:GetCode())
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local sum=Duel.GetOperatedGroup():GetSum(Card.GetBaseAttack)
		if sum>0 then
			Duel.Damage(tp,sum,REASON_EFFECT)
		end
	end
end
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end