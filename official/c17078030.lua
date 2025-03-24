--光の護封壁
--Wall of Revealing Light
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
	--cannot attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.atktarget)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		for _,eff in pairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_LPCOST_CHANGE)}) do
			local val=eff:GetValue()
			if (type(val)=='integer' and val==0)
				or (type(val)=='function' and (val(eff,e,tp,1000)~=1000)) then
				return false
			end
		end
		return Duel.CheckLPCost(tp,1000)
	end
	local lp=Duel.GetLP(tp)
	local t={}
	for i=1,math.floor((lp)/1000) do t[i]=i*1000 end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local announce=Duel.AnnounceNumber(tp,table.unpack(t))
	Duel.PayLPCost(tp,announce)
	e:GetLabelObject():SetLabel(announce)
	e:GetHandler():SetHint(CHINT_NUMBER,announce)
end
function s.atktarget(e,c)
	return c:GetAttack()<=e:GetLabel()
end