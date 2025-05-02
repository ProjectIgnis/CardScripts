--Catch of the Day
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_names={3643300}
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Check for "The Legendary Fisherman" to have destroyed a monster or inflicted battle damage
	local ge1=Effect.CreateEffect(e:GetHandler())
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EVENT_BATTLE_DAMAGE)
	ge1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return eg:IsExists(s.lffilter,1,nil,tp) end)
	ge1:SetOperation(function(e) Duel.RegisterFlagEffect(e:GetHandlerPlayer(),id+100,RESET_PHASE|PHASE_END,0,1) end)
	Duel.RegisterEffect(ge1,tp)
	local ge2=ge1:Clone()
	ge2:SetCode(EVENT_BATTLE_DESTROYING)
	Duel.RegisterEffect(ge2,tp)
	--Special Summon 1 Level 4 or lower WATER monster from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE|PHASE_BATTLE)
	e1:SetRange(0x5f)
	e1:SetCountLimit(1)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	Duel.RegisterEffect(e1,tp)
end
function s.lffilter(c,tp)
	return c:IsControler(tp) and c:IsCode(3643300)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--OPD check
	if Duel.GetFlagEffect(tp,id)>0 then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.umifilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil,tp)
	--condition
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,3643300),tp,LOCATION_ONFIELD,0,1,nil) and #g>0
end
function s.umifilter(c,tp)
	return c:IsCode(CARD_UMI) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.umifilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil,tp)
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,3643300),tp,LOCATION_ONFIELD,0,1,nil) and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		--OPD register
		Duel.RegisterFlagEffect(tp,id,0,0,0)
		--Activate 1 "Umi" from your Deck or GY
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetFlagEffect(tp,id+100)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Special Summon 1 Level 4 or lower WATER monster from your Deck
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetOperation(function () Duel.SetChainLimitTillChainEnd(aux.FALSE) end)
		g:GetFirst():RegisterEffect(e1)
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		e1:Reset()
	end
end
