--鎮魂の決闘
--Battle of Sleeping Spirits
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_BATTLE_END)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_NEOS}
function s.spfilter(c,e,tp,turn)
	return c:IsReason(REASON_BATTLE) and c:GetTurnID()==turn
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
function s.cansummon(e,p,turn)
	return Duel.GetLocationCount(p,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,p,LOCATION_GRAVE,0,1,nil,e,p,turn)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local turn=Duel.GetTurnCount()
		return s.cansummon(e,tp,turn) or s.cansummon(e,1-tp,turn)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,PLAYER_ALL,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local turn_p=Duel.GetTurnPlayer()
	local turn=Duel.GetTurnCount()
	s.spsummon(e,turn_p,turn,tp)
	s.spsummon(e,1-turn_p,turn,tp)
end
function s.spsummon(e,p,turn,tp)
	if not s.cansummon(e,p,turn) or not Duel.SelectYesNo(p,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(p,s.spfilter,p,LOCATION_GRAVE,0,1,1,nil,e,p,turn):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,p,p,false,false,POS_FACEUP_ATTACK)>0
		and p==tp and tc:IsCode(CARD_NEOS) then
		--Double ATK during Damage Step
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_BATTLE_START)
		e1:SetCountLimit(1)
		e1:SetOperation(s.atkop)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	--Double ATK
	local e1=Effect.CreateEffect(e:GetOwner())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(tc:GetAttack()*2)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
	tc:RegisterEffect(e1)
end