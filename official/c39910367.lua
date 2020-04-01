--魔法都市エンディミオン
--Magical Citadel of Endymion
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SPELL)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Add counter
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
	--Remove counter replace
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_RCOUNTER_REPLACE+COUNTER_SPELL)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.rcon)
	e4:SetOperation(s.rop)
	c:RegisterEffect(e4)
	--Destroy replace
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTarget(s.desreptg)
	e5:SetOperation(s.desrepop)
	c:RegisterEffect(e5)
	--Add counter2
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetRange(LOCATION_FZONE)
	e6:SetOperation(s.addop2)
	c:RegisterEffect(e6)
end
s.listed_names={id}
s.counter_place_list={COUNTER_SPELL}
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=re:GetHandler()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and c~=e:GetHandler() then
		e:GetHandler():AddCounter(COUNTER_SPELL,1)
	end
end
function s.rcon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_COST)~=0 and ep==e:GetOwnerPlayer() and e:GetHandler():GetCounter(COUNTER_SPELL)>=ev
end
function s.rop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(ep,COUNTER_SPELL,ev,REASON_EFFECT)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_REPLACE+REASON_RULE)
		and e:GetHandler():GetCounter(COUNTER_SPELL)>0 end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(ep,COUNTER_SPELL,1,REASON_EFFECT)
end
function s.addop2(e,tp,eg,ep,ev,re,r,rp)
	local count=0
	local c=eg:GetFirst()
	while c~=nil do
		if not c:IsCode(id) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) then
			count=count+c:GetCounter(COUNTER_SPELL)
		end
		c=eg:GetNext()
	end
	if count>0 then
		e:GetHandler():AddCounter(COUNTER_SPELL,count)
	end
end
