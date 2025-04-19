--サテライト・キャノン (Anime)
--Satellite Cannon (Anime)
--fixed by MLD & Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Negate attacks that target "Satellite Cannon"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--Add 1 Turn Counter to this card during controller's End Phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(s.ccon)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	--Remove all Turn Counters from this card during controller's Battle Phase to increase ATK by 1000 for each Turn Counter removed until End Phase
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13893596,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCost(s.atkcost)
	e3:SetCondition(s.atkcon)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
s.listed_names={50400231}
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if a:IsLevelBelow(7) and d and d:IsCode(50400231) then
		Duel.NegateAttack()
	end
end
function s.ccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		c:AddCounter(0x1105,1)
	end
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=c:GetCounter(0x1105)
	if chk==0 then return ct>0 and c:IsCanRemoveCounter(tp,0x1105,ct,REASON_COST) end
	c:RemoveCounter(tp,0x1105,ct,REASON_COST)
	e:SetLabel(ct)
end
function s.atkcon(e)
	return Duel.IsBattlePhase() and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	if ct>0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)

	end
end