--Ｓｐ－オーバー・ブースト
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
	return tc and tc:GetCounter(0x91)<7 and not Duel.IsPlayerAffectedByEffect(tp,100100090)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local tc=Duel.GetFieldCard(p,LOCATION_SZONE,5)
	if not tc or Duel.IsPlayerAffectedByEffect(p,100100090) then return end
	tc:RegisterFlagEffect(110000000,RESET_CHAIN,0,1)
	if tc:GetCounter(0x91)<7 then
		tc:AddCounter(0x91,6)
	else
		tc:AddCounter(0x91,12-tc:GetCounter(0x91))
	end
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetOperation(s.op)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	tc:RegisterEffect(e3)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
	if tc:GetCounter(0x91)<=1 then return end
	if tc:GetCounter(0x91)>1 then 
		tc:RemoveCounter(tp,0x91,tc:GetCounter(0x91)-1,REASON_EFFECT)	
	end
end
