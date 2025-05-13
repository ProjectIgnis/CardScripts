--彗聖の将－ワンモア・ザ・ナイト
--Moissa Knight, the Comet General
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--Return itself from the Pendulum Zone to the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.tdcon)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	--Gain an additional Pendulum Summon this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DRAW)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) and Duel.GetCurrentPhase()<PHASE_END end)
	e2:SetCost(s.pendscost)
	e2:SetTarget(s.pendstg)
	e2:SetOperation(s.pendsop)
	c:RegisterEffect(e2)
end
function s.cfilter(c,tp)
	return c:IsPendulumSummoned() and c:IsSummonPlayer(tp)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsAbleToDeck() then
		local seq_op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
		Duel.SendtoDeck(c,nil,seq_op,REASON_EFFECT)
	end
end
function s.pendscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
function s.pendstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id+100)==0 end
end
function s.pendsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Pendulum.RegisterAdditionalPendulumSummon(c,tp,id,aux.Stringid(id,2),function(c) return c:IsLocation(LOCATION_HAND) end)
	Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END|RESET_SELF_TURN,0,1)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,4))
end