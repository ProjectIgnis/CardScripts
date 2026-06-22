--スカブ・ブラスト
--Scab Blast
--scripted by Keddy
local s,id=GetID()
local COUNTER_SCAB=0x109a
function s.initial_effect(c)
	--Inflict 200 damage to your opponent for each Scab Counter on the field.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--If this card is in the Graveyard, you can add it to your hand instead of conducting your normal draw during your Draw Phase.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45950291,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.counter_list={COUNTER_SCAB}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCounter(0,1,1,COUNTER_SCAB)>0 end
	local dam=Duel.GetCounter(0,1,1,COUNTER_SCAB)*200
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	if dam>0 then 
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam) 
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,dam=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,dam,REASON_EFFECT)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		and Duel.GetDrawCount(tp)>0
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHanderl()
	if chk==0 then return c:IsAbleToHand() end
	local dt=Duel.GetDrawCount(tp)
	if dt~=0 then
		_replace_count=0
		_replace_max=dt
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE|PHASE_DRAW)
		e1:SetValue(0)
		Duel.RegisterEffect(e1,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	_replace_count=_replace_count+1
	if _replace_count<=_replace_max and c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
