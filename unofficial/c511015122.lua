--ファントム・エフェクト
--Phantom Effect
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return false end
	local e1=Duel.IsPlayerAffectedByEffect(tp,EFFECT_REVERSE_DAMAGE)
	local e2=Duel.IsPlayerAffectedByEffect(tp,EFFECT_REVERSE_RECOVER)
	local rd=e1 and not e2
	local rr=not e1 and e2
	local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	if cv then e:SetLabel(cv) end
	if ex and (cp==tp or cp==PLAYER_ALL) and not rd and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_NO_EFFECT_DAMAGE) then
		return true
	end
	ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_RECOVER)
	if cv then e:SetLabel(cv) end
	return ex and (cp==tp or cp==PLAYER_ALL) and rr and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_NO_EFFECT_DAMAGE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,0,-2,0,1,RACE_ZOMBIE,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID))
	e1:SetValue(s.damcon)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,0,-1,0,1,RACE_ZOMBIE,ATTRIBUTE_DARK) then return end
	Duel.BreakEffect()
	local token=Duel.CreateToken(tp,id+1)
	Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetValue(e:GetLabel())
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e2,true)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e3,true)
	Duel.SpecialSummonComplete()
end
function s.damcon(e,re,val,r,rp,rc)
	local cc=Duel.GetCurrentChain()
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cc==0 or r&REASON_EFFECT==0 or cid~=e:GetLabel() then return val end
	return 0
end