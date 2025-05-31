--ブラックフェザードラゴン (Anime)
--Black-Winged Dragon (Anime)
--Scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1 or more non-Tuner monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--If you would take damage, except from a battle involving this card, you can make this card lose that much ATK instead. (Battle damage register)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return Duel.GetBattleDamage(e:GetHandlerPlayer())>0 end)
	e1:SetTarget(s.batdamtg)
	e1:SetOperation(s.batdamop)
	c:RegisterEffect(e1)
	--If you would take damage, except from a battle involving this card, you can make this card lose that much ATK instead. (Effect damage register)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.effdamcon)
	e2:SetTarget(s.effdamtg)
	e2:SetOperation(s.effdamop)
	c:RegisterEffect(e2)
	--This card loses ATK equal to the damage you would have taken
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(s.flagval)
	c:RegisterEffect(e3)
	--Make the ATK lost from the above effect 0 and if you do, monsters your opponent controls lose ATK equal to the ATK gained
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
function s.batdamtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetAttack()>=Duel.GetBattleDamage(tp) and not c:IsRelateToBattle() end
end
function s.batdamop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	local c=e:GetHandler()
	if c:GetFlagEffect(id)==0 then c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,0) end
	if Duel.SelectEffectYesNo(tp,c) then
		Duel.HintSelection(Group.FromCards(c))
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_DAMAGE,0,1)
		c:SetFlagEffectLabel(id,c:GetFlagEffectLabel(id)+Duel.GetBattleDamage(tp))
		Duel.ChangeBattleDamage(tp,0)
	end
end
function s.effdamcon(e,tp,eg,ep,ev,re,r,rp)
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
function s.effdamtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttack()>=e:GetLabel() end
end
function s.effdamop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	local c=e:GetHandler()
	if c:GetFlagEffect(id)==0 then c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,0) end
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
--Value registration for lowering this card's ATK
function s.flagval(e,c)
	return e:GetHandler():GetFlagEffectLabel(id) and -e:GetHandler():GetFlagEffectLabel(id) or 0
end
--This card gains ATK equal to the ATK lost, then monsters your opponent controls lose ATK equal to the ATK gained
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffectLabel(id) and e:GetHandler():GetFlagEffectLabel(id)>0 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
function s.atk(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-c:GetFlagEffectLabel(id))
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	c:SetFlagEffectLabel(id,0)
end
