--Shadow Clone Zone
--多分影分身
--  By Shad3
--cleaned and updated by MLD
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.filter)
	--Add ATK
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:GetLevel()==3
end
function s.check(p)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,p,0,LOCATION_MZONE,nil)
	if #g==0 then return 0 end
	local tc=g:GetFirst()
	local n=0
	local defs={}
	while tc do
		local d=tc:GetDefense()
		local v=defs[d]
		if v then
			v=v+1
			if v==2 then n=n+1 end
			n=n+1
			defs[d]=v
		else
			defs[d]=1
		end
		tc=g:GetNext()
	end
	return n
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local n=s.check(tp)
	if chk==0 then return n>1 end
	e:SetLabel(n)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local n=e:GetLabel()
	if n>1 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(n-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end
