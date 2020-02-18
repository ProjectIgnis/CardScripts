--ドンヨリボー＠イグニスター
--Donyoribo @Ignister
--Scripted by Larry126
local s,id,alias=GetID()
function s.initial_effect(c)
	alias=c:GetOriginalCodeRule()
	--Battle Damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,alias)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Effect Damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_F)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1,alias+1)
	e2:SetCondition(s.damcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
s.listed_series={0x135}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	return tc and tc:IsControler(tp) and tc:IsSetCard(0x135) and Duel.GetBattleDamage(tp)>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetOperation(s.bdop)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end
function s.bdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(tp,0)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x135)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
	for p=0,1 do
		local e1=Duel.IsPlayerAffectedByEffect(p,EFFECT_REVERSE_DAMAGE)
		local e2=Duel.IsPlayerAffectedByEffect(p,EFFECT_REVERSE_RECOVER)
		local rd=e1 and not e2
		local rr=not e1 and e2
		local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
		if ex and (cp==p or p==PLAYER_ALL) and not rd and not Duel.IsPlayerAffectedByEffect(p,EFFECT_NO_EFFECT_DAMAGE) then 
			return true 
		end
		ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_RECOVER)
		if ex and (p==tp or p==PLAYER_ALL) and rr and not Duel.IsPlayerAffectedByEffect(p,EFFECT_NO_EFFECT_DAMAGE) then
			return true
		end
	end
	return false
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3)))
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if op==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,1)
		e1:SetLabel(cid)
		e1:SetValue(s.damval)
		e1:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e1,tp)
	elseif op==1 then
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CHANGE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,1)
		e2:SetLabel(cid)
		e2:SetValue(s.damval2)
		e2:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e2,tp)  
	end
end
function s.damval(e,re,val,r,rp,rc)
	local cc=Duel.GetCurrentChain()
	if cc==0 or r&REASON_EFFECT==0 then return val end
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return val end
	return 0
end
function s.damval2(e,re,val,r,rp,rc)
	local cc=Duel.GetCurrentChain()
	if cc==0 or r&REASON_EFFECT==0 then return val end
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return val end
	return val*2
end
