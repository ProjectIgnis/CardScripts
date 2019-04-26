--Puella Magi - Homura Akemi
function c210533302.initial_effect(c)
	c:EnableCounterPermit(0x1,LOCATION_MZONE+LOCATION_PZONE)
	--counter limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_COUNTER_LIMIT|0x1)
	e1:SetValue(c210533302.CounterValue)
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
	e2:SetTarget(c210533302.splimit)
	c:RegisterEffect(e2)
	--pendulum activation
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(1160)
	e3:SetType(EFFECT_TYPE_ACTIVATE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetTarget(c210533302.pat)
	e3:SetOperation(c210533302.pao)
	c:RegisterEffect(e3)
	--negate 1
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCost(c210533302.ncos)
	e4:SetCondition(c210533302.ncon1)
	e4:SetTarget(c210533302.nt1)
	e4:SetOperation(c210533302.no1)
	c:RegisterEffect(e4)
	--special summoned by pendulum summon
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(c210533302.psccon)
	e5:SetTarget(c210533302.psct)
	e5:SetOperation(c210533302.psco)
	c:RegisterEffect(e5)
	--special summoned by effect of "Puella Magi Incubator - Kyubey"
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetCondition(c210533302.ssekccon)
	e6:SetTarget(c210533302.ssekct)
	e6:SetOperation(c210533302.ssekco)
	c:RegisterEffect(e6)
	--atk/def gain
	local e7=Effect.CreateEffect(c)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_UPDATE_ATTACK)
	e7:SetValue(c210533302.aduv)
	e7:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e8)
	--negate 2
	local e9=Effect.CreateEffect(c)
	e9:SetCategory(CATEGORY_NEGATE)
	e9:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e9:SetType(EFFECT_TYPE_QUICK_O)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCode(EVENT_CHAINING)
	e9:SetCost(c210533302.ncos)
	e9:SetCondition(c210533302.ncon2)
	e9:SetTarget(c210533302.nt2)
	e9:SetOperation(c210533302.no2)
	c:RegisterEffect(e9)
end
function c210533302.CounterValue(e)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_MZONE) then
		return 2
	elseif c:IsLocation(LOCATION_PZONE) then
		return 1
	else
		return 0
	end
end
function c210533302.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0xf72)
end
function c210533302.pat(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
function c210533302.pao(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x1,1,true)
	end
end
function c210533302.ncos(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,1,REASON_COST)
end
function c210533302.ncon1(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function c210533302.nt1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c210533302.nof1(c)
	return c:IsType(TYPE_TRAP+TYPE_SPELL) and c:IsSSetable() and aux.IsCodeListed(c,210533302)
end
function c210533302.no1(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,c210533302.nof1,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SSet(tp,g)
		end
	end
end
function c210533302.psccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
function c210533302.psct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
function c210533302.psco(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x1,1,true)
	end
end
function c210533302.ssekccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SPECIAL|72)
end
function c210533302.ssekct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1)
end
function c210533302.ssekco(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x1,2,true)
	end
end
function c210533302.aduv(e,c)
	return 300*c:GetCounter(0x1)
end
function c210533302.nf(c,tp)
	return c:IsSetCard(0xf72) and c:IsType(TYPE_PENDULUM) and (c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_PZONE))
		and c:IsControler(tp)
end
function c210533302.ncon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g then return false end
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and ep~=tp and Duel.IsChainNegatable(ev)
	and g:IsExists(c210533302.nf,1,nil,tp)
end
function c210533302.nt2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function c210533302.no2(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end