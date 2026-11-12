--コールド・パフォーマンス
--Abysmal Entertainment
local s,id=GetID()
function s.initial_effect(c)
	--If a Pendulum Monster(s) you control is destroyed: Place 1 of those Pendulum Monsters in your Pendulum Zone, also you take no damage this turn.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return c:GetPreviousTypeOnField()&(TYPE_PENDULUM|TYPE_MONSTER)==(TYPE_PENDULUM|TYPE_MONSTER) and c:IsPreviousControler(tp)
end
function s.condition(e,tp,eg,ev,ep,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp)
end
function s.target(e,tp,eg,ev,ep,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
	local tc=eg:FilterSelect(tp,s.filter,1,1,nil,tp)
	Duel.SetTargetCard(tc)
end
function s.operation(e,tp,eg,ev,ep,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then 
		Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetTargetRange(1,0)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	Duel.RegisterEffect(e2,tp)
end
