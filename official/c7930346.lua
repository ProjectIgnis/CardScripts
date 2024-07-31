--折々の紙神
--Origami Goddess
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Toss a coin and draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COIN+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	--Double ATK for each head
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(0,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	--Raise a custom event when coin tossing is detected
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_TOSS_COIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.coincon)
	e3:SetOperation(s.coinop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(s.chainsolvedop)
	e4:SetLabel(0,0)
	c:RegisterEffect(e4)
	e3:SetLabelObject(e4)
end
s.toss_coin=true
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp) end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local heads=0
	while Duel.TossCoin(tp,1)==COIN_HEADS do
		heads=heads+1
	end
	if heads>=2 then
		Duel.Draw(tp,heads//2,REASON_EFFECT)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local heads_ct=ev
	if heads_ct==0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		--Double this card's ATK for each heads
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetAttack()*(2^heads_ct))
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
function s.coincon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetCode()~=EVENT_TOSS_COIN_NEGATE
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	local heads_ct=aux.GetCoinHeadsFromEv(ev)
	if not Duel.IsChainSolving() then
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,re,r,rp,ep,heads_ct)
	else
		local total_ct=aux.GetCoinCountFromEv(ev)
		local chain_solved_eff=e:GetLabelObject()
		chain_solved_eff:SetLabel(chain_solved_eff:GetLabel()+heads_ct,total_ct)
	end
end
function s.chainsolvedop(e,tp,eg,ep,ev,re,r,rp)
	local heads_ct,total_ct=e:GetLabel()
	if total_ct==0 then return end
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,re,r,rp,ep,heads_ct)
	e:SetLabel(0,0)
end