--一日万倍龍
--Myriaday Dragon
--Scripted by The Razgriz
local s,id=GetID()
local COUNTER_MYRIAD=0x21d
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_MYRIAD)
	--Once per turn, during the End Phase: You can pay 100 LP; place 1 Myriad Counter on this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(Cost.PayLP(100))
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then return c:IsCanAddCounter(COUNTER_MYRIAD,1) end
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,c,1,tp,COUNTER_MYRIAD)
	end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			c:AddCounter(COUNTER_MYRIAD,1)
		end
	end)
	c:RegisterEffect(e1)
	--Once per turn, during your Main Phase: You can place 1 Myriad Counter on this card for every 1000 points difference between your LP and your opponent's
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		local number_of_counters=math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))//1000
		if chk==0 then return number_of_counters>0 and c:IsCanAddCounter(COUNTER_MYRIAD,number_of_counters) end
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,c,number_of_counters,tp,COUNTER_MYRIAD)
	end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		local number_of_counters=math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))//1000
		if number_of_counters>0 then
			c:AddCounter(COUNTER_MYRIAD,number_of_counters)
		end
	end)
	c:RegisterEffect(e2)
	--Gains 10,000 ATK/DEF while it has 10 or more Myriad Counters
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_SINGLE)
	e3a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3a:SetCode(EFFECT_UPDATE_ATTACK)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetCondition(function(e)
		return e:GetHandler():GetCounter(COUNTER_MYRIAD)>=10
	end)
	e3a:SetValue(10000)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3b)
	--If this card would be destroyed by battle or card effect, remove 1 Myriad Counter from it instead
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then
			local c=e:GetHandler()
			return not c:IsReason(REASON_REPLACE|REASON_RULE) and c:HasCounter(COUNTER_MYRIAD,1)
		end
		return true
	end)
	e4:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		e:GetHandler():RemoveCounter(tp,COUNTER_MYRIAD,1,REASON_EFFECT)
	end)
	c:RegisterEffect(e4)
end
s.counter_place_list={COUNTER_MYRIAD}