--嵐闘機ストームライダーガルダイバー
--Stormrider Gulldiver
--Scripted by Belisk.
local s,id=GetID()
function s.initial_effect(c)
	--no damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.damcon)
	e1:SetCost(s.damcost)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	-- e2:SetCode(EVENT_PHASE_START+PHASE_MAIN2)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.spcon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	if s.counter==nil then
		s.counter=true
		s[0]=0
		s[1]=0
		local ec1=Effect.CreateEffect(c)
		ec1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ec1:SetCode(EVENT_BATTLE_DESTROYED)
		ec1:SetOperation(s.operation)
		Duel.RegisterEffect(ec1,0)
		local ec2=Effect.CreateEffect(c)
		ec2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ec2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ec2:SetOperation(s.resetcount)
		Duel.RegisterEffect(ec2,0)
	end
end
s.listed_series={0x580}
function s.resetcount(e,tp,eg,ep,ev,re,r,rp)
	s[0]=0
	s[1]=0
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_BATTLE==REASON_BATTLE and eg:IsExists(Card.GetPreviousControler,1,nil,tp,tp)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		local py=tc:GetPreviousControler()
		if py==0 then
			local p=tc:GetReasonPlayer()
			s[1-p]=s[1-p]+1
		end
		if py==1 then
			local p=tc:GetReasonPlayer()
			s[1-p]=s[1-p]+1
		end
		tc=eg:GetNext()
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetBattleDamage(tp)>0
end
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(HALF_DAMAGE)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
	Duel.BreakEffect()
	c:RegisterFlagEffect(id,RESET_PHASE|PHASE_END,0,1)
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	--start of main2 event trigger
	local m2=Effect.CreateEffect(c)
	m2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	m2:SetCode(EVENT_ADJUST)
	m2:SetRange(LOCATION_GRAVE)
	m2:SetCondition(s.adjcon)
	m2:SetOperation(s.adjop)
	m2:SetCountLimit(1)
	m2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(m2)
end
function s.adjcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN2 and not Duel.CheckPhaseActivity()
end
function s.adjop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+id,nil,0,0,0,0)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
function s.spfilter(c,e,tp,rate)
	return c:IsSetCard(0x580) and c:IsLinkMonster() and c:GetLink()<=rate and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rate=s[tp]
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,rate) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rate=s[tp]
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,rate)
	local tc=g:GetFirst()
	if tc then
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			local atk=tc:GetAttack()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(math.ceil(atk/2))
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
		Duel.SpecialSummonComplete()
	end
end