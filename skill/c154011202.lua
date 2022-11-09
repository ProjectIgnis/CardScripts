--Cheater's Coin
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
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
	--coin result
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
	e1:SetCondition(s.con)
	e1:SetOperation(s.op)
	Duel.RegisterEffect(e1,tp)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local ex,eg,et,cp,ct=Duel.GetOperationInfo(ev,CATEGORY_COIN)
	if ex and ct>0 and Duel.GetTurnPlayer()==ep and Duel.GetLP(tp)>=(Duel.GetLP(1-tp)+1000) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=5 then
		e:SetLabelObject(re)
		return true
	else return false end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TOSS_COIN_NEGATE)
	e1:SetRange(0x5f)
	e1:SetCondition(s.coincon)
	e1:SetOperation(s.coinop)
	e1:SetLabelObject(e:GetLabelObject())
	Duel.RegisterEffect(e1,tp)
end
function s.coincon(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject()
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCoinResult()==1 then return false end
	local res={Duel.GetCoinResult()}
	local ct=ev
	for i=1,ct do
		res[i]=1
	end
	Duel.Hint(HINT_CARD,0,id)
	Duel.SetCoinResult(table.unpack(res))
end