--coded by Lyris
--Clean Barrier - Clear Force
local s,id=GetID()
function s.initial_effect(c)
	--When an opponent's monster declares an attack: The ATK of all face-up monsters your opponent currently controls becomes their original ATK, [Number 107: Galaxy-Eyes Tachyon Dragon] also negate any card effects that would change the ATK of a monster(s) your opponent controls [Distortion Crystal]. These changes last until the end of the Battle Phase.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		--Check for ATK changing effects
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_ADJUST)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetOperation(s.operation)
		Duel.RegisterEffect(e2,0)
	end)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()  
	local g=Duel.GetMatchingGroup(nil,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		if tc:IsFaceup() and tc:GetFlagEffect(id)==0 then
			local e1=Effect.CreateEffect(c) 
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
			e1:SetCode(EVENT_CHAIN_SOLVED)
			e1:SetRange(LOCATION_MZONE)
			e1:SetLabel(tc:GetAttack())
			e1:SetOperation(s.op)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)  
		end 
		tc=g:GetNext()
	end	 
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==c:GetAttack() then return end
	local val=c:GetAttack()-e:GetLabel()
	Duel.RaiseEvent(c,id,re,REASON_EFFECT,rp,tp,val)
	e:SetLabel(c:GetAttack())
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.filter(c)
	return c:IsFaceup() and c:GetAttack()~=c:GetBaseAttack()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--[[local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_DISABLE)
	e0:SetTargetRange(0,LOCATION_MZONE)
	Duel.RegisterEffect(e0,tp)]]
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(id)
	e0:SetCondition(s.atkcon)
	e0:SetOperation(s.atkop)
	e0:SetReset(RESET_PHASE+PHASE_BATTLE)
	Duel.RegisterEffect(e0,tp)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		if tc:GetAttack()~=tc:GetBaseAttack() then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(tc:GetBaseAttack())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
			tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
end
--[[function s.dfilter(c)
	return c:IsHasEffect(EFFECT_UPDATE_ATTACK) or c:IsHasEffect(EFFECT_SET_ATTACK) or c:IsHasEffect(EFFECT_SET_ATTACK_FINAL) or c:IsHasEffect(EFFECT_SET_BASE_ATTACK)
end]]
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp) and ev~=0
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	e1:SetValue(tc:GetAttack()-ev)
	tc:RegisterEffect(e1)
end
