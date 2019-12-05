--倍返し
--Double Payback
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x1a)
	--counter
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetCondition(s.actcon)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
end
s.counter_place_list={0x1a}
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and tp~=rp and ev>=1000 and (r&REASON_EFFECT)~=0
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local ct=math.floor(ev/1000)
		c:AddCounter(0x1a,ct)
		--damage
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCondition(s.damcon)
		e1:SetTarget(s.damtg)
		e1:SetOperation(s.damop)
		if Duel.GetTurnPlayer()==tp then
			e1:SetLabel(0)
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		else
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
		end
		c:RegisterEffect(e1)
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.GetTurnCount()~=e:GetLabel()
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	local dam=e:GetHandler():GetCounter(0x1a)*2000;
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Damage(p,d,REASON_EFFECT)
	end
end
