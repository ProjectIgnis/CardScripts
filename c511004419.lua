--performapal nightmare knight
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCost(aux.bfgcost)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DAMAGE)
		ge1:SetOperation(s.gop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.gop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE and Duel.GetTurnPlayer()==tp
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)~=0 or Duel.GetFlagEffect(1-tp,id)~=0 end
	local dep=nil
	if Duel.GetFlagEffect(tp,id)~=0 and Duel.GetFlagEffect(1-tp,id)~=0 then
		dep=PLAYER_ALL
	elseif Duel.GetFlagEffect(tp,id)~=0 then
		dep=tp
	else
		dep=1-tp
	end
	Duel.SetTargetPlayer(dep)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,dep,1000)
end
function s.operation(e,tp,eg,ev,ep,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if p~=PLAYER_ALL then
		Duel.Damage(p,d,REASON_EFFECT)
	else
		Duel.Damage(1-tp,d,REASON_EFFECT,true)
		Duel.Damage(tp,d,REASON_EFFECT,true)
		Duel.RDComplete()
	end
end
