--Orichalcos Sword of Sealing
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,nil,nil,s.cost)
	--negate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e3)
	aux.GlobalCheck(s,function()
		--register
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DRAW)
		ge1:SetOperation(s.op)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.cfilter(c)
	return c:GetFlagEffect(id)>0 and c:IsDiscardable()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=eg
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		tc=g:GetNext()
	end
end
