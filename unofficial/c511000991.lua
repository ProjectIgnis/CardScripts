--レベル・タックス
--Level Tax
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Players cannot Summon a Level 5 or higher monster unless they pay LP equal to its ATK
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1a:SetCode(EFFECT_SUMMON_COST)
	e1a:SetCost(s.costchk)
	e1a:SetOperation(s.costop)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_FLIPSUMMON_COST)
	local e1c=e1a:Clone()
	e1c:SetCode(EFFECT_SPSUMMON_COST)
	--Grant the above effects to Level 5 or higher monsters
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2a:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2a:SetRange(LOCATION_SZONE)
	e2a:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
	e2a:SetTarget(aux.TargetBoolFunction(Card.IsLevelAbove,5))
	e2a:SetLabelObject(e1a)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetLabelObject(e1b)
	c:RegisterEffect(e2b)
	local e2c=e2a:Clone()
	e2c:SetLabelObject(e1c)
	c:RegisterEffect(e2c)
	--Handle multiple "Level Tax" effects stacking
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(511000991)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(1,1)
	c:RegisterEffect(e3)
end
function s.costchk(e,c,tp)
	local ct=#{Duel.GetPlayerEffect(tp,id)}
	local cost=c:GetAttack()*ct
	if Duel.CheckLPCost(tp,cost) then
		e:SetLabel(cost)
		return true
	else
		e:SetLabel(0)
		return false
	end
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.PayLPCost(tp,e:GetLabel())
	e:SetLabel(0)
end