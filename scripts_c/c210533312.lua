--Homura's Shield
function c210533312.initial_effect(c)
	c:EnableCounterPermit(0xf00,LOCATION_SZONE)
	c:SetCounterLimit(0xf00,3)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--when destroyed, place counter's
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c210533312.asc)
	c:RegisterEffect(e2)
	--activate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	--e3:SetCountLimit(1)
	e3:SetCost(c210533312.cost)
	e3:SetCondition(c210533312.condition)
	e3:SetTarget(c210533312.target)
	e3:SetOperation(c210533312.operation)
	c:RegisterEffect(e3)
end
c210533312.listed_names={210533302}
function c210533312.asc(e,tp,eg,ep,ev,re,r,rp)
	local count=0
	if not eg then return end
	for tc in aux.Next(eg) do
		if tc:IsPreviousSetCard(0xf72) and tc:GetPreviousControler()==tp and tc:GetPreviousTypeOnField()&TYPE_PENDULUM>0 
		and tc:IsPreviousLocation(LOCATION_MZONE+LOCATION_PZONE) and tc:IsReason(REASON_DESTROY) then
			count=count+1
		end
	end
	if count>0 then
		e:GetHandler():AddCounter(0xf00,count,true)
	end
end
function c210533312.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0xf00,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0xf00,3,REASON_COST)
end
function c210533312.cfilter1(c)
	return c:IsFaceup() and c:IsCode(210533302)
end
function c210533312.cfilter2(c)
	return c:IsFacedown() or not c:IsSetCard(0xf72)
end
function c210533312.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c210533312.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		and not Duel.IsExistingMatchingCard(c210533312.cfilter2,tp,LOCATION_MZONE,0,1,nil)
end
function c210533312.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function c210533312.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local phase=Duel.SelectOption(tp,aux.Stringid(210533312,0),aux.Stringid(210533312,1),aux.Stringid(210533312,2))
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	if phase==0 then
		e1:SetCode(EFFECT_SKIP_DP)
		e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_OPPO_TURN,1)
	elseif phase==1 then
		e1:SetCode(EFFECT_SKIP_M1)
		e1:SetReset(RESET_PHASE+PHASE_MAIN1+RESET_OPPO_TURN,1)
	else
		e1:SetCode(EFFECT_SKIP_BP)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,1)
	end
	Duel.RegisterEffect(e1,tp)
end