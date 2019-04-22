--Puella Magi - Sayaka Miki
function c210533303.initial_effect(c)
	c:EnableCounterPermit(0x1,LOCATION_MZONE+LOCATION_PZONE)
	--counter limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_COUNTER_LIMIT|0x1)
	e1:SetValue(c210533303.CounterValue)
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
	e2:SetTarget(c210533303.splimit)
	c:RegisterEffect(e2)
	--pendulum activation
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(1160)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetTarget(c210533303.pat)
	e3:SetOperation(c210533303.pao)
	c:RegisterEffect(e3)
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(210533303,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCost(c210533303.sscos)
	e4:SetTarget(c210533303.sst)
	e4:SetOperation(c210533303.sso)
	c:RegisterEffect(e4)
	--special summoned by pendulum summon
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(c210533303.psccon)
	e5:SetTarget(c210533303.psct)
	e5:SetOperation(c210533303.psco)
	c:RegisterEffect(e5)
	--special summoned by effect of "Puella Magi Incubator - Kyubey"
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetCondition(c210533303.ssekccon)
	e6:SetTarget(c210533303.ssekct)
	e6:SetOperation(c210533303.ssekco)
	c:RegisterEffect(e6)
	--atk/def gain
	local e7=Effect.CreateEffect(c)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_UPDATE_ATTACK)
	e7:SetValue(c210533303.aduv)
	e7:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e8)
	--add as many counters
	local e9=Effect.CreateEffect(c)
	e9:SetCategory(CATEGORY_COUNTER)
	e9:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e9:SetType(EFFECT_TYPE_IGNITION)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCountLimit(1)
	e9:SetCost(c210533303.aamsccos)
	e9:SetTarget(c210533303.aamsct)
	e9:SetOperation(c210533303.aamsco)
	c:RegisterEffect(e9)
end
function c210533303.CounterValue(e)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_MZONE) then
		return 2
	elseif c:IsLocation(LOCATION_PZONE) then
		return 1
	else
		return 0
	end
end
function c210533303.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xf72)
end
function c210533303.pat(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
function c210533303.pao(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x1,1,true)
	end
end
function c210533303.sscos(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,1,REASON_COST)
end
function c210533303.sstf(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf72) and c:IsCanBeSpecialSummoned(e,72,tp,false,false)
end
function c210533303.sst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210533303.sstf,tp,0x12,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x12)
end
function c210533303.ssof(c)
	return c:IsType(TYPE_TRAP+TYPE_SPELL) and c:IsSSetable() and aux.IsCodeListed(c,210533303)
end
function c210533303.sso(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c210533303.sstf),tp,0x12,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,72,tp,tp,false,false,POS_FACEUP) then
		if c:IsRelateToEffect(e) then
			Duel.Destroy(c,REASON_EFFECT)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,c210533303.ssof,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SSet(tp,g)
		end
	end
end
function c210533303.psccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
function c210533303.psct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
function c210533303.psco(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x1,1,true)
	end
end
function c210533303.ssekccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SPECIAL|72)
end
function c210533303.ssekct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
function c210533303.ssekco(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x1,2,true)
	end
end
function c210533303.aduv(e,c)
	return 300*c:GetCounter(0x1)
end
function c210533303.amsf(c,e)
	return not c:IsCode(210533303) and c:IsSetCard(0xf72) and c:IsType(TYPE_PENDULUM) and c:IsCanAddCounter(0x1,1) and (not e or c:IsCanBeEffectTarget(e))
end
function c210533303.aamsccos(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c210533303.amsf,tp,LOCATION_MZONE+LOCATION_PZONE,0,nil,e)
	if chk==0 then return c:IsCanRemoveCounter(tp,0x1,1,REASON_COST) end
	local counter_max
	for i=1,math.min(#g,2) do
		if c:IsCanRemoveCounter(tp,0x1,i,REASON_COST) then counter_max=i end
	end
	Duel.Hint(HINT_SELECTMSG,tp,10)
	local l=Duel.AnnounceLevel(tp,1,counter_max)
	c:RemoveCounter(tp,0x1,l,REASON_COST)
	e:SetLabel(l)
end
function c210533303.aamsct(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(c210533303.amsf,tp,LOCATION_MZONE+LOCATION_PZONE,0,1,nil) end
	local l=e:GetLabel()
	local tc=Duel.SelectTarget(tp,c210533303.amsf,tp,LOCATION_MZONE+LOCATION_PZONE,0,l,l,nil)
end
function c210533303.gf(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e)
end
function c210533303.aamsco(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	g=g:Filter(c210533303.gf,nil,e)
	for tc in aux.Next(g) do
		local counter_max=0
		while tc:IsCanAddCounter(0x1,counter_max+1) do
			counter_max=counter_max+1
		end
		tc:AddCounter(0x1,counter_max,true)
	end
end