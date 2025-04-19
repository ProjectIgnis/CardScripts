--パワー・ウォール (VG)
--Power Wall (VG)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer() and Duel.GetBattleDamage(tp)>=100 and Duel.GetAttackTarget()==nil
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dam=Duel.GetBattleDamage(tp)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==1 then 
		Duel.DiscardDeck(tp,1,REASON_COST)
		Duel.SetTargetParam(100)
	else
		local t={}
		local l=1
		while dam>0 and ct>0 do
			dam=dam-100
			ct=ct-1
			t[l]=l
			l=l+1
		end
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(85087012,2))
		local ac=Duel.AnnounceNumber(tp,table.unpack(t))
		Duel.DiscardDeck(tp,ac,REASON_COST)
		Duel.SetTargetParam(ac*100)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetOperation(s.damop)
	e1:SetLabel(Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM))
	e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local dam=Duel.GetBattleDamage(tp)-e:GetLabel()
	if dam<0 then dam=0 end
	Duel.ChangeBattleDamage(tp,dam)
end