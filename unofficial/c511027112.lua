--ブラックフェザードラゴン (Anime)
--Black-Winged Dragon (Anime)
--Scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--damage negation battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.con1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--damage negation card effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--attack down
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(s.flagval)
	c:RegisterEffect(e3)
	--regain atk + atkdown
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.tg3)
	e4:SetOperation(s.op3)
	c:RegisterEffect(e4)
end
--damage negation battle
function s.con1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetBattleDamage(tp)>0
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetAttack()>=Duel.GetBattleDamage(tp) and not c:IsRelateToBattle() end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	local c=e:GetHandler()
	if c:GetFlagEffect(id)==0 then c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,0) end
	if Duel.SelectEffectYesNo(tp,c) then
		Duel.HintSelection(Group.FromCards(c))
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_DAMAGE,0,1)
		c:SetFlagEffectLabel(id,c:GetFlagEffectLabel(id)+Duel.GetBattleDamage(tp))
		Duel.ChangeBattleDamage(tp,0)
	end
end
--damage negation card effect
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local e1=Duel.IsPlayerAffectedByEffect(tp,EFFECT_REVERSE_DAMAGE)
	local e2=Duel.IsPlayerAffectedByEffect(tp,EFFECT_REVERSE_RECOVER)
	local rd=e1 and not e2
	local rr=not e1 and e2
	local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	if ex and (cp==tp or cp==PLAYER_ALL) and not rd and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_NO_EFFECT_DAMAGE) then
		e:SetLabel(cv)
		return true 
	end
	ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_RECOVER)
	if ex and (cp==tp or cp==PLAYER_ALL) and rr and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_NO_EFFECT_DAMAGE) then
		e:SetLabel(cv)
		return true
	else
		e:SetLabel(0)
		return false
	end
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttack()>=e:GetLabel() end
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	local c=e:GetHandler()
	if c:GetFlagEffect(id)==0 then c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,0) end
	if Duel.SelectEffectYesNo(tp,c) then
		Duel.HintSelection(Group.FromCards(c))
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
		c:SetFlagEffectLabel(id,c:GetFlagEffectLabel(id)+e:GetLabel())
		local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetLabel(cid)
		e1:SetValue(s.refcon)
		e1:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.refcon(e,re,val,r,rp,rc)
	local cc=Duel.GetCurrentChain()
	if cc==0 or r~=REASON_EFFECT then return end
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid==e:GetLabel() then return 0
	else return val end
end
--attack down
function s.flagval(e,c)
	return e:GetHandler():GetFlagEffectLabel(id) and -e:GetHandler():GetFlagEffectLabel(id) or 0
end
--regain atk + atkdown
function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffectLabel(id) and e:GetHandler():GetFlagEffectLabel(id)>0 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
	for tc in aux.Next(Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-c:GetFlagEffectLabel(id))
		tc:RegisterEffect(e1)
	end
	c:SetFlagEffectLabel(id,0)
end