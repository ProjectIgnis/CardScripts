--Cold Performance
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return c:GetPreviousTypeOnField()&(TYPE_PENDULUM+TYPE_MONSTER)==(TYPE_PENDULUM+TYPE_MONSTER) and c:IsPreviousControler(tp)
end
function s.condition(e,tp,eg,ev,ep,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp)
end
function s.target(e,tp,eg,ev,ep,re,r,rp,chk,chkc)
	local lp=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local rp=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if chkc then return eg:IsExists(s.filter,1,nil) and (lp==nil or rp==nil) end
	if chk==0 then return lp==nil or rp==nil end
	local tc=eg:FilterSelect(tp,s.filter,1,1,nil,tp)
	Duel.SetTargetCard(tc)
end
function s.operation(e,tp,eg,ev,ep,re,r,rp)
	local lp=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local rp=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if lp and rp then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetTargetRange(1,0)
		e1:SetValue(0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end  
end
