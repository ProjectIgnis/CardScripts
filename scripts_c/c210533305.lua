--Puella Magi - Kyoko Sakura
function c210533305.initial_effect(c)
	c:EnableCounterPermit(0x1,LOCATION_MZONE+LOCATION_PZONE)
	--counter limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_COUNTER_LIMIT|0x1)
	e1:SetValue(c210533305.CounterValue)
	c:RegisterEffect(e1)
	--pendulum summon
	aux.EnablePendulumAttribute(c,false)
	--splimit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c210533305.splimit)
	c:RegisterEffect(e2)
	--pendulum activation
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(1160)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetTarget(c210533305.pat)
	e3:SetOperation(c210533305.pao)
	c:RegisterEffect(e3)
	--disable
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(210533305,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCost(c210533305.actlimcost)
	e4:SetTarget(c210533305.actlimtarget)
	e4:SetOperation(c210533305.actlimoperation)
	c:RegisterEffect(e4)
	--special summoned by pendulum summon
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(c210533305.psccon)
	e5:SetTarget(c210533305.psct)
	e5:SetOperation(c210533305.psco)
	c:RegisterEffect(e5)
	--special summoned by effect of "Puella Magi Incubator - Kyubey"
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetCondition(c210533305.ssekccon)
	e6:SetTarget(c210533305.ssekct)
	e6:SetOperation(c210533305.ssekco)
	c:RegisterEffect(e6)
	--atk/def gain
	local e7=Effect.CreateEffect(c)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_UPDATE_ATTACK)
	e7:SetValue(c210533305.aduv)
	e7:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e8)
	--special summon as many
	local e9=Effect.CreateEffect(c)
	e9:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e9:SetType(EFFECT_TYPE_IGNITION)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCountLimit(1)
	e9:SetCost(c210533305.sstcos)
	e9:SetTarget(c210533305.sstt)
	e9:SetOperation(c210533305.ssto)
	c:RegisterEffect(e9)
	--cannot be destroyed
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD)
	e10:SetCode(EFFECT_INDESTRUCTABLE)
	e10:SetCondition(c210533305.icon)
	e10:SetRange(LOCATION_MZONE)
	e10:SetTarget(c210533305.it)
	e10:SetTargetRange(LOCATION_MZONE,0)
	e10:SetValue(1)
	c:RegisterEffect(e10)
end
function c210533305.CounterValue(e)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_MZONE) then
		return 2
	elseif c:IsLocation(LOCATION_PZONE) then
		return 1
	else
		return 0
	end
end
function c210533305.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xf72)
end
function c210533305.pat(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
function c210533305.pao(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x1,1,true)
	end
end
function c210533305.actlimcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,1,REASON_COST)
end
function c210533305.actlimtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,nil,nil)
end
function c210533305.actlimof(c)
	return c:IsType(TYPE_TRAP+TYPE_SPELL) and c:IsSSetable() and aux.IsCodeListed(c,210533305)
end
function c210533305.actlimoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetCondition(c210533305.actcon)
		e1:SetOperation(c210533305.actop1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_SPSUMMON_SUCCESS)
		Duel.RegisterEffect(e2,tp)
		local e3=e1:Clone()
		e3:SetCode(EVENT_CHAIN_END)
		e3:SetOperation(c210533305.actop2)
		Duel.RegisterEffect(e3,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,c210533305.actlimof,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SSet(tp,g)
		end
	end
end
function c210533305.actfilter(c,tp)
	return c:IsSetCard(0xf72) and c:IsSummonPlayer(tp)
end
function c210533305.actcon(e,tp)
	return eg and eg:IsExists(c210533305.actfilter,1,nil,tp)
end
function c210533305.actop1(e,tp)
	if Duel.GetCurrentChain()==0 then
		Duel.SetChainLimitTillChainEnd(c210533305.chainlm)
	elseif Duel.GetCurrentChain()==1 then
		Duel.RegisterFlagEffect(210533305,RESET_PHASE+PHASE_END,0,1)
	end
end
function c210533305.actop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(210533305)~=0 then
		Duel.SetChainLimitTillChainEnd(c210533305.chainlm)
	end
	Duel.ResetFlagEffect(210533305)
end
function c210533305.chainlm(e,rp,tp)
	return tp==rp
end
function c210533305.psccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
function c210533305.psct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
function c210533305.psco(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x1,1,true)
	end
end
function c210533305.ssekccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SPECIAL|72)
end
function c210533305.ssekct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
function c210533305.ssekco(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x1,2,true)
	end
end
function c210533305.aduv(e,c)
	return 300*c:GetCounter(0x1)
end
function c210533305.sstcos(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,0x1,1,REASON_COST) end
	local counter_max
	for i=1,2 do
		if c:IsCanRemoveCounter(tp,0x1,i,REASON_COST) and (i==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133))
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>=i then
			counter_max=i
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,10)
	local l=Duel.AnnounceLevel(tp,1,counter_max)
	c:RemoveCounter(tp,0x1,l,REASON_COST)
	e:SetLabel(l)
end
function c210533305.sstt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,210533300,0xf72,0x4011,2100,2000,8,RACE_SPELLCASTER,ATTRIBUTE_FIRE) end
	local l=e:GetLabel()
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,l,tp,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,l,tp,nil)
end
function c210533305.ssto(e,tp,eg,ep,ev,re,r,rp)
	local l=e:GetLabel()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,210533300,0xf72,0x4011,2100,2000,8,RACE_SPELLCASTER,ATTRIBUTE_FIRE) then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		l=1
	else
		l=math.min(l,ft)
	end
	for i=1,l do
		local token=Duel.CreateToken(tp,210533300,0xf72,0x4011,2100,2000,RACE_SPELLCASTER,ATTRIBUTE_FIRE)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
end
function c210533305.iconf(c)
	return c:IsCode(210533300) and c:IsFaceup()
end
function c210533305.icon(e)
	return Duel.IsExistingMatchingCard(c210533305.iconf,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function c210533305.it(e,c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xf72) and c:IsFaceup()
end