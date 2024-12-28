--影騎士シメーリア
--Centur-Ion Chimerea
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Change activated monster effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.chcon)
	e1:SetTarget(s.chtg)
	e1:SetOperation(s.chop)
	c:RegisterEffect(e1)
	--Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e2:SetCondition(function(e) return Duel.IsMainPhase() and e:GetHandler():IsContinuousTrap() end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_CENTURION}
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsMonsterEffect() and Duel.GetCurrentChain(true)>=2
end
function s.plfilter(c,tp)
	return c:IsSetCard(SET_CENTURION) and c:IsMonster() and c:IsFaceup() and not c:IsForbidden()
		and c:CheckUniqueOnField(tp)
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,tp) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local p=1-tp
	if Duel.GetLocationCount(p,LOCATION_SZONE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(p,aux.NecroValleyFilter(s.plfilter),p,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if tc and Duel.MoveToField(tc,p,p,LOCATION_SZONE,POS_FACEUP,tc:IsMonsterCard()) then
		--Treat it as a Continuous Trap
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_TRAP|TYPE_CONTINUOUS)
		e1:SetReset((RESET_EVENT|RESETS_STANDARD)&~RESET_TURN_SET)
		tc:RegisterEffect(e1)
	end
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeChainOperation(ev,s.plop)
	--Cannot Special Summon "Centur-Ion Chimerea" for the rest of this turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return c:IsCode(id) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end