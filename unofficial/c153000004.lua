--クリボー (Deck Master)
--Kuriboh (Deck Master)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	if not DeckMaster then
		return
	end
	--Deck Master Effect
	local dme1=Effect.CreateEffect(c)
	dme1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	dme1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	dme1:SetCondition(s.dmcon)
	dme1:SetOperation(s.dmop1)
	local dme2=Effect.CreateEffect(c)
	dme2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	dme2:SetCode(EVENT_CHAIN_SOLVING)
	dme2:SetCondition(s.dmcon)
	dme2:SetOperation(s.dmop2)
	DeckMaster.RegisterAbilities(c,dme1,dme2)
	--No Damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.dmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	local dm=Duel.GetDeckMaster(tp)
	return (Duel.GetBattleDamage(tp)>0 or aux.damcon1(e,tp,eg,ep,ev,re,r,rp)) and dm and dm:IsCode(40640057)
		and (dm:IsLocation(LOCATION_MZONE) or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and dm:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.dmop1(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	local c=e:GetOwner()
	if not c:IsLocation(LOCATION_MZONE) and Duel.SummonDeckMaster(tp)<=0 then return end
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	Duel.ChangeBattleDamage(tp,0)
end
function s.dmop2(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	local c=e:GetOwner()
	if not c:IsLocation(LOCATION_MZONE) and Duel.SummonDeckMaster(tp)<=0 then return end
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
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
function s.refcon(e,re,val,r,rp,rc)
	local cc=Duel.GetCurrentChain()
	if cc==0 or r~=REASON_EFFECT then return end
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid==e:GetLabel() then return 0
	else return val end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetBattleDamage(tp)>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end