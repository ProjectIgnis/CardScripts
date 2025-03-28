--烙印凶鳴
--Screams of the Branded
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 of your Fusion Monsters that is banished or in GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Set itself from GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	--Check for Fusion Monsters sent to the GY
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={CARD_ALBAZ}
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		if tc:IsType(TYPE_FUSION) then 
			Duel.RegisterFlagEffect(tc:GetControler(),id,RESET_PHASE|PHASE_END,0,1)
		end
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0
end
function s.filter(c,e,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_COST) and re and re:IsActivated() and re:IsMonsterEffect()
		and re:GetHandler():IsCode(CARD_ALBAZ) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetCountLimit(1,id)
		e1:SetHintTiming(TIMING_END_PHASE)
		e1:SetCondition(s.setcon)
		e1:SetTarget(s.settg)
		e1:SetOperation(s.setop)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	end
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPhase(PHASE_END)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end