--D・ライトン
local s,id=GetID()
function s.initial_effect(c)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REFLECT_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(s.cona)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.refval)
	c:RegisterEffect(e1)
	--def
	local e5=Effect.CreateEffect(c)	
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_CHAIN_SOLVED)
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(s.surop2)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_DAMAGE)
	c:RegisterEffect(e6)
end
s.toss_coin=true
function s.cona(e)
	return e:GetHandler():IsAttackPos()
end
function s.refval(e,re,val,r,rp,rc)
	return rp~=e:GetHandlerPlayer() and r&REASON_EFFECT~=0
end
function s.surop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLP(tp)<=0 and not c:IsStatus(STATUS_DISABLED) and not c:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsDefensePos() 
		and Duel.GetFlagEffect(tp,id)==0 then
		Duel.Hint(HINT_CARD,0,id)
		Duel.RegisterFlagEffect(tp,id,0,0,0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)
		local coin=Duel.SelectOption(tp,60,61)
		local res=Duel.TossCoin(tp,1)
		if coin~=res then
			Duel.SetLP(tp,0)
			Duel.Recover(tp,100,REASON_EFFECT)
		end
	end
end
