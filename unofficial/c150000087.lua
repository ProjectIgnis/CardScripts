--ドラッグシュート
--Drag Chute
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		--destroy check
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROY)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		--null recovery
		local rec=Duel.Recover
		Duel.Recover = function(...)
			local param={...}
			if Duel.GetFlagEffect(0,id+1)>0 then
				param[2]=0
				return rec(table.unpack(param))
			end
			return rec(...)
		end
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for ec in aux.Next(eg) do
		if ec:IsType(TYPE_MONSTER) then
			Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(0,id)>0 or Duel.GetFlagEffect(0,id+1)==0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,Duel.GetFlagEffect(0,id)*300)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetFlagEffect(0,id)
	if d>0 then
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		Duel.Damage(p,d*300,REASON_EFFECT)
	end
	Duel.RegisterFlagEffect(0,id+1,RESET_PHASE+PHASE_END,0,1)
end
