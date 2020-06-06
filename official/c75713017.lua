--燎星のプロメテオロン
--Prometeor, the Burning Star
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--extra attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(s.atcon)
	e1:SetCost(s.atcost)
	e1:SetOperation(s.atop)
	c:RegisterEffect(e1)
end
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not bc then return false end
	local seq=bc:GetPreviousSequence()
	e:SetLabel(seq+16)
	return Duel.GetAttacker()==c and aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and c:CanChainAttack(0) and seq<5
end
function s.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_DISCARD+REASON_COST)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetLabel()
	Duel.ChainAttack()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetLabel(0x1<<seq)
	e1:SetOperation(s.disop)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
end
function s.disop(e,tp)
	return e:GetLabel()
end
