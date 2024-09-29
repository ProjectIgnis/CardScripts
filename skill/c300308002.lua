--Destructive Fate
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	--Flip this card over at the start of the Duel
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	local c=e:GetHandler()
	--Declare 1 result of a coin(s) toss
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(0x5f)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
	e1:SetCondition(s.con)
	e1:SetOperation(s.op)
	Duel.RegisterEffect(e1,tp)
	--Flip this card over during the 3rd End Phase of your turn
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(0x5f)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp and Duel.GetFlagEffect(tp,id)>0 end)
	e2:SetOperation(s.flipop2)
	e2:SetLabel(0)
	e2:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN,3)
	Duel.RegisterEffect(e2,tp)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local ex,eg,et,cp,ct=Duel.GetOperationInfo(ev,CATEGORY_COIN)
	if Duel.GetFlagEffect(tp,id)==0 or not (Duel.GetTurnPlayer()==tp or re:GetHandlerPlayer()==tp) then return false end
	if ex and ((re:IsSpellEffect() and Duel.GetFlagEffect(tp,id+100)==0) or (re:IsMonsterEffect() and Duel.GetFlagEffect(tp,id+200)==0)) and ct>0 then
		e:SetLabelObject(re)
		return true
	else return false end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_CARD,0,id)
	local lp=Duel.GetLP(tp)
	Duel.SetLP(tp,lp/2)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TOSS_COIN_NEGATE)
	e1:SetRange(0x5f)
	e1:SetCondition(s.coincon)
	e1:SetOperation(s.coinop)
	e1:SetLabel(Duel.GetCurrentChain())
	e1:SetLabelObject(e:GetLabelObject())
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
end
function s.coincon(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject() and Duel.GetCurrentChain()==e:GetLabel() 
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetLabelObject()
	if rc:IsSpellEffect() then
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1)
	elseif rc:IsMonsterEffect() then
		Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE|PHASE_END,0,1)
	end  
	local coin=Duel.AnnounceCoin(tp)
	local res={}
	local ct=ev
	for i=1,ct do
		if coin==COIN_HEADS then
			table.insert(res,COIN_HEADS)
		else
			table.insert(res,COIN_TAILS)
		end
	end
	Duel.SetCoinResult(table.unpack(res))
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()+1
	e:SetLabel(ct)
	e:GetHandler():SetTurnCounter(ct)
	if ct==3 then
		Duel.ResetFlagEffect(tp,id)
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
	end
	if re then re:Reset() end 
end