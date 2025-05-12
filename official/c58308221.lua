--ＥＸＰ
--Extra Pendulum
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--You can Pendulum Summon from the Extra Deck in addition to your Pendulum Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id+100)==0 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Pendulum.RegisterAdditionalPendulumSummon(e:GetHandler(),tp,id,function(c) return c:IsLocation(LOCATION_EXTRA) end)
end
