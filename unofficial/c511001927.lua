--パワー・スピリッツ
--Power Spirit
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(Cost.PayLP(1000))
	c:RegisterEffect(e1)
	--Face-up Attack Position monsters you control cannot be destroyed by battle, except by battle with an opponent's monster that has 1000 or more ATK than them
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetValue(s.indval)
	c:RegisterEffect(e2)
end
function s.indtg(e,c)
	e:SetLabel(c:GetAttack())
	return c:IsAttackPos()
end
function s.indval(e,c)
	return c:IsAttackBelow(e:GetLabel()+999)
end
