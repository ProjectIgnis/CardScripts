--強制終了
--Scrubbed Raid
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--End the Battle Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.bpcon)
	e2:SetCost(s.bpcost)
	e2:SetOperation(s.bpop)
	c:RegisterEffect(e2)
end
function s.bpcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase() and Duel.GetCurrentPhase()<PHASE_BATTLE
end
function s.bpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		and e:GetHandler():GetFlagEffect(id)==0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	Duel.SendtoGrave(g,REASON_COST)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESET_CHAIN,0,1)
end
function s.bpop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE|PHASE_BATTLE_STEP,1)
end