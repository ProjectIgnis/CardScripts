--Ability Yeil
--scripted by André and Shad3 and Cybercatman
local s,id=GetID()
function s.initial_effect(c)
	--active
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
function s.op()
	Duel.RegisterFlagEffect(0,id,0,0,0)
end
function s.handcon(tp)
	return tp~=Duel.GetTurnPlayer()
end
