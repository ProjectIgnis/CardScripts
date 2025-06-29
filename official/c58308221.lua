--ＥＸＰ
--Extra Pendulum
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--During your Main Phase this turn, you can conduct 1 Pendulum Summon of a monster(s) from your Extra Deck in addition to your Pendulum Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function(e,tp) return Pendulum.PlayerCanGainAdditionalPendulumSummon(tp,id) end)
	e1:SetOperation(function(e,tp) Pendulum.GrantAdditionalPendulumSummon(e:GetHandler(),nil,tp,LOCATION_EXTRA,aux.Stringid(id,1),aux.Stringid(id,2),id) end)
	c:RegisterEffect(e1)
end