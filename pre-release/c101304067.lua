--デーモンの簒奪
--Archfiend Usurpation
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ARCHFIEND}
function s.setfilter(c)
	return c:IsSetCard(SET_ARCHFIEND) and c:IsTrap() and c:IsSSetable(true)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local b1=((e:GetHandler():IsLocation(LOCATION_SZONE) and ft>0) or ft>1)
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	local ritual_params={
				lvtype=RITPROC_GREATER,
				filter=aux.FilterBoolFunction(Card.IsSetCard,SET_ARCHFIEND),
				location=LOCATION_HAND|LOCATION_EXTRA
			}
	local b2=Ritual.Target(ritual_params)(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(0)
	elseif op==2 then
		e:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
		Ritual.Target(ritual_params)(e,tp,eg,ep,ev,re,r,rp,1)
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_EXTRA)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Set 1 "Archfiend" Trap from your Deck or GY, it can be activated this turn
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil):GetFirst()
		if sc and Duel.SSet(tp,sc)>0 then
			--It can be activated this turn
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,3))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			sc:RegisterEffect(e1)
		end
	elseif op==2 then
		--Ritual Summon 1 "Archfiend" Ritual Monster from your hand or face-up Extra Deck, by Tributing monsters from your hand or field whose total Levels equal or exceed its Level
		local ritual_params={
				lvtype=RITPROC_GREATER,
				filter=aux.FilterBoolFunction(Card.IsSetCard,SET_ARCHFIEND),
				location=LOCATION_HAND|LOCATION_EXTRA
			}
		Ritual.Operation(ritual_params)(e,tp,eg,ep,ev,re,r,rp)
	end
end