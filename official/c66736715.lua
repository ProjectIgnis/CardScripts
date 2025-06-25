--彗聖の将－ワンモア・ザ・ナイト
--Moissa Knight, the Comet General
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--Place this card on either the top or bottom of the Deck
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
	--During your Main Phase this turn, you can conduct 1 Pendulum Summon of a monster(s) from your hand in addition to your Pendulum Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DRAW)
	e2:SetCondition(function(e,tp) return Pendulum.PlayerCanGainAdditionalPendulumSummon(tp,id) end)
	e2:SetCost(Cost.SelfReveal)
	e2:SetOperation(function(e,tp) Pendulum.GrantAdditionalPendulumSummon(e:GetHandler(),nil,tp,LOCATION_HAND,aux.Stringid(id,2),aux.Stringid(id,3),id) end)
	c:RegisterEffect(e2)
end
function s.tdconfilter(c,tp)
	return c:IsPendulumSummoned() and c:IsSummonPlayer(tp)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.tdconfilter,1,nil,tp)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsAbleToDeck() then
		local seq_op=0
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 then
			seq_op=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
		end
		Duel.SendtoDeck(c,nil,seq_op,REASON_EFFECT)
	end
end